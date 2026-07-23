mod manifest;
mod ui;

use clap::Parser;
use crossterm::{
    event::{self, Event, KeyCode, KeyEventKind},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
    tty::IsTty,
};
use manifest::{LinkEntry, Status};
use ratatui::{backend::CrosstermBackend, widgets::ListState, Terminal};
use std::collections::HashSet;
use std::io::{self, Write};
use std::path::PathBuf;
use std::process::ExitCode;

/// Interactive front-end for ./install. Prints `SELECTED_PLATFORM=<name>` and
/// `MANIFEST_FILE=<path>` to stdout on confirm; the TUI itself renders on
/// stderr so stdout stays clean for the caller to capture via command
/// substitution.
#[derive(Parser, Debug)]
struct Args {
    #[arg(long)]
    repo: PathBuf,

    #[arg(long)]
    default_platform: String,

    /// If set, the platform is already decided (an explicit -p was given to
    /// ./install) -- skip the platform-select screen entirely.
    #[arg(long)]
    platform: Option<String>,
}

/// One row of the select-links tree: either a component group header or one
/// of that group's individual symlinks (index into the entries vec).
pub enum Row {
    Group(usize),
    Entry(usize),
}

enum Screen {
    SelectPlatform,
    SelectLinks,
    Confirm,
}

struct Confirmed {
    platform: String,
    manifest_file: PathBuf,
}

const EXIT_CANCELLED: u8 = 2;
const EXIT_ERROR: u8 = 1;

fn main() -> ExitCode {
    let args = Args::parse();

    if !io::stdin().is_tty() || !io::stderr().is_tty() {
        eprintln!("[-] --wizard needs an interactive terminal (stdin/stderr must be a tty)");
        return ExitCode::from(EXIT_ERROR);
    }

    match run(args) {
        Ok(Some(c)) => {
            println!("SELECTED_PLATFORM={}", c.platform);
            println!("MANIFEST_FILE={}", c.manifest_file.display());
            ExitCode::SUCCESS
        }
        Ok(None) => ExitCode::from(EXIT_CANCELLED),
        Err(e) => {
            eprintln!("[-] wizard error: {e}");
            ExitCode::from(EXIT_ERROR)
        }
    }
}

fn platform_choices(repo: &std::path::Path) -> io::Result<Vec<String>> {
    let mut out = Vec::new();
    for entry in std::fs::read_dir(repo.join("install.d"))? {
        let entry = entry?;
        let name = entry.file_name().to_string_lossy().to_string();
        let Some(platform) = name.strip_suffix(".conf.yaml") else {
            continue;
        };
        if matches!(platform, "common" | "linux" | "post") {
            continue;
        }
        out.push(platform.to_string());
    }
    out.sort();
    Ok(out)
}

fn run(args: Args) -> Result<Option<Confirmed>, Box<dyn std::error::Error>> {
    enable_raw_mode()?;
    let mut stderr = io::stderr();
    execute!(stderr, EnterAlternateScreen)?;
    let backend = CrosstermBackend::new(stderr);
    let mut terminal = Terminal::new(backend)?;

    let result = event_loop(&mut terminal, &args);

    disable_raw_mode()?;
    execute!(terminal.backend_mut(), LeaveAlternateScreen)?;
    terminal.show_cursor()?;
    io::stderr().flush()?;

    result
}

/// Component names present in `entries`, in a fixed sensible order (falling
/// back to alphabetical for anything unrecognized).
fn groups_for(entries: &[LinkEntry]) -> Vec<String> {
    const ORDER: &[&str] = &[
        "shell",
        "git",
        "editors",
        "terminal",
        "tooling",
        "private (pconfigs)",
        "x11 / freedesktop",
        "platform extras",
    ];
    let present: HashSet<&str> = entries.iter().map(|e| e.group).collect();
    let mut out: Vec<String> = ORDER
        .iter()
        .filter(|g| present.contains(*g))
        .map(|g| g.to_string())
        .collect();
    let mut rest: Vec<String> = present
        .iter()
        .filter(|g| !ORDER.contains(g))
        .map(|g| g.to_string())
        .collect();
    rest.sort();
    out.extend(rest);
    out
}

/// A group header row followed by every entry in that group, in group order.
fn build_rows(entries: &[LinkEntry], groups: &[String]) -> Vec<Row> {
    let mut rows = Vec::new();
    for (gi, group) in groups.iter().enumerate() {
        rows.push(Row::Group(gi));
        for (ei, e) in entries.iter().enumerate() {
            if e.group == group {
                rows.push(Row::Entry(ei));
            }
        }
    }
    rows
}

fn event_loop<B: ratatui::backend::Backend>(
    terminal: &mut Terminal<B>,
    args: &Args,
) -> Result<Option<Confirmed>, Box<dyn std::error::Error>> {
    let home = PathBuf::from(std::env::var("HOME").unwrap_or_else(|_| "/".to_string()));

    let platforms = platform_choices(&args.repo)?;

    let mut platform_state = ListState::default();
    let default_idx = platforms
        .iter()
        .position(|p| p == &args.default_platform)
        .unwrap_or(0);
    platform_state.select(Some(default_idx));

    let mut chosen_platform: Option<String> = args.platform.clone();
    let mut raw_yaml = String::new();
    let mut entries: Vec<LinkEntry> = Vec::new();
    let mut groups: Vec<String> = Vec::new();
    let mut rows: Vec<Row> = Vec::new();
    let mut checked: Vec<bool> = Vec::new();
    let mut links_state = ListState::default();
    links_state.select(Some(0));
    let mut confirm_yes = true;

    // An explicit -p on ./install locks the platform in -- skip straight to
    // the link tree instead of showing a picker for a decision already made.
    let mut screen = if let Some(platform) = &chosen_platform {
        let composed = compose_for(&args.repo, &home, platform)?;
        raw_yaml = composed.0;
        entries = composed.1;
        groups = groups_for(&entries);
        rows = build_rows(&entries, &groups);
        checked = vec![true; entries.len()];
        Screen::SelectLinks
    } else {
        Screen::SelectPlatform
    };

    loop {
        terminal.draw(|f| match screen {
            Screen::SelectPlatform => ui::draw_platform_select(f, &platforms, &mut platform_state),
            Screen::SelectLinks => {
                let p = chosen_platform.as_deref().unwrap_or("?");
                ui::draw_select_links(f, &rows, &groups, &entries, &checked, p, &mut links_state)
            }
            Screen::Confirm => {
                let p = chosen_platform.as_deref().unwrap_or("?");
                let total = checked.iter().filter(|c| **c).count();
                let overwrite_count = entries
                    .iter()
                    .zip(&checked)
                    .filter(|(e, c)| **c && e.status == Status::Overwrite)
                    .count();
                ui::draw_confirm(f, p, total, overwrite_count, confirm_yes)
            }
        })?;

        let Event::Key(key) = event::read()? else {
            continue;
        };
        if key.kind != KeyEventKind::Press {
            continue;
        }

        match screen {
            Screen::SelectPlatform => match key.code {
                KeyCode::Esc => return Ok(None),
                KeyCode::Up | KeyCode::Char('k') => move_selection(&mut platform_state, platforms.len(), -1),
                KeyCode::Down | KeyCode::Char('j') => move_selection(&mut platform_state, platforms.len(), 1),
                KeyCode::Enter => {
                    let idx = platform_state.select_or(0);
                    let platform = platforms[idx].clone();
                    let composed = compose_for(&args.repo, &home, &platform)?;
                    raw_yaml = composed.0;
                    entries = composed.1;
                    groups = groups_for(&entries);
                    rows = build_rows(&entries, &groups);
                    checked = vec![true; entries.len()];
                    links_state.select(Some(0));
                    chosen_platform = Some(platform);
                    screen = Screen::SelectLinks;
                }
                _ => {}
            },
            Screen::SelectLinks => match key.code {
                KeyCode::Esc => return Ok(None),
                KeyCode::Up | KeyCode::Char('k') => move_selection(&mut links_state, rows.len(), -1),
                KeyCode::Down | KeyCode::Char('j') => move_selection(&mut links_state, rows.len(), 1),
                KeyCode::Char(' ') => {
                    let idx = links_state.select_or(0);
                    match rows.get(idx) {
                        Some(Row::Entry(ei)) => checked[*ei] = !checked[*ei],
                        Some(Row::Group(gi)) => {
                            let group = groups[*gi].clone();
                            let member_idxs: Vec<usize> = entries
                                .iter()
                                .enumerate()
                                .filter(|(_, e)| e.group == group)
                                .map(|(i, _)| i)
                                .collect();
                            let all_checked = member_idxs.iter().all(|i| checked[*i]);
                            for i in member_idxs {
                                checked[i] = !all_checked;
                            }
                        }
                        None => {}
                    }
                }
                KeyCode::Char('a') => {
                    let all_checked = checked.iter().all(|c| *c);
                    for c in checked.iter_mut() {
                        *c = !all_checked;
                    }
                }
                KeyCode::Enter => screen = Screen::Confirm,
                _ => {}
            },
            Screen::Confirm => match key.code {
                KeyCode::Esc => return Ok(None),
                KeyCode::Left | KeyCode::Right | KeyCode::Char('h') | KeyCode::Char('l') | KeyCode::Tab => {
                    confirm_yes = !confirm_yes
                }
                KeyCode::Enter => {
                    if !confirm_yes {
                        return Ok(None);
                    }
                    let Some(platform) = chosen_platform.clone() else {
                        return Ok(None);
                    };
                    let keep: HashSet<String> = entries
                        .iter()
                        .zip(&checked)
                        .filter(|(_, c)| **c)
                        .map(|(e, _)| e.dest.clone())
                        .collect();
                    let filtered_yaml = manifest::filter_manifest(&raw_yaml, &keep)?;
                    let manifest_file = std::env::temp_dir()
                        .join(format!("dfwizard-manifest-{}.yaml", std::process::id()));
                    std::fs::write(&manifest_file, filtered_yaml)?;
                    return Ok(Some(Confirmed { platform, manifest_file }));
                }
                _ => {}
            },
        }
    }
}

fn compose_for(
    repo: &std::path::Path,
    home: &std::path::Path,
    platform: &str,
) -> Result<(String, Vec<LinkEntry>), Box<dyn std::error::Error>> {
    let yaml = manifest::compose(repo, platform)?;
    let entries = manifest::parse_and_diff(&yaml, repo, home)?;
    Ok((yaml, entries))
}

fn move_selection(state: &mut ListState, len: usize, delta: i32) {
    if len == 0 {
        return;
    }
    let cur = state.selected().unwrap_or(0) as i32;
    let next = (cur + delta).rem_euclid(len as i32);
    state.select(Some(next as usize));
}

trait SelectOr {
    fn select_or(&self, default: usize) -> usize;
}
impl SelectOr for ListState {
    fn select_or(&self, default: usize) -> usize {
        self.selected().unwrap_or(default)
    }
}

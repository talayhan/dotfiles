use crate::manifest::{LinkEntry, Status};
use crate::Row;
use ratatui::{
    layout::{Constraint, Layout, Rect},
    style::{Color, Modifier, Style},
    text::{Line, Span},
    widgets::{Block, Borders, List, ListItem, ListState, Paragraph},
    Frame,
};

/// Compact left-aligned logo drawn at the top of every screen, plus a
/// step-specific subtitle underneath it. Returns the remaining area for the
/// step's own content.
fn draw_header(f: &mut Frame, area: Rect, subtitle: &str) -> Rect {
    let chunks = Layout::vertical([Constraint::Length(3), Constraint::Length(1), Constraint::Min(0)])
        .split(area);

    let logo = Line::from(vec![
        Span::styled("\u{258c} ", Style::default().fg(Color::Yellow)),
        Span::styled(
            "dotfiles",
            Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD),
        ),
        Span::styled(" install wizard", Style::default().fg(Color::DarkGray)),
    ]);
    let sub = Line::from(Span::styled(
        format!("  {subtitle}"),
        Style::default().fg(Color::DarkGray),
    ));
    f.render_widget(Paragraph::new(vec![logo, sub]), chunks[0]);

    chunks[2]
}

pub fn draw_platform_select(f: &mut Frame, platforms: &[String], state: &mut ListState) {
    let body = draw_header(
        f,
        f.area(),
        "select a platform  (\u{2191}/\u{2193} move, enter confirm, esc quit)",
    );
    let items: Vec<ListItem> = platforms.iter().map(|p| ListItem::new(p.clone())).collect();
    let list = List::new(items)
        .block(Block::default().borders(Borders::ALL))
        .highlight_style(Style::default().add_modifier(Modifier::REVERSED).fg(Color::Yellow))
        .highlight_symbol("> ");
    f.render_stateful_widget(list, body, state);
}

/// A single scrollable tree: a header row per component group (togglable --
/// flips every entry under it) followed by every individual symlink in that
/// group (each independently togglable).
pub fn draw_select_links(
    f: &mut Frame,
    rows: &[Row],
    groups: &[String],
    entries: &[LinkEntry],
    checked: &[bool],
    platform: &str,
    state: &mut ListState,
) {
    let total_checked = checked.iter().filter(|c| **c).count();
    let overwrite_count = entries
        .iter()
        .zip(checked)
        .filter(|(e, c)| **c && e.status == Status::Overwrite)
        .count();
    let subtitle = if overwrite_count > 0 {
        format!(
            "platform: {platform}  --  {total_checked}/{} links selected, {overwrite_count} will OVERWRITE existing files  (\u{2191}/\u{2193} move, space toggle, a all/none, enter continue, esc cancel)",
            entries.len()
        )
    } else {
        format!(
            "platform: {platform}  --  {total_checked}/{} links selected  (\u{2191}/\u{2193} move, space toggle, a all/none, enter continue, esc cancel)",
            entries.len()
        )
    };
    let body = draw_header(f, f.area(), &subtitle);

    let items: Vec<ListItem> = rows
        .iter()
        .map(|row| match row {
            Row::Group(gi) => {
                let group = &groups[*gi];
                let member_idxs: Vec<usize> = entries
                    .iter()
                    .enumerate()
                    .filter(|(_, e)| e.group == group)
                    .map(|(i, _)| i)
                    .collect();
                let checked_count = member_idxs.iter().filter(|i| checked[**i]).count();
                let mark = if checked_count == 0 {
                    "[ ]"
                } else if checked_count == member_idxs.len() {
                    "[x]"
                } else {
                    "[~]"
                };
                ListItem::new(Line::from(Span::styled(
                    format!("{mark} {group}  ({checked_count}/{})", member_idxs.len()),
                    Style::default().add_modifier(Modifier::BOLD),
                )))
            }
            Row::Entry(ei) => {
                let e = &entries[*ei];
                let (status_text, color) = status_label(e.status);
                let status_text = if e.glob {
                    format!("{status_text} (globbed)")
                } else {
                    status_text.to_string()
                };
                let mark = if checked[*ei] { "[x]" } else { "[ ]" };
                let mark_color = if checked[*ei] { Color::Green } else { Color::DarkGray };
                ListItem::new(Line::from(vec![
                    Span::raw("    "),
                    Span::styled(format!("{mark} "), Style::default().fg(mark_color)),
                    Span::styled(format!("{:<38}", e.dest), Style::default().fg(color)),
                    Span::styled(format!("{:<14}", status_text), Style::default().fg(color)),
                    Span::styled(e.src.clone(), Style::default().fg(Color::DarkGray)),
                ]))
            }
        })
        .collect();

    let list = List::new(items)
        .block(Block::default().borders(Borders::ALL))
        .highlight_style(Style::default().add_modifier(Modifier::REVERSED));
    f.render_stateful_widget(list, body, state);
}

pub fn draw_confirm(f: &mut Frame, platform: &str, total: usize, overwrite_count: usize, selected_yes: bool) {
    let body = draw_header(
        f,
        f.area(),
        "confirm  (\u{2190}/\u{2192} choose, enter select, esc cancel)",
    );

    let mut lines = vec![
        Line::from(Span::styled(
            format!("Install for '{platform}'?"),
            Style::default().add_modifier(Modifier::BOLD),
        )),
        Line::from(format!("  {total} links selected")),
    ];
    if overwrite_count > 0 {
        lines.push(Line::from(Span::styled(
            format!("  {overwrite_count} existing file(s) will be overwritten"),
            Style::default().fg(Color::Red),
        )));
    }
    lines.push(Line::from(""));

    let yes_style = if selected_yes {
        Style::default().add_modifier(Modifier::REVERSED).fg(Color::Green)
    } else {
        Style::default().fg(Color::Green)
    };
    let no_style = if !selected_yes {
        Style::default().add_modifier(Modifier::REVERSED).fg(Color::Red)
    } else {
        Style::default().fg(Color::Red)
    };
    lines.push(Line::from(vec![
        Span::styled("  [ Proceed ]  ", yes_style),
        Span::styled("  [ Cancel ]  ", no_style),
    ]));

    f.render_widget(Paragraph::new(lines).block(Block::default().borders(Borders::ALL)), body);
}

fn status_label(status: Status) -> (&'static str, Color) {
    match status {
        Status::New => ("new", Color::Green),
        Status::UpToDate => ("up to date", Color::DarkGray),
        Status::Relink => ("relink", Color::Yellow),
        Status::Overwrite => ("OVERWRITE", Color::Red),
    }
}

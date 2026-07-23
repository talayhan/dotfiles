use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Status {
    /// Destination doesn't exist yet; dotbot will create it.
    New,
    /// Already a symlink pointing at the expected source.
    UpToDate,
    /// A symlink, but pointing somewhere else; `force: true` will repoint it.
    Relink,
    /// A real file/dir sits at the destination; `force: true` will delete it.
    Overwrite,
}

#[derive(Debug, Clone)]
pub struct LinkEntry {
    pub dest: String,
    pub src: String,
    pub glob: bool,
    pub status: Status,
    pub group: &'static str,
}

/// Which component a destination belongs to, for the wizard's checklist.
/// Derived from the same grouping the comments in install.d/common.conf.yaml
/// and install.d/linux.conf.yaml already describe -- this doesn't restructure
/// those files, it just mirrors their existing section boundaries.
pub fn classify_group(dest: &str) -> &'static str {
    match dest {
        "~/.bash_aliases" | "~/.bash_functions" | "~/.exports" | "~/.os.sh"
        | "~/.local/bin/bashmarks" | "~/.zshrc" | "~/.scripts" => "shell",

        "~/.gitconfig" | "~/.gitignore" | "~/.gitconfig_delta" | "~/.gitconfig_delta_themes" => "git",

        "~/.vimrc" => "editors",

        "~/.tmux.conf" | "~/.config/alacritty/alacritty.yml" => "terminal",

        "~/.gdbinit" | "~/.clang-format" | "~/.vifm" | "~/.taskrc" | "~/.newsboat"
        | "~/.config/gpt-cli/gpt.yml" => "tooling",

        "~/vimwiki" | "~/.config/tmuxinator" => "private (pconfigs)",

        "~/.pam_environment" | "~/.Xinitrc" | "~/.Xresources" | "~/.urxvt/ext"
        | "~/.gtkrc-2.0" | "~/.config/gtk-3.0/settings.ini" | "~/.config/zathura/zathurarc"
        | "~/.fonts" | "~/.icons" | "~/.templates" => "x11 / freedesktop",

        d if d.starts_with("~/.config/nvim") => "editors",

        _ => "platform extras",
    }
}

#[derive(Debug)]
pub enum ComposeError {
    Io(std::io::Error),
    InstallFailed(String),
    Yaml(serde_yaml::Error),
}

impl std::fmt::Display for ComposeError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ComposeError::Io(e) => write!(f, "io error: {e}"),
            ComposeError::InstallFailed(s) => write!(f, "install -n failed: {s}"),
            ComposeError::Yaml(e) => write!(f, "could not parse composed manifest: {e}"),
        }
    }
}

impl std::error::Error for ComposeError {}

/// Run `install -n -p <platform>` to get the composed manifest text, reusing
/// the bash script's own composition rules instead of duplicating them here.
pub fn compose(repo: &Path, platform: &str) -> Result<String, ComposeError> {
    let output = Command::new(repo.join("install"))
        .arg("-n")
        .arg("-p")
        .arg(platform)
        .current_dir(repo)
        .output()
        .map_err(ComposeError::Io)?;

    if !output.status.success() {
        return Err(ComposeError::InstallFailed(
            String::from_utf8_lossy(&output.stderr).to_string(),
        ));
    }

    Ok(String::from_utf8_lossy(&output.stdout).to_string())
}

/// Parse the composed manifest's `link:` directives and classify each entry
/// against the real filesystem under `repo`/`$HOME`.
pub fn parse_and_diff(
    yaml: &str,
    repo: &Path,
    home: &Path,
) -> Result<Vec<LinkEntry>, ComposeError> {
    let doc: serde_yaml::Value = serde_yaml::from_str(yaml).map_err(ComposeError::Yaml)?;
    let list = doc.as_sequence().cloned().unwrap_or_default();

    let mut entries = Vec::new();

    for item in list {
        let Some(mapping) = item.as_mapping() else {
            continue;
        };
        let Some(link_value) = mapping.get(serde_yaml::Value::String("link".into())) else {
            continue;
        };
        let Some(link_map) = link_value.as_mapping() else {
            continue;
        };

        for (dest_v, src_v) in link_map {
            let Some(dest) = dest_v.as_str() else {
                continue;
            };

            let (src, glob, guard) = match src_v {
                serde_yaml::Value::String(s) => (s.clone(), false, None),
                serde_yaml::Value::Mapping(m) => {
                    let path = m
                        .get(serde_yaml::Value::String("path".into()))
                        .and_then(|v| v.as_str())
                        .unwrap_or_default()
                        .to_string();
                    let glob = m
                        .get(serde_yaml::Value::String("glob".into()))
                        .and_then(|v| v.as_bool())
                        .unwrap_or(false);
                    let guard = m
                        .get(serde_yaml::Value::String("if".into()))
                        .and_then(|v| v.as_str())
                        .map(|s| s.to_string());
                    (path, glob, guard)
                }
                _ => continue,
            };

            if src.is_empty() {
                continue;
            }

            // Entries guarded by an `if:` (currently only the pconfigs
            // submodule) are legitimately absent when the guard fails --
            // evaluate it the same way dotbot does, and skip if it fails.
            if let Some(cond) = &guard {
                let passed = Command::new("bash")
                    .arg("-c")
                    .arg(cond)
                    .current_dir(repo)
                    .status()
                    .map(|s| s.success())
                    .unwrap_or(false);
                if !passed {
                    continue;
                }
            }

            let status = if glob {
                // Globs fan one destination out over many source files;
                // report the group without a per-file diff, matching how
                // tests/verify_install.sh already treats these.
                Status::New
            } else {
                classify(&expand_home(dest, home), &repo.join(&src))
            };

            entries.push(LinkEntry {
                group: classify_group(dest),
                dest: dest.to_string(),
                src,
                glob,
                status,
            });
        }
    }

    Ok(entries)
}

/// Rewrite the composed manifest's `link:` directives to keep only the given
/// destinations, leaving every other directive (clean/shell/defaults/etc.)
/// untouched. Used to turn a component checklist into a manifest dotbot can
/// run directly, without restructuring install.d/*.conf.yaml.
pub fn filter_manifest(
    yaml: &str,
    keep_dests: &std::collections::HashSet<String>,
) -> Result<String, ComposeError> {
    let doc: serde_yaml::Value = serde_yaml::from_str(yaml).map_err(ComposeError::Yaml)?;
    let mut list = doc.as_sequence().cloned().unwrap_or_default();

    let link_key = serde_yaml::Value::String("link".into());
    for item in list.iter_mut() {
        let Some(mapping) = item.as_mapping_mut() else {
            continue;
        };
        let Some(link_value) = mapping.get_mut(&link_key) else {
            continue;
        };
        let Some(link_map) = link_value.as_mapping() else {
            continue;
        };

        let filtered: serde_yaml::Mapping = link_map
            .iter()
            .filter(|(k, _)| k.as_str().is_some_and(|d| keep_dests.contains(d)))
            .map(|(k, v)| (k.clone(), v.clone()))
            .collect();
        *link_value = serde_yaml::Value::Mapping(filtered);
    }

    serde_yaml::to_string(&serde_yaml::Value::Sequence(list)).map_err(ComposeError::Yaml)
}

fn expand_home(dest: &str, home: &Path) -> PathBuf {
    match dest.strip_prefix("~/") {
        Some(rest) => home.join(rest),
        None if dest == "~" => home.to_path_buf(),
        None => PathBuf::from(dest),
    }
}

fn classify(dest: &Path, expected_src: &Path) -> Status {
    match fs::symlink_metadata(dest) {
        Err(_) => Status::New,
        Ok(meta) if meta.file_type().is_symlink() => match fs::read_link(dest) {
            Ok(target) => {
                let resolved_target = if target.is_absolute() {
                    target
                } else {
                    dest.parent().unwrap_or(Path::new("/")).join(target)
                };
                let a = fs::canonicalize(&resolved_target).unwrap_or(resolved_target);
                let b = fs::canonicalize(expected_src).unwrap_or_else(|_| expected_src.to_path_buf());
                if a == b {
                    Status::UpToDate
                } else {
                    Status::Relink
                }
            }
            Err(_) => Status::Relink,
        },
        Ok(_) => Status::Overwrite,
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::os::unix::fs::symlink;

    fn tmp_dir(name: &str) -> PathBuf {
        let dir = std::env::temp_dir().join(format!("dfwizard-test-{name}-{}", std::process::id()));
        let _ = fs::remove_dir_all(&dir);
        fs::create_dir_all(&dir).unwrap();
        dir
    }

    #[test]
    fn parses_simple_and_extended_links() {
        let repo = tmp_dir("repo-a");
        let home = tmp_dir("home-a");
        fs::write(repo.join("bashrc"), "").unwrap();
        fs::create_dir_all(repo.join("pconfigs/vimwiki")).unwrap();

        let yaml = format!(
            r#"
- link:
    ~/.bashrc: bashrc
    ~/vimwiki:
      path: pconfigs/vimwiki
      if: '[ -d pconfigs/vimwiki ]'
    ~/nope:
      path: pconfigs/nope
      if: '[ -d pconfigs/nope ]'
"#
        );

        let entries = parse_and_diff(&yaml, &repo, &home).unwrap();
        assert_eq!(entries.len(), 2, "the if:-guarded missing entry should be skipped");

        let bashrc = entries.iter().find(|e| e.dest == "~/.bashrc").unwrap();
        assert_eq!(bashrc.src, "bashrc");
        assert_eq!(bashrc.status, Status::New);

        let vimwiki = entries.iter().find(|e| e.dest == "~/vimwiki").unwrap();
        assert_eq!(vimwiki.src, "pconfigs/vimwiki");
        assert_eq!(vimwiki.status, Status::New);
    }

    #[test]
    fn classifies_up_to_date_relink_and_overwrite() {
        let repo = tmp_dir("repo-b");
        let home = tmp_dir("home-b");
        fs::write(repo.join("a"), "a").unwrap();
        fs::write(repo.join("b"), "b").unwrap();

        // up to date: symlink already points at the right source
        symlink(repo.join("a"), home.join("up_to_date")).unwrap();
        // relink: symlink points somewhere else
        symlink(repo.join("b"), home.join("stale")).unwrap();
        // overwrite: a real file sits at the destination
        fs::write(home.join("real_file"), "not a link").unwrap();

        let yaml = r#"
- link:
    ~/up_to_date: a
    ~/stale: a
    ~/real_file: a
    ~/missing: a
"#;

        let entries = parse_and_diff(yaml, &repo, &home).unwrap();
        let status_of = |d: &str| entries.iter().find(|e| e.dest == d).unwrap().status;

        assert_eq!(status_of("~/up_to_date"), Status::UpToDate);
        assert_eq!(status_of("~/stale"), Status::Relink);
        assert_eq!(status_of("~/real_file"), Status::Overwrite);
        assert_eq!(status_of("~/missing"), Status::New);
    }

    #[test]
    fn filter_manifest_keeps_only_selected_dests_and_other_directives() {
        let yaml = r#"
- clean: ['~']
- link:
    ~/.gitconfig: git/gitconfig
    ~/.zshrc: config/zshrc
    ~/.vifm: config/vifm
"#;
        let mut keep = std::collections::HashSet::new();
        keep.insert("~/.gitconfig".to_string());

        let filtered = filter_manifest(yaml, &keep).unwrap();
        let doc: serde_yaml::Value = serde_yaml::from_str(&filtered).unwrap();
        let list = doc.as_sequence().unwrap();

        assert!(list.iter().any(|i| i.as_mapping().unwrap().contains_key("clean")), "non-link directives must survive untouched");

        let link_map = list
            .iter()
            .find_map(|i| i.as_mapping().unwrap().get("link"))
            .unwrap()
            .as_mapping()
            .unwrap();
        assert_eq!(link_map.len(), 1);
        assert!(link_map.contains_key("~/.gitconfig"));
    }

    #[test]
    fn groups_match_the_existing_manifest_sections() {
        assert_eq!(classify_group("~/.zshrc"), "shell");
        assert_eq!(classify_group("~/.gitconfig"), "git");
        assert_eq!(classify_group("~/.config/nvim/init.lua"), "editors");
        assert_eq!(classify_group("~/.tmux.conf"), "terminal");
        assert_eq!(classify_group("~/vimwiki"), "private (pconfigs)");
        assert_eq!(classify_group("~/.Xresources"), "x11 / freedesktop");
        assert_eq!(classify_group("~/.i3/config"), "platform extras");
    }
}

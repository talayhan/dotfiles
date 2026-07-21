#!/usr/bin/env bash
# Platform detection shared by the installer, the tool scripts and the shell rc files.
#
# Sourcing this sets:
#   DOTFILES_OS      manjaro | ubuntu | centos7 | macos | unknown
#   DOTFILES_FAMILY  linux | darwin
#   DOTFILES_ARCH    output of uname -m
#
# It is sourced by interactive shells, so it must stay quiet and must not `set -e`.

detect_os() {
    case "$(uname -s)" in
        Darwin)
            DOTFILES_FAMILY="darwin"
            DOTFILES_OS="macos"
            ;;
        Linux)
            DOTFILES_FAMILY="linux"
            if [ -r /etc/os-release ]; then
                # shellcheck disable=SC1091
                local id version
                id=$(. /etc/os-release && echo "${ID}")
                version=$(. /etc/os-release && echo "${VERSION_ID}")
                case "${id}" in
                    manjaro|manjaro-arm|arch)  DOTFILES_OS="manjaro" ;;
                    ubuntu|debian|pop|linuxmint) DOTFILES_OS="ubuntu" ;;
                    centos|rhel|rocky|almalinux)
                        case "${version}" in
                            7*) DOTFILES_OS="centos7" ;;
                            *)  DOTFILES_OS="centos7" ;;
                        esac
                        ;;
                    *) DOTFILES_OS="unknown" ;;
                esac
            else
                DOTFILES_OS="unknown"
            fi
            ;;
        *)
            DOTFILES_FAMILY="unknown"
            DOTFILES_OS="unknown"
            ;;
    esac

    DOTFILES_ARCH="$(uname -m)"
    export DOTFILES_OS DOTFILES_FAMILY DOTFILES_ARCH
}

detect_os

# Homebrew lives in a different place on every platform. Pick the first prefix
# that actually exists rather than hardcoding one.
brew_prefix() {
    local candidate
    for candidate in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew; do
        if [ -x "${candidate}/bin/brew" ]; then
            echo "${candidate}"
            return 0
        fi
    done
    return 1
}

# Platform-appropriate "copy stdin to the system clipboard" command.
clipboard_copy_cmd() {
    if [ "${DOTFILES_FAMILY}" = "darwin" ]; then
        echo "pbcopy"
    elif [ -n "${WAYLAND_DISPLAY}" ] && command -v wl-copy >/dev/null 2>&1; then
        echo "wl-copy"
    elif command -v xclip >/dev/null 2>&1; then
        echo "xclip -i -sel clipboard"
    elif command -v xsel >/dev/null 2>&1; then
        echo "xsel --clipboard --input"
    else
        echo "cat >/dev/null"
    fi
}

# Desktop notification, portable across macOS and freedesktop Linux.
notify() {
    local message="${1}"
    local title="${2:-dotfiles}"
    if [ "${DOTFILES_FAMILY}" = "darwin" ]; then
        osascript -e "display notification \"${message}\" with title \"${title}\"" 2>/dev/null
    elif command -v notify-send >/dev/null 2>&1; then
        notify-send "${title}" "${message}"
    else
        printf '%s: %s\n' "${title}" "${message}"
    fi
}

# Interactive region screenshot straight to the clipboard.
screenshot_to_clipboard() {
    local target
    target="/tmp/$(date +%F_%H-%M-%S).png"
    if [ "${DOTFILES_FAMILY}" = "darwin" ]; then
        screencapture -i -c
    elif command -v scrot >/dev/null 2>&1; then
        scrot -s "${target}" -e 'xclip -selection clipboard -target image/png -i $f'
    else
        printf 'No screenshot tool available on this platform.\n' >&2
        return 1
    fi
}

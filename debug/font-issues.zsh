#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

source functions/colors.zsh
source functions/icons.zsh
source functions/utilities.zsh
# Map our $OS to neofetch $os
os="$OS"


trim() {
    set -f
    # shellcheck disable=2048,2086
    set -- $*
    printf '%s\n' "${*//[[:space:]]/}"
    set +f
}

get_ppid() {
    # Get parent process ID of PID.
    case "$os" in
        "Windows")
            ppid="$(ps -p "${1:-$PPID}" | awk '{printf $2}')"
            ppid="${ppid/PPID}"
        ;;

        "Linux")
            ppid="$(grep -i -F "PPid:" "/proc/${1:-$PPID}/status")"
            ppid="$(trim "${ppid/PPid:}")"
        ;;

        *)
            ppid="$(ps -p "${1:-$PPID}" -o ppid=)"
        ;;
    esac

    printf "%s" "$ppid"
}

get_process_name() {
    # Get PID name.
    case "$os" in
        "Windows")
            name="$(ps -p "${1:-$PPID}" | awk '{printf $8}')"
            name="${name/COMMAND}"
            name="${name/*\/}"
        ;;

        "Linux")
            name="$(< "/proc/${1:-$PPID}/comm")"
        ;;

        *)
            name="$(ps -p "${1:-$PPID}" -o comm=)"
        ;;
    esac

    printf "%s" "$name"
}

# Taken from NeoFetch (slightly modified)
get_term() {
    local term

    # If function was run, stop here.
    # ((term_run == 1)) && return

    # Workaround for macOS systems that
    # don't support the block below.
    case "$TERM_PROGRAM" in
        "iTerm.app")    term="iTerm2" ;;
        "Terminal.app") term="Apple Terminal" ;;
        "Hyper")        term="HyperTerm" ;;
        *)              term="${TERM_PROGRAM/\.app}" ;;
    esac

    # Most likely TosWin2 on FreeMiNT - quick check
    [[ "$TERM" == "tw52" || "$TERM" == "tw100" ]] && \
        term="TosWin2"

    [[ "$SSH_CONNECTION" ]] && \
        term="$SSH_TTY"

    # Check $PPID for terminal emulator.
    while [[ -z "$term" ]]; do
        parent="$(get_ppid "$parent")"
        [[ -z "$parent" ]] && break
        name="$(get_process_name "$parent")"

        case "${name// }" in
            "${SHELL/*\/}"|*"sh"|"screen"|"su"*) ;;

            "login"*|*"Login"*|"init"|"(init)")
                term="$(tty)"
            ;;

            "ruby"|"1"|"tmux"*|"systemd"|"sshd"*|"python"*|"USER"*"PID"*|"kdeinit"*|"launchd"*)
                break
            ;;

            "gnome-terminal-") term="gnome-terminal" ;;
            "urxvtd")          term="urxvt" ;;
            *"nvim")           term="Neovim Terminal" ;;
            *"NeoVimServer"*)  term="VimR Terminal" ;;
            *)                 term="${name##*/}" ;;
        esac
    done

    # Log that the function was run.
    # term_run=1

    echo "${term}"
}

get_term_font() {
    local term="${1}"
    # ((term_run != 1)) && get_term

    case "$term" in
        "alacritty"*)
            shopt -s nullglob
            confs=({$XDG_CONFIG_HOME,$HOME}/{alacritty,}/{.,}alacritty.ym?)
            shopt -u nullglob

            [[ -f "${confs[0]}" ]] || return

            term_font="$(awk -F ':|#' '/normal:/ {getline; print}' "${confs[0]}")"
            term_font="${term_font/*family:}"
            term_font="${term_font/$'\n'*}"
            term_font="${term_font/\#*}"
        ;;

        "Apple_Terminal")
            term_font="$(osascript <<END
                         tell application "Terminal" to font name of window frontmost
END
)"
        ;;

        "iTerm2")
            # Unfortunately the profile name is not unique, but it seems to be the only thing
            # that identifies an active profile. There is the "id of current session of current win-
            # dow" though, but that does not match to a guid in the plist.
            # So, be warned, collisions may occur!
            # See: https://groups.google.com/forum/#!topic/iterm2-discuss/0tO3xZ4Zlwg
            local current_profile_name profiles_count profile_name diff_font

            current_profile_name="$(osascript <<END
                                    tell application "iTerm2" to profile name \
                                    of current session of current window
END
)"

            # Warning: Dynamic profiles are not taken into account here!
            # https://www.iterm2.com/documentation-dynamic-profiles.html
            font_file="${HOME}/Library/Preferences/com.googlecode.iterm2.plist"

            # Count Guids in "New Bookmarks"; they should be unique
            profiles_count="$(/usr/libexec/PlistBuddy -c "Print ':New Bookmarks:'" "$font_file" | \
                              grep -w -c "Guid")"

            for ((i=0; i<profiles_count; i++)); do
                profile_name="$(/usr/libexec/PlistBuddy -c "Print ':New Bookmarks:${i}:Name:'" "$font_file")"

                if [[ "$profile_name" == "$current_profile_name" ]]; then
                    # "Normal Font"
                    term_font="$(/usr/libexec/PlistBuddy -c "Print ':New Bookmarks:${i}:Normal Font:'" \
                                 "$font_file")"

                    # Font for non-ascii characters
                    # Only check for a different non-ascii font, if the user checked
                    # the "use a different font for non-ascii text" switch.
                    diff_font="$(/usr/libexec/PlistBuddy -c "Print ':New Bookmarks:${i}:Use Non-ASCII Font:'" \
                                 "$font_file")"

                    if [[ "$diff_font" == "true" ]]; then
                        non_ascii="$(/usr/libexec/PlistBuddy -c "Print ':New Bookmarks:${i}:Non Ascii Font:'" \
                                     "$font_file")"

                        [[ "$term_font" != "$non_ascii" ]] && \
                            term_font="$term_font (normal) / $non_ascii (non-ascii)"
                    fi
                fi
            done
        ;;

        "deepin-terminal"*)
            term_font="$(awk -F '=' '/font=/ {a=$2} /font_size/ {b=$2} END {print a " " b}' \
                         "${XDG_CONFIG_HOME}/deepin/deepin-terminal/config.conf")"
        ;;

        "GNUstep_Terminal")
             term_font="$(awk -F '>|<' '/>TerminalFont</ {getline; f=$3}
                          />TerminalFontSize</ {getline; s=$3} END {print f " " s}' \
                          "${HOME}/GNUstep/Defaults/Terminal.plist")"
        ;;

        "Hyper"*)
            term_font="$(awk -F':|,' '/fontFamily/ {print $2; exit}' "${HOME}/.hyper.js")"
            term_font="$(trim_quotes "$term_font")"
        ;;

        "kitty"*)
            shopt -s nullglob
            confs=({$KITTY_CONFIG_DIRECTORY,$XDG_CONFIG_HOME,~/Library/Preferences}/kitty/kitty.con?)
            shopt -u nullglob

            [[ -f "${confs[0]}" ]] || return

            term_font="$(awk '/^([[:space:]]*|[^#_])font_family[[:space:]]+/ {
                                  $1 = "";
                                  gsub(/^[[:space:]]/, "");
                                  font = $0
                              }
                              /^([[:space:]]*|[^#_])font_size[[:space:]]+/ {
                                  size = $2
                              }
                              END { print font " " size}' "${confs[0]}")"
        ;;

        "konsole"*)
            # Get Process ID of current konsole window / tab
            child="$(get_ppid "$$")"

            IFS=$'\n' read -d "" -ra konsole_instances < <(qdbus | grep -F 'org.kde.konsole')

            for i in "${konsole_instances[@]}"; do
                IFS=$'\n' read -d "" -ra konsole_sessions < <(qdbus "$i" | grep -F '/Sessions/')

                for session in "${konsole_sessions[@]}"; do
                    if ((child == "$(qdbus "$i" "$session" processId)")); then
                        profile="$(qdbus "$i" "$session" environment |\
                                   awk -F '=' '/KONSOLE_PROFILE_NAME/ {print $2}')"
                        break
                    fi
                done
                [[ "$profile" ]] && break
            done

            # We could have two profile files for the same profile name, take first match
            profile_filename="$(grep -l "Name=${profile}" "$HOME"/.local/share/konsole/*.profile)"
            profile_filename="${profile_filename/$'\n'*}"

            [[ "$profile_filename" ]] && \
                term_font="$(awk -F '=|,' '/Font=/ {print $2 " " $3}' "$profile_filename")"
        ;;

        "lxterminal"*)
            term_font="$(awk -F '=' '/fontname=/ {print $2; exit}' \
                         "${XDG_CONFIG_HOME}/lxterminal/lxterminal.conf")"
        ;;

        "mate-terminal")
            # To get the actual config we have to create a temporarily file with the
            # --save-config option.
            mateterm_config="/tmp/mateterm.cfg"

            # Ensure /tmp exists and we do not overwrite anything.
            if [[ -d /tmp && ! -f "$mateterm_config" ]]; then
                mate-terminal --save-config="$mateterm_config"

                role="$(xprop -id "${WINDOWID}" WM_WINDOW_ROLE)"
                role="${role##* }"
                role="${role//\"}"

                profile="$(awk -F '=' -v r="$role" \
                                  '$0~r {
                                            getline;
                                            if(/Maximized/) getline;
                                            if(/Fullscreen/) getline;
                                            id=$2"]"
                                         } $0~id {if(id) {getline; print $2; exit}}' \
                           "$mateterm_config")"

                rm -f "$mateterm_config"

                mate_get() {
                   gsettings get org.mate.terminal.profile:/org/mate/terminal/profiles/"$1"/ "$2"
                }

                if [[ "$(mate_get "$profile" "use-system-font")" == "true" ]]; then
                    term_font="$(gsettings get org.mate.interface monospace-font-name)"
                else
                    term_font="$(mate_get "$profile" "font")"
                fi
                term_font="$(trim_quotes "$term_font")"
            fi
        ;;

        "mintty")
            term_font="$(awk -F '=' '!/^($|#)/ && /Font/ {printf $2; exit}' "${HOME}/.minttyrc")"
        ;;

        "pantheon"*)
            term_font="$(gsettings get org.pantheon.terminal.settings font)"

            [[ -z "${term_font//\'}" ]] && \
                term_font="$(gsettings get org.gnome.desktop.interface monospace-font-name)"

            term_font="$(trim_quotes "$term_font")"
        ;;

        "qterminal")
            term_font="$(awk -F '=' '/fontFamily=/ {a=$2} /fontSize=/ {b=$2} END {print a " " b}' \
                         "${XDG_CONFIG_HOME}/qterminal.org/qterminal.ini")"
        ;;

        "sakura"*)
            term_font="$(awk -F '=' '/^font=/ {print $2; exit}' \
                         "${XDG_CONFIG_HOME}/sakura/sakura.conf")"
        ;;

        "st")
            term_font="$(ps -o command= -p "$parent" | grep -F -- "-f")"

            if [[ "$term_font" ]]; then
                term_font="${term_font/*-f/}"
                term_font="${term_font/ -*/}"

            else
                # On Linux we can get the exact path to the running binary through the procfs
                # (in case `st` is launched from outside of $PATH) on other systems we just
                # have to guess and assume `st` is invoked from somewhere in the users $PATH
                [[ -L /proc/$parent/exe ]] && binary="/proc/$parent/exe" || binary="$(type -p st)"

                # Grep the output of strings on the `st` binary for anything that looks vaguely
                # like a font definition. NOTE: There is a slight limitation in this approach.
                # Technically "Font Name" is a valid font. As it doesn't specify any font options
                # though it is hard to match it correctly amongst the rest of the noise.
                [[ -n "$binary" ]] && \
                    term_font="$(strings "$binary" | grep -F -m 1 \
                                                          -e "pixelsize=" \
                                                          -e "size=" \
                                                          -e "antialias=" \
                                                          -e "autohint=")"
            fi

            term_font="${term_font/xft:}"
            term_font="${term_font/:*}"
        ;;

        "terminology")
            term_font="$(strings "${XDG_CONFIG_HOME}/terminology/config/standard/base.cfg" |\
                         awk '/^font\.name$/{print a}{a=$0}')"
            term_font="${term_font/.pcf}"
            term_font="${term_font/:*}"
        ;;

        "termite")
            [[ -f "${XDG_CONFIG_HOME}/termite/config" ]] && \
                termite_config="${XDG_CONFIG_HOME}/termite/config"

            term_font="$(awk -F '= ' '/\[options\]/ {
                                          opt=1
                                      }
                                      /^\s*font/ {
                                          if(opt==1) a=$2;
                                          opt=0
                                      } END {print a}' "/etc/xdg/termite/config" \
                         "$termite_config")"
        ;;

        "urxvt" | "urxvtd" | "rxvt-unicode" | "xterm")
            xrdb="$(xrdb -query)"
            term_font="$(grep -im 1 -e "^${term/d}"'\**\.*font' -e '^\*font' <<< "$xrdb")"
            term_font="${term_font/*"*font:"}"
            term_font="${term_font/*".font:"}"
            term_font="${term_font/*"*.font:"}"
            term_font="$(trim "$term_font")"

            [[ -z "$term_font" && "$term" == "xterm" ]] && \
                term_font="$(grep '^XTerm.vt100.faceName' <<< "$xrdb")"

            term_font="$(trim "${term_font/*"faceName:"}")"

            # xft: isn't required at the beginning so we prepend it if it's missing
            [[ "${term_font:0:1}" != "-" && \
               "${term_font:0:4}" != "xft:" ]] && \
                term_font="xft:$term_font"

            # Xresources has two different font formats, this checks which
            # one is in use and formats it accordingly.
            case "$term_font" in
                *"xft:"*)
                    term_font="${term_font/xft:}"
                    term_font="${term_font/:*}"
                ;;

                "-"*)
                    IFS=- read -r _ _ term_font _ <<< "$term_font"
                ;;
            esac
        ;;

        "xfce4-terminal")
            term_font="$(awk -F '=' '/^FontName/{a=$2}/^FontUseSystem=TRUE/{a=$0} END {print a}' \
                         "${XDG_CONFIG_HOME}/xfce4/terminal/terminalrc")"

            [[ "$term_font" == "FontUseSystem=TRUE" ]] && \
                term_font="$(gsettings get org.gnome.desktop.interface monospace-font-name)"

            term_font="$(trim_quotes "$term_font")"

            # Default fallback font hardcoded in terminal-preferences.c
            [[ -z "$term_font" ]] && term_font="Monospace 12"
        ;;
    esac

    echo "${term_font}"
}

local currentTerminal=$(get_term)
local currentFont=$(get_term_font "${currentTerminal}")
print -P "===== Font debugging ====="
print -P "You are using %F{blue}${currentTerminal}%f with Font %F{blue}${currentFont}%f\n"

if [[ $(echo "${currentFont}" | grep -c -E "Powerline|Awesome|Nerd") -eq 0 ]]; then
    print -P "%F{yellow}WARNING%f It does not seem like you use an Powerline-enabled or Awesome Terminal Font!"
    print -P "Please make sure that your font settings are correct!"
else
    print -P "Your font settings seem to be all right. If you still have issues,"
    print -P "it is more likely to be a font issue than a Powerlevel9k related one."
fi

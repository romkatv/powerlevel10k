#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Taken from NeoFetch (slightly modified)
get_term() {
    local term
    # If function was run, stop here.
    #((term_run == 1)) && return

    # Workaround for macOS systems that
    # don't support the block below.
    case "$TERM_PROGRAM" in
        "iTerm.app") term="iTerm2" ;;
        "Terminal.app") term="Apple Terminal" ;;
        "Hyper") term="HyperTerm" ;;
        *) term="${TERM_PROGRAM/\.app}" ;;
    esac

    # Check $PPID for terminal emulator.
    while [[ -z "$term" ]]; do
        parent="$(get_ppid "$parent")"
        name="$(get_process_name "$parent")"

        case "${name// }" in
            "${SHELL/*\/}" | *"sh" | "tmux"* | "screen" | "su"*) ;;
            "login"* | *"Login"* | "init" | "(init)") term="$(tty)" ;;
            "ruby" | "1" | "systemd" | "sshd"* | "python"* | "USER"*"PID"*) break ;;
            "gnome-terminal-") term="gnome-terminal" ;;
            *) term="${name##*/}" ;;
        esac
    done

    # Log that the function was run.
    #term_run=1

    echo "${term}"
}

get_term_font() {
    local term="${1}"
    #((term_run != 1)) && get_term

    case "$term" in
        "alacritty"*)
            term_font="$(awk -F ':|#' '/normal:/ {getline; print}' "${XDG_CONFIG_HOME}/alacritty/alacritty.yml")"
            term_font="${term_font/*family:}"
            term_font="${term_font/$'\n'*}"
            term_font="${term_font/\#*}"
        ;;

        "Apple_Terminal")
            term_font="$(osascript -e 'tell application "Terminal" to font name of window frontmost')"
        ;;
        "iTerm2")
            # Unfortunately the profile name is not unique, but it seems to be the only thing
            # that identifies an active profile. There is the "id of current session of current window"
            # thou, but that does not match to a guid in the plist.
            # So, be warned! Collisions may occur!
            # See: https://groups.google.com/forum/#!topic/iterm2-discuss/0tO3xZ4Zlwg
            # and: https://gitlab.com/gnachman/iterm2/issues/5586
            local currentProfileName=$(osascript -e 'tell application "iTerm2" to profile name of current session of current window')

            # Warning: Dynamic profiles are not taken into account here!
            # https://www.iterm2.com/documentation-dynamic-profiles.html

            local nonAsciiFont
            
            # Count Guids in "New Bookmarks"; they should be unique
            local profilesCount=$(/usr/libexec/PlistBuddy -c "Print :New\ Bookmarks:" ~/Library/Preferences/com.googlecode.iterm2.plist 2>/dev/null | grep -c "Guid")
            for idx in $(seq 0 "${profilesCount}"); do
                local profileName=$(/usr/libexec/PlistBuddy -c "Print :New\ Bookmarks:${idx}:Name:" ~/Library/Preferences/com.googlecode.iterm2.plist 2>/dev/null)
                if [[ "${profileName}" == "${currentProfileName}" ]]; then
                    # "Normal Font"
                    term_font=$(/usr/libexec/PlistBuddy -c "Print :New\ Bookmarks:${idx}:Normal\ Font:" ~/Library/Preferences/com.googlecode.iterm2.plist)
            
                    # Font for non-ascii characters
                    # Only check for a different non-ascii font, if the user checked
                    # the "use a different font for non-ascii text" switch.
                    local useDifferentFont=$(/usr/libexec/PlistBuddy -c "Print :New\ Bookmarks:${idx}:Use\ Non-ASCII\ Font:" ~/Library/Preferences/com.googlecode.iterm2.plist)
                    if [[ "$useDifferentFont" == "true" ]]; then
                        local nonAsciiFont=$(/usr/libexec/PlistBuddy -c "Print :New\ Bookmarks:${idx}:Non\ Ascii\ Font:" ~/Library/Preferences/com.googlecode.iterm2.plist)
                        if [[ "$term_font" != "$nonAsciiFont" ]]; then
                            term_font="$term_font (normal) / $nonAsciiFont (non-ascii)"
                        fi
                    fi
                fi
            done
        ;;

        "deepin-terminal"*)
            term_font="$(awk -F '=' '/font=/ {a=$2} /font_size/ {b=$2} END{print a " " b}' "${XDG_CONFIG_HOME}/deepin/deepin-terminal/config.conf")"
        ;;

        "Hyper"*)
            term_font="$(awk -F "," '/fontFamily/ {a=$1} END{print a}' "${HOME}/.hyper.js" | awk -F "'" '{a=$2} END{print a}')"
        ;;

        "konsole"*)
            # Get Process ID of current konsole window / tab
            child="$(get_ppid "$$")"

            konsole_instances=($(qdbus | grep 'org.kde.konsole'))

            for i in "${konsole_instances[@]}"; do
                konsole_sessions=($(qdbus "${i}" | grep '/Sessions/'))
                for session in "${konsole_sessions[@]}"; do
                    if ((child == "$(qdbus "${i}" "${session}" processId)")); then
                        profile="$(qdbus "${i}" "${session}" environment | awk -F '=' '/KONSOLE_PROFILE_NAME/ {print $2}')"
                        break
                    fi
                done
                [[ "$profile" ]] && break
            done

            # We could have two profile files for the same profile name, take first match
            profile_filename="$(grep -l "Name=${profile}" "${HOME}"/.local/share/konsole/*.profile)"
            profile_filename="${profile_filename/$'\n'*}"
            [[ "$profile_filename" ]] && term_font="$(awk -F '=|,' '/Font=/ {print $2 " " $3}' "$profile_filename")"
        ;;

        "mintty")
            term_font="$(awk -F '=' '!/^($|#)/ && /Font/ {printf $2; exit}' "${HOME}/.minttyrc")"
        ;;

        "pantheon"*)
            term_font="$(gsettings get org.pantheon.terminal.settings font)"
            [[ -z "${term_font//\'}" ]] && term_font="$(gsettings get org.gnome.desktop.interface monospace-font-name)"
            term_font="$(trim_quotes "$term_font")"
        ;;

        "sakura"*)
            term_font="$(awk -F '=' '/^font=/ {a=$2} END{print a}' "${XDG_CONFIG_HOME}/sakura/sakura.conf")"
        ;;

        "terminology")
            term_font="$(strings "${XDG_CONFIG_HOME}/terminology/config/standard/base.cfg" | awk '/^font\.name$/{print a}{a=$0}')"
            term_font="${term_font/.pcf}"
            term_font="${term_font/:*}"
        ;;

        "termite")
            [[ -f "${XDG_CONFIG_HOME}/termite/config" ]] && termite_config="${XDG_CONFIG_HOME}/termite/config"
            term_font="$(awk -F '= ' '/\[options\]/ {opt=1} /^font/ {if(opt==1) a=$2; opt=0} END{print a}' "/etc/xdg/termite/config" "$termite_config")"
        ;;

        "urxvt" | "urxvtd" | "rxvt-unicode" | "xterm")
            term_font="$(grep -i -F "${term/d}*font" < <(xrdb -query))"
            term_font="${term_font/*font:}"
            term_font="$(trim "$term_font")"

            # Xresources has two different font formats, this checks which
            # one is in use and formats it accordingly.
            case "$term_font" in
                *"xft:"*)
                    term_font="${term_font/xft:}"
                    term_font="${term_font/:*}"
                ;;

                "-"*) term_font="$(awk -F '\\-' '{printf $3}' <<< "$term_font")" ;;
            esac
        ;;

        "xfce4-terminal")
            term_font="$(awk -F '=' '/^FontName/ {a=$2} END{print a}' "${XDG_CONFIG_HOME}/xfce4/terminal/terminalrc")"
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

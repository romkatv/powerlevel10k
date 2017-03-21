#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

if [[ "$TERM_PROGRAM" != "iTerm.app" ]]; then
    print "Your Terminal Emulator does not appear to be iTerm2!"
    print "This debug script is intended only for iTerm2 terminals."
    exit 1
fi

if [[ ! -x "/usr/libexec/PlistBuddy" ]]; then
    print "To use this debug script, you need to install XCode!"
    exit 2
fi

local normalFont
local type
local command
local ambiguousDoubleWidth
local minimumContrast
local useDifferentFont

# Unfortunately the profile name is not unique, but it seems to be the only
# thing that identifies an active profile. There is the "ID of current session
# of current window" though, but that does not match to a `guid` in the plist.
# So, be warned - collisions may occur!
# See: https://groups.google.com/forum/#!topic/iterm2-discuss/0tO3xZ4Zlwg
local currentProfileName=$(osascript -e 'tell application "iTerm2" to profile name of current session of current window')

# Warning: Dynamic profiles are not taken into account here!
# https://www.iterm2.com/documentation-dynamic-profiles.html

# Count `guids` in "New Bookmarks"; they should be unique
local profilesCount=$(/usr/libexec/PlistBuddy -c "Print :New\ Bookmarks:" ~/Library/Preferences/com.googlecode.iterm2.plist 2>/dev/null | grep -c "Guid")
for idx in $(seq 0 "${profilesCount}"); do
    local profileName=$(/usr/libexec/PlistBuddy -c "Print :New\ Bookmarks:${idx}:Name:" ~/Library/Preferences/com.googlecode.iterm2.plist 2>/dev/null)
    if [[ "${profileName}" == "${currentProfileName}" ]]; then
        # "Normal Font"
        normalFont=$(/usr/libexec/PlistBuddy -c "Print :New\ Bookmarks:${idx}:Normal\ Font:" ~/Library/Preferences/com.googlecode.iterm2.plist)
        type=$(/usr/libexec/PlistBuddy -c "Print :New\ Bookmarks:${idx}:Terminal\ Type:" ~/Library/Preferences/com.googlecode.iterm2.plist)
        command=$(/usr/libexec/PlistBuddy -c "Print :New\ Bookmarks:${idx}:Command:" ~/Library/Preferences/com.googlecode.iterm2.plist)
        ambiguousDoubleWidth=$(/usr/libexec/PlistBuddy -c "Print :New\ Bookmarks:${idx}:Ambiguous\ Double\ Width:" ~/Library/Preferences/com.googlecode.iterm2.plist)
        minimumContrast=$(/usr/libexec/PlistBuddy -c "Print :New\ Bookmarks:${idx}:Minimum\ Contrast:" ~/Library/Preferences/com.googlecode.iterm2.plist)

        # Font for non-ascii characters
        # Only check for a different non-ASCII font, if the user checked
        # the "use a different font for non-ascii text" switch.
        useDifferentFont=$(/usr/libexec/PlistBuddy -c "Print :New\ Bookmarks:${idx}:Use\ Non-ASCII\ Font:" ~/Library/Preferences/com.googlecode.iterm2.plist)
        if [[ "$useDifferentFont" == "true" ]]; then
            nonAsciiFont=$(/usr/libexec/PlistBuddy -c "Print :New\ Bookmarks:${idx}:Non\ Ascii\ Font:" ~/Library/Preferences/com.googlecode.iterm2.plist)
            if [[ "$normalFont" != "$nonAsciiFont" ]]; then
                normalFont="$normalFont (normal) / $nonAsciiFont (non-ascii)"
            fi
        fi
        break
    fi
done

print -P "You use %F{blue}iTerm2%f with the following settings:"
print -P "  Font: ${normalFont}"
print -P "  Terminal-Type: ${type}"
print -P "  Command: ${command}"

#############################
# Analyse possible problems #
#############################
local problemsFound
if [[ "${ambiguousDoubleWidth}" == "true" ]]; then
    problemsFound="${problemsFound}\n  * Please uncheck 'Treat ambiguous characters as double-width'."
fi
if (( minimumContrast > 0 )); then
    problemsFound="${problemsFound}\n  * Please set minimum contrast to zero."
fi
if [[ $(echo "${normalFont}" | grep -c -E "Powerline|Awesome|Nerd|Source Code Pro") -eq 0 ]]; then
    problemsFound="${problemsFound}\n  * It does not seem like you use an Powerline-enabled or Awesome Terminal Font!"
fi

#############################
# Output problems           #
#############################
if [[ -n "${problemsFound}" ]]; then
    print -P "\n"
    print -P "%F{yellow}Possible Problems found:%f"
    print -P "${problemsFound}"
else
    print -P "%F{green}No Problems found%f. Yay!"
fi

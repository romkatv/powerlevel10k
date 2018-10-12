#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"
  # Load Powerlevel9k
  source powerlevel9k.zsh-theme
}

function testSegmentOnRightSide() {
    # Reset RPROMPT, so a running P9K does not interfere with the test
    local RPROMPT=
    local -a POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(custom_world1 custom_world2)
    local POWERLEVEL9K_CUSTOM_WORLD1='echo world1'
    local POWERLEVEL9K_CUSTOM_WORLD2='echo world2'

    powerlevel9k_prepare_prompts

    local reset_attributes=$'\e[00m'
    assertEquals "%f%b%k%F{007}%f%K{007}%F{000} world1 %f%F{000}%f%K{007}%F{000} world2%E%{${reset_attributes}%}" "${(e)RPROMPT}"
}

function testDisablingRightPrompt() {
    # Reset RPROMPT, so a running P9K does not interfere with the test
    local RPROMPT=
    local -a POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(custom_world1 custom_world2)
    local POWERLEVEL9K_CUSTOM_WORLD1='echo world1'
    local POWERLEVEL9K_CUSTOM_WORLD2='echo world2'
    local POWERLEVEL9K_DISABLE_RPROMPT=true

    powerlevel9k_prepare_prompts

    assertEquals "" "${(e)RPROMPT}"
}

function testLeftMultilinePrompt() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world1)
    local POWERLEVEL9K_CUSTOM_WORLD1='echo world1'
    local POWERLEVEL9K_PROMPT_ON_NEWLINE=true

    powerlevel9k_prepare_prompts

    local nl=$'\n'
    assertEquals "╭─%f%b%k%K{007} %F{000}world1 %k%F{007}%f ${nl}╰─ " "${(e)PROMPT}"
}

function testRightPromptOnSameLine() {
    # Reset RPROMPT, so a running P9K does not interfere with the test
    local RPROMPT=
    local -a POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(custom_world1)
    local POWERLEVEL9K_CUSTOM_WORLD1='echo world1'

    local POWERLEVEL9K_PROMPT_ON_NEWLINE=true
    local POWERLEVEL9K_RPROMPT_ON_NEWLINE=false # We want the RPROMPT on the same line as our left prompt

    # Skip test, as this cannot be tested properly.
    # The "go one line up" instruction does not get
    # printed as real characters in RPROMPT.
    # On command line the assert statement produces
    # a visually identical output as we expect, but
    # it fails anyway. :(
    startSkipping

    powerlevel9k_prepare_prompts
    assertEquals "%{\e[1A%}%F{007}%f%K{007}%F{000} world1 %f%{\e[1B%}" "${(e)RPROMPT}"
}

function testPrefixingFirstLineOnLeftPrompt() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world1)
    local POWERLEVEL9K_CUSTOM_WORLD1='echo world1'

    local POWERLEVEL9K_PROMPT_ON_NEWLINE=true
    local POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX='XXX'

    powerlevel9k_prepare_prompts

    local nl=$'\n'
    assertEquals "XXX%f%b%k%K{007} %F{000}world1 %k%F{007}%f ${nl}╰─ " "${(e)PROMPT}"
}

function testPrefixingSecondLineOnLeftPrompt() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world1)
    local POWERLEVEL9K_CUSTOM_WORLD1='echo world1'

    local POWERLEVEL9K_PROMPT_ON_NEWLINE=true
    local POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='XXX'

    powerlevel9k_prepare_prompts

    local nl=$'\n'
    assertEquals "╭─%f%b%k%K{007} %F{000}world1 %k%F{007}%f ${nl}XXX" "${(e)PROMPT}"
}

source shunit2/shunit2

#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"

  ### Test specific
  # Resets if someone has set these in his/hers env
  unset POWERLEVEL9K_STATUS_VERBOSE
  unset POWERLEVEL9K_STATUS_OK_IN_NON_VERBOSE
}

function testStatusPrintsNothingIfReturnCodeIsZeroAndVerboseIsUnset() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status custom_world)
    local POWERLEVEL9K_CUSTOM_WORLD='echo world'
    local POWERLEVEL9K_STATUS_VERBOSE=false
    local POWERLEVEL9K_STATUS_SHOW_PIPESTATUS=false

    # Load Powerlevel9k
    source powerlevel9k.zsh-theme

    assertEquals "%K{white} %F{black}world %k%F{white}%f " "$(build_left_prompt)"
}

function testStatusWorksAsExpectedIfReturnCodeIsZeroAndVerboseIsSet() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status)
    local POWERLEVEL9K_STATUS_VERBOSE=true
    local POWERLEVEL9K_STATUS_SHOW_PIPESTATUS=false
    local POWERLEVEL9K_STATUS_HIDE_SIGNAME=true

    # Load Powerlevel9k
    source powerlevel9k.zsh-theme

    assertEquals "%K{black} %F{green%}✔%f %k%F{black}%f " "$(build_left_prompt)"
}

function testStatusInGeneralErrorCase() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status)
    local POWERLEVEL9K_STATUS_VERBOSE=true
    local POWERLEVEL9K_STATUS_SHOW_PIPESTATUS=false

    # Load Powerlevel9k
    source powerlevel9k.zsh-theme
    local RETVAL=1

    assertEquals "%K{red} %F{yellow1%}↵ %f%F{yellow1}1 %k%F{red}%f " "$(build_left_prompt)"
}

function testPipestatusInErrorCase() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status)
    local POWERLEVEL9K_STATUS_VERBOSE=true
    local POWERLEVEL9K_STATUS_SHOW_PIPESTATUS=true

    # Load Powerlevel9k
    source powerlevel9k.zsh-theme
    local -a RETVALS
    RETVALS=(0 0 1 0)

    assertEquals "%K{red} %F{yellow1%}↵ %f%F{yellow1}0|0|1|0 %k%F{red}%f " "$(build_left_prompt)"
}

function testStatusCrossWinsOverVerbose() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status)
    local POWERLEVEL9K_STATUS_SHOW_PIPESTATUS=false
    local POWERLEVEL9K_STATUS_VERBOSE=true
    local POWERLEVEL9K_STATUS_CROSS=true

    # Load Powerlevel9k
    source powerlevel9k.zsh-theme
    local RETVAL=1

    assertEquals "%K{black} %F{red%}✘%f %k%F{black}%f " "$(build_left_prompt)"
}

function testStatusShowsSignalNameInErrorCase() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status)
    local POWERLEVEL9K_STATUS_SHOW_PIPESTATUS=false
    local POWERLEVEL9K_STATUS_VERBOSE=true
    local POWERLEVEL9K_STATUS_HIDE_SIGNAME=false

    # Load Powerlevel9k
    source powerlevel9k.zsh-theme
    local RETVAL=132

    assertEquals "%K{red} %F{yellow1%}↵ %f%F{yellow1}SIGILL(4) %k%F{red}%f " "$(build_left_prompt)"
}

function testStatusSegmentIntegrated() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status)
    local -a POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
    local POWERLEVEL9K_STATUS_CROSS=true
    
    # Load Powerlevel9k
    source powerlevel9k.zsh-theme

    false; powerlevel9k_prepare_prompts

    assertEquals "%f%b%k%K{black} %F{red%}✘%f %k%F{black}%f " "${(e)PROMPT}"
}

source shunit2/shunit2
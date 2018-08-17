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

    assertEquals "%K{007} %F{000}world %k%F{007}%f " "$(build_left_prompt)"
}

function testStatusWorksAsExpectedIfReturnCodeIsZeroAndVerboseIsSet() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status)
    local POWERLEVEL9K_STATUS_VERBOSE=true
    local POWERLEVEL9K_STATUS_SHOW_PIPESTATUS=false
    local POWERLEVEL9K_STATUS_HIDE_SIGNAME=true

    # Load Powerlevel9k
    source powerlevel9k.zsh-theme

    assertEquals "%K{000} %F{002}✔%f %k%F{000}%f " "$(build_left_prompt)"
}

function testStatusInGeneralErrorCase() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status)
    local POWERLEVEL9K_STATUS_VERBOSE=true
    local POWERLEVEL9K_STATUS_SHOW_PIPESTATUS=false

    # Load Powerlevel9k
    source powerlevel9k.zsh-theme
    local RETVAL=1

    assertEquals "%K{001} %F{226}↵ %f%F{226}1 %k%F{001}%f " "$(build_left_prompt)"
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

    assertEquals "%K{001} %F{226}↵ %f%F{226}0|0|1|0 %k%F{001}%f " "$(build_left_prompt)"
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

    assertEquals "%K{000} %F{001}✘%f %k%F{000}%f " "$(build_left_prompt)"
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

    assertEquals "%K{001} %F{226}↵ %f%F{226}SIGILL(4) %k%F{001}%f " "$(build_left_prompt)"
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

    assertEquals "%f%b%k%K{000} %F{001}✘%f %k%F{000}%f " "${(e)PROMPT}"
}

source shunit2/shunit2
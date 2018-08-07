#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"
  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  ### Test specific
  # Resets if someone has set these in his/hers env
  unset POWERLEVEL9K_STATUS_VERBOSE
  unset POWERLEVEL9K_STATUS_OK_IN_NON_VERBOSE
}

function testStatusPrintsNothingIfReturnCodeIsZeroAndVerboseIsUnset() {
    local POWERLEVEL9K_CUSTOM_WORLD='echo world'
    local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status custom_world)
    local POWERLEVEL9K_STATUS_VERBOSE=false
    local POWERLEVEL9K_STATUS_SHOW_PIPESTATUS=false

    assertEquals "%K{015} %F{000}world %k%F{015}%f " "$(build_left_prompt)"
}

function testStatusWorksAsExpectedIfReturnCodeIsZeroAndVerboseIsSet() {
    local POWERLEVEL9K_STATUS_VERBOSE=true
    local POWERLEVEL9K_STATUS_SHOW_PIPESTATUS=false
    local POWERLEVEL9K_STATUS_HIDE_SIGNAME=true
    local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status)

    assertEquals "%K{000} %F{002%}✔%f %k%F{000}%f " "$(build_left_prompt)"
}

function testStatusInGeneralErrorCase() {
    local RETVAL=1
    local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status)
    local POWERLEVEL9K_STATUS_VERBOSE=true
    local POWERLEVEL9K_STATUS_SHOW_PIPESTATUS=false

    assertEquals "%K{009} %F{226%}↵ %f%F{226}1 %k%F{009}%f " "$(build_left_prompt)"
}

function testPipestatusInErrorCase() {
    local -a RETVALS
    RETVALS=(0 0 1 0)
    local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status)
    local POWERLEVEL9K_STATUS_VERBOSE=true
    local POWERLEVEL9K_STATUS_SHOW_PIPESTATUS=true

    assertEquals "%K{009} %F{226%}↵ %f%F{226}0|0|1|0 %k%F{009}%f " "$(build_left_prompt)"
}

function testStatusCrossWinsOverVerbose() {
    local RETVAL=1
    local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status)
    local POWERLEVEL9K_STATUS_SHOW_PIPESTATUS=false
    local POWERLEVEL9K_STATUS_VERBOSE=true
    local POWERLEVEL9K_STATUS_CROSS=true

    assertEquals "%K{000} %F{009%}✘%f %k%F{000}%f " "$(build_left_prompt)"
}

function testStatusShowsSignalNameInErrorCase() {
    local RETVAL=132
    local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status)
    local POWERLEVEL9K_STATUS_SHOW_PIPESTATUS=false
    local POWERLEVEL9K_STATUS_VERBOSE=true
    local POWERLEVEL9K_STATUS_HIDE_SIGNAME=false

    assertEquals "%K{009} %F{226%}↵ %f%F{226}SIGILL(4) %k%F{009}%f " "$(build_left_prompt)"
}

function testStatusSegmentIntegrated() {
    local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status)
    local POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

    false; powerlevel9k_prepare_prompts

    assertEquals "%f%b%k%K{000} %F{009%}✘%f %k%F{000}%f " "${(e)PROMPT}"
}

source shunit2/source/2.1/src/shunit2
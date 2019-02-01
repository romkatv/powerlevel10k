#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"

  P9K_HOME=$(pwd)
  ### Test specific
}

function testNewlineDoesNotCreateExtraSegmentSeparator() {
    local POWERLEVEL9K_CUSTOM_WORLD1="echo world1"
    local POWERLEVEL9K_CUSTOM_WORLD2="echo world2"
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world1 newline newline newline custom_world2)

    # Load Powerlevel9k
    source ${P9K_HOME}/powerlevel9k.zsh-theme
    local OS="OSX" # Fake OSX

    local newline=$'\n'

    assertEquals "%K{007} %F{000}world1 %k%F{007}%f${newline}%k%f${newline}%k%f${newline}%K{007} %F{000}world2 %k%F{007}%f " "$(build_left_prompt)"
}

function testNewlineMakesPreviousSegmentEndWell() {
    local POWERLEVEL9K_CUSTOM_WORLD1="echo world1"
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world1 newline)

    # Load Powerlevel9k
    source ${P9K_HOME}/powerlevel9k.zsh-theme
    local OS="OSX" # Fake OSX

    local newline=$'\n'

    assertEquals "%K{007} %F{000}world1 %k%F{007}%f${newline}%k%F{none}%f " "$(build_left_prompt)"
}

source shunit2/shunit2
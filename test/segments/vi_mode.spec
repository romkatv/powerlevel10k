#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"
}

function testViInsertModeWorks() {
  local KEYMAP='viins'

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  assertEquals "%K{black} %F{blue}INSERT " "$(prompt_vi_mode left 1 false)"
}

function testViInsertModeWorksWhenLabeledAsMain() {
  local KEYMAP='main'

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  assertEquals "%K{black} %F{blue}INSERT " "$(prompt_vi_mode left 1 false)"
}

function testViCommandModeWorks() {
  local KEYMAP='vicmd'

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  assertEquals "%K{black} %F{white}NORMAL " "$(prompt_vi_mode left 1 false)"
}

function testViInsertModeStringIsCustomizable() {
  local KEYMAP='viins'

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  assertEquals "%K{black} %F{blue}INSERT " "$(prompt_vi_mode left 1 false)"
}

source shunit2/source/2.1/src/shunit2
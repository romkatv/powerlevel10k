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

function mockGo() {
  echo 'go version go1.5.3 darwin/amd64'
}

function testGo() {
  alias go=mockGo
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(go_version)

  assertEquals "%K{green} %F{255}go1.5.3 %k%F{green}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unalias go
}

function testGoSegmentPrintsNothingIfGoIsNotAvailable() {
  alias go=noGo
  POWERLEVEL9K_CUSTOM_WORLD='echo world'
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world go_version)

  assertEquals "%K{white} %F{black}world %k%F{white}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_CUSTOM_WORLD
  unalias go
}

source shunit2/source/2.1/src/shunit2

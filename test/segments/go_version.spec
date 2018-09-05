#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"
}

function mockGo() {
  case "$1" in
  'version')
    echo 'go version go1.5.3 darwin/amd64'
    ;;
  'env')
    echo "$HOME/go"
    ;;
  esac
}

function mockGoEmptyGopath() {
  case "$1" in
  'version')
    echo 'go version go1.5.3 darwin/amd64'
    ;;
  'env')
    echo ""
    ;;
  esac
}

function testGo() {
  alias go=mockGo
  local POWERLEVEL9K_GO_ICON=""
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(go_version)

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  local PWD="$HOME/go/src/github.com/bhilburn/powerlevel9k"

  assertEquals "%K{002} %F{255} %f%F{255}go1.5.3 %k%F{002}%f " "$(build_left_prompt)"

  unalias go
}

function testGoSegmentPrintsNothingIfEmptyGopath() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world go_version)
  local POWERLEVEL9K_CUSTOM_WORLD='echo world'
  alias go=mockGoEmptyGopath

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  assertEquals "%K{007} %F{000}world %k%F{007}%f " "$(build_left_prompt)"
}

function testGoSegmentPrintsNothingIfNotInGopath() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world go_version)
  local POWERLEVEL9K_CUSTOM_WORLD='echo world'
  alias go=mockGo

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  assertEquals "%K{007} %F{000}world %k%F{007}%f " "$(build_left_prompt)"
}

function testGoSegmentPrintsNothingIfGoIsNotAvailable() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world go_version)
  local POWERLEVEL9K_CUSTOM_WORLD='echo world'
  alias go=noGo

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  assertEquals "%K{007} %F{000}world %k%F{007}%f " "$(build_left_prompt)"

  unalias go
}

source shunit2/shunit2

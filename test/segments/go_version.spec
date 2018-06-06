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
  POWERLEVEL9K_GO_ICON=""
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(go_version)

  PWD="$HOME/go/src/github.com/bhilburn/powerlevel9k"

  assertEquals "%K{green} %F{grey93%} %f%F{grey93}go1.5.3 %k%F{green}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_GO_ICON
  unset PWD
  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unalias go
}

function testGoSegmentPrintsNothingIfEmptyGopath() {
  alias go=mockGoEmptyGopath
  POWERLEVEL9K_CUSTOM_WORLD='echo world'
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world go_version)

  assertEquals "%K{white} %F{black}world %k%F{white}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_CUSTOM_WORLD

}

function testGoSegmentPrintsNothingIfNotInGopath() {
  alias go=mockGo
  POWERLEVEL9K_CUSTOM_WORLD='echo world'
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world go_version)

  assertEquals "%K{white} %F{black}world %k%F{white}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_CUSTOM_WORLD
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

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

function mockRust() {
  echo 'rustc  0.4.1a-alpha'
}

function testRust() {
  alias rustc=mockRust
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(rust_version)

  assertEquals "%K{208} %F{black}Rust 0.4.1a-alpha %k%F{208}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unalias rustc
}

function testRustPrintsNothingIfRustIsNotAvailable() {
  alias rustc=noRust
  POWERLEVEL9K_CUSTOM_WORLD='echo world'
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world rust_version)

  assertEquals "%K{white} %F{black}world %k%F{white}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_CUSTOM_WORLD
  unalias rustc
}

source shunit2/source/2.1/src/shunit2

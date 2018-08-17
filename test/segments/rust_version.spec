#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

TEST_BASE_FOLDER=/tmp/powerlevel9k-test
RUST_TEST_FOLDER="${TEST_BASE_FOLDER}/rust-test"

function setUp() {
  OLDPATH="${PATH}"
  mkdir -p "${RUST_TEST_FOLDER}"
  PATH="${RUST_TEST_FOLDER}:${PATH}"

  export TERM="xterm-256color"
}

function tearDown() {
  PATH="${OLDPATH}"
  rm -fr "${TEST_BASE_FOLDER}"
}

function mockRust() {
  echo "#!/bin/sh\n\necho 'rustc 0.4.1a-alpha'" > "${RUST_TEST_FOLDER}/rustc"
  chmod +x "${RUST_TEST_FOLDER}/rustc"
}

function testRust() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(rust_version)
  mockRust

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  assertEquals "%K{208} %F{000}Rust %f%F{000}0.4.1a-alpha %k%F{208}%f " "$(build_left_prompt)"
}

function testRustPrintsNothingIfRustIsNotAvailable() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world rust_version)
  local POWERLEVEL9K_CUSTOM_WORLD='echo world'

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  assertEquals "%K{007} %F{000}world %k%F{007}%f " "$(build_left_prompt)"
}

source shunit2/shunit2

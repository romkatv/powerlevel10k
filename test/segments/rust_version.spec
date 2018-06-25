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
  # Load Powerlevel9k
  source powerlevel9k.zsh-theme
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
  mockRust
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(rust_version)

  assertEquals "%K{208} %F{black%}Rust %f%F{black}0.4.1a-alpha %k%F{darkorange}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
}

function testRustPrintsNothingIfRustIsNotAvailable() {
  POWERLEVEL9K_CUSTOM_WORLD='echo world'
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world rust_version)

  assertEquals "%K{white} %F{black}world %k%F{white}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_CUSTOM_WORLD
}

source shunit2/source/2.1/src/shunit2

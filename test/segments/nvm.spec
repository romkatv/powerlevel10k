#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"
  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  P9K_HOME=$(pwd)
  ### Test specific
  # Create default folder and git init it.
  FOLDER=/tmp/powerlevel9k-test/nvm-test
  mkdir -p "${FOLDER}/bin"
  OLD_PATH=$PATH
  PATH=${FOLDER}/bin:$PATH
  cd $FOLDER
}

function tearDown() {
  # Restore old path
  PATH="${OLD_PATH}"
  # Go back to powerlevel9k folder
  cd "${P9K_HOME}"
  # Remove eventually created test-specific folder
  rm -fr "${FOLDER}"
  # At least remove test folder completely
  rm -fr /tmp/powerlevel9k-test
}

function testNvmSegmentPrintsNothingIfNvmIsNotAvailable() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(nvm custom_world)
  local POWERLEVEL9K_CUSTOM_WORLD='echo world'

  assertEquals "%K{white} %F{black}world %k%F{white}%f " "$(build_left_prompt)"
}

function testNvmSegmentWorksWithoutHavingADefaultAlias() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(nvm)

  function nvm_version() {
    [[ ${1} == 'current' ]] && echo 'v4.6.0' || echo 'v1.4.0'
  }

  assertEquals "%K{magenta} %F{black%}⬢ %f%F{black}4.6.0 %k%F{magenta}%f " "$(build_left_prompt)"
}

function testNvmSegmentPrintsNothingWhenOnDefaultVersion() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(nvm custom_world)
  local POWERLEVEL9K_CUSTOM_WORLD='echo world'

  function nvm_version() {
    [[ ${1} == 'current' ]] && echo 'v4.6.0' || echo 'v4.6.0'
  }

  assertEquals "%K{white} %F{black}world %k%F{white}%f " "$(build_left_prompt)"
}

source shunit2/source/2.1/src/shunit2
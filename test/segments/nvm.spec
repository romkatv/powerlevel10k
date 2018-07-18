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
  mkdir -p "${FOLDER}"
  cd $FOLDER
}

function tearDown() {
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
  alias nvm=nonvm

  assertEquals "%K{white} %F{black}world %k%F{white}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_CUSTOM_WORLD
  unalias nvm
}

function testNvmSegmentWorksWithoutHavingADefaultAlias() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(nvm)
  nvm() { echo 'v4.6.0'; }

  assertEquals "%K{green} %F{011%}⬢ %f%F{011}4.6.0 %k%F{green}%f " "$(build_left_prompt)"

  unfunction nvm
}

function testNvmSegmentPrintsNothingWhenOnDefaultVersion() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(nvm custom_world)
  local POWERLEVEL9K_CUSTOM_WORLD='echo world'
  nvm() { echo 'v4.6.0'; }

  export NVM_DIR="${FOLDER}"
  mkdir alias
  echo 'v4.6.0' > alias/default

  assertEquals "%K{white} %F{black}world %k%F{white}%f " "$(build_left_prompt)"

  unfunction nvm
  unset POWERLEVEL9K_CUSTOM_WORLD
  unset NVM_DIR
}

source shunit2/source/2.1/src/shunit2
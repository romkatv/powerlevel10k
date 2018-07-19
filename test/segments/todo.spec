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
  FOLDER=/tmp/powerlevel9k-test
  mkdir -p "${FOLDER}"
  mkdir ${FOLDER}/bin
  OLD_PATH=$PATH
  PATH=${FOLDER}/bin:$PATH
  cd $FOLDER
}

function tearDown() {
  # Reset PATH
  PATH=$OLD_PATH
  # Go back to powerlevel9k folder
  cd "${P9K_HOME}"
  # Remove eventually created test-specific folder
  rm -fr "${FOLDER}"
  # At least remove test folder completely
  rm -fr /tmp/powerlevel9k-test
}

function testTodoSegmentPrintsNothingIfTodoShIsNotInstalled() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(todo custom_world)
    local POWERLEVEL9K_CUSTOM_WORLD='echo world'

    assertEquals "%K{white} %F{black}world %k%F{white}%f " "$(build_left_prompt)"
}

function testTodoSegmentWorksAsExpected() {
    # TODO: Skript in den PATH legen!
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(todo)
    echo '#!/bin/sh' > ${FOLDER}/bin/todo.sh
    echo 'echo "TODO: 34 of 100 tasks shown";' >> ${FOLDER}/bin/todo.sh
    chmod +x ${FOLDER}/bin/todo.sh

    assertEquals "%K{244} %F{black%}☑ %f%F{black}100 %k%F{grey50}%f " "$(build_left_prompt)"
}

source shunit2/source/2.1/src/shunit2
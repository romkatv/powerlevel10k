#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"

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

    # Load Powerlevel9k
    source ${P9K_HOME}/powerlevel9k.zsh-theme

    assertEquals "%K{007} %F{000}world %k%F{007}%f " "$(build_left_prompt)"
}

function testTodoSegmentWorksAsExpected() {
    # TODO: Skript in den PATH legen!
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(todo)
    echo '#!/bin/sh' > ${FOLDER}/bin/todo.sh
    echo 'echo "TODO: 34 of 100 tasks shown";' >> ${FOLDER}/bin/todo.sh
    chmod +x ${FOLDER}/bin/todo.sh

    # Load Powerlevel9k
    source ${P9K_HOME}/powerlevel9k.zsh-theme

    assertEquals "%K{244} %F{000}☑ %f%F{000}100 %k%F{244}%f " "$(build_left_prompt)"
}

source shunit2/shunit2
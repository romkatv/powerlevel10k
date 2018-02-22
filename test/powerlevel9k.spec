#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"
  # Load Powerlevel9k
  source powerlevel9k.zsh-theme
  source functions/*

  # Unset mode, so that user settings
  # do not interfere with tests
  unset POWERLEVEL9K_MODE
}

function testJoinedSegments() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir dir_joined)
  cd /tmp

  assertEquals "%K{blue} %F{black}/tmp %K{blue}%F{black}%F{black}/tmp %k%F{blue}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  cd -
}

function testTransitiveJoinedSegments() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir root_indicator_joined dir_joined)
  cd /tmp

  assertEquals "%K{blue} %F{black}/tmp %K{blue}%F{black}%F{black}/tmp %k%F{blue}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  cd -
}

function testJoiningWithConditionalSegment() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir background_jobs dir_joined)
  cd /tmp

  assertEquals "%K{blue} %F{black}/tmp %K{blue}%F{black} %F{black}/tmp %k%F{blue}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  cd -
}

function testDynamicColoringOfSegmentsWork() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='red'
  cd /tmp

  assertEquals "%K{red} %F{black}/tmp %k%F{red}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_DIR_DEFAULT_BACKGROUND
  cd -
}

function testDynamicColoringOfVisualIdentifiersWork() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  POWERLEVEL9K_DIR_DEFAULT_VISUAL_IDENTIFIER_COLOR='green'
  POWERLEVEL9K_FOLDER_ICON="icon-here"

  cd /tmp

  assertEquals "%K{blue} %F{green%}icon-here%f %F{black}/tmp %k%F{blue}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_DIR_DEFAULT_VISUAL_IDENTIFIER_COLOR
  unset POWERLEVEL9K_FOLDER_ICON
  cd -
}

function testColoringOfVisualIdentifiersDoesNotOverwriteColoringOfSegment() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  POWERLEVEL9K_DIR_DEFAULT_VISUAL_IDENTIFIER_COLOR='green'
  POWERLEVEL9K_DIR_DEFAULT_FOREGROUND='red'
  POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='yellow'
  POWERLEVEL9K_FOLDER_ICON="icon-here"

  # Re-Source the icons, as the POWERLEVEL9K_MODE is directly
  # evaluated there.
  source functions/icons.zsh

  cd /tmp

  assertEquals "%K{yellow} %F{green%}icon-here%f %F{red}/tmp %k%F{yellow}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_DIR_DEFAULT_VISUAL_IDENTIFIER_COLOR
  unset POWERLEVEL9K_DIR_DEFAULT_FOREGROUND
  unset POWERLEVEL9K_DIR_DEFAULT_BACKGROUND
  unset POWERLEVEL9K_FOLDER_ICON
  cd -
}

function testOverwritingIconsWork() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  POWERLEVEL9K_FOLDER_ICON='icon-here'
  #local testFolder=$(mktemp -d -p p9k)
  # Move testFolder under home folder
  #mv testFolder ~
  # Go into testFolder
  #cd ~/$testFolder

  cd /tmp
  assertEquals "%K{blue} %F{black%}icon-here%f %F{black}/tmp %k%F{blue}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_DIR_FOLDER_ICON
  cd -
  # rm -fr ~/$testFolder
}

source shunit2/source/2.1/src/shunit2

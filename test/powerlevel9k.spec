#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function oneTimeSetUp() {
  # Load Powerlevel9k
  source powerlevel9k.zsh-theme
  source functions/*
}

function testJoinedSegments() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir dir_joined)

  assertEquals "%K{blue} %F{black}%~ %K{blue}%F{black}%F{black}%~ %k%F{blue}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
}

function testTransitiveJoinedSegments() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir root_indicator_joined dir_joined)

  assertEquals "%K{blue} %F{black}%~ %K{blue}%F{black}%F{black}%~ %k%F{blue}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
}

function testJoiningWithConditionalSegment() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir background_jobs dir_joined)

  assertEquals "%K{blue} %F{black}%~ %K{blue}%F{black} %F{black}%~ %k%F{blue}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
}

function testDynamicColoringOfSegmentsWork() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND='red'

  assertEquals "%K{red} %F{black}%~ %k%F{red}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND
}

source shunit2/source/2.1/src/shunit2

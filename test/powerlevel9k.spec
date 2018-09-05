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
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir dir_joined)
  cd /tmp

  assertEquals "%K{004} %F{000}/tmp %K{004}%F{000}%F{000}/tmp %k%F{004}%f " "$(build_left_prompt)"

  cd -
}

function testTransitiveJoinedSegments() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir root_indicator_joined dir_joined)
  cd /tmp

  assertEquals "%K{004} %F{000}/tmp %K{004}%F{000}%F{000}/tmp %k%F{004}%f " "$(build_left_prompt)"

  cd -
}

function testJoiningWithConditionalSegment() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir background_jobs dir_joined)
  cd /tmp

  assertEquals "%K{004} %F{000}/tmp %K{004}%F{000} %F{000}/tmp %k%F{004}%f " "$(build_left_prompt)"

  cd -
}

function testDynamicColoringOfSegmentsWork() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='red'
  cd /tmp

  assertEquals "%K{001} %F{000}/tmp %k%F{001}%f " "$(build_left_prompt)"

  cd -
}

function testDynamicColoringOfVisualIdentifiersWork() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_DIR_DEFAULT_VISUAL_IDENTIFIER_COLOR='green'
  local POWERLEVEL9K_FOLDER_ICON="icon-here"

  cd /tmp

  assertEquals "%K{004} %F{002}icon-here %f%F{000}/tmp %k%F{004}%f " "$(build_left_prompt)"

  cd -
}

function testColoringOfVisualIdentifiersDoesNotOverwriteColoringOfSegment() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_DIR_DEFAULT_VISUAL_IDENTIFIER_COLOR='green'
  local POWERLEVEL9K_DIR_DEFAULT_FOREGROUND='red'
  local POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='yellow'
  local POWERLEVEL9K_FOLDER_ICON="icon-here"

  # Re-Source the icons, as the POWERLEVEL9K_MODE is directly
  # evaluated there.
  source functions/icons.zsh

  cd /tmp

  assertEquals "%K{003} %F{002}icon-here %f%F{001}/tmp %k%F{003}%f " "$(build_left_prompt)"

  cd -
}

function testOverwritingIconsWork() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_FOLDER_ICON='icon-here'
  #local testFolder=$(mktemp -d -p p9k)
  # Move testFolder under home folder
  #mv testFolder ~
  # Go into testFolder
  #cd ~/$testFolder

  cd /tmp
  assertEquals "%K{004} %F{000}icon-here %f%F{000}/tmp %k%F{004}%f " "$(build_left_prompt)"

  cd -
  # rm -fr ~/$testFolder
}

function testNewlineOnRpromptCanBeDisabled() {
  local POWERLEVEL9K_PROMPT_ON_NEWLINE=true
  local POWERLEVEL9K_RPROMPT_ON_NEWLINE=false
  local POWERLEVEL9K_CUSTOM_WORLD='echo world'
  local POWERLEVEL9K_CUSTOM_RWORLD='echo rworld'
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world)
  local -a POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS
  POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(custom_rworld)

  powerlevel9k_prepare_prompts
  assertEquals '$(print_icon MULTILINE_FIRST_PROMPT_PREFIX)[39m[0m[49m[47m [30mworld [49m[37m[39m  $(print_icon MULTILINE_LAST_PROMPT_PREFIX)[1A[39m[0m[49m[37m[39m[47m[30m rworld[K[00m[1B' "$(print -P ${PROMPT}${RPROMPT})"
}

source shunit2/shunit2

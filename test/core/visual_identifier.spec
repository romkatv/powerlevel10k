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
}

function testOverwritingIconsWork() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world1)
  local POWERLEVEL9K_CUSTOM_WORLD1='echo world1'
  local POWERLEVEL9K_CUSTOM_WORLD1_ICON='icon-here'

  assertEquals "%K{007} %F{000}icon-here %f%F{000}world1 %k%F{007}%f " "$(build_left_prompt)"
}

function testVisualIdentifierAppearsBeforeSegmentContentOnLeftSegments() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world1)
  local POWERLEVEL9K_CUSTOM_WORLD1='echo world1'
  local POWERLEVEL9K_CUSTOM_WORLD1_ICON='icon-here'

  assertEquals "%K{007} %F{000}icon-here %f%F{000}world1 %k%F{007}%f " "$(build_left_prompt)"
}

function testVisualIdentifierAppearsAfterSegmentContentOnRightSegments() {
  local -a POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS
  POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(custom_world1)
  local POWERLEVEL9K_CUSTOM_WORLD1='echo world1'
  local POWERLEVEL9K_CUSTOM_WORLD1_ICON='icon-here'

  assertEquals "%F{007}%f%K{007}%F{000} world1%F{000} icon-here%f%E" "$(build_right_prompt)"
}

function testVisualIdentifierPrintsNothingIfNotAvailable() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world1)
  local POWERLEVEL9K_CUSTOM_WORLD1='echo world1'

  assertEquals "%K{007} %F{000}world1 %k%F{007}%f " "$(build_left_prompt)"
}

function testVisualIdentifierIsPrintedInNumericalColorCode() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world1)
  local POWERLEVEL9K_CUSTOM_WORLD1='echo world1'
  local POWERLEVEL9K_CUSTOM_WORLD1_ICON="xxx"
  local POWERLEVEL9K_CUSTOM_WORLD1_VISUAL_IDENTIFIER_COLOR="purple3"

  assertEquals "%K{007} %F{056}xxx %f%F{000}world1 %k%F{007}%f " "$(build_left_prompt)"
}

source shunit2/shunit2
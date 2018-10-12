#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"
  # Load Powerlevel9k
  source powerlevel9k.zsh-theme
}

function testDynamicColoringOfSegmentsWork() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(date)
  local POWERLEVEL9K_DATE_ICON="date-icon"
  local POWERLEVEL9K_DATE_BACKGROUND='red'

  assertEquals "%K{001} %F{000}date-icon %f%F{000}%D{%d.%m.%y} %k%F{001}%f " "$(build_left_prompt)"
}

function testDynamicColoringOfVisualIdentifiersWork() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(date)
  local POWERLEVEL9K_DATE_ICON="date-icon"
  local POWERLEVEL9K_DATE_VISUAL_IDENTIFIER_COLOR='green'

  assertEquals "%K{007} %F{002}date-icon %f%F{000}%D{%d.%m.%y} %k%F{007}%f " "$(build_left_prompt)"
}

function testColoringOfVisualIdentifiersDoesNotOverwriteColoringOfSegment() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(date)
  local POWERLEVEL9K_DATE_ICON="date-icon"
  local POWERLEVEL9K_DATE_VISUAL_IDENTIFIER_COLOR='green'
  local POWERLEVEL9K_DATE_FOREGROUND='red'
  local POWERLEVEL9K_DATE_BACKGROUND='yellow'

  assertEquals "%K{003} %F{002}date-icon %f%F{001}%D{%d.%m.%y} %k%F{003}%f " "$(build_left_prompt)"
}

function testColorOverridingOfStatefulSegment() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(host)
  local POWERLEVEL9K_SSH_ICON="ssh-icon"
  local POWERLEVEL9K_HOST_REMOTE_BACKGROUND='red'
  local POWERLEVEL9K_HOST_REMOTE_FOREGROUND='green'
  # Provoke state
  local SSH_CLIENT="x"

  assertEquals "%K{001} %F{002}ssh-icon %f%F{002}%m %k%F{001}%f " "$(build_left_prompt)"
}

function testColorOverridingOfCustomSegment() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world)
  local POWERLEVEL9K_CUSTOM_WORLD='echo world'
  local POWERLEVEL9K_CUSTOM_WORLD_ICON='CW'
  local POWERLEVEL9K_CUSTOM_WORLD_VISUAL_IDENTIFIER_COLOR='green'
  local POWERLEVEL9K_CUSTOM_WORLD_FOREGROUND='red'
  local POWERLEVEL9K_CUSTOM_WORLD_BACKGROUND='red'

  assertEquals "%K{001} %F{002}CW %f%F{001}world %k%F{001}%f " "$(build_left_prompt)"
}

source shunit2/shunit2
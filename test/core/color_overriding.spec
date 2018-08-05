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

  assertEquals "%K{red} %F{black%}date-icon %f%F{black}%D{%d.%m.%y} %k%F{red}%f " "$(build_left_prompt)"
}

function testDynamicColoringOfVisualIdentifiersWork() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(date)
  local POWERLEVEL9K_DATE_ICON="date-icon"
  local POWERLEVEL9K_DATE_VISUAL_IDENTIFIER_COLOR='green'

  assertEquals "%K{white} %F{green%}date-icon %f%F{black}%D{%d.%m.%y} %k%F{white}%f " "$(build_left_prompt)"
}

function testColoringOfVisualIdentifiersDoesNotOverwriteColoringOfSegment() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(date)
  local POWERLEVEL9K_DATE_ICON="date-icon"
  local POWERLEVEL9K_DATE_VISUAL_IDENTIFIER_COLOR='green'
  local POWERLEVEL9K_DATE_FOREGROUND='red'
  local POWERLEVEL9K_DATE_BACKGROUND='yellow'

  assertEquals "%K{yellow} %F{green%}date-icon %f%F{red}%D{%d.%m.%y} %k%F{yellow}%f " "$(build_left_prompt)"
}

function testColorOverridingOfStatefulSegment() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(host)
  local POWERLEVEL9K_SSH_ICON="ssh-icon"
  local POWERLEVEL9K_HOST_REMOTE_BACKGROUND='red'
  local POWERLEVEL9K_HOST_REMOTE_FOREGROUND='green'
  # Provoke state
  local SSH_CLIENT="x"

  assertEquals "%K{red} %F{green%}ssh-icon %f%F{green}%m %k%F{red}%f " "$(build_left_prompt)"
}

function testColorOverridingOfCustomSegment() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world)
  local POWERLEVEL9K_CUSTOM_WORLD='echo world'
  local POWERLEVEL9K_CUSTOM_WORLD_ICON='CW'
  local POWERLEVEL9K_CUSTOM_WORLD_VISUAL_IDENTIFIER_COLOR='green'
  local POWERLEVEL9K_CUSTOM_WORLD_FOREGROUND='red'
  local POWERLEVEL9K_CUSTOM_WORLD_BACKGROUND='red'

  assertEquals "%K{red} %F{green%}CW %f%F{red}world %k%F{red}%f " "$(build_left_prompt)"
}

source shunit2/shunit2
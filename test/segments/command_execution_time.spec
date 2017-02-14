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

function testCommandExecutionTimeIsNotShownIfTimeIsBelowThreshold() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world command_execution_time)
  POWERLEVEL9K_CUSTOM_WORLD='echo world'
  _P9K_COMMAND_DURATION=2

  assertEquals "%K{white} %F{black}world %k%F{white}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_CUSTOM_WORLD
  unset _P9K_COMMAND_DURATION
}

function testCommandExecutionTimesThresholdCouldBeChanged() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world command_execution_time)
  POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=1
  _P9K_COMMAND_DURATION=2

  assertEquals "%K{red} %F{226%}Dur%f %F{226}2 %k%F{red}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset _P9K_COMMAND_DURATION
  unset POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD
}

function testCommandExecutionTimeIsFormattedHumandReadbleForMinuteLongCommand() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world command_execution_time)
  _P9K_COMMAND_DURATION=180

  assertEquals "%K{red} %F{226%}Dur%f %F{226}03:00 %k%F{red}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset _P9K_COMMAND_DURATION
}

function testCommandExecutionTimeIsFormattedHumandReadbleForHourLongCommand() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world command_execution_time)
  _P9K_COMMAND_DURATION=7200

  assertEquals "%K{red} %F{226%}Dur%f %F{226}02:00:00 %k%F{red}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset _P9K_COMMAND_DURATION
}

source shunit2/source/2.1/src/shunit2
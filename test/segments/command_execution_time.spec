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

function testCommandExecutionTimeThresholdCouldBeChanged() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(command_execution_time)
  POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=1
  _P9K_COMMAND_DURATION=2.03

  assertEquals "%K{red} %F{yellow1%}Dur %f%F{yellow1}2.03 %k%F{red}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset _P9K_COMMAND_DURATION
  unset POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD
}

function testCommandExecutionTimeThresholdCouldBeSetToZero() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(command_execution_time)
  POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=0
  _P9K_COMMAND_DURATION=0.03

  assertEquals "%K{red} %F{yellow1%}Dur %f%F{yellow1}0.03 %k%F{red}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset _P9K_COMMAND_DURATION
  unset POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD
}

function testCommandExecutionTimePrecisionCouldBeChanged() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(command_execution_time)
  POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=0
  POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=4
  _P9K_COMMAND_DURATION=0.0001

  assertEquals "%K{red} %F{yellow1%}Dur %f%F{yellow1}0.0001 %k%F{red}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset _P9K_COMMAND_DURATION
  unset POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION
  unset POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD
}

function testCommandExecutionTimePrecisionCouldBeSetToZero() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(command_execution_time)
  POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  _P9K_COMMAND_DURATION=23.5001

  assertEquals "%K{red} %F{yellow1%}Dur %f%F{yellow1}23 %k%F{red}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset _P9K_COMMAND_DURATION
  unset POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION
}

function testCommandExecutionTimeIsFormattedHumandReadbleForMinuteLongCommand() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(command_execution_time)
  _P9K_COMMAND_DURATION=180

  assertEquals "%K{red} %F{yellow1%}Dur %f%F{yellow1}03:00 %k%F{red}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset _P9K_COMMAND_DURATION
}

function testCommandExecutionTimeIsFormattedHumandReadbleForHourLongCommand() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(command_execution_time)
  _P9K_COMMAND_DURATION=7200

  assertEquals "%K{red} %F{yellow1%}Dur %f%F{yellow1}02:00:00 %k%F{red}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset _P9K_COMMAND_DURATION
}

source shunit2/source/2.1/src/shunit2
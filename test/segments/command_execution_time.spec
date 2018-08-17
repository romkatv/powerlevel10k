#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"
}

function testCommandExecutionTimeIsNotShownIfTimeIsBelowThreshold() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world command_execution_time)
  local POWERLEVEL9K_CUSTOM_WORLD='echo world'

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  # Override payload
  local _P9K_COMMAND_DURATION=2

  assertEquals "%K{007} %F{000}world %k%F{007}%f " "$(build_left_prompt)"
}

function testCommandExecutionTimeThresholdCouldBeChanged() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(command_execution_time)
  local POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=1

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  # Override payload
  local _P9K_COMMAND_DURATION=2.03

  assertEquals "%K{001} %F{226}Dur %f%F{226}2.03 %k%F{001}%f " "$(build_left_prompt)"
}

function testCommandExecutionTimeThresholdCouldBeSetToZero() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(command_execution_time)
  local POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=0
  local _P9K_COMMAND_DURATION=0.03

  assertEquals "%K{001} %F{226}Dur %f%F{226}0.03 %k%F{001}%f " "$(build_left_prompt)"
}

function testCommandExecutionTimePrecisionCouldBeChanged() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(command_execution_time)
  local POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=0
  local POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=4

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  # Override payload
  local _P9K_COMMAND_DURATION=0.0001

  assertEquals "%K{001} %F{226}Dur %f%F{226}0.0001 %k%F{001}%f " "$(build_left_prompt)"
}

function testCommandExecutionTimePrecisionCouldBeSetToZero() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(command_execution_time)
  local POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  # Override payload
  local _P9K_COMMAND_DURATION=23.5001

  assertEquals "%K{001} %F{226}Dur %f%F{226}23 %k%F{001}%f " "$(build_left_prompt)"
}

function testCommandExecutionTimeIsFormattedHumandReadbleForMinuteLongCommand() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(command_execution_time)

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  # Override payload
  local _P9K_COMMAND_DURATION=180

  assertEquals "%K{001} %F{226}Dur %f%F{226}03:00 %k%F{001}%f " "$(build_left_prompt)"
}

function testCommandExecutionTimeIsFormattedHumandReadbleForHourLongCommand() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(command_execution_time)

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  # Override payload
  local _P9K_COMMAND_DURATION=7200

  assertEquals "%K{001} %F{226}Dur %f%F{226}02:00:00 %k%F{001}%f " "$(build_left_prompt)"
}

source shunit2/shunit2
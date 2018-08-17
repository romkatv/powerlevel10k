#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"
}

function mockLaravelVersion() {
  case "$1" in
    "artisan")
      # artisan --version follows the format Laravel Framework <version>
      echo "Laravel Framework 5.4.23"
      ;;
    default)
  esac
}

function mockNoLaravelVersion() {
  # When php can't find a file it will output a message
  echo "Could not open input file: artisan"
  return 0
}

function testLaravelVersionSegment() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(laravel_version)
  local POWERLEVEL9K_LARAVEL_ICON='x'
  alias php=mockLaravelVersion

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  assertEquals "%K{009} %F{007}x %f%F{007}5.4.23 %k%F{009}%f " "$(build_left_prompt)"

  unalias php
}

function testLaravelVersionSegmentIfArtisanIsNotAvailable() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world laravel_version)
  local POWERLEVEL9K_CUSTOM_WORLD='echo world'
  local POWERLEVEL9K_LARAVEL_ICON='x'
  alias php=mockNoLaravelVersion

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  assertEquals "%K{007} %F{000}world %k%F{007}%f " "$(build_left_prompt)"

  unalias php
}

function testLaravelVersionSegmentPrintsNothingIfPhpIsNotAvailable() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world laravel_version)
  local POWERLEVEL9K_CUSTOM_WORLD='echo world'
  local POWERLEVEL9K_LARAVEL_ICON='x'
  alias php=noPhp

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  assertEquals "%K{007} %F{000}world %k%F{007}%f " "$(build_left_prompt)"

  unalias php
}

source shunit2/shunit2

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
      echo "Laravel Framework version 5.4.23"
      ;;
    default)
  esac
}

function mockNoLaravelVersion() {
  # This should output some error
  >&2 echo "Artisan not available"
  return 1
}

function testLaravelVersionSegment() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(laravel_version)
  local POWERLEVEL9K_LARAVEL_ICON='x'
  alias php=mockLaravelVersion

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  assertEquals "%K{001} %F{white%}x %f%F{white}5.4.23 %k%F{maroon}%f " "$(build_left_prompt)"

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

  assertEquals "%K{white} %F{black}world %k%F{white}%f " "$(build_left_prompt)"

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

  assertEquals "%K{white} %F{black}world %k%F{white}%f " "$(build_left_prompt)"

  unalias php
}

source shunit2/shunit2

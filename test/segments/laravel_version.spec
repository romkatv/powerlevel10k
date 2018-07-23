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
  alias php=mockLaravelVersion
  POWERLEVEL9K_LARAVEL_ICON='x'
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(laravel_version)

  assertEquals "%K{001} %F{white%}x %f%F{white}5.4.23 %k%F{maroon}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_LARAVEL_ICON
  unalias php
}

function testLaravelVersionSegmentIfArtisanIsNotAvailable() {
  alias php=mockNoLaravelVersion
  POWERLEVEL9K_CUSTOM_WORLD='echo world'
  POWERLEVEL9K_LARAVEL_ICON='x'
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world laravel_version)

  assertEquals "%K{white} %F{black}world %k%F{white}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_LARAVEL_ICON
  unset POWERLEVEL9K_CUSTOM_WORLD
  unalias php
}

function testLaravelVersionSegmentPrintsNothingIfPhpIsNotAvailable() {
  alias php=noPhp
  POWERLEVEL9K_CUSTOM_WORLD='echo world'
  POWERLEVEL9K_LARAVEL_ICON='x'
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world laravel_version)

  assertEquals "%K{white} %F{black}world %k%F{white}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_LARAVEL_ICON
  unset POWERLEVEL9K_CUSTOM_WORLD
  unalias php
}

source shunit2/source/2.1/src/shunit2

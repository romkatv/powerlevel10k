#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"
}

function testPhpVersionSegmentPrintsNothingIfPhpIsNotAvailable() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(php_version custom_world)
  local POWERLEVEL9K_CUSTOM_WORLD='echo world'
  alias php="nophp"

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  assertEquals "%K{007} %F{000}world %k%F{007}%f " "$(build_left_prompt)"

  unalias php
}

function testPhpVersionSegmentWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(php_version)
  alias php="echo 'PHP 5.6.27 (cli) (built: Oct 23 2016 11:47:58)
Copyright (c) 1997-2016 The PHP Group
Zend Engine v2.6.0, Copyright (c) 1998-2016 Zend Technologies
'"

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  assertEquals "%K{013} %F{255}PHP 5.6.27 %k%F{013}%f " "$(build_left_prompt)"

  unalias php
}

source shunit2/shunit2
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

function testLeftNormalSegmentsShouldNotBeJoined() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world1 custom_world2 custom_world3 custom_world4_joined custom_world5 custom_world6)
  local POWERLEVEL9K_CUSTOM_WORLD1="echo world1"
  local POWERLEVEL9K_CUSTOM_WORLD2="echo world2"
  local POWERLEVEL9K_CUSTOM_WORLD3="echo " # Print nothing to simulate unmet conditions
  local POWERLEVEL9K_CUSTOM_WORLD4="echo world4"
  local POWERLEVEL9K_CUSTOM_WORLD5="echo " # Print nothing to simulate unmet conditions
  local POWERLEVEL9K_CUSTOM_WORLD6="echo world6"
  
  assertEquals "%K{white} %F{black}world1 %K{white}%F{black} %F{black}world2 %K{white}%F{black} %F{black}world4 %K{white}%F{black} %F{black}world6 %k%F{white}%f " "$(build_left_prompt)"
}

function testLeftJoinedSegments() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world1 custom_world2_joined)
  local POWERLEVEL9K_CUSTOM_WORLD1="echo world1"
  local POWERLEVEL9K_CUSTOM_WORLD2="echo world2"

  assertEquals "%K{white} %F{black}world1 %K{white}%F{black}%F{black}world2 %k%F{white}%f " "$(build_left_prompt)"
}

function testLeftTransitiveJoinedSegments() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world1 custom_world2_joined custom_world3_joined)
  local POWERLEVEL9K_CUSTOM_WORLD1="echo world1"
  local POWERLEVEL9K_CUSTOM_WORLD2="echo world2"
  local POWERLEVEL9K_CUSTOM_WORLD3="echo world3"

  assertEquals "%K{white} %F{black}world1 %K{white}%F{black}%F{black}world2 %K{white}%F{black}%F{black}world3 %k%F{white}%f " "$(build_left_prompt)"
}

function testLeftTransitiveJoiningWithConditionalJoinedSegment() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world1 custom_world2_joined custom_world3_joined custom_world4_joined)
  local POWERLEVEL9K_CUSTOM_WORLD1="echo world1"
  local POWERLEVEL9K_CUSTOM_WORLD2="echo world2"
  local POWERLEVEL9K_CUSTOM_WORLD3="echo " # Print nothing to simulate unmet conditions
  local POWERLEVEL9K_CUSTOM_WORLD4="echo world4"

  assertEquals "%K{white} %F{black}world1 %K{white}%F{black}%F{black}world2 %K{white}%F{black}%F{black}world4 %k%F{white}%f " "$(build_left_prompt)"
}

function testLeftPromotingSegmentWithConditionalPredecessor() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world1 custom_world2 custom_world3_joined)
  local POWERLEVEL9K_CUSTOM_WORLD1="echo world1"
  local POWERLEVEL9K_CUSTOM_WORLD2="echo " # Print nothing to simulate unmet conditions
  local POWERLEVEL9K_CUSTOM_WORLD3="echo world3"

  assertEquals "%K{white} %F{black}world1 %K{white}%F{black} %F{black}world3 %k%F{white}%f " "$(build_left_prompt)"
}

function testLeftPromotingSegmentWithJoinedConditionalPredecessor() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world1 custom_world2 custom_world3_joined custom_world4_joined)
  local POWERLEVEL9K_CUSTOM_WORLD1="echo world1"
  local POWERLEVEL9K_CUSTOM_WORLD2="echo " # Print nothing to simulate unmet conditions
  local POWERLEVEL9K_CUSTOM_WORLD3="echo " # Print nothing to simulate unmet conditions
  local POWERLEVEL9K_CUSTOM_WORLD4="echo world4"

  assertEquals "%K{white} %F{black}world1 %K{white}%F{black} %F{black}world4 %k%F{white}%f " "$(build_left_prompt)"
}

function testLeftPromotingSegmentWithDeepJoinedConditionalPredecessor() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world1 custom_world2 custom_world3_joined custom_world4_joined custom_world5_joined custom_world6_joined)
  local POWERLEVEL9K_CUSTOM_WORLD1="echo world1"
  local POWERLEVEL9K_CUSTOM_WORLD2="echo " # Print nothing to simulate unmet conditions
  local POWERLEVEL9K_CUSTOM_WORLD3="echo " # Print nothing to simulate unmet conditions
  local POWERLEVEL9K_CUSTOM_WORLD4="echo world4"
  local POWERLEVEL9K_CUSTOM_WORLD5="echo " # Print nothing to simulate unmet conditions
  local POWERLEVEL9K_CUSTOM_WORLD6="echo world6"

  assertEquals "%K{white} %F{black}world1 %K{white}%F{black} %F{black}world4 %K{white}%F{black}%F{black}world6 %k%F{white}%f " "$(build_left_prompt)"
}

function testLeftJoiningBuiltinSegmentWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(php_version php_version_joined)
  alias php="echo PHP 1.2.3"

  assertEquals "%K{013} %F{255}PHP 1.2.3 %K{013}%F{255}%F{255}PHP 1.2.3 %k%F{fuchsia}%f " "$(build_left_prompt)"

  unalias php
}

function testRightNormalSegmentsShouldNotBeJoined() {
  local -a POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS
  POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(custom_world1 custom_world2 custom_world3 custom_world4 custom_world5_joined custom_world6)
  local POWERLEVEL9K_CUSTOM_WORLD1="echo world1"
  local POWERLEVEL9K_CUSTOM_WORLD2="echo world2"
  local POWERLEVEL9K_CUSTOM_WORLD3="echo " # Print nothing to simulate unmet conditions
  local POWERLEVEL9K_CUSTOM_WORLD4="echo world4"
  local POWERLEVEL9K_CUSTOM_WORLD5="echo " # Print nothing to simulate unmet conditions
  local POWERLEVEL9K_CUSTOM_WORLD6="echo world6"

  assertEquals "%F{white}%f%K{white}%F{black} world1 %f%F{black}%f%K{white}%F{black} world2 %f%F{black}%f%K{white}%F{black} world4 %f%F{black}%f%K{white}%F{black} world6%E" "$(build_right_prompt)"
}

function testRightJoinedSegments() {
  local -a POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS
  POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(custom_world1 custom_world2_joined)
  local POWERLEVEL9K_CUSTOM_WORLD1="echo world1"
  local POWERLEVEL9K_CUSTOM_WORLD2="echo world2"

  assertEquals "%F{white}%f%K{white}%F{black} world1 %f%K{white}%F{black}world2%E" "$(build_right_prompt)"
}

function testRightTransitiveJoinedSegments() {
  local -a POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS
  POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(custom_world1 custom_world2_joined custom_world3_joined)
  local POWERLEVEL9K_CUSTOM_WORLD1="echo world1"
  local POWERLEVEL9K_CUSTOM_WORLD2="echo world2"
  local POWERLEVEL9K_CUSTOM_WORLD3="echo world3"

  assertEquals "%F{white}%f%K{white}%F{black} world1 %f%K{white}%F{black}world2 %f%K{white}%F{black}world3%E" "$(build_right_prompt)"
}

function testRightTransitiveJoiningWithConditionalJoinedSegment() {
  local -a POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS
  POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(custom_world1 custom_world2_joined custom_world3_joined custom_world4_joined)
  local POWERLEVEL9K_CUSTOM_WORLD1="echo world1"
  local POWERLEVEL9K_CUSTOM_WORLD2="echo world2"
  local POWERLEVEL9K_CUSTOM_WORLD3="echo " # Print nothing to simulate unmet conditions
  local POWERLEVEL9K_CUSTOM_WORLD4="echo world4"

  assertEquals "%F{white}%f%K{white}%F{black} world1 %f%K{white}%F{black}world2 %f%K{white}%F{black}world4%E" "$(build_right_prompt)"
}

function testRightPromotingSegmentWithConditionalPredecessor() {
  local -a POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS
  POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(custom_world1 custom_world2 custom_world3_joined)
  local POWERLEVEL9K_CUSTOM_WORLD1="echo world1"
  local POWERLEVEL9K_CUSTOM_WORLD2="echo " # Print nothing to simulate unmet conditions
  local POWERLEVEL9K_CUSTOM_WORLD3="echo world3"

  assertEquals "%F{white}%f%K{white}%F{black} world1 %f%F{black}%f%K{white}%F{black} world3%E" "$(build_right_prompt)"
}

function testRightPromotingSegmentWithJoinedConditionalPredecessor() {
  local -a POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS
  POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(custom_world1 custom_world2 custom_world3_joined custom_world4_joined)
  local POWERLEVEL9K_CUSTOM_WORLD1="echo world1"
  local POWERLEVEL9K_CUSTOM_WORLD2="echo " # Print nothing to simulate unmet conditions
  local POWERLEVEL9K_CUSTOM_WORLD3="echo " # Print nothing to simulate unmet conditions
  local POWERLEVEL9K_CUSTOM_WORLD4="echo world4"

  assertEquals "%F{white}%f%K{white}%F{black} world1 %f%F{black}%f%K{white}%F{black} world4%E" "$(build_right_prompt)"
}

function testRightPromotingSegmentWithDeepJoinedConditionalPredecessor() {
  local -a POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS
  POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(custom_world1 custom_world2 custom_world3_joined custom_world4_joined custom_world5_joined custom_world6_joined)
  local POWERLEVEL9K_CUSTOM_WORLD1="echo world1"
  local POWERLEVEL9K_CUSTOM_WORLD2="echo " # Print nothing to simulate unmet conditions
  local POWERLEVEL9K_CUSTOM_WORLD3="echo " # Print nothing to simulate unmet conditions
  local POWERLEVEL9K_CUSTOM_WORLD4="echo world4"
  local POWERLEVEL9K_CUSTOM_WORLD5="echo " # Print nothing to simulate unmet conditions
  local POWERLEVEL9K_CUSTOM_WORLD6="echo world6"

  assertEquals "%F{white}%f%K{white}%F{black} world1 %f%F{black}%f%K{white}%F{black} world4 %f%K{white}%F{black}world6%E" "$(build_right_prompt)"
}

function testRightJoiningBuiltinSegmentWorks() {
  local -a POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS
  POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(php_version php_version_joined)
  alias php="echo PHP 1.2.3"

  assertEquals "%F{013}%f%K{013}%F{255} PHP 1.2.3 %f%K{013}%F{255}PHP 1.2.3%E" "$(build_right_prompt)"

  unalias php
}
source shunit2/shunit2
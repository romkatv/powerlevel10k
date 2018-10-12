#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"

  # Test specific
  P9K_HOME=$(pwd)
  FOLDER=/tmp/powerlevel9k-test
  mkdir -p $FOLDER
  cd $FOLDER
}

function tearDown() {
  # Go back to powerlevel9k folder
  cd "${P9K_HOME}"
  # Remove eventually created test-specific folder
  rm -fr "${FOLDER}"
  # At least remove test folder completely
  rm -fr /tmp/powerlevel9k-test
  unset FOLDER
  unset P9K_HOME

  # Remove IP cache file
  rm -f ${POWERLEVEL9K_PUBLIC_IP_FILE}
}

function testDiskUsageSegmentWhenDiskIsAlmostFull() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(disk_usage)
  df() {
      echo "Filesystem     1K-blocks      Used Available Use% Mounted on
/dev/disk1     487219288 471466944  15496344  97% /"
  }

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{001} %F{007}hdd  %f%F{007}97%% %k%F{001}%f " "$(build_left_prompt)"

  unfunction df
}

function testDiskUsageSegmentWhenDiskIsVeryFull() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(disk_usage)
  df() {
      echo "Filesystem     1K-blocks      Used Available Use% Mounted on
/dev/disk1     487219288 471466944  15496344  94% /"
  }

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{003} %F{000}hdd  %f%F{000}94%% %k%F{003}%f " "$(build_left_prompt)"

  unfunction df
}

function testDiskUsageSegmentWhenDiskIsQuiteEmpty() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(disk_usage)
  df() {
      echo "Filesystem     1K-blocks      Used Available Use% Mounted on
/dev/disk1     487219288 471466944  15496344  4% /"
  }

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{000} %F{003}hdd  %f%F{003}4%% %k%F{000}%f " "$(build_left_prompt)"

  unfunction df
}

function testDiskUsageSegmentPrintsNothingIfDiskIsQuiteEmptyAndOnlyWarningsShouldBeDisplayed() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(disk_usage custom_world)
  df() {
      echo "Filesystem     1K-blocks      Used Available Use% Mounted on
/dev/disk1     487219288 471466944  15496344  4% /"
  }

  local POWERLEVEL9K_DISK_USAGE_ONLY_WARNING=true
  local POWERLEVEL9K_CUSTOM_WORLD='echo world'

  assertEquals "%K{007} %F{000}world %k%F{007}%f " "$(build_left_prompt)"

  unfunction df
}

function testDiskUsageSegmentWarningLevelCouldBeAdjusted() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(disk_usage)
  local POWERLEVEL9K_DISK_USAGE_WARNING_LEVEL=10
  df() {
    echo "Filesystem     1K-blocks      Used Available Use% Mounted on
/dev/disk1     487219288 471466944  15496344  11% /"
  }

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{003} %F{000}hdd  %f%F{000}11%% %k%F{003}%f " "$(build_left_prompt)"

  unfunction df
}

function testDiskUsageSegmentCriticalLevelCouldBeAdjusted() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(disk_usage)
  local POWERLEVEL9K_DISK_USAGE_WARNING_LEVEL=5
  local POWERLEVEL9K_DISK_USAGE_CRITICAL_LEVEL=10
  df() {
    echo "Filesystem     1K-blocks      Used Available Use% Mounted on
/dev/disk1     487219288 471466944  15496344  11% /"
  }

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{001} %F{007}hdd  %f%F{007}11%% %k%F{001}%f " "$(build_left_prompt)"

  unfunction df
}

source shunit2/shunit2
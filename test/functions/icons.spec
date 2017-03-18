#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
    # Store old value for LC_CTYPE
    _OLD_LC_CTYPE="${LC_CTYPE}"
    # Reset actual LC_CTYPE
    unset LC_CTYPE

    # Store old P9K mode
    _OLD_P9K_MODE="${POWERLEVEL9K_MODE}"
}

function tearDown() {
    # Restore LC_CTYPE
    LC_CTYPE="${_OLD_LC_CTYPE}"

    # Restore old P9K mode
    POWERLEVEL9K_MODE="${_OLD_P9K_MODE}"
}

function testLcCtypeIsSetCorrectlyInDefaultMode() {
  POWERLEVEL9K_MODE="default"
  # Load Powerlevel9k
  source functions/icons.zsh

  assertEquals 'en_US.UTF-8' "${LC_CTYPE}"
}

function testLcCtypeIsSetCorrectlyInAwesomePatchedMode() {
  POWERLEVEL9K_MODE="awesome-patched"
  # Load Powerlevel9k
  source functions/icons.zsh

  assertEquals 'en_US.UTF-8' "${LC_CTYPE}"
}

function testLcCtypeIsSetCorrectlyInAwesomeFontconfigMode() {
  POWERLEVEL9K_MODE="awesome-fontconfig"
  # Load Powerlevel9k
  source functions/icons.zsh

  assertEquals 'en_US.UTF-8' "${LC_CTYPE}"
}

function testLcCtypeIsSetCorrectlyInNerdfontFontconfigMode() {
  POWERLEVEL9K_MODE="nerdfont-fontconfig"
  # Load Powerlevel9k
  source functions/icons.zsh

  assertEquals 'en_US.UTF-8' "${LC_CTYPE}"
}

function testLcCtypeIsSetCorrectlyInFlatMode() {
  POWERLEVEL9K_MODE="flat"
  # Load Powerlevel9k
  source functions/icons.zsh

  assertEquals 'en_US.UTF-8' "${LC_CTYPE}"
}

function testLcCtypeIsSetCorrectlyInCompatibleMode() {
  POWERLEVEL9K_MODE="compatible"
  # Load Powerlevel9k
  source functions/icons.zsh

  assertEquals 'en_US.UTF-8' "${LC_CTYPE}"
}

source shunit2/source/2.1/src/shunit2
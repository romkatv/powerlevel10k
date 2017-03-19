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

# Go through all icons defined in default mode, and
# check if all of them are defined in the other modes.
function testAllIconsAreDefinedLikeInDefaultMode() {
  # Always compare against this mode
  local _P9K_TEST_MODE="default"
  POWERLEVEL9K_MODE="${_P9K_TEST_MODE}"
  source functions/icons.zsh
  # _ICONS_UNDER_TEST is an array of just the keys of $icons.
  # We later check via (r) "subscript" flag that our key
  # is in the values of our flat array.
  typeset -ah _ICONS_UNDER_TEST
  _ICONS_UNDER_TEST=(${(k)icons[@]})

  # Switch to "awesome-patched" mode
  POWERLEVEL9K_MODE="awesome-patched"
  source functions/icons.zsh
  typeset -ah current_icons
  current_icons=(${(k)icons[@]})
  for key in ${_ICONS_UNDER_TEST}; do
    # Iterate over all keys found in the _ICONS_UNDER_TEST
    # array and compare it with the icons array of the
    # current POWERLEVEL9K_MODE.
    # Use parameter expansion, to directly check if the
    # key exists in the flat current array of keys. That
    # is quite complicated, but there seems no easy way
    # to check the mere existance of a key in an array.
    # The usual way would always return the value, so that
    # would do the wrong thing as we have some (on purpose)
    # empty values.
    assertTrue "The key ${key} does exist in ${_P9K_TEST_MODE} mode, but not in ${POWERLEVEL9K_MODE}!" "(( ${+current_icons[(r)$key]} ))"
  done

  # Switch to "awesome-fontconfig" mode
  POWERLEVEL9K_MODE="awesome-fontconfig"
  source functions/icons.zsh
  typeset -ah current_icons
  current_icons=(${(k)icons[@]})
  for key in ${_ICONS_UNDER_TEST}; do
    assertTrue "The key ${key} does exist in ${_P9K_TEST_MODE} mode, but not in ${POWERLEVEL9K_MODE}!" "(( ${+current_icons[(r)$key]} ))"
  done

  # Switch to "nerdfont-fontconfig" mode
  POWERLEVEL9K_MODE="nerdfont-fontconfig"
  source functions/icons.zsh
  typeset -ah current_icons
  current_icons=(${(k)icons[@]})
  for key in ${_ICONS_UNDER_TEST}; do
    assertTrue "The key ${key} does exist in ${_P9K_TEST_MODE} mode, but not in ${POWERLEVEL9K_MODE}!" "(( ${+current_icons[(r)$key]} ))"
  done

  # Switch to "flat" mode
  POWERLEVEL9K_MODE="flat"
  source functions/icons.zsh
  typeset -ah current_icons
  current_icons=(${(k)icons[@]})
  for key in ${_ICONS_UNDER_TEST}; do
    assertTrue "The key ${key} does exist in ${_P9K_TEST_MODE} mode, but not in ${POWERLEVEL9K_MODE}!" "(( ${+current_icons[(r)$key]} ))"
  done

  # Switch to "compatible" mode
  POWERLEVEL9K_MODE="compatible"
  source functions/icons.zsh
  typeset -ah current_icons
  current_icons=(${(k)icons[@]})
  for key in ${_ICONS_UNDER_TEST}; do
    assertTrue "The key ${key} does exist in ${_P9K_TEST_MODE} mode, but not in ${POWERLEVEL9K_MODE}!" "(( ${+current_icons[(r)$key]} ))"
  done

  unset current_icons
  unset _ICONS_UNDER_TEST
}

# Go through all icons defined in awesome-patched mode, and
# check if all of them are defined in the other modes.
function testAllIconsAreDefinedLikeInAwesomePatchedMode() {
  # Always compare against this mode
  local _P9K_TEST_MODE="awesome-patched"
  POWERLEVEL9K_MODE="$_P9K_TEST_MODE"
  source functions/icons.zsh
  # _ICONS_UNDER_TEST is an array of just the keys of $icons.
  # We later check via (r) "subscript" flag that our key
  # is in the values of our flat array.
  typeset -ah _ICONS_UNDER_TEST
  _ICONS_UNDER_TEST=(${(k)icons[@]})

  # Switch to "default" mode
  POWERLEVEL9K_MODE="default"
  source functions/icons.zsh
  typeset -ah current_icons
  current_icons=(${(k)icons[@]})
  for key in ${_ICONS_UNDER_TEST}; do
    # Iterate over all keys found in the _ICONS_UNDER_TEST
    # array and compare it with the icons array of the
    # current POWERLEVEL9K_MODE.
    # Use parameter expansion, to directly check if the
    # key exists in the flat current array of keys. That
    # is quite complicated, but there seems no easy way
    # to check the mere existance of a key in an array.
    # The usual way would always return the value, so that
    # would do the wrong thing as we have some (on purpose)
    # empty values.
    assertTrue "The key ${key} does exist in ${_P9K_TEST_MODE} mode, but not in ${POWERLEVEL9K_MODE}!" "(( ${+current_icons[(r)$key]} ))"
  done

  # Switch to "awesome-fontconfig" mode
  POWERLEVEL9K_MODE="awesome-fontconfig"
  source functions/icons.zsh
  typeset -ah current_icons
  current_icons=(${(k)icons[@]})
  for key in ${_ICONS_UNDER_TEST}; do
    assertTrue "The key ${key} does exist in ${_P9K_TEST_MODE} mode, but not in ${POWERLEVEL9K_MODE}!" "(( ${+current_icons[(r)$key]} ))"
  done

  # Switch to "nerdfont-fontconfig" mode
  POWERLEVEL9K_MODE="nerdfont-fontconfig"
  source functions/icons.zsh
  typeset -ah current_icons
  current_icons=(${(k)icons[@]})
  for key in ${_ICONS_UNDER_TEST}; do
    assertTrue "The key ${key} does exist in ${_P9K_TEST_MODE} mode, but not in ${POWERLEVEL9K_MODE}!" "(( ${+current_icons[(r)$key]} ))"
  done

  # Switch to "flat" mode
  POWERLEVEL9K_MODE="flat"
  source functions/icons.zsh
  typeset -ah current_icons
  current_icons=(${(k)icons[@]})
  for key in ${_ICONS_UNDER_TEST}; do
    assertTrue "The key ${key} does exist in ${_P9K_TEST_MODE} mode, but not in ${POWERLEVEL9K_MODE}!" "(( ${+current_icons[(r)$key]} ))"
  done

  # Switch to "compatible" mode
  POWERLEVEL9K_MODE="compatible"
  source functions/icons.zsh
  typeset -ah current_icons
  current_icons=(${(k)icons[@]})
  for key in ${_ICONS_UNDER_TEST}; do
    assertTrue "The key ${key} does exist in ${_P9K_TEST_MODE} mode, but not in ${POWERLEVEL9K_MODE}!" "(( ${+current_icons[(r)$key]} ))"
  done

  unset current_icons
  unset _ICONS_UNDER_TEST
}

# Go through all icons defined in awesome-fontconfig mode, and
# check if all of them are defined in the other modes.
function testAllIconsAreDefinedLikeInAwesomeFontconfigMode() {
  # Always compare against this mode
  local _P9K_TEST_MODE="awesome-fontconfig"
  POWERLEVEL9K_MODE="$_P9K_TEST_MODE"
  source functions/icons.zsh
  # _ICONS_UNDER_TEST is an array of just the keys of $icons.
  # We later check via (r) "subscript" flag that our key
  # is in the values of our flat array.
  typeset -ah _ICONS_UNDER_TEST
  _ICONS_UNDER_TEST=(${(k)icons[@]})

  # Switch to "default" mode
  POWERLEVEL9K_MODE="default"
  source functions/icons.zsh
  typeset -ah current_icons
  current_icons=(${(k)icons[@]})
  for key in ${_ICONS_UNDER_TEST}; do
    # Iterate over all keys found in the _ICONS_UNDER_TEST
    # array and compare it with the icons array of the
    # current POWERLEVEL9K_MODE.
    # Use parameter expansion, to directly check if the
    # key exists in the flat current array of keys. That
    # is quite complicated, but there seems no easy way
    # to check the mere existance of a key in an array.
    # The usual way would always return the value, so that
    # would do the wrong thing as we have some (on purpose)
    # empty values.
    assertTrue "The key ${key} does exist in ${_P9K_TEST_MODE} mode, but not in ${POWERLEVEL9K_MODE}!" "(( ${+current_icons[(r)$key]} ))"
  done

  # Switch to "awesome-patched" mode
  POWERLEVEL9K_MODE="awesome-patched"
  source functions/icons.zsh
  typeset -ah current_icons
  current_icons=(${(k)icons[@]})
  for key in ${_ICONS_UNDER_TEST}; do
    assertTrue "The key ${key} does exist in ${_P9K_TEST_MODE} mode, but not in ${POWERLEVEL9K_MODE}!" "(( ${+current_icons[(r)$key]} ))"
  done

  # Switch to "nerdfont-fontconfig" mode
  POWERLEVEL9K_MODE="nerdfont-fontconfig"
  source functions/icons.zsh
  typeset -ah current_icons
  current_icons=(${(k)icons[@]})
  for key in ${_ICONS_UNDER_TEST}; do
    assertTrue "The key ${key} does exist in ${_P9K_TEST_MODE} mode, but not in ${POWERLEVEL9K_MODE}!" "(( ${+current_icons[(r)$key]} ))"
  done

  # Switch to "flat" mode
  POWERLEVEL9K_MODE="flat"
  source functions/icons.zsh
  typeset -ah current_icons
  current_icons=(${(k)icons[@]})
  for key in ${_ICONS_UNDER_TEST}; do
    assertTrue "The key ${key} does exist in ${_P9K_TEST_MODE} mode, but not in ${POWERLEVEL9K_MODE}!" "(( ${+current_icons[(r)$key]} ))"
  done

  # Switch to "compatible" mode
  POWERLEVEL9K_MODE="compatible"
  source functions/icons.zsh
  typeset -ah current_icons
  current_icons=(${(k)icons[@]})
  for key in ${_ICONS_UNDER_TEST}; do
    assertTrue "The key ${key} does exist in ${_P9K_TEST_MODE} mode, but not in ${POWERLEVEL9K_MODE}!" "(( ${+current_icons[(r)$key]} ))"
  done

  unset current_icons
  unset _ICONS_UNDER_TEST
}

# Go through all icons defined in nerdfont-fontconfig mode, and
# check if all of them are defined in the other modes.
function testAllIconsAreDefinedLikeInNerdfontFontconfigMode() {
  # Always compare against this mode
  local _P9K_TEST_MODE="nerdfont-fontconfig"
  POWERLEVEL9K_MODE="$_P9K_TEST_MODE"
  source functions/icons.zsh
  # _ICONS_UNDER_TEST is an array of just the keys of $icons.
  # We later check via (r) "subscript" flag that our key
  # is in the values of our flat array.
  typeset -ah _ICONS_UNDER_TEST
  _ICONS_UNDER_TEST=(${(k)icons[@]})

  # Switch to "default" mode
  POWERLEVEL9K_MODE="default"
  source functions/icons.zsh
  typeset -ah current_icons
  current_icons=(${(k)icons[@]})
  for key in ${_ICONS_UNDER_TEST}; do
    # Iterate over all keys found in the _ICONS_UNDER_TEST
    # array and compare it with the icons array of the
    # current POWERLEVEL9K_MODE.
    # Use parameter expansion, to directly check if the
    # key exists in the flat current array of keys. That
    # is quite complicated, but there seems no easy way
    # to check the mere existance of a key in an array.
    # The usual way would always return the value, so that
    # would do the wrong thing as we have some (on purpose)
    # empty values.
    assertTrue "The key ${key} does exist in ${_P9K_TEST_MODE} mode, but not in ${POWERLEVEL9K_MODE}!" "(( ${+current_icons[(r)$key]} ))"
  done

  # Switch to "awesome-patched" mode
  POWERLEVEL9K_MODE="awesome-patched"
  source functions/icons.zsh
  typeset -ah current_icons
  current_icons=(${(k)icons[@]})
  for key in ${_ICONS_UNDER_TEST}; do
    assertTrue "The key ${key} does exist in ${_P9K_TEST_MODE} mode, but not in ${POWERLEVEL9K_MODE}!" "(( ${+current_icons[(r)$key]} ))"
  done

  # Switch to "awesome-fontconfig" mode
  POWERLEVEL9K_MODE="awesome-fontconfig"
  source functions/icons.zsh
  typeset -ah current_icons
  current_icons=(${(k)icons[@]})
  for key in ${_ICONS_UNDER_TEST}; do
    assertTrue "The key ${key} does exist in ${_P9K_TEST_MODE} mode, but not in ${POWERLEVEL9K_MODE}!" "(( ${+current_icons[(r)$key]} ))"
  done

  # Switch to "flat" mode
  POWERLEVEL9K_MODE="flat"
  source functions/icons.zsh
  typeset -ah current_icons
  current_icons=(${(k)icons[@]})
  for key in ${_ICONS_UNDER_TEST}; do
    assertTrue "The key ${key} does exist in ${_P9K_TEST_MODE} mode, but not in ${POWERLEVEL9K_MODE}!" "(( ${+current_icons[(r)$key]} ))"
  done

  # Switch to "compatible" mode
  POWERLEVEL9K_MODE="compatible"
  source functions/icons.zsh
  typeset -ah current_icons
  current_icons=(${(k)icons[@]})
  for key in ${_ICONS_UNDER_TEST}; do
    assertTrue "The key ${key} does exist in ${_P9K_TEST_MODE} mode, but not in ${POWERLEVEL9K_MODE}!" "(( ${+current_icons[(r)$key]} ))"
  done

  unset current_icons
  unset _ICONS_UNDER_TEST
}

source shunit2/source/2.1/src/shunit2
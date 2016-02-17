#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  # Load Powerlevel9k
  source functions/colors.zsh
}

function testGetColorCodeWithAnsiForegroundColor() {
  assertEquals '002' "$(getColorCode 'green')"
}

function testGetColorCodeWithAnsiBackgroundColor() {
  assertEquals '002' "$(getColorCode 'bg-green')"
}

function testGetColorCodeWithNumericalColor() {
  assertEquals '002' "$(getColorCode '002')"
}

function testIsSameColorComparesAnsiForegroundAndNumericalColorCorrectly() {
  assertTrue "isSameColor 'green' '002'"
}

function testIsSameColorComparesAnsiBackgroundAndNumericalColorCorrectly() {
  assertTrue "isSameColor 'bg-green' '002'"
}

function testIsSameColorComparesNumericalBackgroundAndNumericalColorCorrectly() {
  assertTrue "isSameColor '010' '2'"
}

function testIsSameColorDoesNotYieldNotEqualColorsTruthy() {
  assertFalse "isSameColor 'green' '003'"
}


source shunit2/source/2.1/src/shunit2

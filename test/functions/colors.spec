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

function testGetColorCodeWithNoneColor() {
  assertEquals 'none' "$(getColorCode 'NONE')"
}

function testIsSameColorComparesAnsiForegroundAndNumericalColorCorrectly() {
  assertTrue "isSameColor 'green' '002'"
}

function testIsSameColorComparesAnsiBackgroundAndNumericalColorCorrectly() {
  assertTrue "isSameColor 'bg-green' '002'"
}

function testIsSameColorComparesShortCodesCorrectly() {
  assertTrue "isSameColor '002' '2'"
}

function testIsSameColorDoesNotYieldNotEqualColorsTruthy() {
  assertFalse "isSameColor 'green' '003'"
}

function testIsSameColorHandlesNoneCorrectly() {
  assertTrue "isSameColor 'none' 'NOnE'"
}

function testIsSameColorCompareTwoNoneColorsCorrectly() {
  assertTrue "isSameColor 'none' 'none'"
}

function testIsSameColorComparesColorWithNoneCorrectly() {
  assertFalse "isSameColor 'green' 'none'"
}

function testBrightColorsWork() {
  # We had some code in the past that equalized bright colors
  # with normal ones. This code is now gone, and this test should
  # ensure that all input channels for bright colors are handled
  # correctly.
  assertTrue "isSameColor 'cyan' '006'"
  assertEquals '006' "$(getColorCode 'cyan')"
  assertEquals '006' "$(getColor 'cyan')"
}

source shunit2/shunit2

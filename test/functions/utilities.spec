#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function oneTimeSetUp() {
  # Load Powerlevel9k
  source functions/utilities.zsh
}

function testPrintSizeHumanReadableWithBigNumber() {
  # Interesting: Currently we can't support numbers bigger than that.
  assertEquals '0.87E' "$(printSizeHumanReadable 1000000000000000000)"
}

function testPrintSizeHumanReadableWithExabytesAsBase() {
  assertEquals '9.77Z' "$(printSizeHumanReadable 10000 'E')"
}

source shunit2/source/2.1/src/shunit2

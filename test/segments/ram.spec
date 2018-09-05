#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"

  P9K_HOME=$(pwd)
  ### Test specific
  # Create default folder and git init it.
  FOLDER=/tmp/powerlevel9k-test/ram-test
  mkdir -p "${FOLDER}"
  cd $FOLDER
}

function tearDown() {
  # Go back to powerlevel9k folder
  cd "${P9K_HOME}"
  # Remove eventually created test-specific folder
  rm -fr "${FOLDER}"
  # At least remove test folder completely
  rm -fr /tmp/powerlevel9k-test
}

function testRamSegmentWorksOnOsx() {
    alias vm_stat="echo 'Mach Virtual Memory Statistics: (page size of 4096 bytes)
Pages free:                              299687.
Pages active:                           1623792.
Pages inactive:                         1313411.
'"

    # Load Powerlevel9k
    source ${P9K_HOME}/powerlevel9k.zsh-theme
    local OS="OSX" # Fake OSX

    assertEquals "%K{003} %F{000}RAM %f%F{000}6.15G " "$(prompt_ram left 1 false ${FOLDER})"

    unalias vm_stat
}

function testRamSegmentWorksOnBsd() {
    mkdir -p var/run
    echo "avail memory 5678B 299687 4444G 299" > var/run/dmesg.boot

    # Load Powerlevel9k
    source ${P9K_HOME}/powerlevel9k.zsh-theme
    local OS="BSD" # Fake BSD

    assertEquals "%K{003} %F{000}RAM %f%F{000}0.29M " "$(prompt_ram left 1 false ${FOLDER})"
}

function testRamSegmentWorksOnLinux() {
    mkdir proc
    echo "MemAvailable: 299687" > proc/meminfo

    # Load Powerlevel9k
    source ${P9K_HOME}/powerlevel9k.zsh-theme
    local OS="Linux" # Fake Linux

    assertEquals "%K{003} %F{000}RAM %f%F{000}0.29G " "$(prompt_ram left 1 false ${FOLDER})"
}

source shunit2/shunit2
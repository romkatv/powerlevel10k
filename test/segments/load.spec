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
  FOLDER=/tmp/powerlevel9k-test/load-test
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

function testLoadSegmentWorksOnOsx() {
    sysctl() {
        if [[ "$*" == 'vm.loadavg' ]]; then
            echo "vm.loadavg: { 1,38 1,45 2,16 }";
        fi

        if [[ "$*" == '-n hw.logicalcpu' ]]; then
            echo "4";
        fi
    }

    local POWERLEVEL9K_LOAD_WHICH=1

    # Load Powerlevel9k
    source ${P9K_HOME}/powerlevel9k.zsh-theme
    local OS="OSX" # Fake OSX

    assertEquals "%K{002} %F{000}L %f%F{000}1.38 " "$(prompt_load left 1 false ${FOLDER})"

    unfunction sysctl
}

function testLoadSegmentWorksOnBsd() {
    sysctl() {
        if [[ "$*" == 'vm.loadavg' ]]; then
            echo "vm.loadavg: { 1,38 1,45 2,16 }";
        fi

        if [[ "$*" == '-n hw.ncpu' ]]; then
            echo "4";
        fi
    }

    local POWERLEVEL9K_LOAD_WHICH=1
    
    # Load Powerlevel9k
    source ${P9K_HOME}/powerlevel9k.zsh-theme
    local OS="BSD" # Fake BSD

    assertEquals "%K{002} %F{000}L %f%F{000}1.38 " "$(prompt_load left 1 false ${FOLDER})"

    unfunction sysctl
}

function testLoadSegmentWorksOnLinux() {
    # Prepare loadavg
    mkdir proc
    echo "1.38 0.01 0.05 1/87 8641" > proc/loadavg

    alias nproc="echo 4"
    local POWERLEVEL9K_LOAD_WHICH=1

    # Load Powerlevel9k
    source ${P9K_HOME}/powerlevel9k.zsh-theme
    local OS="Linux" # Fake Linux

    assertEquals "%K{002} %F{000}L %f%F{000}1.38 " "$(prompt_load left 1 false ${FOLDER})"

    unalias nproc
}

# Test normal state. This test is not OS specific.
# We test it as the Linux version, but that
# does not matter here.
function testLoadSegmentNormalState() {
    # Prepare loadavg
    mkdir proc
    echo "1.00 0.01 0.05 1/87 8641" > proc/loadavg

    alias nproc="echo 4"
    local POWERLEVEL9K_LOAD_WHICH=1

    # Load Powerlevel9k
    source ${P9K_HOME}/powerlevel9k.zsh-theme
    local OS="Linux" # Fake Linux

    assertEquals "%K{002} %F{000}L %f%F{000}1.00 " "$(prompt_load left 1 false ${FOLDER})"

    unalias nproc
}

# Test warning state. This test is not OS specific.
# We test it as the Linux version, but that
# does not matter here.
function testLoadSegmentWarningState() {
    # Prepare loadavg
    mkdir proc
    echo "2.01 0.01 0.05 1/87 8641" > proc/loadavg

    alias nproc="echo 4"
    local POWERLEVEL9K_LOAD_WHICH=1

    # Load Powerlevel9k
    source ${P9K_HOME}/powerlevel9k.zsh-theme
    local OS="Linux" # Fake Linux

    assertEquals "%K{003} %F{000}L %f%F{000}2.01 " "$(prompt_load left 1 false ${FOLDER})"

    unalias nproc
}

# Test critical state. This test is not OS specific.
# We test it as the Linux version, but that
# does not matter here.
function testLoadSegmentCriticalState() {
    # Prepare loadavg
    mkdir proc
    echo "2.81 0.01 0.05 1/87 8641" > proc/loadavg

    alias nproc="echo 4"
    local POWERLEVEL9K_LOAD_WHICH=1

    # Load Powerlevel9k
    source ${P9K_HOME}/powerlevel9k.zsh-theme
    local OS="Linux" # Fake Linux

    assertEquals "%K{001} %F{000}L %f%F{000}2.81 " "$(prompt_load left 1 false ${FOLDER})"

    unalias nproc
}

source shunit2/shunit2
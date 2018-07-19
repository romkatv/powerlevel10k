#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"
  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  P9K_HOME=$(pwd)
  ### Test specific
  # Create default folder and git init it.
  FOLDER=/tmp/powerlevel9k-test/swap-test
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

function testSwapSegmentWorksOnOsx() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(swap)
    local OS="OSX" # Fake OSX
    sysctl() {
        echo "vm.swapusage: total = 3072,00M  used = 1620,50M  free = 1451,50M  (encrypted)"
    }

    assertEquals "%K{yellow} %F{black%}SWP %f%F{black}1.58G " "$(prompt_swap left 1 false ${FOLDER})"

    unfunction sysctl
}

function testSwapSegmentWorksOnLinux() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(swap)
    local OS="Linux" # Fake Linux
    mkdir proc
    echo "SwapTotal: 1000000" > proc/meminfo
    echo "SwapFree: 1000" >> proc/meminfo

    assertEquals "%K{yellow} %F{black%}SWP %f%F{black}0.95G " "$(prompt_swap left 1 false ${FOLDER})"
}

source shunit2/source/2.1/src/shunit2
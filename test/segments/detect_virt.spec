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

function testDetectVirtSegmentPrintsNothingIfSystemdIsNotAvailable() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(detect_virt custom_world)
    local POWERLEVEL9K_CUSTOM_WORLD='echo world'
    alias systemd-detect-virt="novirt"

    # Load Powerlevel9k
    source powerlevel9k.zsh-theme

    assertEquals "%K{007} %F{000}world %k%F{007}%f " "$(build_left_prompt)"

    unalias systemd-detect-virt
}

function testDetectVirtSegmentIfSystemdReturnsPlainName() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(detect_virt)
    alias systemd-detect-virt="echo 'xxx'"

    # Load Powerlevel9k
    source powerlevel9k.zsh-theme

    assertEquals "%K{000} %F{003}xxx %k%F{000}%f " "$(build_left_prompt)"

    unalias systemd-detect-virt
}

function testDetectVirtSegmentIfRootFsIsOnExpectedInode() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(detect_virt)
    # Well. This is a weak test, as it fixates the implementation,
    # but it is necessary, as the implementation relys on the root
    # directory having the inode number "2"..
    alias systemd-detect-virt="echo 'none'"

    # Load Powerlevel9k
    source powerlevel9k.zsh-theme

    # The original command in the implementation is "ls -di / | grep -o 2",
    # which translates to: Show the inode number of "/" and test if it is "2".
    alias ls="echo '2'"

    assertEquals "%K{000} %F{003}none %k%F{000}%f " "$(build_left_prompt)"

    unalias ls
    unalias systemd-detect-virt
}

function testDetectVirtSegmentIfRootFsIsNotOnExpectedInode() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(detect_virt)
    # Well. This is a weak test, as it fixates the implementation,
    # but it is necessary, as the implementation relys on the root
    # directory having the inode number "2"..
    alias systemd-detect-virt="echo 'none'"

    # Load Powerlevel9k
    source powerlevel9k.zsh-theme

    # The original command in the implementation is "ls -di / | grep -o 2",
    # which translates to: Show the inode number of "/" and test if it is "2".
    alias ls="echo '3'"

    assertEquals "%K{000} %F{003}chroot %k%F{000}%f " "$(build_left_prompt)"

    unalias ls
    unalias systemd-detect-virt
}

source shunit2/shunit2
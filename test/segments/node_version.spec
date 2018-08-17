#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"
}

function testNodeVersionSegmentPrintsNothingWithoutNode() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(node_version custom_world)
    local POWERLEVEL9K_CUSTOM_WORLD='echo world'
    alias node="nonode 2>/dev/null"

    # Load Powerlevel9k
    source powerlevel9k.zsh-theme

    assertEquals "%K{007} %F{000}world %k%F{007}%f " "$(build_left_prompt)"

    unalias node
}

function testNodeVersionSegmentWorks() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(node_version)
    node() {
        echo "v1.2.3"
    }

    # Load Powerlevel9k
    source powerlevel9k.zsh-theme

    assertEquals "%K{002} %F{007}⬢ %f%F{007}1.2.3 %k%F{002}%f " "$(build_left_prompt)"

    unfunction node
}

source shunit2/shunit2
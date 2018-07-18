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

function testNodeVersionSegmentPrintsNothingWithoutNode() {
    local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(node_version custom_world)
    local POWERLEVEL9K_CUSTOM_WORLD='echo world'
    alias node="nonode 2>/dev/null"

    assertEquals "%K{white} %F{black}world %k%F{white}%f " "$(build_left_prompt)"

    unset POWERLEVEL9K_CUSTOM_WORLD
    unalias node
}

function testNodeVersionSegmentWorks() {
    local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(node_version)
    node() {
        echo "v1.2.3"
    }

    assertEquals "%K{green} %F{white%}⬢ %f%F{white}1.2.3 %k%F{green}%f " "$(build_left_prompt)"

    unfunction node
}

source shunit2/source/2.1/src/shunit2
#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"
  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  # Test specfic
  # unset all possible user specified variables
  unset NODE_VIRTUAL_ENV_DISABLE_PROMPT
  unset NODE_VIRTUAL_ENV
}

function testNodeenvSegmentPrintsNothingWithoutNode() {
    local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(nodeenv custom_world)
    local POWERLEVEL9K_CUSTOM_WORLD='echo world'
    alias node="nonode 2>/dev/null"

    assertEquals "%K{white} %F{black}world %k%F{white}%f " "$(build_left_prompt)"

    unalias node
}

function testNodeenvSegmentPrintsNothingIfNodeVirtualEnvIsNotSet() {
    local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(nodeenv custom_world)
    local POWERLEVEL9K_CUSTOM_WORLD='echo world'
    node() {
        echo "v1.2.3"
    }

    assertEquals "%K{white} %F{black}world %k%F{white}%f " "$(build_left_prompt)"

    unfunction node
}

function testNodeenvSegmentPrintsNothingIfNodeVirtualEnvDisablePromptIsSet() {
    local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(nodeenv custom_world)
    local POWERLEVEL9K_CUSTOM_WORLD='echo world'
    node() {
        echo "v1.2.3"
    }
    NODE_VIRTUAL_ENV="node-env"
    NODE_VIRTUAL_ENV_DISABLE_PROMPT=true

    assertEquals "%K{white} %F{black}world %k%F{white}%f " "$(build_left_prompt)"

    unset NODE_VIRTUAL_ENV_DISABLE_PROMPT
    unset NODE_VIRTUAL_ENV
    unfunction node
}

function testNodeenvSegmentPrintsAtLeastNodeEnvWithoutNode() {
    local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(nodeenv)
    alias node="nonode 2>/dev/null"
    NODE_VIRTUAL_ENV="node-env"

    assertEquals "%K{black} %F{green%}⬢ %f%F{green}[node-env] %k%F{black}%f " "$(build_left_prompt)"

    unset NODE_VIRTUAL_ENV
    unalias node
}

function testNodeenvSegmentWorks() {
    local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(nodeenv)
    node() {
        echo "v1.2.3"
    }
    NODE_VIRTUAL_ENV="node-env"

    assertEquals "%K{black} %F{green%}⬢ %f%F{green}v1.2.3[node-env] %k%F{black}%f " "$(build_left_prompt)"

    unfunction node
    unset NODE_VIRTUAL_ENV
}

source shunit2/source/2.1/src/shunit2
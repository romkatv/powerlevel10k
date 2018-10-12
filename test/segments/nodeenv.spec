#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"

  # Test specfic
  # unset all possible user specified variables
  unset NODE_VIRTUAL_ENV_DISABLE_PROMPT
  unset NODE_VIRTUAL_ENV
}

function testNodeenvSegmentPrintsNothingWithoutNode() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(nodeenv custom_world)
    local POWERLEVEL9K_CUSTOM_WORLD='echo world'
    alias node="nonode 2>/dev/null"

    # Load Powerlevel9k
    source powerlevel9k.zsh-theme

    assertEquals "%K{007} %F{000}world %k%F{007}%f " "$(build_left_prompt)"

    unalias node
}

function testNodeenvSegmentPrintsNothingIfNodeVirtualEnvIsNotSet() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(nodeenv custom_world)
    local POWERLEVEL9K_CUSTOM_WORLD='echo world'
    node() {
        echo "v1.2.3"
    }

    # Load Powerlevel9k
    source powerlevel9k.zsh-theme

    assertEquals "%K{007} %F{000}world %k%F{007}%f " "$(build_left_prompt)"

    unfunction node
}

function testNodeenvSegmentPrintsNothingIfNodeVirtualEnvDisablePromptIsSet() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(nodeenv custom_world)
    local POWERLEVEL9K_CUSTOM_WORLD='echo world'
    node() {
        echo "v1.2.3"
    }
    NODE_VIRTUAL_ENV="node-env"
    NODE_VIRTUAL_ENV_DISABLE_PROMPT=true

    # Load Powerlevel9k
    source powerlevel9k.zsh-theme

    assertEquals "%K{007} %F{000}world %k%F{007}%f " "$(build_left_prompt)"

    unset NODE_VIRTUAL_ENV_DISABLE_PROMPT
    unset NODE_VIRTUAL_ENV
    unfunction node
}

function testNodeenvSegmentPrintsAtLeastNodeEnvWithoutNode() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(nodeenv)
    alias node="nonode 2>/dev/null"
    NODE_VIRTUAL_ENV="node-env"

    # Load Powerlevel9k
    source powerlevel9k.zsh-theme

    assertEquals "%K{000} %F{002}⬢ %f%F{002}[node-env] %k%F{000}%f " "$(build_left_prompt)"

    unset NODE_VIRTUAL_ENV
    unalias node
}

function testNodeenvSegmentWorks() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(nodeenv)
    node() {
        echo "v1.2.3"
    }
    NODE_VIRTUAL_ENV="node-env"

    # Load Powerlevel9k
    source powerlevel9k.zsh-theme

    assertEquals "%K{000} %F{002}⬢ %f%F{002}v1.2.3[node-env] %k%F{000}%f " "$(build_left_prompt)"

    unfunction node
    unset NODE_VIRTUAL_ENV
}

source shunit2/shunit2
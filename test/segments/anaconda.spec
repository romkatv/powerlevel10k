#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"
}

function testAnacondaSegmentPrintsNothingIfNoAnacondaPathIsSet() {
    local POWERLEVEL9K_CUSTOM_WORLD='echo world'
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(anaconda custom_world)

    # Load Powerlevel9k
    source powerlevel9k.zsh-theme

    # Unset anacona variables
    unset CONDA_ENV_PATH
    unset CONDA_PREFIX

    assertEquals "%K{007} %F{000}world %k%F{007}%f " "$(build_left_prompt)"
}

function testAnacondaSegmentWorksIfOnlyAnacondaPathIsSet() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(anaconda)
    local POWERLEVEL9K_PYTHON_ICON="icon-here"

    # Load Powerlevel9k
    source powerlevel9k.zsh-theme

    CONDA_ENV_PATH=/tmp
    unset CONDA_PREFIX

    assertEquals "%K{004} %F{000}icon-here %f%F{000}(tmp) %k%F{004}%f " "$(build_left_prompt)"
}

function testAnacondaSegmentWorksIfOnlyAnacondaPrefixIsSet() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(anaconda)
    local POWERLEVEL9K_PYTHON_ICON="icon-here"

    # Load Powerlevel9k
    source powerlevel9k.zsh-theme

    unset CONDA_ENV_PATH
    local CONDA_PREFIX="test"

    assertEquals "%K{004} %F{000}icon-here %f%F{000}(test) %k%F{004}%f " "$(build_left_prompt)"
}

function testAnacondaSegmentWorks() {
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(anaconda)
    local POWERLEVEL9K_PYTHON_ICON="icon-here"

    # Load Powerlevel9k
    source powerlevel9k.zsh-theme

    local CONDA_ENV_PATH=/tmp
    local CONDA_PREFIX="test"

    assertEquals "%K{004} %F{000}icon-here %f%F{000}(tmptest) %k%F{004}%f " "$(build_left_prompt)"
}

source shunit2/shunit2
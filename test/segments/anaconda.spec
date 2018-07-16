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

function testAnacondaSegmentPrintsNothingIfNoAnacondaPathIsSet() {
    local POWERLEVEL9K_CUSTOM_WORLD='echo world'
    local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(anaconda custom_world)
    # Unset anacona variables
    unset CONDA_ENV_PATH
    unset CONDA_PREFIX

    assertEquals "%K{white} %F{black}world %k%F{white}%f " "$(build_left_prompt)"
}

function testAnacondaSegmentWorksIfOnlyAnacondaPathIsSet() {
    CONDA_ENV_PATH=/tmp
    unset CONDA_PREFIX
    local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(anaconda)
    local POWERLEVEL9K_PYTHON_ICON="icon-here"

    assertEquals "%K{blue} %F{black%}icon-here %f%F{black}(tmp) %k%F{blue}%f " "$(build_left_prompt)"
}

function testAnacondaSegmentWorksIfOnlyAnacondaPrefixIsSet() {
    unset CONDA_ENV_PATH
    local CONDA_PREFIX="test"
    local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(anaconda)
    local POWERLEVEL9K_PYTHON_ICON="icon-here"

    assertEquals "%K{blue} %F{black%}icon-here %f%F{black}(test) %k%F{blue}%f " "$(build_left_prompt)"
}

function testAnacondaSegmentWorks() {
    local CONDA_ENV_PATH=/tmp
    local CONDA_PREFIX="test"
    local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(anaconda)
    local POWERLEVEL9K_PYTHON_ICON="icon-here"

    assertEquals "%K{blue} %F{black%}icon-here %f%F{black}(tmptest) %k%F{blue}%f " "$(build_left_prompt)"

}

source shunit2/source/2.1/src/shunit2
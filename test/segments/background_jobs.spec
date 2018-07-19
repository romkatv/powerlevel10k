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

function testBackgroundJobsSegmentPrintsNothingWithoutBackgroundJobs() {
    local POWERLEVEL9K_CUSTOM_WORLD='echo world'
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(background_jobs custom_world)
    alias jobs="nojobs 2>/dev/null"

    assertEquals "%K{white} %F{black}world %k%F{white}%f " "$(build_left_prompt)"

    unalias jobs
}

function testBackgroundJobsSegmentWorksWithOneBackgroundJob() {
    unset POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(background_jobs)
    jobs() {
        echo '[1]  + 30444 suspended  nvim xx'
    }

    assertEquals "%K{black} %F{cyan%}⚙%f %k%F{black}%f " "$(build_left_prompt)"

    unfunction jobs
}

function testBackgroundJobsSegmentWorksWithMultipleBackgroundJobs() {
    unset POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(background_jobs)
    jobs() {
        echo "[1]    31190 suspended  nvim xx"
        echo "[2]  - 31194 suspended  nvim xx2"
        echo "[3]  + 31206 suspended  nvim xx3"
    }

    assertEquals "%K{black} %F{cyan%}⚙%f %k%F{black}%f " "$(build_left_prompt)"

    unfunction jobs
}

function testBackgroundJobsSegmentWithVerboseMode() {
    local POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=true
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(background_jobs)
    jobs() {
        echo "[1]    31190 suspended  nvim xx"
        echo "[2]  - 31194 suspended  nvim xx2"
        echo "[3]  + 31206 suspended  nvim xx3"
    }

    assertEquals "%K{black} %F{cyan%}⚙ %f%F{cyan}3 %k%F{black}%f " "$(build_left_prompt)"

    unfunction jobs
}

source shunit2/source/2.1/src/shunit2
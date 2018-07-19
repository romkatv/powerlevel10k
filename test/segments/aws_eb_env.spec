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

function testAwsEbEnvSegmentPrintsNothingIfNoElasticBeanstalkEnvironmentIsSet() {
    local POWERLEVEL9K_CUSTOM_WORLD='echo world'
    local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(aws_eb_env custom_world)

    assertEquals "%K{white} %F{black}world %k%F{white}%f " "$(build_left_prompt)"
}

function testAwsEbEnvSegmentWorksIfElasticBeanstalkEnvironmentIsSet() {
    mkdir -p /tmp/powerlevel9k-test/.elasticbeanstalk
    echo "test:\n    environment: test" > /tmp/powerlevel9k-test/.elasticbeanstalk/config.yml
    cd /tmp/powerlevel9k-test

    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(aws_eb_env)

    assertEquals "%K{black} %F{green%}🌱  %f%F{green}test %k%F{black}%f " "$(build_left_prompt)"

    rm -fr /tmp/powerlevel9k-test
    cd -
}

function testAwsEbEnvSegmentWorksIfElasticBeanstalkEnvironmentIsSetInParentDirectory() {
    # Skip test, because currently we cannot detect
    # if the configuration is in a parent directory
    startSkipping # Skip test
    mkdir -p /tmp/powerlevel9k-test/.elasticbeanstalk
    mkdir -p /tmp/powerlevel9k-test/1/12/123/1234/12345
    echo "test:\n    environment: test" > /tmp/powerlevel9k-test/.elasticbeanstalk/config.yml
    cd /tmp/powerlevel9k-test/1/12/123/1234/12345

    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(aws_eb_env)

    assertEquals "%K{black} %F{green%}🌱  %f%F{green}test %k%F{black}%f " "$(build_left_prompt)"

    rm -fr /tmp/powerlevel9k-test
    cd -
}

source shunit2/source/2.1/src/shunit2
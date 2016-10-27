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

function testTruncateFoldersWorks() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  POWERLEVEL9K_SHORTEN_STRATEGY='truncate_folders'

  FOLDER=/tmp/powerlevel9k-test/1/12/123/1234/12345/123456/1234567/12345678/123456789
  mkdir -p $FOLDER
  cd $FOLDER

  assertEquals "%K{blue} %F{black}%3(c:…/:)%2c %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test

  unset FOLDER
  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_SHORTEN_DIR_LENGTH
  unset POWERLEVEL9K_SHORTEN_STRATEGY
}

function testTruncateMiddleWorks() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  POWERLEVEL9K_SHORTEN_STRATEGY='truncate_middle'

  FOLDER=/tmp/powerlevel9k-test/1/12/123/1234/12345/123456/1234567/12345678/123456789
  mkdir -p $FOLDER
  cd $FOLDER

  assertEquals "%K{blue} %F{black}/tmp/po…st/1/12/123/1234/12…45/12…56/12…67/12…78/123456789 %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test

  unset FOLDER
  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_SHORTEN_DIR_LENGTH
  unset POWERLEVEL9K_SHORTEN_STRATEGY
}

function testTruncationFromRightWorks() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  POWERLEVEL9K_SHORTEN_STRATEGY='truncate_from_right'

  FOLDER=/tmp/powerlevel9k-test/1/12/123/1234/12345/123456/1234567/12345678/123456789
  mkdir -p $FOLDER
  cd $FOLDER

  assertEquals "%K{blue} %F{black}/tmp/po…/1/12/123/12…/12…/12…/12…/12…/123456789 %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test

  unset FOLDER
  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_SHORTEN_DIR_LENGTH
  unset POWERLEVEL9K_SHORTEN_STRATEGY
}

function testHomeFolderDetectionWorks() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  POWERLEVEL9K_HOME_ICON='home-icon'

  cd ~
  assertEquals "%K{blue} %F{black%}home-icon%f %F{black}%~ %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_HOME_ICON
}

function testHomeSubfolderDetectionWorks() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  POWERLEVEL9K_HOME_SUB_ICON='sub-icon'

  FOLDER=~/powerlevel9k-test
  mkdir $FOLDER
  cd $FOLDER
  assertEquals "%K{blue} %F{black%}sub-icon%f %F{black}%~ %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  rm -fr $FOLDER
  unset FOLDER
  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_HOME_SUB_ICON
}

function testOtherFolderDetectionWorks() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  POWERLEVEL9K_FOLDER_ICON='folder-icon'

  FOLDER=/tmp/powerlevel9k-test
  mkdir $FOLDER
  cd $FOLDER
  assertEquals "%K{blue} %F{black%}folder-icon%f %F{black}%~ %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  rm -fr $FOLDER
  unset FOLDER
  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_FOLDER_ICON
}

source shunit2/source/2.1/src/shunit2

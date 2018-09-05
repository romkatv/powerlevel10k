#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"

  P9K_HOME="${PWD}"
}

function tearDown() {
  unset P9K_HOME
}

function testDirPathAbsoluteWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_DIR_PATH_ABSOLUTE=true

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  cd ~

  # Unfortunately, we cannot fake Linux or OSX here, because
  # of /home or /Users path.. That is why we change the test
  # according to the OS of the host.
  if [[ "${OS}" == 'Linux' ]]; then
    assertEquals "%K{004} %F{000}/home/${USER} %k%F{004}%f " "$(build_left_prompt)"
  elif [[ "${OS}" == 'OSX' ]]; then
    assertEquals "%K{004} %F{000}/Users/${USER} %k%F{004}%f " "$(build_left_prompt)"
  fi

  cd -
}

function testTruncateFoldersWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  local POWERLEVEL9K_SHORTEN_STRATEGY='truncate_folders'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  local FOLDER=/tmp/powerlevel9k-test/1/12/123/1234/12345/123456/1234567/12345678/123456789
  mkdir -p $FOLDER
  cd $FOLDER

  assertEquals "%K{004} %F{000}…/12345678/123456789 %k%F{004}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test
}

function testTruncateFolderWithHomeDirWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  local CURRENT_DIR=$(pwd)

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  cd ~
  local FOLDER="powerlevel9k-test-${RANDOM}"
  mkdir -p $FOLDER
  cd $FOLDER
  # Switch back to home folder as this causes the problem.
  cd ..

  assertEquals "%K{004} %F{000}~ %k%F{004}%f " "$(build_left_prompt)"

  rmdir $FOLDER
  cd ${CURRENT_DIR}
}

function testTruncateMiddleWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  local POWERLEVEL9K_SHORTEN_STRATEGY='truncate_middle'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  local FOLDER=/tmp/powerlevel9k-test/1/12/123/1234/12345/123456/1234567/12345678/123456789
  mkdir -p $FOLDER
  cd $FOLDER

  assertEquals "%K{004} %F{000}/tmp/po…st/1/12/123/1234/12…45/12…56/12…67/12…78/123456789 %k%F{004}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test
}

function testTruncationFromRightWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  local POWERLEVEL9K_SHORTEN_STRATEGY='truncate_from_right'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  local FOLDER=/tmp/powerlevel9k-test/1/12/123/1234/12345/123456/1234567/12345678/123456789
  mkdir -p $FOLDER
  cd $FOLDER

  assertEquals "%K{004} %F{000}/tmp/po…/1/12/123/12…/12…/12…/12…/12…/123456789 %k%F{004}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test
}

function testTruncateToLastWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  local POWERLEVEL9K_SHORTEN_STRATEGY="truncate_to_last"

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  local FOLDER=/tmp/powerlevel9k-test/1/12/123/1234/12345/123456/1234567/12345678/123456789
  mkdir -p $FOLDER
  cd $FOLDER

  assertEquals "%K{004} %F{000}123456789 %k%F{004}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test
}

function testTruncateToFirstAndLastWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  local POWERLEVEL9K_SHORTEN_STRATEGY="truncate_to_first_and_last"

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  local FOLDER=/tmp/powerlevel9k-test/1/12/123/1234/12345/123456/1234567/12345678/123456789
  mkdir -p $FOLDER
  cd $FOLDER

  assertEquals "%K{004} %F{000}/tmp/powerlevel9k-test/…/…/…/…/…/…/…/12345678/123456789 %k%F{004}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test
}

function testTruncateAbsoluteWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  local POWERLEVEL9K_SHORTEN_STRATEGY="truncate_absolute"

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  local FOLDER=/tmp/powerlevel9k-test/1/12/123/1234/12345/123456/1234567/12345678/123456789
  mkdir -p $FOLDER
  cd $FOLDER

  assertEquals "%K{004} %F{000}…89 %k%F{004}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test
}

function testTruncationFromRightWithEmptyDelimiter() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  local POWERLEVEL9K_SHORTEN_DELIMITER=""
  local POWERLEVEL9K_SHORTEN_STRATEGY='truncate_from_right'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  local FOLDER=/tmp/powerlevel9k-test/1/12/123/1234/12345/123456/1234567/12345678/123456789
  mkdir -p $FOLDER
  cd $FOLDER

  assertEquals "%K{004} %F{000}/tmp/po/1/12/123/12/12/12/12/12/123456789 %k%F{004}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test
}

function testTruncateWithFolderMarkerWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_SHORTEN_STRATEGY="truncate_with_folder_marker"

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  local BASEFOLDER=/tmp/powerlevel9k-test
  local FOLDER=$BASEFOLDER/1/12/123/1234/12345/123456/1234567
  mkdir -p $FOLDER
  # Setup folder marker
  touch $BASEFOLDER/1/12/.shorten_folder_marker
  cd $FOLDER
  assertEquals "%K{004} %F{000}/…/12/123/1234/12345/123456/1234567 %k%F{004}%f " "$(build_left_prompt)"

  cd -
  rm -fr $BASEFOLDER
}

function testTruncateWithFolderMarkerWithChangedFolderMarker() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_SHORTEN_STRATEGY="truncate_with_folder_marker"
  local POWERLEVEL9K_SHORTEN_FOLDER_MARKER='.xxx'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  local BASEFOLDER=/tmp/powerlevel9k-test
  local FOLDER=$BASEFOLDER/1/12/123/1234/12345/123456/1234567
  mkdir -p $FOLDER
  # Setup folder marker
  touch $BASEFOLDER/1/12/.xxx
  cd $FOLDER
  assertEquals "%K{004} %F{000}/…/12/123/1234/12345/123456/1234567 %k%F{004}%f " "$(build_left_prompt)"

  cd -
  rm -fr $BASEFOLDER
}

function testTruncateWithPackageNameWorks() {
  local p9kFolder=$(pwd)
  local BASEFOLDER=/tmp/powerlevel9k-test
  local FOLDER=$BASEFOLDER/1/12/123/1234/12345/123456/1234567/12345678/123456789
  mkdir -p $FOLDER

  cd /tmp/powerlevel9k-test
  echo '
{
  "name": "My_Package"
}
' > package.json
  # Unfortunately: The main folder must be a git repo..
  git init &>/dev/null

  # Go back to deeper folder
  cd "${FOLDER}"

  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  local POWERLEVEL9K_SHORTEN_STRATEGY='truncate_with_package_name'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{004} %F{000}My_Package/1/12/123/12…/12…/12…/12…/12…/123456789 %k%F{004}%f " "$(build_left_prompt)"

  # Go back
  cd $p9kFolder
  rm -fr $BASEFOLDER
}

function testTruncateWithPackageNameIfRepoIsSymlinkedInsideDeepFolder() {
  local p9kFolder=$(pwd)
  local BASEFOLDER=/tmp/powerlevel9k-test
  local FOLDER=$BASEFOLDER/1/12/123/1234/12345/123456/1234567/12345678/123456789
  mkdir -p $FOLDER
  cd $FOLDER

  # Unfortunately: The main folder must be a git repo..
  git init &>/dev/null

  echo '
{
  "name": "My_Package"
}
' > package.json

  # Create a subdir inside the repo
  mkdir -p asdfasdf/qwerqwer

  cd $BASEFOLDER
  ln -s ${FOLDER} linked-repo

  # Go to deep folder inside linked repo
  cd linked-repo/asdfasdf/qwerqwer

  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  local POWERLEVEL9K_SHORTEN_STRATEGY='truncate_with_package_name'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{004} %F{000}My_Package/as…/qwerqwer %k%F{004}%f " "$(build_left_prompt)"

  # Go back
  cd $p9kFolder
  rm -fr $BASEFOLDER
}

function testTruncateWithPackageNameIfRepoIsSymlinkedInsideGitDir() {
  local p9kFolder=$(pwd)
  local BASEFOLDER=/tmp/powerlevel9k-test
  local FOLDER=$BASEFOLDER/1/12/123/1234/12345/123456/1234567/12345678/123456789
  mkdir -p $FOLDER
  cd $FOLDER

  # Unfortunately: The main folder must be a git repo..
  git init &>/dev/null

  echo '
{
  "name": "My_Package"
}
' > package.json

  cd $BASEFOLDER
  ln -s ${FOLDER} linked-repo

  cd linked-repo/.git/refs/heads

  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  local POWERLEVEL9K_SHORTEN_STRATEGY='truncate_with_package_name'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{004} %F{000}My_Package/.g…/re…/heads %k%F{004}%f " "$(build_left_prompt)"

  # Go back
  cd $p9kFolder
  rm -fr $BASEFOLDER
}

function testHomeFolderDetectionWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_HOME_ICON='home-icon'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  cd ~
  assertEquals "%K{004} %F{000}home-icon %f%F{000}~ %k%F{004}%f " "$(build_left_prompt)"

  cd -
}

function testHomeSubfolderDetectionWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_HOME_SUB_ICON='sub-icon'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  local FOLDER=~/powerlevel9k-test
  mkdir $FOLDER
  cd $FOLDER
  assertEquals "%K{004} %F{000}sub-icon %f%F{000}~/powerlevel9k-test %k%F{004}%f " "$(build_left_prompt)"

  cd -
  rm -fr $FOLDER
}

function testOtherFolderDetectionWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_FOLDER_ICON='folder-icon'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  local FOLDER=/tmp/powerlevel9k-test
  mkdir $FOLDER
  cd $FOLDER
  assertEquals "%K{004} %F{000}folder-icon %f%F{000}/tmp/powerlevel9k-test %k%F{004}%f " "$(build_left_prompt)"

  cd -
  rm -fr $FOLDER
}

function testChangingDirPathSeparator() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_DIR_PATH_SEPARATOR='xXx'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  local FOLDER="/tmp/powerlevel9k-test/1/2"
  mkdir -p $FOLDER
  cd $FOLDER

  assertEquals "%K{004} %F{000}xXxtmpxXxpowerlevel9k-testxXx1xXx2 %k%F{004}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test
}

function testHomeFolderAbbreviation() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local dir=$PWD

  cd ~/
  # default
  local POWERLEVEL9K_HOME_FOLDER_ABBREVIATION='~'
  
  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{004} %F{000}~ %k%F{004}%f " "$(build_left_prompt)"

  # substituted
  local POWERLEVEL9K_HOME_FOLDER_ABBREVIATION='qQq'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{004} %F{000}qQq %k%F{004}%f " "$(build_left_prompt)"

  cd /tmp
  # default
  local POWERLEVEL9K_HOME_FOLDER_ABBREVIATION='~'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{004} %F{000}/tmp %k%F{004}%f " "$(build_left_prompt)"

  # substituted
  local POWERLEVEL9K_HOME_FOLDER_ABBREVIATION='qQq'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{004} %F{000}/tmp %k%F{004}%f " "$(build_left_prompt)"

  cd "$dir"
}

function testOmittingFirstCharacterWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER=true
  local POWERLEVEL9K_FOLDER_ICON='folder-icon'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  cd /tmp

  assertEquals "%K{004} %F{000}folder-icon %f%F{000}tmp %k%F{004}%f " "$(build_left_prompt)"

  cd -
}

function testOmittingFirstCharacterWorksWithChangingPathSeparator() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER=true
  local POWERLEVEL9K_DIR_PATH_SEPARATOR='xXx'
  local POWERLEVEL9K_FOLDER_ICON='folder-icon'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  mkdir -p /tmp/powerlevel9k-test/1/2
  cd /tmp/powerlevel9k-test/1/2

  assertEquals "%K{004} %F{000}folder-icon %f%F{000}tmpxXxpowerlevel9k-testxXx1xXx2 %k%F{004}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test
}

# This test makes it obvious that combining a truncation strategy
# that cuts off folders from the left and omitting the the first
# character does not make much sense. The truncation strategy
# comes first, prints an ellipsis and that gets then cut off by
# POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER..
# But it does more sense in combination with other truncation
# strategies.
function testOmittingFirstCharacterWorksWithChangingPathSeparatorAndDefaultTruncation() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER=true
  local POWERLEVEL9K_DIR_PATH_SEPARATOR='xXx'
  local POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  local POWERLEVEL9K_SHORTEN_STRATEGY='truncate_folders'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  mkdir -p /tmp/powerlevel9k-test/1/2
  cd /tmp/powerlevel9k-test/1/2

  assertEquals "%K{004} %F{000}xXx1xXx2 %k%F{004}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test
}

function testOmittingFirstCharacterWorksWithChangingPathSeparatorAndMiddleTruncation() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER=true
  local POWERLEVEL9K_DIR_PATH_SEPARATOR='xXx'
  local POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  local POWERLEVEL9K_SHORTEN_STRATEGY='truncate_middle'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  mkdir -p /tmp/powerlevel9k-test/1/2
  cd /tmp/powerlevel9k-test/1/2

  assertEquals "%K{004} %F{000}tmpxXxpo…stxXx1xXx2 %k%F{004}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test
}

function testOmittingFirstCharacterWorksWithChangingPathSeparatorAndRightTruncation() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER=true
  local POWERLEVEL9K_DIR_PATH_SEPARATOR='xXx'
  local POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  local POWERLEVEL9K_SHORTEN_STRATEGY='truncate_from_right'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  mkdir -p /tmp/powerlevel9k-test/1/2
  cd /tmp/powerlevel9k-test/1/2

  assertEquals "%K{004} %F{000}tmpxXxpo…xXx1xXx2 %k%F{004}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test
}

function testTruncateToUniqueWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER=true
  local POWERLEVEL9K_DIR_PATH_SEPARATOR='xXx'
  local POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  local POWERLEVEL9K_SHORTEN_STRATEGY='truncate_to_unique'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  mkdir -p /tmp/powerlevel9k-test/adam/devl
  mkdir -p /tmp/powerlevel9k-test/alice/devl
  mkdir -p /tmp/powerlevel9k-test/alice/docs
  mkdir -p /tmp/powerlevel9k-test/bob/docs
  cd /tmp/powerlevel9k-test/alice/devl

  assertEquals "%K{004} %F{000}txXxpxXxalxXxde %k%F{004}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test
}

function testBoldHomeDirWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_DIR_PATH_HIGHLIGHT_BOLD=true

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  cd ~

  assertEquals "%K{004} %F{000}%B~%b %k%F{004}%f " "$(build_left_prompt)"

  cd -
}

function testBoldHomeSubdirWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_DIR_PATH_HIGHLIGHT_BOLD=true

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  mkdir -p ~/powerlevel9k-test
  cd ~/powerlevel9k-test

  assertEquals "%K{004} %F{000}~/%Bpowerlevel9k-test%b %k%F{004}%f " "$(build_left_prompt)"

  cd -
  rm -fr ~/powerlevel9k-test
}

function testBoldRootDirWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_DIR_PATH_HIGHLIGHT_BOLD=true

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  cd /

  assertEquals "%K{004} %F{000}%B/%b %k%F{004}%f " "$(build_left_prompt)"

  cd -
}

function testBoldRootSubdirWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_DIR_PATH_HIGHLIGHT_BOLD=true

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  cd /tmp

  assertEquals "%K{004} %F{000}/%Btmp%b %k%F{004}%f " "$(build_left_prompt)"

  cd -
}

function testBoldRootSubSubdirWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_DIR_PATH_HIGHLIGHT_BOLD=true

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  mkdir -p /tmp/powerlevel9k-test
  cd /tmp/powerlevel9k-test

  assertEquals "%K{004} %F{000}/tmp/%Bpowerlevel9k-test%b %k%F{004}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test
}

function testHighlightHomeWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND='red'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  cd ~

  assertEquals "%K{004} %F{000}%F{red}~ %k%F{004}%f " "$(build_left_prompt)"

  cd -
}

function testHighlightHomeSubdirWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND='red'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  mkdir -p ~/powerlevel9k-test
  cd ~/powerlevel9k-test

  assertEquals "%K{004} %F{000}~/%F{red}powerlevel9k-test %k%F{004}%f " "$(build_left_prompt)"

  cd -
  rm -fr ~/powerlevel9k-test
}

function testHighlightRootWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND='red'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  cd /

  assertEquals "%K{004} %F{000}%F{red}/ %k%F{004}%f " "$(build_left_prompt)"

  cd -
}

function testHighlightRootSubdirWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND='red'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  cd /tmp

  assertEquals "%K{004} %F{000}/%F{red}tmp %k%F{004}%f " "$(build_left_prompt)"

  cd -
}

function testHighlightRootSubSubdirWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND='red'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  mkdir /tmp/powerlevel9k-test
  cd /tmp/powerlevel9k-test

  assertEquals "%K{004} %F{000}/tmp/%F{red}powerlevel9k-test %k%F{004}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test
}

function testDirSeparatorColorHomeSubdirWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_DIR_PATH_SEPARATOR_FOREGROUND='red'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  mkdir -p ~/powerlevel9k-test
  cd ~/powerlevel9k-test

  assertEquals "%K{004} %F{000}~%F{red}/%F{black}powerlevel9k-test %k%F{004}%f " "$(build_left_prompt)"

  cd -
  rm -fr ~/powerlevel9k-test
}

function testDirSeparatorColorRootSubSubdirWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  local POWERLEVEL9K_DIR_PATH_SEPARATOR_FOREGROUND='red'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  mkdir -p /tmp/powerlevel9k-test
  cd /tmp/powerlevel9k-test

  assertEquals "%K{004} %F{000}%F{red}/%F{black}tmp%F{red}/%F{black}powerlevel9k-test %k%F{004}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test
}

source shunit2/shunit2

#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"
  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  # Every test should at least use the dir segment
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
}

function tearDown() {
  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
}

function testDirPathAbsoluteWorks() {
  POWERLEVEL9K_DIR_PATH_ABSOLUTE=true

  cd ~
  assertEquals "%K{blue} %F{black}/home/travis %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  unset POWERLEVEL9K_DIR_PATH_ABSOLUTE
}

function testTruncateFoldersWorks() {
  POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  POWERLEVEL9K_SHORTEN_STRATEGY='truncate_folders'

  FOLDER=/tmp/powerlevel9k-test/1/12/123/1234/12345/123456/1234567/12345678/123456789
  mkdir -p $FOLDER
  cd $FOLDER

  assertEquals "%K{blue} %F{black}…/12345678/123456789 %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test

  unset FOLDER
  unset POWERLEVEL9K_SHORTEN_DIR_LENGTH
  unset POWERLEVEL9K_SHORTEN_STRATEGY
}

function testTruncateFolderWithHomeDirWorks() {
  POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  CURRENT_DIR=$(pwd)

  cd ~
  FOLDER="powerlevel9k-test-${RANDOM}"
  mkdir -p $FOLDER
  cd $FOLDER
  # Switch back to home folder as this causes the problem.
  cd ..

  assertEquals "%K{blue} %F{black}~ %k%F{blue}%f " "$(build_left_prompt)"

  rmdir $FOLDER
  cd ${CURRENT_DIR}

  unset CURRENT_DIR
  unset FOLDER
  unset POWERLEVEL9K_SHORTEN_DIR_LENGTH
}

function testTruncateMiddleWorks() {
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
  unset POWERLEVEL9K_SHORTEN_STRATEGY
}

function testTruncationFromRightWorks() {
  POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  POWERLEVEL9K_SHORTEN_STRATEGY='truncate_from_right'

  FOLDER=/tmp/powerlevel9k-test/1/12/123/1234/12345/123456/1234567/12345678/123456789
  mkdir -p $FOLDER
  cd $FOLDER

  assertEquals "%K{blue} %F{black}/tmp/po…/1/12/123/12…/12…/12…/12…/12…/123456789 %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test

  unset FOLDER
  unset POWERLEVEL9K_SHORTEN_DIR_LENGTH
  unset POWERLEVEL9K_SHORTEN_STRATEGY
}

function testTruncateToLastWorks() {
  POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  POWERLEVEL9K_SHORTEN_STRATEGY="truncate_to_last"

  FOLDER=/tmp/powerlevel9k-test/1/12/123/1234/12345/123456/1234567/12345678/123456789
  mkdir -p $FOLDER
  cd $FOLDER

  assertEquals "%K{blue} %F{black}123456789 %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test

  unset FOLDER
  unset POWERLEVEL9K_SHORTEN_DIR_LENGTH
  unset POWERLEVEL9K_SHORTEN_STRATEGY
}

function testTruncateToFirstAndLastWorks() {
  POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  POWERLEVEL9K_SHORTEN_STRATEGY="truncate_to_first_and_last"

  FOLDER=/tmp/powerlevel9k-test/1/12/123/1234/12345/123456/1234567/12345678/123456789
  mkdir -p $FOLDER
  cd $FOLDER

  assertEquals "%K{blue} %F{black}/tmp/powerlevel9k-test/…/…/…/…/…/…/…/12345678/123456789 %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test

  unset FOLDER
  unset POWERLEVEL9K_SHORTEN_DIR_LENGTH
  unset POWERLEVEL9K_SHORTEN_STRATEGY
}

function testTruncateAbsoluteWorks() {
  POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  POWERLEVEL9K_SHORTEN_STRATEGY="truncate_absolute"

  FOLDER=/tmp/powerlevel9k-test/1/12/123/1234/12345/123456/1234567/12345678/123456789
  mkdir -p $FOLDER
  cd $FOLDER

  assertEquals "%K{blue} %F{black}…89 %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test

  unset FOLDER
  unset POWERLEVEL9K_SHORTEN_DIR_LENGTH
  unset POWERLEVEL9K_SHORTEN_STRATEGY
}

function testTruncationFromRightWithEmptyDelimiter() {
  POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  POWERLEVEL9K_SHORTEN_DELIMITER=""
  POWERLEVEL9K_SHORTEN_STRATEGY='truncate_from_right'

  FOLDER=/tmp/powerlevel9k-test/1/12/123/1234/12345/123456/1234567/12345678/123456789
  mkdir -p $FOLDER
  cd $FOLDER

  assertEquals "%K{blue} %F{black}/tmp/po/1/12/123/12/12/12/12/12/123456789 %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test

  unset FOLDER
  unset POWERLEVEL9K_SHORTEN_DIR_LENGTH
  unset POWERLEVEL9K_SHORTEN_DELIMITER
  unset POWERLEVEL9K_SHORTEN_STRATEGY
}

function testTruncateWithFolderMarkerWorks() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  POWERLEVEL9K_SHORTEN_STRATEGY="truncate_with_folder_marker"

  local BASEFOLDER=/tmp/powerlevel9k-test
  local FOLDER=$BASEFOLDER/1/12/123/1234/12345/123456/1234567
  mkdir -p $FOLDER
  # Setup folder marker
  touch $BASEFOLDER/1/12/.shorten_folder_marker
  cd $FOLDER
  assertEquals "%K{blue} %F{black}/…/12/123/1234/12345/123456/1234567 %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  rm -fr $BASEFOLDER
  unset BASEFOLDER
  unset FOLDER
  unset POWERLEVEL9K_SHORTEN_STRATEGY
  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
}

function testTruncateWithFolderMarkerWithChangedFolderMarker() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  POWERLEVEL9K_SHORTEN_STRATEGY="truncate_with_folder_marker"
  POWERLEVEL9K_SHORTEN_FOLDER_MARKER='.xxx'

  local BASEFOLDER=/tmp/powerlevel9k-test
  local FOLDER=$BASEFOLDER/1/12/123/1234/12345/123456/1234567
  mkdir -p $FOLDER
  # Setup folder marker
  touch $BASEFOLDER/1/12/.xxx
  cd $FOLDER
  assertEquals "%K{blue} %F{black}/…/12/123/1234/12345/123456/1234567 %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  rm -fr $BASEFOLDER
  unset BASEFOLDER
  unset FOLDER
  unset POWERLEVEL9K_SHORTEN_FOLDER_MARKER
  unset POWERLEVEL9K_SHORTEN_STRATEGY
  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
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

  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  POWERLEVEL9K_SHORTEN_STRATEGY='truncate_with_package_name'

  assertEquals "%K{blue} %F{black}My_Package/1/12/123/12…/12…/12…/12…/12…/123456789 %k%F{blue}%f " "$(build_left_prompt)"

  # Go back
  cd $p9kFolder
  rm -fr $BASEFOLDER
  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_SHORTEN_STRATEGY
  unset POWERLEVEL9K_SHORTEN_DIR_LENGTH
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

  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  POWERLEVEL9K_SHORTEN_STRATEGY='truncate_with_package_name'

  assertEquals "%K{blue} %F{black}My_Package/as…/qwerqwer %k%F{blue}%f " "$(build_left_prompt)"

  # Go back
  cd $p9kFolder
  rm -fr $BASEFOLDER
  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_SHORTEN_STRATEGY
  unset POWERLEVEL9K_SHORTEN_DIR_LENGTH
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

  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
  POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  POWERLEVEL9K_SHORTEN_STRATEGY='truncate_with_package_name'

  assertEquals "%K{blue} %F{black}My_Package/.g…/re…/heads %k%F{blue}%f " "$(build_left_prompt)"

  # Go back
  cd $p9kFolder
  rm -fr $BASEFOLDER
  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_SHORTEN_STRATEGY
  unset POWERLEVEL9K_SHORTEN_DIR_LENGTH
}

function testHomeFolderDetectionWorks() {
  POWERLEVEL9K_HOME_ICON='home-icon'

  cd ~
  assertEquals "%K{blue} %F{black%}home-icon %f%F{black}~ %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  unset POWERLEVEL9K_HOME_ICON
}

function testHomeSubfolderDetectionWorks() {
  POWERLEVEL9K_HOME_SUB_ICON='sub-icon'

  FOLDER=~/powerlevel9k-test
  mkdir $FOLDER
  cd $FOLDER
  assertEquals "%K{blue} %F{black%}sub-icon %f%F{black}~/powerlevel9k-test %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  rm -fr $FOLDER
  unset FOLDER
  unset POWERLEVEL9K_HOME_SUB_ICON
}

function testOtherFolderDetectionWorks() {
  POWERLEVEL9K_FOLDER_ICON='folder-icon'

  FOLDER=/tmp/powerlevel9k-test
  mkdir $FOLDER
  cd $FOLDER
  assertEquals "%K{blue} %F{black%}folder-icon %f%F{black}/tmp/powerlevel9k-test %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  rm -fr $FOLDER
  unset FOLDER
  unset POWERLEVEL9K_FOLDER_ICON
}

function testChangingDirPathSeparator() {
  POWERLEVEL9K_DIR_PATH_SEPARATOR='xXx'
  local FOLDER="/tmp/powerlevel9k-test/1/2"
  mkdir -p $FOLDER
  cd $FOLDER

  assertEquals "%K{blue} %F{black}xXxtmpxXxpowerlevel9k-testxXx1xXx2 %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  unset FOLDER
  rm -fr /tmp/powerlevel9k-test
  unset POWERLEVEL9K_DIR_PATH_SEPARATOR
}

function testHomeFolderAbbreviation() {
  local POWERLEVEL9K_HOME_FOLDER_ABBREVIATION
  local dir=$PWD

  cd ~/
  # default
  POWERLEVEL9K_HOME_FOLDER_ABBREVIATION='~'
  assertEquals "%K{blue} %F{black}~ %k%F{blue}%f " "$(build_left_prompt)"

  # substituted
  POWERLEVEL9K_HOME_FOLDER_ABBREVIATION='qQq'
  assertEquals "%K{blue} %F{black}qQq %k%F{blue}%f " "$(build_left_prompt)"

  cd /tmp
  # default
  POWERLEVEL9K_HOME_FOLDER_ABBREVIATION='~'
  assertEquals "%K{blue} %F{black}/tmp %k%F{blue}%f " "$(build_left_prompt)"

  # substituted
  POWERLEVEL9K_HOME_FOLDER_ABBREVIATION='qQq'
  assertEquals "%K{blue} %F{black}/tmp %k%F{blue}%f " "$(build_left_prompt)"

  cd "$dir"
}

function testOmittingFirstCharacterWorks() {
  POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER=true
  POWERLEVEL9K_FOLDER_ICON='folder-icon'
  cd /tmp

  assertEquals "%K{blue} %F{black%}folder-icon %f%F{black}tmp %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  unset POWERLEVEL9K_FOLDER_ICON
  unset POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER
}

function testOmittingFirstCharacterWorksWithChangingPathSeparator() {
  POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER=true
  POWERLEVEL9K_DIR_PATH_SEPARATOR='xXx'
  POWERLEVEL9K_FOLDER_ICON='folder-icon'
  mkdir -p /tmp/powerlevel9k-test/1/2
  cd /tmp/powerlevel9k-test/1/2

  assertEquals "%K{blue} %F{black%}folder-icon %f%F{black}tmpxXxpowerlevel9k-testxXx1xXx2 %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test
  unset POWERLEVEL9K_FOLDER_ICON
  unset POWERLEVEL9K_DIR_PATH_SEPARATOR
  unset POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER
}

# This test makes it obvious that combining a truncation strategy
# that cuts off folders from the left and omitting the the first
# character does not make much sense. The truncation strategy
# comes first, prints an ellipsis and that gets then cut off by
# POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER..
# But it does more sense in combination with other truncation
# strategies.
function testOmittingFirstCharacterWorksWithChangingPathSeparatorAndDefaultTruncation() {
  POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER=true
  POWERLEVEL9K_DIR_PATH_SEPARATOR='xXx'
  POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  POWERLEVEL9K_SHORTEN_STRATEGY='truncate_folders'
  mkdir -p /tmp/powerlevel9k-test/1/2
  cd /tmp/powerlevel9k-test/1/2

  assertEquals "%K{blue} %F{black}xXx1xXx2 %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test
  unset POWERLEVEL9K_DIR_PATH_SEPARATOR
  unset POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER
  unset POWERLEVEL9K_SHORTEN_DIR_LENGTH
  unset POWERLEVEL9K_SHORTEN_STRATEGY
}

function testOmittingFirstCharacterWorksWithChangingPathSeparatorAndMiddleTruncation() {
  POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER=true
  POWERLEVEL9K_DIR_PATH_SEPARATOR='xXx'
  POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  POWERLEVEL9K_SHORTEN_STRATEGY='truncate_middle'
  mkdir -p /tmp/powerlevel9k-test/1/2
  cd /tmp/powerlevel9k-test/1/2

  assertEquals "%K{blue} %F{black}tmpxXxpo…stxXx1xXx2 %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test
  unset POWERLEVEL9K_DIR_PATH_SEPARATOR
  unset POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER
  unset POWERLEVEL9K_SHORTEN_DIR_LENGTH
  unset POWERLEVEL9K_SHORTEN_STRATEGY
}

function testOmittingFirstCharacterWorksWithChangingPathSeparatorAndRightTruncation() {
  POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER=true
  POWERLEVEL9K_DIR_PATH_SEPARATOR='xXx'
  POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  POWERLEVEL9K_SHORTEN_STRATEGY='truncate_from_right'
  mkdir -p /tmp/powerlevel9k-test/1/2
  cd /tmp/powerlevel9k-test/1/2

  assertEquals "%K{blue} %F{black}tmpxXxpo…xXx1xXx2 %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test
  unset POWERLEVEL9K_DIR_PATH_SEPARATOR
  unset POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER
  unset POWERLEVEL9K_SHORTEN_DIR_LENGTH
  unset POWERLEVEL9K_SHORTEN_STRATEGY
}

function testTruncateToUniqueWorks() {
  POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER=true
  POWERLEVEL9K_DIR_PATH_SEPARATOR='xXx'
  POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  POWERLEVEL9K_SHORTEN_STRATEGY='truncate_to_unique'
  mkdir -p /tmp/powerlevel9k-test/adam/devl
  mkdir -p /tmp/powerlevel9k-test/alice/devl
  mkdir -p /tmp/powerlevel9k-test/alice/docs
  mkdir -p /tmp/powerlevel9k-test/bob/docs
  cd /tmp/powerlevel9k-test/alice/devl

  assertEquals "%K{blue} %F{black}txXxpxXxalxXxde %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test
  unset POWERLEVEL9K_DIR_PATH_SEPARATOR
  unset POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER
  unset POWERLEVEL9K_SHORTEN_DIR_LENGTH
  unset POWERLEVEL9K_SHORTEN_STRATEGY
}

function testBoldHomeDirWorks() {
  POWERLEVEL9K_DIR_PATH_HIGHLIGHT_BOLD=true
  cd ~

  assertEquals "%K{blue} %F{black}%B~%b %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  unset POWERLEVEL9K_DIR_PATH_HIGHLIGHT_BOLD
}

function testBoldHomeSubdirWorks() {
  POWERLEVEL9K_DIR_PATH_HIGHLIGHT_BOLD=true
  mkdir -p ~/powerlevel9k-test
  cd ~/powerlevel9k-test

  assertEquals "%K{blue} %F{black}~/%Bpowerlevel9k-test%b %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  rm -fr ~/powerlevel9k-test
  unset POWERLEVEL9K_DIR_PATH_HIGHLIGHT_BOLD
}

function testBoldRootDirWorks() {
  POWERLEVEL9K_DIR_PATH_HIGHLIGHT_BOLD=true
  cd /

  assertEquals "%K{blue} %F{black}%B/%b %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  unset POWERLEVEL9K_DIR_PATH_HIGHLIGHT_BOLD
}

function testBoldRootSubdirWorks() {
  POWERLEVEL9K_DIR_PATH_HIGHLIGHT_BOLD=true
  cd /tmp

  assertEquals "%K{blue} %F{black}/%Btmp%b %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  unset POWERLEVEL9K_DIR_PATH_HIGHLIGHT_BOLD
}

function testBoldRootSubSubdirWorks() {
  POWERLEVEL9K_DIR_PATH_HIGHLIGHT_BOLD=true
  mkdir -p /tmp/powerlevel9k-test
  cd /tmp/powerlevel9k-test

  assertEquals "%K{blue} %F{black}/tmp/%Bpowerlevel9k-test%b %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test
  unset POWERLEVEL9K_DIR_PATH_HIGHLIGHT_BOLD
}

function testHighlightHomeWorks() {
  POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND='red'
  cd ~

  assertEquals "%K{blue} %F{black}%F{red}~ %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  unset POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND
}

function testHighlightHomeSubdirWorks() {
  POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND='red'
  mkdir -p ~/powerlevel9k-test
  cd ~/powerlevel9k-test

  assertEquals "%K{blue} %F{black}~/%F{red}powerlevel9k-test %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  rm -fr ~/powerlevel9k-test
  unset POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND
}

function testHighlightRootWorks() {
  POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND='red'
  cd /

  assertEquals "%K{blue} %F{black}%F{red}/ %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  unset POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND
}

function testHighlightRootSubdirWorks() {
  POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND='red'
  cd /tmp

  assertEquals "%K{blue} %F{black}/%F{red}tmp %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  unset POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND
}

function testHighlightRootSubSubdirWorks() {
  POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND='red'
  mkdir /tmp/powerlevel9k-test
  cd /tmp/powerlevel9k-test

  assertEquals "%K{blue} %F{black}/tmp/%F{red}powerlevel9k-test %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test
  unset POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND
}

function testDirSeparatorColorHomeSubdirWorks() {
  POWERLEVEL9K_DIR_PATH_SEPARATOR_FOREGROUND='red'
  mkdir -p ~/powerlevel9k-test
  cd ~/powerlevel9k-test

  assertEquals "%K{blue} %F{black}~%F{red}/%F{black}powerlevel9k-test %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  rm -fr ~/powerlevel9k-test
  unset POWERLEVEL9K_DIR_PATH_SEPARATOR_FOREGROUND
}

function testDirSeparatorColorRootSubSubdirWorks() {
  POWERLEVEL9K_DIR_PATH_SEPARATOR_FOREGROUND='red'
  mkdir -p /tmp/powerlevel9k-test
  cd /tmp/powerlevel9k-test

  assertEquals "%K{blue} %F{black}%F{red}/%F{black}tmp%F{red}/%F{black}powerlevel9k-test %k%F{blue}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test
  unset POWERLEVEL9K_DIR_PATH_SEPARATOR_FOREGROUND
}

source shunit2/source/2.1/src/shunit2

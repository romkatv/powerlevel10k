#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"
  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  # Test specific
  P9K_HOME=$(pwd)
  FOLDER=/tmp/powerlevel9k-test
  mkdir -p $FOLDER
  cd $FOLDER

  # Change cache file, so that the users environment don't
  # interfere with the tests.
  POWERLEVEL9K_PUBLIC_IP_FILE=$FOLDER/public_ip_file
}

function tearDown() {
  # Go back to powerlevel9k folder
  cd "${P9K_HOME}"
  # Remove eventually created test-specific folder
  rm -fr "${FOLDER}"
  # At least remove test folder completely
  rm -fr /tmp/powerlevel9k-test
  unset FOLDER
  unset P9K_HOME

  # Unset cache file
  unset POWERLEVEL9K_PUBLIC_IP_FILE
}

function testPublicIpSegmentPrintsNothingByDefaultIfHostIsNotAvailable() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(public_ip custom_world)
  local POWERLEVEL9K_PUBLIC_IP_HOST='http://unknown.xyz'
  local POWERLEVEL9K_CUSTOM_WORLD='echo world'
  # We need to overwrite dig, as this is a fallback method that
  # uses an alternative host.
  alias dig='nodig'

  assertEquals "%K{white} %F{black}world %k%F{white}%f " "$(build_left_prompt)"

  unalias dig
}

function testPublicIpSegmentPrintsNoticeIfNotConnected() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(public_ip)
  local POWERLEVEL9K_PUBLIC_IP_HOST='http://unknown.xyz'
  local POWERLEVEL9K_PUBLIC_IP_NONE="disconnected"
  # We need to overwrite dig, as this is a fallback method that
  # uses an alternative host.
  alias dig='nodig'

  assertEquals "%K{black} %F{white}disconnected %k%F{black}%f " "$(build_left_prompt)"

  unalias dig
}

function testPublicIpSegmentWorksWithWget() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(public_ip)
  alias dig='nodig'
  alias curl='nocurl'
  wget() {
      echo "wget 1.2.3.4"
  }

  assertEquals "%K{black} %F{white}wget 1.2.3.4 %k%F{black}%f " "$(build_left_prompt)"

  unfunction wget
  unalias dig
  unalias curl
}

function testPublicIpSegmentUsesCurlAsFallbackMethodIfWgetIsNotAvailable() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(public_ip)
  alias dig='nodig'
  alias wget='nowget'
  curl() {
      echo "curl 1.2.3.4"
  }

  assertEquals "%K{black} %F{white}curl 1.2.3.4 %k%F{black}%f " "$(build_left_prompt)"

  unfunction curl
  unalias dig
  unalias wget
}

function testPublicIpSegmentUsesDigAsFallbackMethodIfWgetAndCurlAreNotAvailable() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(public_ip)
  alias curl='nocurl'
  alias wget='nowget'
  dig() {
      echo "dig 1.2.3.4"
  }

  assertEquals "%K{black} %F{white}dig 1.2.3.4 %k%F{black}%f " "$(build_left_prompt)"

  unfunction dig
  unalias curl
  unalias wget
}

function testPublicIpSegmentCachesFile() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(public_ip)
  dig() {
      echo "first"
  }

  assertEquals "%K{black} %F{white}first %k%F{black}%f " "$(build_left_prompt)"

  dig() {
      echo "second"
  }

  # Segment should not have changed!
  assertEquals "%K{black} %F{white}first %k%F{black}%f " "$(build_left_prompt)"

  unfunction dig
}

function testPublicIpSegmentRefreshesCachesFileAfterTimeout() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(public_ip)
  local POWERLEVEL9K_PUBLIC_IP_TIMEOUT=2
  dig() {
      echo "first"
  }

  assertEquals "%K{black} %F{white}first %k%F{black}%f " "$(build_left_prompt)"

  sleep 3
  dig() {
      echo "second"
  }

  # Segment should not have changed!
  assertEquals "%K{black} %F{white}second %k%F{black}%f " "$(build_left_prompt)"

  unfunction dig
}

function testPublicIpSegmentRefreshesCachesFileIfEmpty() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(public_ip)
  dig() {
      echo "first"
  }

  assertEquals "%K{black} %F{white}first %k%F{black}%f " "$(build_left_prompt)"

  # Truncate cache file
  echo "" >! $POWERLEVEL9K_PUBLIC_IP_FILE

  dig() {
      echo "second"
  }

  # Segment should not have changed!
  assertEquals "%K{black} %F{white}second %k%F{black}%f " "$(build_left_prompt)"

  unfunction dig
}

function testPublicIpSegmentWhenGoingOnline() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(public_ip)
  local POWERLEVEL9K_PUBLIC_IP_METHODS="dig"
  local POWERLEVEL9K_PUBLIC_IP_NONE="disconnected"
  alias dig="nodig"

  assertEquals "%K{black} %F{white}disconnected %k%F{black}%f " "$(build_left_prompt)"

  unalias dig

  dig() {
      echo "second"
  }

  # Segment should not have changed!
  assertEquals "%K{black} %F{white}second %k%F{black}%f " "$(build_left_prompt)"

  unfunction dig
}

source shunit2/source/2.1/src/shunit2
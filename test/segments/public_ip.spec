#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"

  # Test specific
  P9K_HOME=$(pwd)
  FOLDER=/tmp/powerlevel9k-test
  mkdir -p $FOLDER
  mkdir $FOLDER/bin
  mkdir $FOLDER/sbin
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
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(public_ip custom_world)
  local POWERLEVEL9K_PUBLIC_IP_HOST='http://unknown.xyz'
  local POWERLEVEL9K_CUSTOM_WORLD='echo world'
  # We need to overwrite dig, as this is a fallback method that
  # uses an alternative host.
  alias dig='nodig'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{007} %F{000}world %k%F{007}%f " "$(build_left_prompt)"

  unalias dig
}

function testPublicIpSegmentPrintsNoticeIfNotConnected() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(public_ip)
  local POWERLEVEL9K_PUBLIC_IP_HOST='http://unknown.xyz'
  local POWERLEVEL9K_PUBLIC_IP_NONE="disconnected"
  # We need to overwrite dig, as this is a fallback method that
  # uses an alternative host.
  alias dig='nodig'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{000} %F{007}disconnected %k%F{000}%f " "$(build_left_prompt)"

  unalias dig
}

function testPublicIpSegmentWorksWithWget() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(public_ip)
  alias dig='nodig'
  alias curl='nocurl'
  wget() {
      echo "wget 1.2.3.4"
  }

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{000} %F{007}wget 1.2.3.4 %k%F{000}%f " "$(build_left_prompt)"

  unfunction wget
  unalias dig
  unalias curl
}

function testPublicIpSegmentUsesCurlAsFallbackMethodIfWgetIsNotAvailable() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(public_ip)
  alias dig='nodig'
  alias wget='nowget'
  curl() {
      echo "curl 1.2.3.4"
  }

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{000} %F{007}curl 1.2.3.4 %k%F{000}%f " "$(build_left_prompt)"

  unfunction curl
  unalias dig
  unalias wget
}

function testPublicIpSegmentUsesDigAsFallbackMethodIfWgetAndCurlAreNotAvailable() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(public_ip)
  alias curl='nocurl'
  alias wget='nowget'
  dig() {
      echo "dig 1.2.3.4"
  }

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{000} %F{007}dig 1.2.3.4 %k%F{000}%f " "$(build_left_prompt)"

  unfunction dig
  unalias curl
  unalias wget
}

function testPublicIpSegmentCachesFile() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(public_ip)
  dig() {
      echo "first"
  }

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{000} %F{007}first %k%F{000}%f " "$(build_left_prompt)"

  dig() {
      echo "second"
  }

  # Segment should not have changed!
  assertEquals "%K{000} %F{007}first %k%F{000}%f " "$(build_left_prompt)"

  unfunction dig
}

function testPublicIpSegmentRefreshesCachesFileAfterTimeout() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(public_ip)
  local POWERLEVEL9K_PUBLIC_IP_TIMEOUT=2
  dig() {
      echo "first"
  }

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{000} %F{007}first %k%F{000}%f " "$(build_left_prompt)"

  sleep 3
  dig() {
      echo "second"
  }

  # Segment should not have changed!
  assertEquals "%K{000} %F{007}second %k%F{000}%f " "$(build_left_prompt)"

  unfunction dig
}

function testPublicIpSegmentRefreshesCachesFileIfEmpty() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(public_ip)
  dig() {
      echo "first"
  }

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{000} %F{007}first %k%F{000}%f " "$(build_left_prompt)"

  # Truncate cache file
  echo "" >! $POWERLEVEL9K_PUBLIC_IP_FILE

  dig() {
      echo "second"
  }

  # Segment should not have changed!
  assertEquals "%K{000} %F{007}second %k%F{000}%f " "$(build_left_prompt)"

  unfunction dig
}

function testPublicIpSegmentWhenGoingOnline() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(public_ip)
  local POWERLEVEL9K_PUBLIC_IP_METHODS="dig"
  local POWERLEVEL9K_PUBLIC_IP_NONE="disconnected"
  alias dig="nodig"

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{000} %F{007}disconnected %k%F{000}%f " "$(build_left_prompt)"

  unalias dig

  dig() {
      echo "second"
  }

  # Segment should not have changed!
  assertEquals "%K{000} %F{007}second %k%F{000}%f " "$(build_left_prompt)"

  unfunction dig
}

function testPublicIpSegmentWithVPNTurnedOnLinux() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(public_ip)
  local OS='linux'

  echo "1.2.3.4" > $POWERLEVEL9K_PUBLIC_IP_FILE
  local POWERLEVEL9K_PUBLIC_IP_VPN_INTERFACE="tun1"

  ip() {
      cat <<EOF
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: enp0s31f6: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc fq_codel state DOWN mode DEFAULT group default qlen 1000
    link/ether 8c:16:45:7d:0c:9a brd ff:ff:ff:ff:ff:ff
3: tun1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DORMANT group default qlen 1000
    link/ether b4:6b:fc:9d:c6:bc brd ff:ff:ff:ff:ff:ff
5: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN mode DEFAULT group default
    link/ether 02:42:8f:5c:ed:39 brd ff:ff:ff:ff:ff:ff
EOF
  }

  assertEquals "%K{000} %F{007}(vpn) %f%F{007}1.2.3.4 " "$(prompt_public_ip left 1 false "$FOLDER")"

  unfunction ip
  rm -f $POWERLEVEL9K_PUBLIC_IP_FILE
}

function testPublicIpSegmentWithVPNTurnedOnOsx() {
  typeset -F now
  now=$(date +%s)

  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(public_ip)
  local OS='OSX'

  echo "1.2.3.4" > $POWERLEVEL9K_PUBLIC_IP_FILE
  local POWERLEVEL9K_PUBLIC_IP_VPN_INTERFACE="tun1"

  # Fake stat call
  function stat() {
    echo $now
  }

  # Fake ifconfig
  cat > $FOLDER/sbin/ifconfig <<EOF
#!/bin/sh
  cat <<INNER
docker0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 172.17.255.255
        ether 02:42:8f:5c:ed:51  txqueuelen 0  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

tun1: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        ether 8c:16:45:7d:0c:9a  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        device interrupt 16  memory 0xe8200000-e8220000

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 5136  bytes 328651 (320.9 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 5136  bytes 328651 (320.9 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
INNER
EOF
  chmod +x $FOLDER/sbin/ifconfig

  assertEquals "%K{000} %F{007}(vpn) %f%F{007}1.2.3.4 " "$(prompt_public_ip left 1 false "$FOLDER")"

  rm -f $POWERLEVEL9K_PUBLIC_IP_FILE
  unfunction stat
}

source shunit2/shunit2
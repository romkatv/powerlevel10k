#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"
}

function testIpSegmentPrintsNothingOnOsxIfNotConnected() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(ip custom_world)
  alias networksetup='echo "not connected"'
  local POWERLEVEL9K_CUSTOM_WORLD='echo world'

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme
  local OS="OSX" # Fake OSX

  assertEquals "%K{007} %F{000}world %k%F{007}%f " "$(build_left_prompt)"

  unalias networksetup
}

function testIpSegmentPrintsNothingOnLinuxIfNotConnected() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(ip custom_world)
  alias ip='echo "not connected"'
  local POWERLEVEL9K_CUSTOM_WORLD='echo world'

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme
  local OS="Linux" # Fake Linux

  assertEquals "%K{007} %F{000}world %k%F{007}%f " "$(build_left_prompt)"

  unalias ip
}

function testIpSegmentWorksOnOsxWithNoInterfaceSpecified() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(ip)
  alias networksetup="echo 'An asterisk (*) denotes that a network service is disabled.
(1) Ethernet
(Hardware Port: Ethernet, Device: en0)

(2) FireWire
(Hardware Port: FireWire, Device: fw0)

(3) Wi-Fi
(Hardware Port: Wi-Fi, Device: en1)

(4) Bluetooth PAN
(Hardware Port: Bluetooth PAN, Device: en3)

(5) Thunderbolt Bridge
(Hardware Port: Thunderbolt Bridge, Device: bridge0)

(6) Apple USB Ethernet Adapter
(Hardware Port: Apple USB Ethernet Adapter, Device: en4)
'"

  alias ipconfig="_(){ echo '1.2.3.4'; };_"

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme
  local OS='OSX' # Fake OSX

  assertEquals "%K{006} %F{000}IP %f%F{000}1.2.3.4 %k%F{006}%f " "$(build_left_prompt)"

  unalias ipconfig
  unalias networksetup
}

# There could be more than one confiured network interfaces.
# `networksetup -listnetworkserviceorder` lists the interfaces
# in hierarchical order, but from outside this is not obvious
# (implementation detail). So we need a test for this case.
function testIpSegmentWorksOnOsxWithMultipleInterfacesSpecified() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(ip)
  alias networksetup="echo 'An asterisk (*) denotes that a network service is disabled.
(1) Ethernet
(Hardware Port: Ethernet, Device: en0)

(2) FireWire
(Hardware Port: FireWire, Device: fw0)

(3) Wi-Fi
(Hardware Port: Wi-Fi, Device: en1)

(4) Bluetooth PAN
(Hardware Port: Bluetooth PAN, Device: en3)

(5) Thunderbolt Bridge
(Hardware Port: Thunderbolt Bridge, Device: bridge0)

(6) Apple USB Ethernet Adapter
(Hardware Port: Apple USB Ethernet Adapter, Device: en4)
'"

  # Return a unique IP address for every interface
  ipconfig() {
      case "${2}" {
          en0)
            echo 1.2.3.4
          ;;
          fw0)
            echo 2.3.4.5
          ;;
          en1)
            echo 3.4.5.6
          ;;
          en3)
            echo 4.5.6.7
          ;;
      }
  }

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme
  local OS='OSX' # Fake OSX

  assertEquals "%K{006} %F{000}IP %f%F{000}1.2.3.4 %k%F{006}%f " "$(build_left_prompt)"

  unfunction ipconfig
  unalias networksetup
}

function testIpSegmentWorksOnOsxWithInterfaceSpecified() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(ip)
  local POWERLEVEL9K_IP_INTERFACE='xxx'
  alias ipconfig="_(){ echo '1.2.3.4'; };_"

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme
  local OS='OSX' # Fake OSX

  assertEquals "%K{006} %F{000}IP %f%F{000}1.2.3.4 %k%F{006}%f " "$(build_left_prompt)"

  unalias ipconfig
}

function testIpSegmentWorksOnLinuxWithNoInterfaceSpecified() {
    setopt aliases
    local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(ip)
    # That command is harder to test, as it is used at first
    # to get all relevant network interfaces and then for
    # getting the configuration of that segment..
    ip(){
      if [[ "$*" == 'link ls up' ]]; then
        echo "1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:7e:84:45 brd ff:ff:ff:ff:ff:ff";
      fi

      if [[ "$*" == '-4 a show eth0' ]]; then
        echo '2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 10.0.2.15/24 brd 10.0.2.255 scope global eth0
       valid_lft forever preferred_lft forever';
      fi
    }

    # Load Powerlevel9k
    source powerlevel9k.zsh-theme
    local OS='Linux' # Fake Linux

    assertEquals "%K{006} %F{000}IP %f%F{000}10.0.2.15 %k%F{006}%f " "$(build_left_prompt)"

    unfunction ip
}

function testIpSegmentWorksOnLinuxWithMultipleInterfacesSpecified() {
    setopt aliases
    local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(ip)
    # That command is harder to test, as it is used at first
    # to get all relevant network interfaces and then for
    # getting the configuration of that segment..
    ip(){
      if [[ "$*" == 'link ls up' ]]; then
        echo "1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:7e:84:45 brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:7e:84:45 brd ff:ff:ff:ff:ff:ff
4: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:7e:84:45 brd ff:ff:ff:ff:ff:ff";
      fi

      if [[ "$*" == '-4 a show eth1' ]]; then
        echo '3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 10.0.2.15/24 brd 10.0.2.255 scope global eth0
       valid_lft forever preferred_lft forever';
      fi
    }

    # Load Powerlevel9k
    source powerlevel9k.zsh-theme
    local OS='Linux' # Fake Linux

    assertEquals "%K{006} %F{000}IP %f%F{000}10.0.2.15 %k%F{006}%f " "$(build_left_prompt)"

    unfunction ip
}

function testIpSegmentWorksOnLinuxWithInterfaceSpecified() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(ip)
  local POWERLEVEL9K_IP_INTERFACE='xxx'
  ip(){
    echo '2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
inet 10.0.2.15/24 brd 10.0.2.255 scope global eth0
    valid_lft forever preferred_lft forever';
  }

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme
  local OS='Linux' # Fake Linux

  assertEquals "%K{006} %F{000}IP %f%F{000}10.0.2.15 %k%F{006}%f " "$(build_left_prompt)"

  unfunction ip
}

source shunit2/shunit2
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
  mkdir $FOLDER/sbin
}

function tearDown() {
  # Go back to powerlevel9k folder
  cd "${P9K_HOME}"
  # Remove eventually created test-specific folder
  rm -fr "${FOLDER}"

  unset FOLDER
  unset P9K_HOME
}

function fakeIfconfig() {
    # Fake ifconfig
  cat > $FOLDER/sbin/ifconfig <<EOF
#!/usr/bin/env zsh

if [[ "\$#" -gt 0 ]]; then
  cat <<INNER
tun1: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 1.2.3.4  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        device interrupt 16  memory 0xe8200000-e8220000
INNER
  exit 0
fi

  cat <<INNER
docker0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 172.17.255.255
        ether 02:42:8f:5c:ed:51  txqueuelen 0  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

tun1: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 1.2.3.4  txqueuelen 1000  (Ethernet)
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
}

function fakeIp() {
  local INTERFACE1="${1}"
  [[ -z "${INTERFACE1}" ]] && INTERFACE1="tun0"
  local INTERFACE2="${2}"
  [[ -z "${INTERFACE2}" ]] && INTERFACE2="disabled-if2"
  cat > $FOLDER/sbin/ip <<EOF
#!/usr/bin/env zsh

  if [[ "\$*" == 'link ls up' ]]; then
    cat <<INNER
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: ${INTERFACE1}: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:7e:84:45 brd ff:ff:ff:ff:ff:ff
3: ${INTERFACE2}: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:7e:84:45 brd ff:ff:ff:ff:ff:ff
4: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:7e:84:45 brd ff:ff:ff:ff:ff:ff
INNER
  fi

  if [[ "\$*" =~ '-brief.*show' ]]; then
    cat <<INNER
lo               UNKNOWN        127.0.0.1/8
${INTERFACE1}    UP             1.2.3.4/24
${INTERFACE2}    UP             5.4.3.2/16
docker0          DOWN           172.17.0.1/16
INNER
  fi

  if [[ "\$*" =~ 'show ${INTERFACE1}' ]]; then
    cat <<INNER
2: ${INTERFACE1}: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
  inet 10.0.2.15/24 brd 10.0.2.255 scope global eth0
  valid_lft forever preferred_lft forever
INNER
  fi

  if [[ "\$*" =~ 'show ${INTERFACE2}' ]]; then
    cat <<INNER
3: ${INTERFACE2}: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
  inet 1.2.3.4 brd 10.0.2.255 scope global eth0
  valid_lft forever preferred_lft forever
INNER
  fi
EOF

  chmod +x $FOLDER/sbin/ip
}

function testVpnIpSegmentPrintsNothingOnOsxIfNotConnected() {
  # Load Powerlevel9k
  source powerlevel9k.zsh-theme
  local OS="OSX" # Fake OSX

  cat > $FOLDER/sbin/ifconfig <<EOF
#!/usr/bin/env zsh

echo "not connected"
EOF
  chmod +x $FOLDER/sbin/ifconfig

  assertEquals "" "$(prompt_vpn_ip left 1 false "$FOLDER")"
}

function testVpnIpSegmentPrintsNothingOnLinuxIfNotConnected() {
  # Load Powerlevel9k
  source powerlevel9k.zsh-theme
  local OS="Linux" # Fake Linux

  cat > $FOLDER/sbin/ip <<EOF
#!/usr/bin/env zsh

echo "not connected"
EOF
  chmod +x $FOLDER/sbin/ip

  assertEquals "" "$(prompt_vpn_ip left 1 false "$FOLDER")"
}

function testVpnIpSegmentWorksOnOsxWithInterfaceSpecified() {
  local POWERLEVEL9K_VPN_IP_INTERFACE='tun1'

  fakeIfconfig

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme
  local OS='OSX' # Fake OSX

  assertEquals "%K{006} %F{000}(vpn) %F{000}1.2.3.4 " "$(prompt_vpn_ip left 1 false "$FOLDER")"
}

function testVpnIpSegmentWorksOnLinuxWithInterfaceSpecified() {
    local POWERLEVEL9K_VPN_IP_INTERFACE='tun1'
    
    fakeIp "tun1"

    # Load Powerlevel9k
    source powerlevel9k.zsh-theme
    local OS='Linux' # Fake Linux

    assertEquals "%K{006} %F{000}(vpn) %F{000}1.2.3.4 " "$(prompt_vpn_ip left 1 false "$FOLDER")"
}

# vpn_ip is not capable of handling multiple vpn interfaces ATM.
# function testVpnIpSegmentWorksOnLinuxWithMultipleInterfacesSpecified() {
#     local POWERLEVEL9K_VPN_IP_INTERFACE=(tun0 tun1)
    
#     fakeIp "tun0" "tun1"

#     # Load Powerlevel9k
#     source powerlevel9k.zsh-theme
#     local OS='Linux' # Fake Linux

# setopt xtrace
#     assertEquals "%K{006} %F{000}(vpn) %F{000}10.0.2.15 " "$(prompt_vpn_ip left 1 false "$FOLDER")"
#     unsetopt xtrace
# }

source shunit2/shunit2
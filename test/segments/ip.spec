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
  local INTERFACE1="${1}"
  [[ -z "${INTERFACE1}" ]] && INTERFACE1="eth0"
  local INTERFACE1_IP="1.2.3.4"
  local INTERFACE2="${2}"
  [[ -z "${INTERFACE2}" ]] && INTERFACE2="disabled-if2"
  local INTERFACE2_IP="5.6.7.8"
    # Fake ifconfig
  cat > $FOLDER/sbin/ifconfig <<EOF
#!/usr/bin/env zsh

if [[ "\$*" =~ '-l' ]]; then
  echo "docker0 tun1 ${INTERFACE1} ${INTERFACE2} lo"
  exit 0
fi

if [[ "\$*" =~ '${INTERFACE1}' ]]; then
  cat <<INNER
tun1: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet ${INTERFACE1_IP}  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        device interrupt 16  memory 0xe8200000-e8220000
INNER
  exit 0
fi

if [[ "\$*" =~ '${INTERFACE2}' ]]; then
  cat <<INNER
tun1: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet ${INTERFACE2_IP}  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        device interrupt 16  memory 0xe8200000-e8220000
INNER
  exit 0
fi


# If neither INTERFACE1 nor INTERFACE2 is queried, fake a offline (DOWN) interface.
# We assume if there is at least one argument, we queried for a specific interface.
if [[ "\$#" -gt 0 ]]; then
  cat <<INNER
tun1: flags=4099<DOWN,BROADCAST,MULTICAST>  mtu 1500
        inet 5.5.5.5  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        device interrupt 16  memory 0xe8200000-e8220000
INNER
  exit 0
fi

if [[ "\$#" -eq 0 ]]; then
  cat <<INNER
docker0: flags=4099<DOWN,BROADCAST,MULTICAST>  mtu 1500
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 172.17.255.255
        ether 02:42:8f:5c:ed:51  txqueuelen 0  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

tun1: flags=4099<DOWN,BROADCAST,MULTICAST>  mtu 1500
        inet 10.20.30.40  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        device interrupt 16  memory 0xe8200000-e8220000

${INTERFACE1}: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet ${INTERFACE1_IP}  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        device interrupt 16  memory 0xe8200000-e8220000

${INTERFACE2}: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet ${INTERFACE2_IP}  txqueuelen 1000  (Ethernet)
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
exit 0
fi
EOF
  chmod +x $FOLDER/sbin/ifconfig
}

function fakeIp() {
  local INTERFACE1="${1}"
  [[ -z "${INTERFACE1}" ]] && INTERFACE1="eth0"
  local INTERFACE2="${2}"
  [[ -z "${INTERFACE2}" ]] && INTERFACE2="disabled-if2"
  cat > $FOLDER/sbin/ip <<EOF
#!/usr/bin/env zsh

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

function testIpSegmentPrintsNothingOnOsxIfNotConnected() {
  cat > $FOLDER/sbin/ifconfig <<EOF
#!/usr/bin/env zsh

echo "not connected"
EOF

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme
  local OS="OSX" # Fake OSX

  assertEquals "" "$(prompt_ip left 1 false "$FOLDER")"
}

function testIpSegmentPrintsNothingOnLinuxIfNotConnected() {
  # Load Powerlevel9k
  source powerlevel9k.zsh-theme
  local OS="Linux" # Fake Linux

  cat > $FOLDER/sbin/ip <<EOF
#!/usr/bin/env zsh

echo "not connected"
EOF
  chmod +x $FOLDER/sbin/ip

  assertEquals "" "$(prompt_ip left 1 false "$FOLDER")"
}

function testIpSegmentWorksOnOsxWithNoInterfaceSpecified() {
  # Load Powerlevel9k
  source powerlevel9k.zsh-theme
  local OS='OSX' # Fake OSX

  fakeIfconfig "eth1" "eth2"

  assertEquals "%K{006} %F{000}IP %F{000}1.2.3.4 " "$(prompt_ip left 1 false "$FOLDER")"
}

function testIpSegmentWorksOnOsxWithInterfaceSpecified() {
  fakeIfconfig "eth1"

  local POWERLEVEL9K_IP_INTERFACE="eth1"

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme
  local OS='OSX' # Fake OSX

  assertEquals "%K{006} %F{000}IP %F{000}1.2.3.4 " "$(prompt_ip left 1 false "$FOLDER")"
}

function testIpSegmentWorksOnLinuxWithNoInterfaceSpecified() {
    # Load Powerlevel9k
    source powerlevel9k.zsh-theme
    local OS='Linux' # Fake Linux

    fakeIp "eth0"

    assertEquals "%K{006} %F{000}IP %F{000}1.2.3.4 " "$(prompt_ip left 1 false "$FOLDER")"
}

function testIpSegmentWorksOnLinuxWithInterfaceSpecified() {
  fakeIp "eth3"

  local POWERLEVEL9K_IP_INTERFACE="eth3"

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme
  local OS='Linux' # Fake Linux

  assertEquals "%K{006} %F{000}IP %F{000}1.2.3.4 " "$(prompt_ip left 1 false "$FOLDER")"
}

source shunit2/shunit2
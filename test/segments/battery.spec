#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"
  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  P9K_HOME=$(pwd)
  ### Test specific
  # Create default folder
  FOLDER=/tmp/powerlevel9k-test
  mkdir -p "${FOLDER}"
  cd $FOLDER

  # Prepare folder for pmset (OSX)
  PMSET_PATH=$FOLDER/usr/bin
  mkdir -p $PMSET_PATH
  # Prepare folder for $BATTERY (Linux)
  BATTERY_PATH=$FOLDER/sys/class/power_supply
  mkdir -p $BATTERY_PATH
  mkdir -p $BATTERY_PATH/BAT0
  mkdir -p $BATTERY_PATH/BAT1
}

function tearDown() {
  # Go back to powerlevel9k folder
  cd "${P9K_HOME}"
  # Remove eventually created test-specific folder
  rm -fr "${FOLDER}" &>/dev/null
  # At least remove test folder completely
  rm -fr /tmp/powerlevel9k-test &>/dev/null
  unset PMSET_PATH
  unset BATTERY_PATH
  unset FOLDER
  unset P9K_HOME
}

# Mock Battery
# For mocking pmset on OSX this function takes one argument (the
# content that pmset should echo).
# For mocking the battery on Linux this function takes two
# arguments: $1 is the capacity; $2 the battery status.
function makeBatterySay() {
  if [[ -z "${FOLDER}" ]]; then
    echo "Fake root path is not correctly set!"
    exit 1
  fi
  # OSX
  echo "#!/bin/sh" > $PMSET_PATH/pmset
  echo "echo \"$1\"" >> $PMSET_PATH/pmset
  chmod +x $PMSET_PATH/pmset

  # Linux
  local capacity="$1"
  echo "$capacity" > $BATTERY_PATH/BAT0/capacity
  echo "$capacity" > $BATTERY_PATH/BAT1/capacity
  local battery_status="$2"
  echo "$battery_status" > $BATTERY_PATH/BAT0/status
  echo "$battery_status" > $BATTERY_PATH/BAT1/status
}

function testBatterySegmentIfBatteryIsLowWhileDischargingOnOSX() {
  local OS='OSX' # Fake OSX
  makeBatterySay "Now drawing from 'Battery Power'
 -InternalBattery-0 (id=1234567)	4%; discharging; 0:05 remaining present: true"

  assertEquals "%K{000} %F{001}🔋 %f%F{001}4%% (0:05) " "$(prompt_battery left 1 false ${FOLDER})"
}

function testBatterySegmentIfBatteryIsLowWhileChargingOnOSX() {
  local OS='OSX' # Fake OSX
  makeBatterySay "Now drawing from 'Battery Power'
 -InternalBattery-0 (id=1234567)	4%; charging; 0:05 remaining present: true"

  assertEquals "%K{000} %F{003}🔋 %f%F{003}4%% (0:05) " "$(prompt_battery left 1 false ${FOLDER})"
}

function testBatterySegmentIfBatteryIsAlmostFullWhileDischargingOnOSX() {
  local OS='OSX' # Fake OSX
  makeBatterySay "Now drawing from 'Battery Power'
 -InternalBattery-0 (id=1234567)	98%; discharging; 3:57 remaining present: true"

  assertEquals "%K{000} %F{007}🔋 %f%F{007}98%% (3:57) " "$(prompt_battery left 1 false ${FOLDER})"
}

function testBatterySegmentIfBatteryIsAlmostFullWhileChargingOnOSX() {
  local OS='OSX' # Fake OSX
  makeBatterySay "Now drawing from 'Battery Power'
 -InternalBattery-0 (id=1234567)	98%; charging; 3:57 remaining present: true"

  assertEquals "%K{000} %F{003}🔋 %f%F{003}98%% (3:57) " "$(prompt_battery left 1 false ${FOLDER})"
}

function testBatterySegmentIfBatteryIsFullOnOSX() {
  local OS='OSX' # Fake OSX
  makeBatterySay "Now drawing from 'AC Power'
 -InternalBattery-0 (id=1234567)	99%; charged; 0:00 remaining present: true"

  assertEquals "%K{000} %F{002}🔋 %f%F{002}99%% " "$(prompt_battery left 1 false ${FOLDER})"
}

function testBatterySegmentIfBatteryIsCalculatingOnOSX() {
  local OS='OSX' # Fake OSX
  makeBatterySay "Now drawing from 'Battery Power'
 -InternalBattery-0 (id=1234567)	99%; discharging; (no estimate) present: true"

  assertEquals "%K{000} %F{007}🔋 %f%F{007}99%% (...) " "$(prompt_battery left 1 false ${FOLDER})"
}

function testBatterySegmentIfBatteryIsLowWhileDischargingOnLinux() {
  local OS='Linux' # Fake Linux
  makeBatterySay "4" "Discharging"

  assertEquals "%K{000} %F{001}🔋 %f%F{001}4%% " "$(prompt_battery left 1 false ${FOLDER})"
}

function testBatterySegmentIfBatteryIsLowWhileChargingOnLinux() {
  local OS='Linux' # Fake Linux
  makeBatterySay "4" "Charging"

  assertEquals "%K{000} %F{003}🔋 %f%F{003}4%% " "$(prompt_battery left 1 false ${FOLDER})"
}

function testBatterySegmentIfBatteryIsNormalWhileDischargingOnLinux() {
  local OS='Linux' # Fake Linux
  makeBatterySay "10" "Discharging"

  assertEquals "%K{000} %F{007}🔋 %f%F{007}10%% " "$(prompt_battery left 1 false ${FOLDER})"
}

function testBatterySegmentIfBatteryIsNormalWhileChargingOnLinux() {
  local OS='Linux' # Fake Linux
  makeBatterySay "10" "Charging"

  assertEquals "%K{000} %F{003}🔋 %f%F{003}10%% " "$(prompt_battery left 1 false ${FOLDER})"
}

function testBatterySegmentIfBatteryIsFullOnLinux() {
  local OS='Linux' # Fake Linux
  makeBatterySay "100" "Full"

  assertEquals "%K{000} %F{002}🔋 %f%F{002}100%% " "$(prompt_battery left 1 false ${FOLDER})"
}

function testBatterySegmentIfBatteryIsNormalWithAcpiEnabledOnLinux() {
  local OS='Linux' # Fake Linux
  makeBatterySay "50" "Discharging"
  echo "echo 'Batter 0: Discharging, 50%, 01:38:54 remaining'" > ${FOLDER}/usr/bin/acpi
  chmod +x ${FOLDER}/usr/bin/acpi
  # For running on Mac, we need to mock date :(
  [[ -f /usr/local/bin/gdate ]] && alias date=gdate

  assertEquals "%K{000} %F{007}🔋 %f%F{007}50%% (1:38) " "$(prompt_battery left 1 false ${FOLDER})"

  unalias date &>/dev/null
  # unaliasing date fails where it was never aliased (e.g. on Linux).
  # This causes the whole test to fail, because the return code is
  # non-zero.
  return 0
}

function testBatterySegmentIfBatteryIsCalculatingWithAcpiEnabledOnLinux() {
  local OS='Linux' # Fake Linux
  makeBatterySay "50" "Discharging"
  # Todo: Include real acpi output!
  echo "echo 'Batter 0: Discharging, 50%, rate remaining'" > ${FOLDER}/usr/bin/acpi
  chmod +x ${FOLDER}/usr/bin/acpi

  assertEquals "%K{000} %F{007}🔋 %f%F{007}50%% (...) " "$(prompt_battery left 1 false ${FOLDER})"
}

source shunit2/shunit2
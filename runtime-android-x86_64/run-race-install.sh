#!/bin/bash

# 
# Copyright 2023 Two Six Technologies
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 

# -----------------------------------------------------------------------------
# Script to install the RACE apk in the emulator, push necessary
# files and set up the env. This is run as a systemd service
# and should depend on the emulator service
# -----------------------------------------------------------------------------

function echo_with_time {
    echo "$(date +%c): $1"
}

echo_with_time "$0 called"

# Wait for emulator before installing apk
echo_with_time "Waiting for emulator to start"
echo_with_time "$PATH"
adb wait-for-device

# Wait for emulator before installing apk
while true; do
    echo_with_time "waiting for emulator to complete boot process..."
    if adb shell getprop dev.bootcomplete | grep "1"; then
       echo_with_time "emulator boot complete"
       break
    fi
    sleep 10
done

echo_with_time "waiting to prevent race condition..."
sleep 10
echo_with_time "installing race node daemon..."
adb install -g -t /android/x86_64/lib/race/core/race-daemon/race-daemon-android-debug.apk
# Make the daemon the device owner so it can perform silent installs
adb shell dpm set-device-owner com.twosix.race.daemon/.AdminReceiver
# Disable Play Protect
adb shell settings put global package_verifier_user_consent -1
echo_with_time "race node daemon installed"

if [[ $UNINSTALL_RACE = "yes" ]]; then
    echo_with_time "Skipping RACE install"
else
    # Install race app
    echo_with_time "installing race client..."
    adb install -g /android/x86_64/lib/race/core/race/race.apk
    echo_with_time "race client installed"

    # Copy Plugins
    echo_with_time "copying plugins..."
    adb shell mkdir -p /storage/self/primary/Download/race/artifacts/;
    adb push /android/x86_64/lib/race /storage/self/primary/;
    adb shell cp -r /storage/self/primary/race/* /storage/self/primary/Download/race/artifacts/;
    echo_with_time "plugins copied"
fi

echo_with_time "setting race encryption type to $RACE_ENCRYPTION_TYPE..."
adb shell setprop debug.RACE_ENCRYPTION_TYPE $RACE_ENCRYPTION_TYPE;
echo_with_time "race encryption type set to $RACE_ENCRYPTION_TYPE"

# Set Persona
# This command must be the last action related to starting the emulator because we use it in the
# container healthcheck to verify that all prior steps are complete. (The healthcheck also checks
# that the app installed properly because that failure should be loud. It would also show up in the
# systemd logs.)
echo_with_time "setting race persona to $RACE_PERSONA..."
adb shell setprop debug.RACE_PERSONA $RACE_PERSONA;
echo_with_time "race persona set to $RACE_PERSONA"

# Start daemon app
adb shell am start -n 'com.twosix.race.daemon/.MainActivity'

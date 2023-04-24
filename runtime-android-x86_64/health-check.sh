#!/usr/bin/env bash

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
# Android client image health check
# -----------------------------------------------------------------------------

# If emulated device is offline, we're not healthy (emulator failed to start/is still starting)
if ! /opt/android/platform-tools/adb devices | grep -qv offline; then
    exit 1
fi

# If the RACE node daemon app is not installed, we're not healthy (app failed to install/is still starting)
if ! /opt/android/platform-tools/adb shell pm list packages com.twosix.race.daemon | grep -q "package:com.twosix.race.daemon"; then
    exit 1
fi

if [[ $UNINSTALL_RACE != "yes" ]]; then
    # If the RACE client app is not installed when it should be, we're not healthy (app failed to install/is still starting)
    if ! /opt/android/platform-tools/adb shell pm list packages com.twosix.race | grep -q "package:com.twosix.race$"; then
        exit 1
    fi
fi

# If the RACE persona isn't set, we're not healthy (emulator didn't initialize/is still starting)
if ! /opt/android/platform-tools/adb shell getprop debug.RACE_PERSONA | grep -q "race"; then
    exit 1
fi

# If the RACE node daemon app is not running, we're not healthy
if ! /opt/android/platform-tools/adb shell ps -A | grep -q "com.twosix.race.daemon"; then
    exit 1
fi

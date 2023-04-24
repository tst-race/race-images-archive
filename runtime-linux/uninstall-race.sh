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
# Script to remove all RACE artifacts, if enabled via environment variable
# -----------------------------------------------------------------------------

if [[ $UNINSTALL_RACE = "yes" ]]; then
    echo "Uninstalling RACE..."
    rm -rf /usr/local/lib/librace*
    rm -rf /usr/local/lib/libRace*
    rm -rf /usr/local/lib/ta2Plugin*
    rm -rf /usr/local/lib/race/ta1/*
    rm -rf /usr/local/lib/race/ta2/*
    rm -rf /usr/local/lib/race/ta3/race
    rm -rf /usr/local/lib/race/ta31/*
    rm -rf /config/*
else
    echo "Skipping, nothing is uninstalled"
fi

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


# Function to print env variables. This is required so that race_wrapper.sh can source environment
# variable for services called by systemd
cat /proc/1/environ | while IFS='=' read -r -d '' n v; do
    # This is a hardcode list of variable that need it's values wrapped in quotes.
    # This list may need to be expanded if other variables require quotes
    if [ "NVIDIA_REQUIRE_CUDA" = "$n" ]; then
            printf "%s=\"%s\"\n" "$n" "$v"
    elif [ "SYSTEMD_PROC_CMDLINE" = "$n" ]; then
            printf "%s=\"%s\"\n" "$n" "$v"
    else
            printf "%s=%s\n" "$n" "$v"
    fi
done
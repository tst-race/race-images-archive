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


log_file=/var/log/systemd/watchdog-stdout.log

function clean_up {
  echo "--------------------------------------------------" >> $log_file
  echo "Removing lock files..." >> $log_file
  rm -fv /tmp/.X*-lock >> $log_file
  rm -fv /tmp/.X11-unix/* >> $log_file
  echo "All lock files are removed!" >> $log_file
  echo "--------------------------------------------------" >> $log_file
  exit 0
}

trap clean_up SIGTERM

while true; do
  sleep 1
done
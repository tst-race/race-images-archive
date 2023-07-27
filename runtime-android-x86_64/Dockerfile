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

FROM ubuntu:20.04

# Install base utilities (to handle installs)
RUN apt-get -y update && \
    apt-get install -y --no-install-recommends \
        openjdk-8-jre \
        wget \
        unzip

# Install Android emulator and platform tools
# (not sure why, but download seems to be more susceptible to hanging when all
# packages are installed in one command invocation)
ARG ANDROID_TOOLS_VERSION=6609375
RUN mkdir -p /opt/android/cmdline-tools && \
    cd /opt/android/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_TOOLS_VERSION}_latest.zip && \
    unzip commandlinetools-*.zip && \
    rm commandlinetools-*.zip
RUN yes | /opt/android/cmdline-tools/tools/bin/sdkmanager --licenses && \
    /opt/android/cmdline-tools/tools/bin/sdkmanager --install emulator && \
    /opt/android/cmdline-tools/tools/bin/sdkmanager --install platform-tools && \
    /opt/android/cmdline-tools/tools/bin/sdkmanager --install "platforms;android-29" && \
    /opt/android/cmdline-tools/tools/bin/sdkmanager --install "system-images;android-29;google_apis_playstore;x86_64"
ENV PATH=${PATH}:/opt/android/emulator:/opt/android/platform-tools

# Create Android Virtual Device (AVD)
RUN /opt/android/cmdline-tools/tools/bin/avdmanager create avd \
    --name android_29 \
    --abi google_apis_playstore/x86_64 \
    --package 'system-images;android-29;google_apis_playstore;x86_64' \
    --device pixel_3a
COPY config.ini /root/.android/avd/android_29.avd/config.ini

# Install packages
RUN apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        expect=5.45.4-* \
        openbox=3.6.1-* \
        tightvncserver=1.3.10-* \
        xfonts-base=1:1.0.* && \
    apt-get clean

# Setup VNC
ENV DISPLAY :1
EXPOSE 5901
COPY vncpass.sh /tmp/
COPY watchdog.sh /usr/local/bin/
RUN chmod +x /tmp/vncpass.sh; sync && \
    /tmp/vncpass.sh && \
    rm /tmp/vncpass.sh && \
    apt-get remove -y expect && apt-get autoremove -y

# Setup supervisor services
RUN apt-get update -y && apt-get install -y supervisor=4.1.0-*
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY health-check.sh \
     print_env_vars.sh \
     race_wrapper.sh \
     run-race-install.sh \
     /code/

COPY config.ini /root/.android/avd/android_29.avd/config.ini

###
# Configure Docker Container
###

# Setting Android HealthCheck
HEALTHCHECK --interval=10s \
    --retries=12 \
    --start-period=5m \
    CMD bash /code/health-check.sh

# Run Command
STOPSIGNAL SIGRTMIN+3
CMD [ "/usr/bin/supervisord", "-n" ]

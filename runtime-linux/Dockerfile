
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

FROM --platform=$TARGETPLATFORM nvidia/cuda:11.7.1-devel-ubuntu20.04 as base

ARG TARGETARCH
ARG TARGETPLATFORM

###
# Setup environment
###
ENV ANDROID_HOME=/opt/android \
    APP_ROOT=/code/ \
    CONFIG_ROOT=/config/ \
    DATA_ROOT=/data/ \
    DEV_DIR=/code/dev/ \
    ENVIRONMENT=development \
    LOG_ROOT=/log/ \
    RACE_ETC_PATH=/etc/race \
    RACE_NODE_TYPE= \
    RACE_PERSONA= \
    TMP_ROOT=/tmp/ \
    DEBIAN_FRONTEND=noninteractive \
    ANDROID_AAR_DEPS=/android/aar/

# Make Necessary Directories
RUN mkdir -p ${APP_ROOT} ${TMP_ROOT} ${CONFIG_ROOT} \
    ${DATA_ROOT} ${LOG_ROOT} ${DEV_DIR} ${RACE_ETC_PATH} ${ANDROID_AAR_DEPS}

###
# Install Linux Packages
###

# Add LLVM repository for clang 15
RUN apt-get -y update && \
    apt install software-properties-common -y && \
    apt-key adv --fetch-keys https://apt.llvm.org/llvm-snapshot.gpg.key && \
    add-apt-repository 'deb http://apt.llvm.org/focal/ llvm-toolchain-focal-15 main' \
    && rm -rf /var/lib/apt/lists/*

# Install utilities first
# Note: to get a list of current packages and versions run this command from within the image:
#     dpkg-query -l | awk '{print $2"="$3}'
RUN apt-get -y update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl=7.68.0* \
        emacs=1:26.3* \
        expect=5.45.4-* \
        file=1:5.38* \
        flex=2.6.4* \
        gettext=0.19.8.1* \
        git=1:2.25.1* \
        htop=2.2.0* \
        iftop=1.0* \
        iproute2=5.5.0* \
        iputils-ping=3:20190709* \
        jq=1.6* \
        lcov=1.14* \
        less=551* \
        lsof=4.93* \
        mtools=4.0.24* \
        net-tools=1.60* \
        netcat=1.206* \
        nmap=7.80* \
        openssh-server=1:8.2* \
        patchelf \
        pkg-config=0.29.1* \
        rhash=1.3.9* \
        sysstat=12.2.0* \
        tcpdump=4.9.3* \
        time=1.7-25.1* \
        traceroute=1:2.1.0* \
        tree=1.8.0* \
        unzip=6.0* \ 
        valgrind=1:3.15.0* \
        vim=2:8* \
        wget=1.20.3* \
        zip=3.0* && \
    update-ca-certificates -f \
    && rm -rf /var/lib/apt/lists/*

# Add CMake repository for cmake 3.23
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add - && \
    add-apt-repository "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main" \
    && rm -rf /var/lib/apt/lists/*

# Install build tools/libraries
RUN apt-get -y update && \
    apt-get install -y --no-install-recommends \
        automake=1:1.16.1* \
        autotools-dev=20180224.1 \
        binfmt-support=2.2.0-* \
        binutils=2.34* \
        binutils-dev=2.34* \
        bison=2:3.5.1* \
        build-essential=12.8* \
        byacc=20140715* \
        clang-15=1:15.0* \
        cmake=3.23.* \
        cmake-data=3.23.* \
        libclang-rt-15-dev=1:15.0* \
        dpkg-dev=1.19.7* \
        g++-7=7.5.0-6ubuntu2 \
        gcc-7=7.5.0-6ubuntu2 \
        libarchive-dev=3.4.0* \
        libbsd-dev=0.10.0* \
        libb64-dev=1.2* \
        libbz2-dev=1.0.8* \
        libcurl4-gnutls-dev=7.68.0* \
        libicu-dev=66.1* \
        libjpeg-dev=8c* \
        libjson-c-dev \
	libevent-dev \
        libsqlite3-dev \
        libltdl-dev=2.4.6* \
        libpcre3=2:8.39* \
        libpcre3-dev=2:8.39* \
        libprotobuf-c-dev=1.3.3* \
        libssh2-1=1.8.0* \
        libssl-dev=1.1.1* \
        libsodium-dev=1.0.18* \
        libtool=2.4.6* \
        libudev-dev=245* \
        libz3-dev=4.8.7* \
        llvm-15=1:15.0* \
        make=4.2* \
        picosat=965* \
        ruby-dev=1:2.7+1 \
        texinfo=6.7.0* && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 1 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 1 && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-15 1 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-15 1 \
    && rm -rf /var/lib/apt/lists/*

###
# Configure Language/Env
###

# Configure C/C++ Environment
ENV CC clang
ENV CXX clang++

# Configure Go Environment
WORKDIR ${TMP_ROOT}
ARG GO_VERSION=1.14.15
RUN case ${TARGETPLATFORM} in \
        "linux/amd64") LINUX_ARCH=amd64 ;; \
        "linux/arm64") LINUX_ARCH=arm64 ;; \
    esac && \
    wget \
        --output-document=/tmp/go${GO_VERSION}.linux-${LINUX_ARCH}.tar.gz \
        https://go.dev/dl/go${GO_VERSION}.linux-${LINUX_ARCH}.tar.gz && \
    tar --extract \
        --file=/tmp/go${GO_VERSION}.linux-${LINUX_ARCH}.tar.gz \
        --directory=/usr/local && \
    rm /tmp/go*.tar.gz
ENV GOROOT=/usr/local/go
ENV GOPATH=$HOME/Projects/Proj1
ENV PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# Configure Rust Environment
# We don't set CARGO_HOME as a permanent env var so that it defaults back to $HOME/.cargo for each
# user. But we install cargo to /opt/cargo so the binaries are globally accessible.
ENV PATH=/opt/cargo/bin:$PATH RUSTUP_HOME=/opt/rustup
RUN curl https://sh.rustup.rs -sSf | env CARGO_HOME=/opt/cargo sh -s -- --profile minimal -y
COPY cargo-config.toml /opt/cargo/config.toml
RUN rustup component add rustfmt && \
    rustup target add x86_64-linux-android && \
    rustup target add aarch64-linux-android

# Install Python
# NOTE: if Python gets updated you will also have to update
#     * the version being built as an external dependency for Android: external-dependencies/build_python.sh
#     * racesdk: https://gitlab.race.twosixlabs.com/race-common/racesdk/-/blob/51843e5d39f3514573f00dbc159f6d3a9f7cbb00/core/source/CMakeLists.txt#L68
#     * raceclient-android: https://gitlab.race.twosixlabs.com/race-common/raceclient-android/-/blob/15887ee8d68b8789b8e74c3ab9a763c48555f4b5/app/src/main/java/com/twosix/race/RaceSdkCreator.java#L354
#     * the external dependencies version in THIS repo (external-dependencies/versions.sh): https://gitlab.race.twosixlabs.com/race-ta3/race-images-base/-/blob/f98151bd9a8cb05fd322614b9919fba513b4da6f/external-dependencies/versions.sh#L44
#     * the version that the compile image pulls from artifactory in THIS repo (compile/Dockerfile): https://gitlab.race.twosixlabs.com/race-ta3/race-images-base/-/blob/develop/compile/Dockerfile#L449
RUN PYTHON_VERSION="3.7.17" && \
    apt update && \
    apt install software-properties-common -y && \
    add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get -y autoremove --purge software-properties-common && \
    apt update && \
    apt-get -y update && apt-get install -y --no-install-recommends \
        python3.7=${PYTHON_VERSION}-* \
        python3.7-dev=${PYTHON_VERSION}-* \
        python3-pip=20.0.2-* \
        python3-setuptools=45.2.0-* \
        python3-wheel=0.34.2-* \
        python3.7-tk=${PYTHON_VERSION}-* \
        python3.7-distutils=${PYTHON_VERSION}-* && \
    wget https://bootstrap.pypa.io/get-pip.py && \
    python3.7 get-pip.py && \
    python3.7 -m pip install --user --no-cache-dir --upgrade --force-reinstall pip && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.7 1 && \
    update-alternatives --set python /usr/bin/python3.7 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 1 && \
    update-alternatives --set python3 /usr/bin/python3.7 && \
    update-alternatives --install /usr/bin/python3-config python3-config /usr/bin/python3.7-config 1 && \
    update-alternatives --set python3-config /usr/bin/python3.7-config && \
    rm get-pip.py && \
    apt-get -y purge python3.8 && \
    apt-get -y autoremove && \
    apt-get -y update && apt-get install -y --no-install-recommends clang-format-10=1:10.* \
    && rm -rf /var/lib/apt/lists/*

# TODO: if we ever want to update to Python 3.8, that is the default for ubuntu:20.04
# RUN apt-get -y update && apt-get install -y --no-install-recommends \
#     python3.8=3.8.10-* \
#     python3.8-dev=3.8.10-* \
#     python3-pip=20.0.2-* \
#     python3-setuptools=45.2.0-* \
#     python3-wheel=0.34.2-* \
#     python3-tk=3.8.10-* && \
#     python3.8 -m pip install --no-cache-dir --upgrade --force-reinstall pip && \
#     update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1 && \
#     update-alternatives --set python /usr/bin/python3.8 && \
#     update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1 && \
#     update-alternatives --set python3 /usr/bin/python3.8 && \
#     update-alternatives --install /usr/bin/python3-config python3-config /usr/bin/python3.8-config 1 && \
#     update-alternatives --set python3-config /usr/bin/python3.8-config

# Configure Python Environment
ENV PYTHONPATH="$PYTHONPATH:$APP_ROOT:/usr/local/lib:/usr/local/lib/race/python/:/usr/local/lib/race/network-manager/:/usr/local/lib/race/comms/:/usr/local/lib/race/core/race/lib/python:/usr/local/lib/python3.7/dist-packages"
RUN ln -fs /usr/bin/python3.7 /usr/bin/python
RUN ln -fs /usr/bin/python3.7 /usr/bin/python3

# Install Python Dependencies
RUN python3.7 -m pip install --no-cache-dir wheel~=0.35.1
RUN python3.7 -m pip install --no-cache-dir \
    pylint==2.6.0 \
    pycryptodome~=3.15.0 \
    ordered_set~=4.0.2 \
    PyYAML~=5.4.1 \
    simplejson~=3.16.0

# Need to install clang-tidy-10 after PyYAML since it depends on it, but will install an earlier version of PyYAML (which we don't want) a dependency.
RUN apt-get -y update && \
    apt-get install -y --no-install-recommends \
        clang-tidy-10=1:10.*

# Configure Java Environment
# Install OpenJDK-8
RUN apt-get -y update && apt-get install -y --no-install-recommends openjdk-8-jdk=8* ant=1.10.7* maven=3.6.3*

# Fix certificate issues
# RUN dpkg --purge --force-depends ca-certificates-java
RUN apt-get -y update && apt-get install -y ca-certificates-java=20190405* && apt-get clean && update-ca-certificates -f;

# use openjdk 1.8
RUN update-java-alternatives --jre-headless --jre --set java-1.8.0-openjdk-${TARGETARCH} && \
    java -version

# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-${TARGETARCH}/

# Install Java Depenencies
WORKDIR ${TMP_ROOT}
COPY pom.xml ${TMP_ROOT}/pom.xml
RUN mvn dependency:copy-dependencies -DoutputDirectory=/usr/local/lib/race/java/ -Dhttps.protocols=TLSv1.2

# Install Jaeger Agent and Collector binaries
WORKDIR ${TMP_ROOT}
ARG JAEGER_VERSION=1.18.1
RUN case ${TARGETPLATFORM} in \
        "linux/amd64") LINUX_ARCH=amd64 ;; \
        "linux/arm64") LINUX_ARCH=arm64 ;; \
    esac && \
    wget \
        --output-document=/tmp/jaeger-${JAEGER_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        https://github.com/jaegertracing/jaeger/releases/download/v${JAEGER_VERSION}/jaeger-${JAEGER_VERSION}-linux-${LINUX_ARCH}.tar.gz && \
    tar --extract \
        --file=/tmp/jaeger-${JAEGER_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        --directory=/tmp && \
    cp /tmp/jaeger-${JAEGER_VERSION}-linux-${LINUX_ARCH}/jaeger-agent /usr/local/bin && \
    cp /tmp/jaeger-${JAEGER_VERSION}-linux-${LINUX_ARCH}/jaeger-collector /usr/local/bin && \
    rm -rf /tmp/jaeger-*

# Install Android CLI tools
WORKDIR ${ANDROID_HOME}
RUN mkdir cmdline-tools && cd cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip && \
    unzip commandlinetools-linux-6609375_latest.zip && \
    rm commandlinetools-linux-6609375_latest.zip
ENV PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/tools/bin

###
# Performer External Dependencies
###

# Install Shared Python Dependencies
RUN python3.7 -m pip install --no-cache-dir \
    jaeger-client~=4.6.0 \
    numpy>=1.21.* \
    psutil==5.7.2 \
    pytz==2020.1 \
    requests==2.26.* \
    scipy~=1.5.4 \
    tqdm~=4.52.0

# Install SRI TA1 System Dependencies
RUN apt-get -y update && \
    apt-get install -y \
        redis-server \
        libgmp3-dev=2:6.2.* \
    && rm -rf /var/lib/apt/lists/*

# Install SRI TA1 Python Dependencies
RUN python3.7 -m pip install --no-cache-dir \
    cbor2==5.4.* \
    colorama==0.4.* \
    cryptography==3.3.* \
    deepmerge==0.3.* \
    dnspython==2.1.0 \
    dynaconf==3.1.* \
    httpx==0.18.* \
    jinja2==2.11.* \
    natsort==7.1.* \
    networkx==2.5.* \
    opentracing==2.4.0 \
    progressbar2==3.53.* \
    pyopenssl==20.0.* \
    python-logstash==0.4.* \
    Quart~=0.15.0 \
    quart-cors==0.5.0 \
    quart_trio==0.8.0 \
    redis==3.5.* \
    requests[socks]==2.24.* \
    setuptools==62.* \
    structlog==21.1.* \
    trio==0.19.* \
    typing_inspect==0.7.*

# Install Stealth TA1 System Dependencies
RUN apt-get -y update && \
    apt-get install -y \
        libcurl4-openssl-dev \
        libsodium-dev \
    && rm -rf /var/lib/apt/lists/*

# Install SRI TA2 System Dependencies
WORKDIR ${TMP_ROOT}
RUN apt-get -y update && \
    apt-get install -y \
        libdbus-glib-1-2=0.110-* \
        gpac=0.5.2* \
        imagemagick=8:6.9.10.* \
        libevent-dev=2.1.* \
        libjpeg62-dev=1:6b2* \
        libjsoncpp-dev=1.7.4* \
        libpng-dev=1.6.37* \
        libx264-dev=2:0.155* \
        libxcb-shm0-dev=1.14* \
        libxml2-dev=2.9.10* \
        nasm=2.14.* \
        parallel=20161222* \
        php7.4-cli=7.4.3* \
        php7.4-gd=7.4.3* \
        software-properties-common=0.99.* \
        x11-apps=7.7* \
        xvfb=2:1.20.13-1* \
    && rm -rf /var/lib/apt/lists/*

WORKDIR ${TMP_ROOT}

# Install SRI TA2 Python Dependencies
RUN python3.7 -m pip install --no-cache-dir \
        beautifulsoup4~=4.9.3 \
        Flask~=2.0.3 \
        imageio~=2.9.0 \
        ipython~=7.19.0 \
        pillow~=9.5.0 \
        reedsolo~=1.5.4

RUN python3.7 -m pip install --no-cache-dir \
    webdrivermanager~=0.9.0 && \
    webdrivermanager firefox --linkpath /usr/local/bin

# When updating the major version of chrome, will also need to update the chromedriver
# to an appropriate version. See https://chromedriver.chromium.org/downloads/version-selection
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN apt-get -y update && \
    apt-get install -y --no-install-recommends \
        apt-utils=2.0.* \
        libcudnn8=8.3.1.22* \
    && rm -rf /var/lib/apt/lists/*
RUN apt-get -y update && TZ=America/New_York apt-get install -y tzdata

RUN curl -o /opt/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/89.0.4389.23/chromedriver_linux64.zip \
    && unzip /opt/chromedriver_linux64.zip -d /opt \
    && cp -rf /opt/chromedriver /usr/local/bin/chromedriver \
    && rm /opt/chromedriver_linux64.zip
RUN curl -o /opt/selenium-server-standalone-3.141.59.jar https://selenium-release.storage.googleapis.com/3.141/selenium-server-standalone-3.141.59.jar

# Install STR TA2 Python Dependencies
RUN python3.7 -m pip install --no-cache-dir \
    boto3==1.24.16 \
    cupy-cuda102==10.0.0 \
    essential_generators==1.0 \
    google-api-python-client==2.51.0 \
    google-auth-httplib2==0.1.0 \
    google-auth-oauthlib==0.4.6 \
    markovify==0.8.3 \
    onnx==1.10.2 \
    opencv-python~=4.5.1.48 \
    paramiko==2.7.2 \
    Pillow==9.5.0 \
    ping3==3.0.1 \
    protobuf==3.20.1 \
    pyautogui==0.9.53 \
    pyee==6.0.0 \
    pypng==0.0.20 \
    pyppeteer==0.0.25 \
    pysftp==0.2.9 \
    python-dateutil==2.8.1 \
    scikit-image~=0.18.1 \
    scikit-learn==0.24.1 \
    tensorflow-estimator==2.9.0 \
    websockets==6.0


# Install Georgetown Linux Dependencies
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    gnupg=2.2.* \
    && rm -rf /var/lib/apt/lists/*


# amd64-specific binaries
FROM base as amd64-installs
RUN python3.7 -m pip install --no-cache-dir \
    fixedint~=0.2.0 \
    torch~=1.7.0 \
    torchvision~=0.8.1 \
    transformers~=4.30.2

RUN wget http://ftp.mozilla.org/pub/firefox/releases/103.0/linux-$(uname -m)/en-US/firefox-103.0.tar.bz2 && \
    tar -xjf firefox-103.0.tar.bz2 && \
    mv firefox /opt/ && \
    ln -s /opt/firefox/firefox /usr/bin/firefox && \
    rm -rf firefox*

RUN python3.7 -m pip install --no-cache-dir tensorflow==2.5.0

ARG CHROME_VERSION=89.0.4389.72-1
RUN \
    wget \
        --output-document=/tmp/google-chrome-stable_${CHROME_VERSION}_amd64.deb \
        http://mirror.cs.uchicago.edu/google-chrome/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_VERSION}_amd64.deb && \
    apt-get update -y && apt-get install -yy /tmp/google-chrome-stable_${CHROME_VERSION}_amd64.deb && \
    rm /tmp/google-chrome-stable_*.deb \
    && rm -rf /var/lib/apt/lists/*

RUN ldconfig /usr/local/cuda-11.7/targets/x86_64-linux/lib/stubs && ldconfig 
RUN python3.7 -m pip install --no-cache-dir numba==0.51.2

# arm64-specific binaries
FROM base as arm64-installs
# TODO these versions of torch* may not work for SRI
# consider build the older versions from source
RUN python3.7 -m pip install --no-cache-dir \
    fixedint~=0.2.0 \
    torch~=1.8.0 \
    torchvision~=0.9.0 \
    transformers~=4.30.2

RUN python3.7 -m pip install --no-cache-dir tensorflow-aarch64==2.7.4
RUN apt-get -y update && apt-get -y install chromium-browser \
    && rm -rf /var/lib/apt/lists/*
RUN ldconfig /usr/local/cuda-11.7/targets/sbsa-linux/lib/stubs && ldconfig

RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-py37_4.12.0-Linux-aarch64.sh && \
    chmod 764 Miniconda3-py37_4.12.0-Linux-aarch64.sh && \
    ./Miniconda3-py37_4.12.0-Linux-aarch64.sh -b && \
    /root/miniconda3/bin/conda init zsh && \
    /root/miniconda3/bin/conda init && \
    exec bash && \
    conda install numba=0.53.1 && \
    rm Miniconda3-py37_4.12.0-Linux-aarch64.sh

# finally install the correct keys, binaries, etc from the multi-stage builds based on TARGETARCH=[amd64, arm64]
FROM ${TARGETARCH}-installs

# Clean up any downloaded files
RUN rm -rf ${TMP_ROOT}/*

# Add cuda to library path so that cupy can find it
# ENV CUDA_PATH=/usr/local/cuda-11.7 -- in case cupy raises CompileException https://docs.cupy.dev/en/stable/install.html
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda-11.7/lib64

# Set last working dir back to app root
WORKDIR ${APP_ROOT}

###
# Install custom-built library dependencies
###

#
# To use a locally-built version of a library:
#
# 1. Copy the resulting `.tar.gz` file into this directory
# 2. Comment out the `RUN` statement that fetches the library
#    from github
# 3. Add the following `ADD` statement in its place (using the
#    appropriate values for `name`, `version`, and `arch`):
#
#    ADD {name}-{version}-linux-{arch}.tar.gz /usr/local/
#

# Boost
ARG BOOST_VERSION=1.73.0-1
RUN case ${TARGETPLATFORM} in \
        "linux/amd64") LINUX_ARCH=x86_64    ;; \
        "linux/arm64") LINUX_ARCH=arm64-v8a ;; \
    esac && \
    wget \
        --output-document=/tmp/boost-${BOOST_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        https://github.com/tst-race/ext-boost/releases/download/${BOOST_VERSION}/boost-${BOOST_VERSION}-linux-${LINUX_ARCH}.tar.gz && \
    tar --extract \
        --file=/tmp/boost-${BOOST_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        --directory=/usr/local && \
    rm /tmp/boost-*.tar.gz

# cpprest
ARG CPPREST_VERSION=2.10.18-1
RUN case ${TARGETPLATFORM} in \
        "linux/amd64") LINUX_ARCH=x86_64    ;; \
        "linux/arm64") LINUX_ARCH=arm64-v8a ;; \
    esac && \
    wget \
        --output-document=/tmp/cpprest-${CPPREST_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        https://github.com/tst-race/ext-cpprest/releases/download/${CPPREST_VERSION}/cpprest-${CPPREST_VERSION}-linux-${LINUX_ARCH}.tar.gz && \
    tar --extract \
        --file=/tmp/cpprest-${CPPREST_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        --directory=/usr/local && \
    rm /tmp/cpprest-*.tar.gz

# ffmpeg
ARG FFMPEG_VERSION=4.2.2-1
RUN case ${TARGETPLATFORM} in \
        "linux/amd64") LINUX_ARCH=x86_64    ;; \
        "linux/arm64") LINUX_ARCH=arm64-v8a ;; \
    esac && \
    wget \
        --output-document=/tmp/ffmpeg-${FFMPEG_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        https://github.com/tst-race/ext-ffmpeg/releases/download/${FFMPEG_VERSION}/ffmpeg-${FFMPEG_VERSION}-linux-${LINUX_ARCH}.tar.gz && \
    tar --extract \
        --file=/tmp/ffmpeg-${FFMPEG_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        --directory=/usr/local && \
    rm /tmp/ffmpeg-*.tar.gz

# GDB
ARG GDB_VERSION=12.1-1
RUN case ${TARGETPLATFORM} in \
        "linux/amd64") LINUX_ARCH=x86_64    ;; \
        "linux/arm64") LINUX_ARCH=arm64-v8a ;; \
    esac && \
    wget \
        --output-document=/tmp/gdb-${GDB_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        https://github.com/tst-race/ext-gdb/releases/download/${GDB_VERSION}/gdb-${GDB_VERSION}-linux-${LINUX_ARCH}.tar.gz && \
    tar --extract \
        --file=/tmp/gdb-${GDB_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        --directory=/usr/local && \
    rm /tmp/gdb-*.tar.gz

# GoogleTest
ARG GOOGLETEST_VERSION=1.12.0-1
RUN case ${TARGETPLATFORM} in \
        "linux/amd64") LINUX_ARCH=x86_64    ;; \
        "linux/arm64") LINUX_ARCH=arm64-v8a ;; \
    esac && \
    wget \
        --output-document=/tmp/googletest-${GOOGLETEST_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        https://github.com/tst-race/ext-googletest/releases/download/${GOOGLETEST_VERSION}/googletest-${GOOGLETEST_VERSION}-linux-${LINUX_ARCH}.tar.gz && \
    tar --extract \
        --file=/tmp/googletest-${GOOGLETEST_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        --directory=/usr/local && \
    rm /tmp/googletest-*.tar.gz

# Jaeger Client
ARG JAEGER_CLIENT_VERSION=0.6.0-1
RUN case ${TARGETPLATFORM} in \
        "linux/amd64") LINUX_ARCH=x86_64    ;; \
        "linux/arm64") LINUX_ARCH=arm64-v8a ;; \
    esac && \
    wget \
        --output-document=/tmp/jaeger-client-cpp-${JAEGER_CLIENT_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        https://github.com/tst-race/ext-jaeger-client-cpp/releases/download/${JAEGER_CLIENT_VERSION}/jaeger-client-cpp-${JAEGER_CLIENT_VERSION}-linux-${LINUX_ARCH}.tar.gz && \
    tar --extract \
        --file=/tmp/jaeger-client-cpp-${JAEGER_CLIENT_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        --directory=/usr/local && \
    rm /tmp/jaeger-client-cpp-*.tar.gz

# libzip
ARG LIBZIP_VERSION=1.8.0-1
RUN case ${TARGETPLATFORM} in \
        "linux/amd64") LINUX_ARCH=x86_64    ;; \
        "linux/arm64") LINUX_ARCH=arm64-v8a ;; \
    esac && \
    wget \
        --output-document=/tmp/libzip-${LIBZIP_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        https://github.com/tst-race/ext-libzip/releases/download/${LIBZIP_VERSION}/libzip-${LIBZIP_VERSION}-linux-${LINUX_ARCH}.tar.gz && \
    tar --extract \
        --file=/tmp/libzip-${LIBZIP_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        --directory=/usr/local && \
    rm /tmp/libzip-*.tar.gz

# nlohmann-json
ARG NGINX_VERSION=1.14.0-1
RUN case ${TARGETPLATFORM} in \
        "linux/amd64") LINUX_ARCH=x86_64    ;; \
        "linux/arm64") LINUX_ARCH=arm64-v8a ;; \
    esac && \
    wget \
        --output-document=/tmp/nginx-${NGINX_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        https://github.com/tst-race/ext-nginx/releases/download/${NGINX_VERSION}/nginx-${NGINX_VERSION}-linux-${LINUX_ARCH}.tar.gz && \
    tar --extract \
        --file=/tmp/nginx-${NGINX_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        --directory=/usr/local && \
    rm /tmp/nginx-*.tar.gz

# nlohmann-json
ARG NLOHMANN_JSON_VERSION=3.10.5-1
RUN case ${TARGETPLATFORM} in \
        "linux/amd64") LINUX_ARCH=x86_64    ;; \
        "linux/arm64") LINUX_ARCH=arm64-v8a ;; \
    esac && \
    wget \
        --output-document=/tmp/nlohmann-json-${NLOHMANN_JSON_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        https://github.com/tst-race/ext-nlohmann-json/releases/download/${NLOHMANN_JSON_VERSION}/nlohmann-json-${NLOHMANN_JSON_VERSION}-linux-${LINUX_ARCH}.tar.gz && \
    tar --extract \
        --file=/tmp/nlohmann-json-${NLOHMANN_JSON_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        --directory=/usr/local && \
    rm /tmp/nlohmann-json-*.tar.gz

# NTL
ARG NTL_VERSION=11.4.4-1
RUN case ${TARGETPLATFORM} in \
        "linux/amd64") LINUX_ARCH=x86_64    ;; \
        "linux/arm64") LINUX_ARCH=arm64-v8a ;; \
    esac && \
    wget \
        --output-document=/tmp/ntl-${NTL_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        https://github.com/tst-race/ext-ntl/releases/download/${NTL_VERSION}/ntl-${NTL_VERSION}-linux-${LINUX_ARCH}.tar.gz && \
    tar --extract \
        --file=/tmp/ntl-${NTL_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        --directory=/usr/local && \
    rm /tmp/ntl-*.tar.gz

# OpenTracing C++ API
ARG OPENTRACING_CPP_VERSION=1.6.0-1
RUN case ${TARGETPLATFORM} in \
        "linux/amd64") LINUX_ARCH=x86_64    ;; \
        "linux/arm64") LINUX_ARCH=arm64-v8a ;; \
    esac && \
    wget \
        --output-document=/tmp/opentracing-cpp-${OPENTRACING_CPP_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        https://github.com/tst-race/ext-opentracing-cpp/releases/download/${OPENTRACING_CPP_VERSION}/opentracing-cpp-${OPENTRACING_CPP_VERSION}-linux-${LINUX_ARCH}.tar.gz && \
    tar --extract \
        --file=/tmp/opentracing-cpp-${OPENTRACING_CPP_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        --directory=/usr/local && \
    rm /tmp/opentracing-cpp-*.tar.gz

# PBC
ARG PBC_VERSION=0.5.14-1
RUN case ${TARGETPLATFORM} in \
        "linux/amd64") LINUX_ARCH=x86_64    ;; \
        "linux/arm64") LINUX_ARCH=arm64-v8a ;; \
    esac && \
    wget \
        --output-document=/tmp/pbc-${PBC_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        https://github.com/tst-race/ext-pbc/releases/download/${PBC_VERSION}/pbc-${PBC_VERSION}-linux-${LINUX_ARCH}.tar.gz && \
    tar --extract \
        --file=/tmp/pbc-${PBC_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        --directory=/usr/local && \
    rm /tmp/pbc-*.tar.gz

# Apache Thrift
ARG THRIFT_VERSION=0.12.0-1
RUN case ${TARGETPLATFORM} in \
        "linux/amd64") LINUX_ARCH=x86_64    ;; \
        "linux/arm64") LINUX_ARCH=arm64-v8a ;; \
    esac && \
    wget \
        --output-document=/tmp/thrift-${THRIFT_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        https://github.com/tst-race/ext-thrift/releases/download/${THRIFT_VERSION}/thrift-${THRIFT_VERSION}-linux-${LINUX_ARCH}.tar.gz && \
    tar --extract \
        --file=/tmp/thrift-${THRIFT_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        --directory=/usr/local && \
    rm /tmp/thrift-*.tar.gz

# yaml-cpp
ARG YAML_CPP_VERSION=0.6.2-1
RUN case ${TARGETPLATFORM} in \
        "linux/amd64") LINUX_ARCH=x86_64    ;; \
        "linux/arm64") LINUX_ARCH=arm64-v8a ;; \
    esac && \
    wget \
        --output-document=/tmp/yaml-cpp-${YAML_CPP_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        https://github.com/tst-race/ext-yaml-cpp/releases/download/${YAML_CPP_VERSION}/yaml-cpp-${YAML_CPP_VERSION}-linux-${LINUX_ARCH}.tar.gz && \
    tar --extract \
        --file=/tmp/yaml-cpp-${YAML_CPP_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        --directory=/usr/local && \
    rm /tmp/yaml-cpp-*.tar.gz

# Jerasure
ARG JERASURE_VERSION=2.0-1
RUN case ${TARGETPLATFORM} in \
        "linux/amd64") LINUX_ARCH=x86_64    ;; \
        "linux/arm64") LINUX_ARCH=arm64-v8a ;; \
    esac && \
    wget \
        --output-document=/tmp/jerasure-${JERASURE_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        https://github.com/tst-race/ext-jerasure/releases/download/${JERASURE_VERSION}/jerasure-${JERASURE_VERSION}-linux-${LINUX_ARCH}.tar.gz && \
    tar --extract \
        --file=/tmp/jerasure-${JERASURE_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        --directory=/usr/local && \
    rm /tmp/jerasure-*.tar.gz

# Liberasurecode
ARG LIBERASURECODE_VERSION=1.6.2-1
RUN case ${TARGETPLATFORM} in \
        "linux/amd64") LINUX_ARCH=x86_64    ;; \
        "linux/arm64") LINUX_ARCH=arm64-v8a ;; \
    esac && \
    wget \
        --output-document=/tmp/liberasurecode-${LIBERASURECODE_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        https://github.com/tst-race/ext-liberasurecode/releases/download/${LIBERASURECODE_VERSION}/liberasurecode-${LIBERASURECODE_VERSION}-linux-${LINUX_ARCH}.tar.gz && \
    tar --extract \
        --file=/tmp/liberasurecode-${LIBERASURECODE_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        --directory=/usr/local && \
    rm /tmp/liberasurecode-*.tar.gz

# gf-complete
ARG GF_COMPLETE_VERSION=1.0.3-1
RUN case ${TARGETPLATFORM} in \
        "linux/amd64") LINUX_ARCH=x86_64    ;; \
        "linux/arm64") LINUX_ARCH=arm64-v8a ;; \
    esac && \
    wget \
        --output-document=/tmp/gf-complete-${GF_COMPLETE_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        https://github.com/tst-race/ext-gf-complete/releases/download/${GF_COMPLETE_VERSION}/gf-complete-${GF_COMPLETE_VERSION}-linux-${LINUX_ARCH}.tar.gz && \
    tar --extract \
        --file=/tmp/gf-complete-${GF_COMPLETE_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        --directory=/usr/local && \
    rm /tmp/gf-complete-*.tar.gz

###
# Install Linux Packages
###


# Install build tools/libraries after
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    bridge-utils=1.6-* \
    openbox=3.6.1-* \
    ruby-dev=1:2.7+* \
    tightvncserver=1.3.10-* \
    xfonts-base=1:1.0.* \
    locales=2.31-* && \
    apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# TODO: not entirely sure these are needed. Adding for now since libvirt-bin is no longer avaiable when upgrading from 18.04 to 20.04. Try to remove it later and see if it's all good.
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    libvirt-daemon-system libvirt-clients \
    && rm -rf /var/lib/apt/lists/*

###
# Configure supervisor
###

RUN apt-get update -y && apt-get install -y supervisor=4.1.0-* \
    && rm -rf /var/lib/apt/lists/*
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY race_wrapper.sh \
   print_env_vars.sh \
   uninstall-race.sh \
   /code/
RUN apt-get update && apt-get install cron -yy \
    && rm -rf /var/lib/apt/lists/*
RUN mkdir /race-service-logs
RUN mkdir /logs

# Copy nginx configuration service files.
COPY nginx.conf.selfsigned /usr/local/conf/nginx.conf

# Setup certificates for nginx.
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=raceserver" -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt && \
    openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048 > /dev/null


###
# Creating Symlinks for node-daemon, racesecli, racetestapp, python, and racesdk java shims.
###

RUN ln -s /usr/local/lib/race/core/race-daemon/bin/race-daemon-linux /usr/local/bin/race-daemon-linux && \
    ln -s /usr/local/lib/race/core/race/bin/racesecli /usr/local/bin/racesecli && \
    ln -s /usr/local/lib/race/core/race/bin/racetestapp /usr/local/bin/racetestapp && \
    ln -s /usr/local/lib/race/core/race/lib/python /usr/local/lib/race/python && \
    ln -s /usr/local/lib/race/core/race/lib/java/racesdk-java-shims-1.jar /usr/local/lib/race/java/racesdk-java-shims-1.jar

HEALTHCHECK --interval=30s --timeout=10s \
    CMD supervisorctl status race-daemon | grep RUNNING

# Run Command
STOPSIGNAL SIGRTMIN+3
CMD [ "/usr/bin/supervisord", "-n" ]

ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib/race/core/race/lib

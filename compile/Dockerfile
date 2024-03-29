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

FROM ghcr.io/tst-race/ext-builder:main

###
# Compilers/tools
###

ARG TARGETARCH
ARG TARGETPLATFORM

# Android
RUN sdkmanager --install "platforms;android-29" && \
    sdkmanager --install "build-tools;31.0.0" && \
    ln -s /opt/android/build-tools/31.0.0 /opt/android/build-tools/default && \
    # Hack because the version of the Android Gradle Plugin we use (4.0.1)
    # thinks build-tools is corrupt without these files. It doesn't use them,
    # they just have to exist. This is fixed in version 7.X of the plugin,
    # but that would require gradle version 7.5+ which then requires JDK 11.
    # Since we don't want to include JDK 11 in the image, we create these
    # empty files to satisfy the Android Gradle Plugin.
    touch /opt/android/build-tools/31.0.0/dx && \
    touch /opt/android/build-tools/31.0.0/lib/dx.jar
ENV ANDROID_HOME=/opt/android

# Go
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
ENV GOROOT=/usr/local/go \
    PATH=/usr/local/go/bin:$PATH

# Java
RUN apt-get -y update && \
    apt-get install -y --no-install-recommends \
        openjdk-8-jdk=8* \
        maven=3.6.3* \
        ca-certificates-java=20190405* && \
    case ${TARGETPLATFORM} in \
        "linux/amd64") \
            apt-get install -y --no-install-recommends \
                openjdk-8-jdk:arm64=8* ;; \
    esac && \
    apt-get clean && \
    update-ca-certificates -f && \
    update-java-alternatives --jre-headless --jre --set java-1.8.0-openjdk-${TARGETARCH}
# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-${TARGETARCH}/

# Rust
# We don't set CARGO_HOME as a permanent env var so that it defaults back to $HOME/.cargo for each
# user. But we install cargo to /opt/cargo so the binaries are globally accessible.
ENV PATH=/opt/cargo/bin:$PATH RUSTUP_HOME=/opt/rustup
RUN wget \
        --output-document=/tmp/rustup.sh \
        https://sh.rustup.rs && \
    CARGO_HOME=/opt/cargo sh /tmp/rustup.sh --profile minimal -y && \
    rustup component add rustfmt && \
    rustup target add x86_64-linux-android && \
    rustup target add aarch64-linux-android && \
    case ${TARGETPLATFORM} in \
        "linux/amd64") \
            rustup target add aarch64-unknown-linux-gnu ;; \
    esac && \
    rm /tmp/rustup.sh

# Python
ARG PYTHON_VERSION=3.7.17
RUN apt-get update -y && \
    add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
        python3.7=${PYTHON_VERSION}-* \
        python3.7-dev=${PYTHON_VERSION}-* \
        python3-pip=20.0.2-* \
        python3-setuptools=45.2.0-* \
        python3-wheel=0.34.2-* \
        python3.7-tk=${PYTHON_VERSION}-* \
        python3.7-distutils=${PYTHON_VERSION}-* && \
    case ${TARGETPLATFORM} in \
        "linux/amd64") \
            apt-get install -y --no-install-recommends \
                libpython3.7-dev:arm64=${PYTHON_VERSION}-* ;; \
    esac && \
    wget https://bootstrap.pypa.io/get-pip.py && \
    python3.7 get-pip.py && \
    python3.7 -m pip install --user --no-cache-dir --upgrade --force-reinstall pip && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.7 1 && \
    update-alternatives --set python /usr/bin/python3.7 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 1 && \
    update-alternatives --set python3 /usr/bin/python3.7 && \
    update-alternatives --install /usr/bin/python3-config python3-config /usr/bin/python3.7-config 1 && \
    update-alternatives --set python3-config /usr/bin/python3.7-config && \
    rm get-pip.py

# Build tools
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        clang-format-10=1:10.* \
        clang-tidy-10=1:10.* \
	g++=4:9.3.* \
        lcov=1.14* \
	libjsoncpp-dev \
        libjson-c-dev \
	libevent-dev \
        libsqlite3-dev \
        # JDK 11 is needed for google-java-format
        m4=1.4.* \
        openjdk-11-jre-headless=11.0* \
        picosat=965* \
        pkg-config=0.29.1* \
        valgrind=1:3.15.0*

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
#    For Linux:
#
#        ADD {name}-{version}-linux-{arch}.tar.gz /usr/local/
#
#    For Android:
#
#        ADD {name}-{version}-android-{arch}.tar.gz /android/{arch}/
#

# Create library download locations.
RUN for OS in linux android; do \
        for ARCH in x86_64 arm64-v8a; do \
            mkdir -p /${OS}/${ARCH}; \
        done; \
    done

# Boost
ARG BOOST_VERSION=1.73.0-1
RUN for OS in linux android; do \
        for ARCH in x86_64 arm64-v8a; do \
            wget \
                --output-document=/tmp/boost-${BOOST_VERSION}-${OS}-${ARCH}.tar.gz \
                https://github.com/tst-race/ext-boost/releases/download/${BOOST_VERSION}/boost-${BOOST_VERSION}-${OS}-${ARCH}.tar.gz && \
            tar --extract \
                --file=/tmp/boost-${BOOST_VERSION}-${OS}-${ARCH}.tar.gz \
                --directory=/${OS}/${ARCH}; \
        done; \
    done && \
    rm /tmp/boost-*.tar.gz

# Cppcheck (Linux-only)
ARG CPPCHECK_VERSION=2.4.1-1
RUN case ${TARGETPLATFORM} in \
        "linux/amd64") LINUX_ARCH=x86_64    ;; \
        "linux/arm64") LINUX_ARCH=arm64-v8a ;; \
    esac && \
    wget \
        --output-document=/tmp/cppcheck-${CPPCHECK_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        https://github.com/tst-race/ext-cppcheck/releases/download/${CPPCHECK_VERSION}/cppcheck-${CPPCHECK_VERSION}-linux-${LINUX_ARCH}.tar.gz && \
    tar --extract \
        --file=/tmp/cppcheck-${CPPCHECK_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        --directory=/usr/local && \
    rm /tmp/cppcheck-*.tar.gz

# cpprest
ARG CPPREST_VERSION=2.10.18-1
RUN for OS in linux android; do \
        for ARCH in x86_64 arm64-v8a; do \
            wget \
                --output-document=/tmp/cpprest-${CPPREST_VERSION}-${OS}-${ARCH}.tar.gz \
                https://github.com/tst-race/ext-cpprest/releases/download/${CPPREST_VERSION}/cpprest-${CPPREST_VERSION}-${OS}-${ARCH}.tar.gz && \
            tar --extract \
                --file=/tmp/cpprest-${CPPREST_VERSION}-${OS}-${ARCH}.tar.gz \
                --directory=/${OS}/${ARCH}; \
        done; \
    done && \
    rm /tmp/cpprest-*.tar.gz

# curl
ARG CURL_VERSION=7.58.0-1
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        libcurl4-gnutls-dev=7.68.0* && \
    case ${TARGETPLATFORM} in \
        "linux/amd64") \
            apt-get install -y --no-install-recommends \
                libcurl4-gnutls-dev:arm64=7.68.0* ;; \
    esac
RUN for ARCH in x86_64 arm64-v8a; do \
        wget \
            --output-document=/tmp/curl-${CURL_VERSION}-android-${ARCH}.tar.gz \
            https://github.com/tst-race/ext-curl/releases/download/${CURL_VERSION}/curl-${CURL_VERSION}-android-${ARCH}.tar.gz && \
        tar --extract \
            --file=/tmp/curl-${CURL_VERSION}-android-${ARCH}.tar.gz \
            --directory=/android/${ARCH}; \
    done && \
    rm /tmp/curl-*.tar.gz

# GDB (Linux-only)
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

# GoogleTest (Linux-only)
ARG GOOGLETEST_VERSION=1.12.0-1
RUN for ARCH in x86_64 arm64-v8a; do \
        wget \
            --output-document=/tmp/googletest-${GOOGLETEST_VERSION}-linux-${ARCH}.tar.gz \
            https://github.com/tst-race/ext-googletest/releases/download/${GOOGLETEST_VERSION}/googletest-${GOOGLETEST_VERSION}-linux-${ARCH}.tar.gz && \
        tar --extract \
            --file=/tmp/googletest-${GOOGLETEST_VERSION}-linux-${ARCH}.tar.gz \
            --directory=/linux/${ARCH}; \
    done && \
    rm /tmp/googletest-*.tar.gz

# Jaeger Client
ARG JAEGER_CLIENT_VERSION=0.6.0-1
RUN for OS in linux android; do \
        for ARCH in x86_64 arm64-v8a; do \
            wget \
                --output-document=/tmp/jaeger-client-cpp-${JAEGER_CLIENT_VERSION}-${OS}-${ARCH}.tar.gz \
                https://github.com/tst-race/ext-jaeger-client-cpp/releases/download/${JAEGER_CLIENT_VERSION}/jaeger-client-cpp-${JAEGER_CLIENT_VERSION}-${OS}-${ARCH}.tar.gz && \
            tar --extract \
                --file=/tmp/jaeger-client-cpp-${JAEGER_CLIENT_VERSION}-${OS}-${ARCH}.tar.gz \
                --directory=/${OS}/${ARCH}; \
        done; \
    done && \
    rm /tmp/jaeger-client-cpp-*.tar.gz

# jsoncpp
ARG JSONCPP_VERSION=1.9.5-1
RUN for OS in linux android; do \
        for ARCH in x86_64 arm64-v8a; do \
            wget \
                --output-document=/tmp/jsoncpp-${JSONCPP_VERSION}-${OS}-${ARCH}.tar.gz \
                https://github.com/tst-race/ext-jsoncpp/releases/download/${JSONCPP_VERSION}/jsoncpp-${JSONCPP_VERSION}-${OS}-${ARCH}.tar.gz && \
            tar --extract \
                --file=/tmp/jsoncpp-${JSONCPP_VERSION}-${OS}-${ARCH}.tar.gz \
                --directory=/${OS}/${ARCH}; \
        done; \
    done && \
    rm /tmp/jsoncpp-*.tar.gz

# libarchive
ARG LIBARCHIVE_VERSION=3.3.2-2
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        libarchive-dev=3.4.0* && \
    case ${TARGETPLATFORM} in \
        "linux/amd64") \
            apt-get install -y --no-install-recommends \
                libarchive-dev:arm64=3.4.0* ;; \
    esac
RUN for ARCH in x86_64 arm64-v8a; do \
        wget \
            --output-document=/tmp/libarchive-${LIBARCHIVE_VERSION}-android-${ARCH}.tar.gz \
            https://github.com/tst-race/ext-libarchive/releases/download/${LIBARCHIVE_VERSION}/libarchive-${LIBARCHIVE_VERSION}-android-${ARCH}.tar.gz && \
        tar --extract \
            --file=/tmp/libarchive-${LIBARCHIVE_VERSION}-android-${ARCH}.tar.gz \
            --directory=/android/${ARCH}; \
    done && \
    rm /tmp/libarchive-*.tar.gz

# libffi (Android-only)
ARG LIBFFI_VERSION=3.3-1
RUN for ARCH in x86_64 arm64-v8a; do \
        wget \
            --output-document=/tmp/libffi-${LIBFFI_VERSION}-android-${ARCH}.tar.gz \
            https://github.com/tst-race/ext-libffi/releases/download/${LIBFFI_VERSION}/libffi-${LIBFFI_VERSION}-android-${ARCH}.tar.gz && \
        tar --extract \
            --file=/tmp/libffi-${LIBFFI_VERSION}-android-${ARCH}.tar.gz \
            --directory=/android/${ARCH}; \
    done && \
    rm /tmp/libffi-*.tar.gz

# libzip
ARG LIBZIP_VERSION=1.8.0-1
RUN for OS in linux android; do \
        for ARCH in x86_64 arm64-v8a; do \
            wget \
                --output-document=/tmp/libzip-${LIBZIP_VERSION}-${OS}-${ARCH}.tar.gz \
                https://github.com/tst-race/ext-libzip/releases/download/${LIBZIP_VERSION}/libzip-${LIBZIP_VERSION}-${OS}-${ARCH}.tar.gz && \
            tar --extract \
                --file=/tmp/libzip-${LIBZIP_VERSION}-${OS}-${ARCH}.tar.gz \
                --directory=/${OS}/${ARCH}; \
        done; \
    done && \
    rm /tmp/libzip-*.tar.gz

# nlohmann-json
ARG NLOHMANN_JSON_VERSION=3.10.5-1
RUN for OS in linux android; do \
        for ARCH in x86_64 arm64-v8a; do \
            wget \
                --output-document=/tmp/nlohmann-json-${NLOHMANN_JSON_VERSION}-${OS}-${ARCH}.tar.gz \
                https://github.com/tst-race/ext-nlohmann-json/releases/download/${NLOHMANN_JSON_VERSION}/nlohmann-json-${NLOHMANN_JSON_VERSION}-${OS}-${ARCH}.tar.gz && \
            tar --extract \
                --file=/tmp/nlohmann-json-${NLOHMANN_JSON_VERSION}-${OS}-${ARCH}.tar.gz \
                --directory=/${OS}/${ARCH}; \
        done; \
    done && \
    rm /tmp/nlohmann-json-*.tar.gz

# NTL (Linux-only)
ARG NTL_VERSION=11.4.4-1
RUN for ARCH in x86_64 arm64-v8a; do \
        wget \
            --output-document=/tmp/ntl-${NTL_VERSION}-linux-${ARCH}.tar.gz \
            https://github.com/tst-race/ext-ntl/releases/download/${NTL_VERSION}/ntl-${NTL_VERSION}-linux-${ARCH}.tar.gz && \
        tar --extract \
            --file=/tmp/ntl-${NTL_VERSION}-linux-${ARCH}.tar.gz \
            --directory=/linux/${ARCH}; \
    done && \
    rm /tmp/ntl-*.tar.gz

# OpenSSL
ARG OPENSSL_VERSION=1.1.1l-1
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        libssl-dev=1.1.1* && \
    case ${TARGETPLATFORM} in \
        "linux/amd64") \
            apt-get install -y --no-install-recommends \
                libssl-dev:arm64=1.1.1* ;; \
    esac
RUN for ARCH in x86_64 arm64-v8a; do \
        wget \
            --output-document=/tmp/openssl-${OPENSSL_VERSION}-android-${ARCH}.tar.gz \
            https://github.com/tst-race/ext-openssl/releases/download/${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}-android-${ARCH}.tar.gz && \
        tar --extract \
            --file=/tmp/openssl-${OPENSSL_VERSION}-android-${ARCH}.tar.gz \
            --directory=/android/${ARCH}; \
    done && \
    rm /tmp/openssl-*.tar.gz

# OpenTracing C++ API
ARG OPENTRACING_CPP_VERSION=1.6.0-1
RUN for OS in linux android; do \
        for ARCH in x86_64 arm64-v8a; do \
            wget \
                --output-document=/tmp/opentracing-cpp-${OPENTRACING_CPP_VERSION}-${OS}-${ARCH}.tar.gz \
                https://github.com/tst-race/ext-opentracing-cpp/releases/download/${OPENTRACING_CPP_VERSION}/opentracing-cpp-${OPENTRACING_CPP_VERSION}-${OS}-${ARCH}.tar.gz && \
            tar --extract \
                --file=/tmp/opentracing-cpp-${OPENTRACING_CPP_VERSION}-${OS}-${ARCH}.tar.gz \
                --directory=/${OS}/${ARCH}; \
        done; \
    done && \
    rm /tmp/opentracing-cpp-*.tar.gz

# PBC (Linux-only)
ARG PBC_VERSION=0.5.14-1
RUN for ARCH in x86_64 arm64-v8a; do \
        wget \
            --output-document=/tmp/pbc-${PBC_VERSION}-linux-${ARCH}.tar.gz \
            https://github.com/tst-race/ext-pbc/releases/download/${PBC_VERSION}/pbc-${PBC_VERSION}-linux-${ARCH}.tar.gz && \
        tar --extract \
            --file=/tmp/pbc-${PBC_VERSION}-linux-${ARCH}.tar.gz \
            --directory=/linux/${ARCH}; \
    done && \
    rm /tmp/pbc-*.tar.gz

# Python (Android-only)
ARG ANDROID_PYTHON_VERSION=3.7.16-3
RUN for ARCH in x86_64 arm64-v8a; do \
        wget \
            --output-document=/tmp/python-${ANDROID_PYTHON_VERSION}-android-${ARCH}.tar.gz \
            https://github.com/tst-race/ext-python/releases/download/${ANDROID_PYTHON_VERSION}/python-${ANDROID_PYTHON_VERSION}-android-${ARCH}.tar.gz && \
        tar --extract \
            --file=/tmp/python-${ANDROID_PYTHON_VERSION}-android-${ARCH}.tar.gz \
            --directory=/android/${ARCH} && \
        wget \
            --output-document=/android/${ARCH}/python-packages-android-${ARCH}.tar.gz \
            https://github.com/tst-race/ext-python/releases/download/${ANDROID_PYTHON_VERSION}/python-packages-${ANDROID_PYTHON_VERSION}-android-${ARCH}.tar.gz; \
    done && \
    rm /tmp/python-*.tar.gz

# sodium
ARG SODIUM_VERSION=1.0.18-1
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        libsodium-dev=1.0.18* && \
    case ${TARGETPLATFORM} in \
        "linux/amd64") \
            apt-get install -y --no-install-recommends \
                libsodium-dev:arm64=1.0.18* ;; \
    esac
RUN for ARCH in x86_64 arm64-v8a; do \
        wget \
            --output-document=/tmp/sodium-${SODIUM_VERSION}-android-${ARCH}.tar.gz \
            https://github.com/tst-race/ext-sodium/releases/download/${SODIUM_VERSION}/sodium-${SODIUM_VERSION}-android-${ARCH}.tar.gz && \
        tar --extract \
            --file=/tmp/sodium-${SODIUM_VERSION}-android-${ARCH}.tar.gz \
            --directory=/android/${ARCH}; \
    done && \
    rm /tmp/sodium-*.tar.gz

# SWIG (Linux-only)
ARG SWIG_VERSION=4.0.1-2
RUN case ${TARGETPLATFORM} in \
        "linux/amd64") LINUX_ARCH=x86_64    ;; \
        "linux/arm64") LINUX_ARCH=arm64-v8a ;; \
    esac && \
    wget \
        --output-document=/tmp/swig-${SWIG_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        https://github.com/tst-race/ext-swig/releases/download/${SWIG_VERSION}/swig-${SWIG_VERSION}-linux-${LINUX_ARCH}.tar.gz && \
    tar --extract \
        --file=/tmp/swig-${SWIG_VERSION}-linux-${LINUX_ARCH}.tar.gz \
        --directory=/usr/local && \
    rm /tmp/swig-*.tar.gz

# Apache Thrift
ARG THRIFT_VERSION=0.12.0-1
RUN for OS in linux android; do \
        for ARCH in x86_64 arm64-v8a; do \
            wget \
                --output-document=/tmp/thrift-${THRIFT_VERSION}-${OS}-${ARCH}.tar.gz \
                https://github.com/tst-race/ext-thrift/releases/download/${THRIFT_VERSION}/thrift-${THRIFT_VERSION}-${OS}-${ARCH}.tar.gz && \
            tar --extract \
                --file=/tmp/thrift-${THRIFT_VERSION}-${OS}-${ARCH}.tar.gz \
                --directory=/${OS}/${ARCH}; \
        done; \
    done && \
    rm /tmp/thrift-*.tar.gz

# yaml-cpp
ARG YAML_CPP_VERSION=0.6.2-1
RUN for OS in linux android; do \
        for ARCH in x86_64 arm64-v8a; do \
            wget \
                --output-document=/tmp/yaml-cpp-${YAML_CPP_VERSION}-${OS}-${ARCH}.tar.gz \
                https://github.com/tst-race/ext-yaml-cpp/releases/download/${YAML_CPP_VERSION}/yaml-cpp-${YAML_CPP_VERSION}-${OS}-${ARCH}.tar.gz && \
            tar --extract \
                --file=/tmp/yaml-cpp-${YAML_CPP_VERSION}-${OS}-${ARCH}.tar.gz \
                --directory=/${OS}/${ARCH}; \
        done; \
    done && \
    rm /tmp/yaml-cpp-*.tar.gz

RUN apt-get update -y && apt-get -y install git libgmp3-dev=2:6.2.*

# Jerasure
ARG JERASURE_VERSION=2.0-1
RUN for OS in linux android; do \
        for ARCH in x86_64 arm64-v8a; do \
            wget \
                --output-document=/tmp/jerasure-${JERASURE_VERSION}-${OS}-${ARCH}.tar.gz \
                https://github.com/tst-race/ext-jerasure/releases/download/${JERASURE_VERSION}/jerasure-${JERASURE_VERSION}-${OS}-${ARCH}.tar.gz && \
            tar --extract \
                --file=/tmp/jerasure-${JERASURE_VERSION}-${OS}-${ARCH}.tar.gz \
                --directory=/${OS}/${ARCH}; \
        done; \
    done && \
    rm /tmp/jerasure-*.tar.gz

# Liberasure
ARG LIBERASURECODE_VERSION=1.6.2-1
RUN for OS in linux android; do \
        for ARCH in x86_64 arm64-v8a; do \
            wget \
                --output-document=/tmp/liberasurecode-${LIBERASURECODE_VERSION}-${OS}-${ARCH}.tar.gz \
                https://github.com/tst-race/ext-liberasurecode/releases/download/${LIBERASURECODE_VERSION}/liberasurecode-${LIBERASURECODE_VERSION}-${OS}-${ARCH}.tar.gz && \
            tar --extract \
                --file=/tmp/liberasurecode-${LIBERASURECODE_VERSION}-${OS}-${ARCH}.tar.gz \
                --directory=/${OS}/${ARCH}; \
        done; \
    done && \
    rm /tmp/liberasurecode-*.tar.gz

# Json-C
ARG JSON_C_VERSION=0.15-20200726-1
RUN for OS in android; do \
        for ARCH in x86_64 arm64-v8a; do \
            wget \
                --output-document=/tmp/json-c-${JSON_C_VERSION}-${OS}-${ARCH}.tar.gz \
                https://github.com/tst-race/ext-json-c/releases/download/${JSON_C_VERSION}/json-c-${JSON_C_VERSION}-${OS}-${ARCH}.tar.gz && \
            tar --extract \
                --file=/tmp/json-c-${JSON_C_VERSION}-${OS}-${ARCH}.tar.gz \
                --directory=/${OS}/${ARCH}; \
        done; \
    done && \
    rm /tmp/json-c-*.tar.gz

# gf-complete 
ARG GF_COMPLETE_VERSION=1.0.3-1
RUN for OS in linux android; do \
        for ARCH in x86_64 arm64-v8a; do \
            wget \
                --output-document=/tmp/gf-complete-${GF_COMPLETE_VERSION}-${OS}-${ARCH}.tar.gz \
                https://github.com/tst-race/ext-gf-complete/releases/download/${GF_COMPLETE_VERSION}/gf-complete-${GF_COMPLETE_VERSION}-${OS}-${ARCH}.tar.gz && \
            tar --extract \
                --file=/tmp/gf-complete-${GF_COMPLETE_VERSION}-${OS}-${ARCH}.tar.gz \
                --directory=/${OS}/${ARCH}; \
        done; \
    done && \
    rm /tmp/gf-complete-*.tar.gz

# Ensure these environment variables exist, even if they are empty
ENV RACE_NODE_TYPE= \
    RACE_PERSONA= \
    PYTHONPATH="${PYTHONPATH}" \
    LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/linux/x86_64/lib:/linux/arm64-v8a/lib"

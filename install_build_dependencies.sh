#!/usr/bin/env sh

set -eEux

# Verify that the script is running in Ubuntu
. /etc/lsb-release
if [ "$DISTRIB_ID" != "Ubuntu" ]; then
    echo "Error: This script only works in Ubuntu"
    exit 1
fi

# Avoid tzdata from asking which timezone to choose
export DEBIAN_FRONTEND=noninteractive

apt-get update

# Install build environment
apt-get -y --no-install-recommends install \
    antlr3 \
    asciidoc \
    autoconf \
    automake \
    autopoint \
    binutils \
    build-essential \
    bzip2 \
    device-tree-compiler \
    flex \
    g++-multilib \
    gawk \
    gcc-multilib \
    gettext \
    git \
    gperf \
    lib32gcc1 \
    libc6-dev-i386 \
    libelf-dev \
    libglib2.0-dev \
    libncurses5-dev \
    libssl-dev \
    libtool \
    libz-dev \
    msmtp \
    p7zip \
    p7zip-full \
    patch \
    python2.7 \
    python3 \
    qemu-utils \
    subversion \
    texinfo \
    uglifyjs \
    unzip \
    upx \
    wget \
    xmlto \
    zlib1g-dev

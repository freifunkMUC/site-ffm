#!/usr/bin/env sh

set -eux

# Verify that the script is running in Ubuntu
. /etc/lsb-release
if [ "$DISTRIB_ID" != "Ubuntu" ]; then
    echo "Error: This script only works in Ubuntu"
    exit 1
fi

# Avoid tzdata from asking which timezone to choose
export DEBIAN_FRONTEND=noninteractive

apt-get update

# ca-certificates required for Github git cloning
apt-get -y --no-install-recommends install ca-certificates

# Install build environment
apt-get -y --no-install-recommends install \
    bash \
    bzip2 \
    clang \
    curl \
    diffutils \
    file \
    g++ \
    gawk \
    gcc \
    git \
    libncurses5-dev \
    make \
    patch \
    perl \
    python3 \
    python3-distutils \
    qemu-utils \
    rsync \
    tar \
    unzip \
    wget

# Install bpftool
apt-get -y --no-install-recommends install bpftool || # Ubuntu 25.04+
{
    # Fallback for Ubuntu 24.04 and earlier
    latest_linux_tools=$(apt -q search "^linux-tools-[0-9].*-generic$" | grep "^linux-tools" | awk -F '/' '{ print $1 }' | sort -V | tail -n 1)
    apt-get -y --no-install-recommends install "${latest_linux_tools}"
    latest_bpftool=$(find /usr/lib/linux-tools/ -name bpftool | sort -V | tail -n 1)
    rm -f /usr/sbin/bpftool # delete wrapper bpftool script
    ln -s "${latest_bpftool}" /usr/sbin/bpftool
}

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

# We require bpftool 7.5+
# https://github.com/libbpf/bpftool/releases#:~:text=work%20with%20object%20files%20in%20either%20endianness%20for%20some%20operations%20like%20object%20linking%20or%20light%20BPF%20skeleton%20creation
apt-get -y --no-install-recommends install bpftool || # Ubuntu 25.04+
{
    # Ubuntu 24.04 do not have bpftool as a package and rely on "linux-tools-$(uname -r)", but those can deliver only bpftool 7.4
    curl -LO https://github.com/libbpf/bpftool/releases/download/v7.6.0/bpftool-v7.6.0-amd64.tar.gz
    curl -LO https://github.com/libbpf/bpftool/releases/download/v7.6.0/bpftool-v7.6.0-amd64.tar.gz.sha256sum
    tar xvf bpftool-v7.6.0-amd64.tar.gz -C /usr/local/bin
    chmod +x /usr/local/bin/bpftool
}

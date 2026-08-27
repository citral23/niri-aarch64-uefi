#!/bin/bash
set -euxo pipefail
shopt -s nullglob

dnf -y install koji

# Resolves whatever is currently tagged into rawhide - always current, tag name doesn't change across releases
NVR=$(koji latest-build --quiet rawhide kernel | awk '{print $1}')
echo "Rawhide kernel: ${NVR}"

dnf5 -y remove kernel kernel-core kernel-modules kernel-modules-core 2>/dev/null || true
rm -rf /usr/lib/modules/*

mkdir -p /tmp/kernel-rpms && cd /tmp/kernel-rpms
koji download-build --arch=aarch64 "${NVR}"
# pulls kernel, kernel-core, kernel-modules, kernel-modules-core,
# kernel-modules-extra (and kernel-devel) .aarch64.rpm for that NVR

dnf -y install \
    ./kernel-core-*.aarch64.rpm \
    ./kernel-modules-[0-9]*.aarch64.rpm \
    ./kernel-modules-core-*.aarch64.rpm \
    ./kernel-modules-extra-[0-9]*.aarch64.rpm \
    ./kernel-[0-9]*.aarch64.rpm
    
rm -rf /tmp/kernel-rpms
dnf -y remove koji

echo "rawhide kernel ${NVR} installed"

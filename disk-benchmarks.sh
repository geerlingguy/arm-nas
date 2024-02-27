#!/bin/bash
set -e

# A script I use to automate the running and reporting of benchmarks I compile
# for my YouTube channel.
#
# Usage:
#   # Run it locally (overriding device and mount path).
#   $ sudo DEVICE_UNDER_TEST=/dev/sda1 DEVICE_MOUNT_PATH=/mnt/sda1 ./disk-benchmark.sh
#
# Author: Jeff Geerling, 2024

printf "\n"
printf "Jeff Geerling's disk benchmarks\n"

# Fail if $SUDO_USER is empty.
if [ -z "$SUDO_USER" ]; then
  printf "This script must be run with sudo.\n"
  exit 1;
fi

# Variables.
DEVICE_MOUNT_PATH=${DEVICE_MOUNT_PATH:-"/ssdpool"}
USER_HOME_PATH=$(getent passwd $SUDO_USER | cut -d: -f6)
IOZONE_INSTALL_PATH=$USER_HOME_PATH
IOZONE_VERSION=iozone3_506

cd $IOZONE_INSTALL_PATH

# Install dependencies.
if [ ! `which curl` ]; then
  printf "Installing curl...\n"
  apt-get install -y curl
  printf "Install complete!\n\n"
fi
if [ ! `which make` ]; then
  printf "Installing build tools...\n"
  apt-get install -y build-essential
  printf "Install complete!\n\n"
fi

# Download and build iozone.
if [ ! -f $IOZONE_INSTALL_PATH/$IOZONE_VERSION/src/current/iozone ]; then
  printf "Installing iozone...\n"
  curl "http://www.iozone.org/src/current/$IOZONE_VERSION.tar" | tar -x
  cd $IOZONE_VERSION/src/current
  make --quiet linux-arm
  printf "Install complete!\n\n"
else
  cd $IOZONE_VERSION/src/current
fi

# Run benchmarks.
printf "Running iozone 1024K random read and write tests...\n"
./iozone -e -I -a -s 128G -r 1024k -i 0 -i 1 -i 2 -f $DEVICE_MOUNT_PATH/iozone
printf "\n"

printf "Running iozone 4K random read and write tests...\n"
./iozone -e -I -a -s 256M -r 4k -i 0 -i 1 -i 2 -f $DEVICE_MOUNT_PATH/iozone
printf "\n"

printf "Disk benchmark complete!\n\n"

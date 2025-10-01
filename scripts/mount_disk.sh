#!/bin/bash

# Script to mount XFS disks with optimized parameters
# Usage: mount_disk.sh <device_path> <mount_point>

# Check that exactly two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Error: Requires 2 arguments: device path and mount point" >&2
    echo "Usage: $0 <device_path> <mount_point>" >&2
    exit 1
fi

DEVICE_PATH=$1
MOUNT_POINT=$2

# Validate that device exists
if [ ! -e "${DEVICE_PATH}" ]; then
    echo "Error: Device ${DEVICE_PATH} does not exist" >&2
    exit 1
fi

# Create mount point if it doesn't exist
mkdir -p "${MOUNT_POINT}"

# Mount the device with optimized XFS parameters
echo "Mounting ${DEVICE_PATH} to ${MOUNT_POINT}..."
mount -t xfs -o noatime,nodiratime,logbufs=8,logbsize=256k,largeio,inode64,swalloc,allocsize=131072k "${DEVICE_PATH}" "${MOUNT_POINT}"

# Check the return code of the mount command
if [ $? -ne 0 ]; then
    echo "Error mounting device!" >&2
    # Display recent kernel messages which might be helpful
    dmesg | tail -n 10
    exit 1
fi

echo "Mount successful."
exit 0
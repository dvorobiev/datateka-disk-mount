#!/bin/bash

# Script to power off a disk via serial port
# Usage: power_off.sh <module> <position>

# Check that exactly two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Error: Requires 2 arguments: module number and position number" >&2
    echo "Usage: $0 <module> <position>" >&2
    exit 1
fi

MODULE=$1
POSITION=$2
SERIAL_PORT="/dev/ttyUSB0"

# Validate module and position are numeric
if ! [[ "$MODULE" =~ ^[0-9]+$ ]] || ! [[ "$POSITION" =~ ^[0-9]+$ ]]; then
    echo "Error: Module and position must be numeric values" >&2
    exit 1
fi

# Check if serial port exists
if [ ! -e "${SERIAL_PORT}" ]; then
    echo "Error: Serial port ${SERIAL_PORT} does not exist" >&2
    exit 1
fi

# Form and execute command
echo "Powering off disk: Module=${MODULE}, Position=${POSITION}"
echo -ne "#hdd_m${MODULE} n${POSITION} off\n\r" > ${SERIAL_PORT}

# Check if command was sent successfully
if [ $? -ne 0 ]; then
    echo "Error: Failed to send command to ${SERIAL_PORT}" >&2
    exit 1
fi

echo "Power off command sent successfully."
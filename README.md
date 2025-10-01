# Datateka Disk Mount Utility

A comprehensive utility for managing disk drives in a storage shelf through serial communication. This tool allows you to power on/off individual disks, mount/unmount them, and monitor their status.

## Features

- Power on/off individual disks using serial commands
- Mount/unmount XFS formatted disks
- Monitor disk status and available space
- Visual grid display of all disks in the storage shelf
- Support for multiple disk modules and positions
- Logging of all operations

## Components

### Python Scripts

- `disk_state.py` - Main disk management utility with interactive interface
- `power_on.py` - Simple script to power on a specific disk

### Shell Scripts

- `scripts/mount_disk.sh` - Script to mount XFS disks with optimized parameters
- `scripts/power_off.sh` - Script to power off a disk via serial port
- `scripts/power_on.sh` - Script to power on a disk via serial port

### Configuration

- `DISK_WWN.csv` - CSV file mapping WWN identifiers to disk positions and mount points

## Usage

### Main Disk Manager

```bash
sudo python3 disk_state.py
```

The main interface provides a visual grid showing the status of all disks:
- ○ - Disk is powered off
- ●/■ - Disk is powered on (● for 20TB+ disks, ■ for 18TB+ disks)
- Orange ● - Disk is nearly full (>95%)

Controls:
1. Power on a disk
2. Power off a disk
3. Refresh the display
q. Quit

### Command Line Scripts

Power on a disk:
```bash
sudo ./scripts/power_on.sh <module> <position>
```

Power off a disk:
```bash
sudo ./scripts/power_off.sh <module> <position>
```

Mount a disk:
```bash
sudo ./scripts/mount_disk.sh <device_path> <mount_point>
```

## Configuration

The `DISK_WWN.csv` file contains the mapping between disk WWN identifiers and their physical positions:

```
wwn;module;position;mount_point
wwn-0x5000039d68d2a2b3;1;1;M1
...
```

- `wwn`: World Wide Name identifier for the disk
- `module`: Module number (1-5)
- `position`: Position within the module (1-12)
- `mount_point`: Directory name where the disk will be mounted under `/mnt/`

## Requirements

- Python 3.x
- pandas
- rich
- XFS formatted disks
- Serial connection to disk controller
- Root privileges for hardware control

## Installation

1. Install required Python packages:
   ```bash
   pip install pandas rich
   ```

2. Ensure the serial port is accessible:
   ```bash
   sudo usermod -a -G dialout $USER
   ```

3. Make scripts executable:
   ```bash
   chmod +x scripts/*.sh
   ```

## License

This project is licensed under the MIT License.
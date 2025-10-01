# Release Notes - Version 1.0.0

## Initial Release

This is the first official release of the Datateka Disk Mount Utility - a comprehensive tool for managing disk drives in a storage shelf through serial communication.

## Features

### Core Functionality
- **Disk Power Management**: Power on/off individual disks using serial commands
- **Disk Mounting**: Mount/unmount XFS formatted disks with optimized parameters
- **Visual Disk Status**: Interactive grid display showing the status of all disks in the storage shelf
- **Configuration Management**: CSV-based configuration for mapping WWN identifiers to disk positions

### Scripts
- `disk_state.py` - Main disk management utility with interactive interface
- `power_on.py` - Simple script to power on a specific disk
- `scripts/mount_disk.sh` - Script to mount XFS disks with optimized parameters
- `scripts/power_off.sh` - Script to power off a disk via serial port
- `scripts/power_on.sh` - Script to power on a disk via serial port

### User Interface
- Visual grid display showing disk status:
  - ○ - Disk is powered off
  - ●/■ - Disk is powered on (● for 20TB+ disks, ■ for 18TB+ disks)
  - Orange ● - Disk is nearly full (>95%)
- Interactive controls for powering on/off disks
- Real-time status updates

## System Requirements
- Python 3.x
- pandas library
- rich library
- XFS formatted disks
- Serial connection to disk controller
- Root privileges for hardware control

## Installation
1. Install required Python packages:
   ```bash
   pip install -r requirements.txt
   ```
2. Ensure the serial port is accessible:
   ```bash
   sudo usermod -a -G dialout $USER
   ```
3. Make scripts executable:
   ```bash
   chmod +x scripts/*.sh
   chmod +x version.sh
   ```

## Usage
Run the main disk manager:
```bash
sudo python3 disk_state.py
```

Or use individual scripts:
```bash
# Power on a disk
sudo ./scripts/power_on.sh <module> <position>

# Power off a disk
sudo ./scripts/power_off.sh <module> <position>

# Mount a disk
sudo ./scripts/mount_disk.sh <device_path> <mount_point>
```

## Configuration
The `DISK_WWN.csv` file contains the mapping between disk WWN identifiers and their physical positions:
```
wwn;module;position;mount_point
wwn-0x5000039d68d2a2b3;1;1;M1
...
```

## Known Limitations
- Currently supports only XFS file system
- Requires direct serial connection to disk controller
- Designed for specific disk shelf hardware configuration

## License
This project is licensed under the MIT License.
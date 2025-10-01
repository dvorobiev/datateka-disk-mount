# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-10-01

### Added
- Light версия утилиты без Python зависимостей
- Новый скрипт `disk_manager.sh` для работы только через bash
- Поддержка всех основных функций (включение/выключение дисков, монтирование/отмонтирование)
- Архив с light версией в релизах
- Документация по использованию light версии

### Changed
- Обновлен README с информацией о двух версиях утилиты
- Улучшена структура документации

## [1.0.0] - 2025-10-01

### Added
- Initial release of Datateka Disk Mount Utility
- Python-based disk management interface with visual grid display
- Shell scripts for mounting XFS disks with optimized parameters
- Shell scripts for powering on/off disks via serial communication
- CSV configuration file for mapping WWN identifiers to disk positions
- Requirements file for Python dependencies
- Version management script
- Comprehensive Russian documentation
- MIT License

### Changed
- Improved error handling in all shell scripts
- Added validation for script arguments
- Added device existence checks before mounting
- Enhanced serial port validation
- Added proper logging and status messages

### Fixed
- Various minor bug fixes and improvements
# Утилита Datateka Disk Mount

[![GitHub](https://img.shields.io/github/license/dvorobiev/datateka-disk-mount)](https://github.com/dvorobiev/datateka-disk-mount/blob/main/LICENSE)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/dvorobiev/datateka-disk-mount)](https://github.com/dvorobiev/datateka-disk-mount/releases)
[![Python Version](https://img.shields.io/badge/python-3.x-blue)](https://www.python.org/)
[![Platform](https://img.shields.io/badge/platform-linux--64-lightgrey)](https://github.com/dvorobiev/datateka-disk-mount)

Комплексная утилита для управления дисками в стеллаже хранения через последовательное соединение. Этот инструмент позволяет включать/выключать отдельные диски, монтировать/размонтировать их и отслеживать их состояние.

## Особенности

- Включение/выключение отдельных дисков с помощью последовательных команд
- Монтирование/размонтирование дисков с файловой системой XFS
- Отслеживание состояния дисков и доступного пространства
- Визуальное отображение сетки всех дисков в стеллаже хранения
- Поддержка нескольких модулей дисков и позиций
- Ведение журнала всех операций

## Версии

### Полная версия (с Python)
- Интерактивный интерфейс с визуальной сеткой
- Полная статистика использования дисков
- Требует Python 3.x и библиотеки pandas, rich

### Light версия (только bash)
- Работает без Python зависимостей
- Подходит для серверов без интернета
- Минимальные системные требования
- Доступна в [релизе v1.1.0](https://github.com/dvorobiev/datateka-disk-mount/releases/tag/v1.1.0) и выше

## Компоненты

### Python скрипты (полная версия)

- `disk_state.py` - Основная утилита управления дисками с интерактивным интерфейсом
- `power_on.py` - Простой скрипт для включения определенного диска

### Shell скрипты (обе версии)

- `scripts/mount_disk.sh` - Скрипт для монтирования дисков XFS с оптимизированными параметрами
- `scripts/power_off.sh` - Скрипт для выключения диска через последовательный порт
- `scripts/power_on.sh` - Скрипт для включения диска через последовательный порт

### Конфигурация

- `DISK_WWN.csv` - CSV-файл, сопоставляющий идентификаторы WWN с позициями дисков и точками монтирования

## Использование

### Полная версия (с Python)

```bash
sudo python3 disk_state.py
```

Основной интерфейс предоставляет визуальную сетку, показывающую состояние всех дисков:
- ○ - Диск выключен
- ●/■ - Диск включен (● для дисков 20ТБ+, ■ для дисков 18ТБ+)
- Оранжевый ● - Диск почти заполнен (>95%)

Управление:
1. Включить диск
2. Выключить диск
3. Обновить отображение
q. Выйти

### Light версия (только bash)

```bash
# Включить диск
./disk_manager.sh poweron <модуль> <позиция>

# Выключить диск
./disk_manager.sh poweroff <модуль> <позиция>

# Показать список всех дисков
./disk_manager.sh list

# Проверить статус диска (смонтирован/не смонтирован)
./disk_manager.sh status <модуль> <позиция>

# Смонтировать диск
./disk_manager.sh mount <модуль> <позиция>

# Отмонтировать диск
./disk_manager.sh umount <модуль> <позиция>
```

## Конфигурация

Файл `DISK_WWN.csv` содержит сопоставление между идентификаторами WWN дисков и их физическими позициями:

```
wwn;module;position;mount_point
wwn-0x5000039d68d2a2b3;1;1;M1
...
```

- `wwn`: Идентификатор World Wide Name для диска
- `module`: Номер модуля (1-5)
- `position`: Позиция в модуле (1-12)
- `mount_point`: Имя каталога, где диск будет смонтирован в `/mnt/`

## Требования

### Полная версия
- Python 3.x
- pandas
- rich
- Диски с файловой системой XFS
- Последовательное соединение с контроллером дисков
- Права суперпользователя для управления оборудованием

### Light версия
- Linux система
- Доступ к /dev/ttyUSB0 (или другому serial порту)
- Утилиты: mount, umount, mountpoint, df, dmesg
- Права root для управления дисками

## Установка

Подробное руководство по установке на другие системы смотрите в [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md).

### Полная версия
1. Клонируйте репозиторий или скачайте релиз
2. Установите зависимости Python (если pip не найден, используйте `python3 -m pip`):
   ```bash
   pip install -r requirements.txt
   ```
   или
   ```bash
   python3 -m pip install -r requirements.txt
   ```
   или установите пакеты вручную:
   ```bash
   python3 -m pip install pandas rich
   ```
3. Добавьте пользователя в группу dialout:
   ```bash
   sudo usermod -a -G dialout $USER
   ```
4. Сделайте скрипты исполняемыми:
   ```bash
   chmod +x scripts/*.sh
   chmod +x version.sh
   chmod +x disk_state.sh
   ```
5. Настройте файл `DISK_WWN.csv` под вашу конфигурацию

### Light версия
1. Скачайте архив light версии из [последнего релиза](https://github.com/dvorobiev/datateka-disk-mount/releases)
2. Распакуйте архив:
   ```bash
   tar -xzf datateka_disk_manager_light.tar.gz
   cd light_version
   ```
3. Сделайте скрипт исполняемым:
   ```bash
   chmod +x disk_manager.sh
   ```
4. Настройте файл `DISK_WWN.csv` под вашу конфигурацию

## Создание релизов

Для создания нового релиза:

1. Используйте скрипт управления версиями:
   ```bash
   ./version.sh patch   # Для увеличения патч-версии
   ./version.sh minor   # Для увеличения минорной версии
   ./version.sh major   # Для увеличения мажорной версии
   ```

2. Для создания релиза на GitHub используйте скрипт:
   ```bash
   ./create_release.sh <github_token>
   ```
   
   Где `<github_token>` - это ваш персональный токен доступа GitHub с правами на запись в репозиторий.

## Версионность

Версия: 1.1.0

Для управления версиями используется скрипт `version.sh`:
```bash
./version.sh show    # Показать текущую версию
./version.sh patch   # Увеличить патч-версию (например, 1.1.0 -> 1.1.1)
./version.sh minor   # Увеличить минорную версию (например, 1.1.1 -> 1.2.0)
./version.sh major   # Увеличить мажорную версию (например, 1.2.0 -> 2.0.0)
```

## Лицензия

Этот проект лицензирован по лицензии MIT.
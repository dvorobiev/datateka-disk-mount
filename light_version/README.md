# Datateka Disk Manager (Light версия)

Облегченная версия утилиты управления дисками без Python зависимости. 
Предназначена для работы на серверах без доступа к интернету.

## Особенности

- Работает только с bash скриптами
- Не требует Python или дополнительных библиотек
- Минимальные зависимости (только стандартные утилиты Linux)
- Подходит для установки через SSH на серверы без интернета

## Файлы

- `disk_manager.sh` - Основной скрипт управления дисками
- `DISK_WWN.csv` - Файл конфигурации дисков (копируется из основной версии)

## Установка

1. Скопируйте файлы на сервер через SSH:
   ```bash
   scp disk_manager.sh DISK_WWN.csv user@server:/path/to/destination/
   ```

2. Сделайте скрипт исполняемым:
   ```bash
   chmod +x disk_manager.sh
   ```

## Использование

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

# Показать справку
./disk_manager.sh help
```

## Примеры

```bash
# Включить диск в модуле 1, позиция 1
./disk_manager.sh poweron 1 1

# Выключить диск в модуле 2, позиция 3
./disk_manager.sh poweroff 2 3

# Показать список всех дисков
./disk_manager.sh list

# Проверить статус диска
./disk_manager.sh status 1 1

# Смонтировать диск
./disk_manager.sh mount 1 1

# Отмонтировать диск
./disk_manager.sh umount 1 1
```

## Требования

- Linux система
- Доступ к /dev/ttyUSB0 (или другому serial порту)
- Утилиты: mount, umount, mountpoint, df, dmesg
- Права root для управления дисками

## Конфигурация

Файл `DISK_WWN.csv` должен содержать информацию о дисках в формате:
```
wwn;module;position;mount_point
wwn-0x5000039d68d2a2b3;1;1;M1
```

Где:
- `wwn` - World Wide Name идентификатор диска
- `module` - Номер модуля (1-5)
- `position` - Позиция в модуле (1-12)
- `mount_point` - Имя каталога для монтирования в `/mnt/`
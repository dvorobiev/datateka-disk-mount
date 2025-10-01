# Руководство по развертыванию утилиты Datateka Disk Mount

Это руководство описывает, как развернуть утилиту Datateka Disk Mount на другой системе.

## Системные требования

### Аппаратные требования
- Linux-совместимая система (64-битная рекомендуется)
- Последовательный порт USB (обычно `/dev/ttyUSB0`) для подключения к контроллеру дисков
- Диски с файловой системой XFS

### Программные требования
- Python 3.x
- Доступ к root/sudo для управления дисками
- Установленные Python-пакеты:
  - pandas
  - rich

## Шаги развертывания

### 1. Клонирование репозитория

```bash
git clone https://github.com/dvorobiev/datateka-disk-mount.git
cd datateka-disk-mount
```

Или скачайте и распакуйте архив релиза:
```bash
wget https://github.com/dvorobiev/datateka-disk-mount/archive/refs/tags/v1.0.0.tar.gz
tar -xzf v1.0.0.tar.gz
cd datateka-disk-mount-1.0.0
```

### 2. Установка зависимостей Python

```bash
pip install -r requirements.txt
```

Или установите пакеты вручную:
```bash
pip install pandas rich
```

### 3. Настройка прав доступа к последовательному порту

Добавьте пользователя в группу `dialout` для доступа к последовательному порту:
```bash
sudo usermod -a -G dialout $USER
```

Вам может потребоваться выйти из системы и войти снова, чтобы изменения вступили в силу.

### 4. Настройка исполняемых прав для скриптов

Сделайте все скрипты исполняемыми:
```bash
chmod +x scripts/*.sh
chmod +x version.sh
chmod +x create_release.sh
```

### 5. Настройка конфигурации дисков

Отредактируйте файл `DISK_WWN.csv`, чтобы он соответствовал вашей конфигурации дисков:

```
wwn;module;position;mount_point
wwn-0x5000039d68d2a2b3;1;1;M1
...
```

Где:
- `wwn` - World Wide Name идентификатор диска
- `module` - Номер модуля (1-5)
- `position` - Позиция в модуле (1-12)
- `mount_point` - Имя каталога для монтирования в `/mnt/`

### 6. Проверка конфигурации последовательного порта

По умолчанию утилита использует порт `/dev/ttyUSB0`. Если ваш контроллер подключен к другому порту, вам нужно будет изменить соответствующие файлы:

1. В `disk_state.py` измените переменную `SERIAL_PORT`
2. В скриптах `scripts/power_on.sh` и `scripts/power_off.sh` измените переменную `SERIAL_PORT`

### 7. Тестирование установки

Проверьте, что все работает правильно:

```bash
# Проверьте, что скрипты работают
./scripts/power_on.sh 1 1
./scripts/power_off.sh 1 1

# Запустите основную утилиту (требуются права root)
sudo python3 disk_state.py
```

## Использование

### Основная утилита

Запустите основную утилиту управления дисками:
```bash
sudo python3 disk_state.py
```

### Индивидуальные скрипты

Используйте отдельные скрипты для управления дисками:
```bash
# Включение диска
sudo ./scripts/power_on.sh <module> <position>

# Выключение диска
sudo ./scripts/power_off.sh <module> <position>

# Монтирование диска
sudo ./scripts/mount_disk.sh <device_path> <mount_point>
```

## Устранение неполадок

### Проблемы с правами доступа

Если вы получаете ошибки доступа:
1. Убедитесь, что вы используете `sudo` при необходимости
2. Проверьте, что ваш пользователь в группе `dialout`:
   ```bash
   groups
   ```
3. Убедитесь, что скрипты исполняемые:
   ```bash
   ls -la scripts/
   ```

### Проблемы с последовательным портом

Если команды не доходят до контроллера дисков:
1. Проверьте, что устройство подключено:
   ```bash
   ls -la /dev/ttyUSB*
   ```
2. Проверьте права доступа к порту:
   ```bash
   ls -la /dev/ttyUSB0
   ```
3. Убедитесь, что другой процесс не использует порт

### Проблемы с монтированием

Если диски не монтируются:
1. Проверьте, что диск включен и определяется системой:
   ```bash
   lsblk
   ls -la /dev/disk/by-id/
   ```
2. Убедитесь, что файловая система XFS:
   ```bash
   sudo file -s /dev/disk/by-id/<wwn>-part1
   ```

## Обслуживание и обновление

### Обновление до новой версии

```bash
cd datateka-disk-mount
git pull origin main
```

Или скачайте новый релиз с GitHub.

### Мониторинг

Проверяйте лог-файл `disk_manager.log` для диагностики проблем.

## Настройка для автоматического запуска (опционально)

Если вы хотите запускать утилиту автоматически, вы можете создать systemd сервис:

1. Создайте файл `/etc/systemd/system/disk-manager.service`:
   ```ini
   [Unit]
   Description=Datateka Disk Manager
   After=multi-user.target

   [Service]
   Type=simple
   ExecStart=/usr/bin/python3 /path/to/datateka-disk-mount/disk_state.py
   Restart=on-failure
   RestartSec=5

   [Install]
   WantedBy=multi-user.target
   ```

2. Включите и запустите сервис:
   ```bash
   sudo systemctl enable disk-manager.service
   sudo systemctl start disk-manager.service
   ```

## Лицензия

Этот проект лицензирован по лицензии MIT.
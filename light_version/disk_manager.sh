#!/bin/bash

# Light версия утилиты управления дисками Datateka
# Работает только через bash скрипты без Python

# Конфигурация
SERIAL_PORT="/dev/ttyUSB0"
CSV_FILE="DISK_WWN.csv"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция для отображения помощи
show_help() {
    echo "Утилита управления дисками Datateka (Light версия)"
    echo "Использование: $0 [опция]"
    echo ""
    echo "Опции:"
    echo "  poweron <модуль> <позиция>    Включить диск"
    echo "  poweroff <модуль> <позиция>   Выключить диск"
    echo "  list                          Показать список дисков"
    echo "  status <модуль> <позиция>     Проверить статус диска (если смонтирован)"
    echo "  mount <модуль> <позиция>      Смонтировать диск"
    echo "  umount <модуль> <позиция>     Отмонтировать диск"
    echo "  help                          Показать эту справку"
    echo ""
    echo "Примеры:"
    echo "  $0 poweron 1 1               Включить диск в модуле 1, позиция 1"
    echo "  $0 list                      Показать все диски"
}

# Функция для проверки существования serial порта
check_serial_port() {
    if [ ! -e "$SERIAL_PORT" ]; then
        echo -e "${RED}Ошибка: Serial порт $SERIAL_PORT не найден${NC}"
        echo "Проверьте подключение устройства."
        return 1
    fi
    return 0
}

# Функция для отправки команды через serial порт
send_command() {
    local command="$1"
    if ! check_serial_port; then
        return 1
    fi
    
    echo -ne "$command" > "$SERIAL_PORT"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Ошибка: Не удалось отправить команду в $SERIAL_PORT${NC}"
        return 1
    fi
    return 0
}

# Функция для включения диска
power_on_disk() {
    local module="$1"
    local position="$2"
    
    # Проверка аргументов
    if [ -z "$module" ] || [ -z "$position" ]; then
        echo -e "${RED}Ошибка: Требуются оба аргумента: модуль и позиция${NC}"
        echo "Пример: $0 poweron 1 1"
        return 1
    fi
    
    # Проверка, что аргументы числовые
    if ! [[ "$module" =~ ^[0-9]+$ ]] || ! [[ "$position" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Ошибка: Модуль и позиция должны быть числами${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Включение диска: Модуль $module, Позиция $position${NC}"
    local command="#hdd_m${module} n${position} on\r\n"
    if send_command "$command"; then
        echo -e "${GREEN}Диск в модуле $module, позиции $position успешно включен${NC}"
    else
        return 1
    fi
}

# Функция для выключения диска
power_off_disk() {
    local module="$1"
    local position="$2"
    
    # Проверка аргументов
    if [ -z "$module" ] || [ -z "$position" ]; then
        echo -e "${RED}Ошибка: Требуются оба аргумента: модуль и позиция${NC}"
        echo "Пример: $0 poweroff 1 1"
        return 1
    fi
    
    # Проверка, что аргументы числовые
    if ! [[ "$module" =~ ^[0-9]+$ ]] || ! [[ "$position" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Ошибка: Модуль и позиция должны быть числами${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Выключение диска: Модуль $module, Позиция $position${NC}"
    local command="#hdd_m${module} n${position} off\r\n"
    if send_command "$command"; then
        echo -e "${GREEN}Диск в модуле $module, позиции $position успешно выключен${NC}"
    else
        return 1
    fi
}

# Функция для отображения списка дисков из CSV файла
list_disks() {
    if [ ! -f "$CSV_FILE" ]; then
        echo -e "${RED}Ошибка: Файл конфигурации $CSV_FILE не найден${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Список дисков:${NC}"
    echo "WWN;Модуль;Позиция;Точка монтирования"
    echo "----------------------------------------"
    # Пропускаем первую строку (заголовок) и выводим остальные
    tail -n +2 "$CSV_FILE" | while IFS=';' read -r wwn module position mount_point; do
        echo "$wwn;$module;$position;$mount_point"
    done
}

# Функция для проверки статуса диска (смонтирован/не смонтирован)
check_status() {
    local module="$1"
    local position="$2"
    
    if [ -z "$module" ] || [ -z "$position" ]; then
        echo -e "${RED}Ошибка: Требуются оба аргумента: модуль и позиция${NC}"
        return 1
    fi
    
    # Получаем точку монтирования из CSV файла
    local mount_point=$(tail -n +2 "$CSV_FILE" | awk -F';' -v mod="$module" -v pos="$position" '$2==mod && $3==pos {print $4}')
    
    if [ -z "$mount_point" ]; then
        echo -e "${RED}Ошибка: Диск с модулем $module и позицией $position не найден в конфигурации${NC}"
        return 1
    fi
    
    # Формируем полный путь к точке монтирования
    local full_mount_point="/mnt/$mount_point"
    
    if mountpoint -q "$full_mount_point" >/dev/null 2>&1; then
        echo -e "${GREEN}Диск в модуле $module, позиции $position СМОНТИРОВАН в $full_mount_point${NC}"
        # Показываем информацию о свободном месте
        if command -v df >/dev/null 2>&1; then
            df -h "$full_mount_point" | tail -n +2
        fi
    else
        echo -e "${YELLOW}Диск в модуле $module, позиции $position НЕ СМОНТИРОВАН${NC}"
    fi
}

# Функция для монтирования диска
mount_disk() {
    local module="$1"
    local position="$2"
    
    if [ -z "$module" ] || [ -z "$position" ]; then
        echo -e "${RED}Ошибка: Требуются оба аргумента: модуль и позиция${NC}"
        return 1
    fi
    
    # Получаем WWN и точку монтирования из CSV файла
    local disk_info=$(tail -n +2 "$CSV_FILE" | awk -F';' -v mod="$module" -v pos="$position" '$2==mod && $3==pos {print $1 ";" $4}')
    
    if [ -z "$disk_info" ]; then
        echo -e "${RED}Ошибка: Диск с модулем $module и позицией $position не найден в конфигурации${NC}"
        return 1
    fi
    
    local wwn=$(echo "$disk_info" | cut -d';' -f1)
    local mount_point=$(echo "$disk_info" | cut -d';' -f2)
    local full_mount_point="/mnt/$mount_point"
    local device_path="/dev/disk/by-id/${wwn}-part1"
    
    # Проверяем, существует ли устройство
    if [ ! -e "$device_path" ]; then
        echo -e "${RED}Ошибка: Устройство $device_path не найдено${NC}"
        echo "Убедитесь, что диск включен и определяется системой."
        return 1
    fi
    
    # Создаем точку монтирования, если её нет
    mkdir -p "$full_mount_point"
    
    echo -e "${YELLOW}Монтирование $device_path в $full_mount_point...${NC}"
    
    # Монтируем с оптимизированными параметрами для XFS
    if mount -t xfs -o noatime,nodiratime,logbufs=8,logbsize=256k,largeio,inode64,swalloc,allocsize=131072k "$device_path" "$full_mount_point"; then
        echo -e "${GREEN}Диск успешно смонтирован в $full_mount_point${NC}"
    else
        echo -e "${RED}Ошибка при монтировании диска${NC}"
        # Показываем последние сообщения ядра
        dmesg | tail -n 10
        return 1
    fi
}

# Функция для отмонтирования диска
umount_disk() {
    local module="$1"
    local position="$2"
    
    if [ -z "$module" ] || [ -z "$position" ]; then
        echo -e "${RED}Ошибка: Требуются оба аргумента: модуль и позиция${NC}"
        return 1
    fi
    
    # Получаем точку монтирования из CSV файла
    local mount_point=$(tail -n +2 "$CSV_FILE" | awk -F';' -v mod="$module" -v pos="$position" '$2==mod && $3==pos {print $4}')
    
    if [ -z "$mount_point" ]; then
        echo -e "${RED}Ошибка: Диск с модулем $module и позицией $position не найден в конфигурации${NC}"
        return 1
    fi
    
    local full_mount_point="/mnt/$mount_point"
    
    # Проверяем, смонтирован ли диск
    if ! mountpoint -q "$full_mount_point" >/dev/null 2>&1; then
        echo -e "${YELLOW}Диск в модуле $module, позиции $position уже отмонтирован${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}Отмонтирование $full_mount_point...${NC}"
    
    if umount "$full_mount_point"; then
        echo -e "${GREEN}Диск успешно отмонтирован${NC}"
    else
        echo -e "${RED}Ошибка при отмонтировании диска${NC}"
        return 1
    fi
}

# Основная логика
case "$1" in
    poweron)
        power_on_disk "$2" "$3"
        ;;
    poweroff)
        power_off_disk "$2" "$3"
        ;;
    list)
        list_disks
        ;;
    status)
        check_status "$2" "$3"
        ;;
    mount)
        mount_disk "$2" "$3"
        ;;
    umount)
        umount_disk "$2" "$3"
        ;;
    help|--help|-h)
        show_help
        ;;
    "")
        show_help
        ;;
    *)
        echo -e "${RED}Неизвестная команда: $1${NC}"
        show_help
        exit 1
        ;;
esac
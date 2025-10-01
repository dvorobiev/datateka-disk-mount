#!/bin/bash

# Light версия утилиты управления дисками Datateka
# Работает только через bash скрипты без Python

# Конфигурация
SERIAL_PORT="/dev/ttyUSB0"
CSV_FILE="DISK_WWN.csv"
MAX_ACTIVE_DISKS=6

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
    echo "  poweron <диск>        Включить диск (например: A1, B3)"
    echo "  poweroff <диск>       Выключить диск (например: A1, B3)"
    echo "  mount <диск>          Смонтировать диск (включает и монтирует)"
    echo "  umount <диск>         Отмонтировать диск"
    echo "  list                  Показать список дисков"
    echo "  status [<диск>]       Проверить статус диска или всех дисков"
    echo "  help                  Показать эту справку"
    echo ""
    echo "Примеры:"
    echo "  $0 poweron A1         Включить диск A1"
    echo "  $0 mount B3           Включить и смонтировать диск B3"
    echo "  $0 list               Показать все диски"
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

# Функция для преобразования нотации диска (A1 -> модуль 1, позиция 1)
parse_disk_notation() {
    local disk_notation="$1"
    
    # Проверка формата (буква + число)
    if ! [[ "$disk_notation" =~ ^[A-Z][0-9]+$ ]]; then
        echo -e "${RED}Ошибка: Неверный формат диска. Используйте формат: буква + число (например: A1, B3)${NC}"
        return 1
    fi
    
    # Извлекаем букву и число
    local letter="${disk_notation:0:1}"
    local number="${disk_notation:1}"
    
    # Преобразуем букву в номер модуля (A=1, B=2, и т.д.)
    local module=$(printf "%d" "'$letter")
    module=$((module - 64))  # ASCII 'A' = 65, поэтому A=1, B=2, ...
    
    # Проверяем, что номер модуля в допустимом диапазоне
    if [ $module -lt 1 ] || [ $module -gt 5 ]; then
        echo -e "${RED}Ошибка: Номер модуля должен быть от 1 до 5${NC}"
        return 1
    fi
    
    # Проверяем, что позиция в допустимом диапазоне
    if [ $number -lt 1 ] || [ $number -gt 12 ]; then
        echo -e "${RED}Ошибка: Позиция должна быть от 1 до 12${NC}"
        return 1
    fi
    
    echo "$module $number"
    return 0
}

# Функция для проверки количества активных дисков
check_active_disks() {
    local current_active=$(mount | grep "/mnt/" | wc -l)
    echo $current_active
}

# Функция для включения диска
power_on_disk() {
    local disk_notation="$1"
    
    # Проверка аргумента
    if [ -z "$disk_notation" ]; then
        echo -e "${RED}Ошибка: Требуется указать диск (например: A1, B3)${NC}"
        echo "Пример: $0 poweron A1"
        return 1
    fi
    
    # Преобразуем нотацию диска
    local parsed=$(parse_disk_notation "$disk_notation")
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    local module=$(echo "$parsed" | cut -d' ' -f1)
    local position=$(echo "$parsed" | cut -d' ' -f2)
    
    echo -e "${YELLOW}Включение диска $disk_notation (Модуль $module, Позиция $position)${NC}"
    local command="#hdd_m${module} n${position} on\r\n"
    if send_command "$command"; then
        echo -e "${GREEN}Диск $disk_notation успешно включен${NC}"
    else
        return 1
    fi
}

# Функция для выключения диска
power_off_disk() {
    local disk_notation="$1"
    
    # Проверка аргумента
    if [ -z "$disk_notation" ]; then
        echo -e "${RED}Ошибка: Требуется указать диск (например: A1, B3)${NC}"
        echo "Пример: $0 poweroff A1"
        return 1
    fi
    
    # Преобразуем нотацию диска
    local parsed=$(parse_disk_notation "$disk_notation")
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    local module=$(echo "$parsed" | cut -d' ' -f1)
    local position=$(echo "$parsed" | cut -d' ' -f2)
    
    echo -e "${YELLOW}Выключение диска $disk_notation (Модуль $module, Позиция $position)${NC}"
    local command="#hdd_m${module} n${position} off\r\n"
    if send_command "$command"; then
        echo -e "${GREEN}Диск $disk_notation успешно выключен${NC}"
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
    echo "Диск;WWN;Модуль;Позиция;Точка монтирования"
    echo "----------------------------------------"
    # Пропускаем первую строку (заголовок) и выводим остальные
    tail -n +2 "$CSV_FILE" | while IFS=';' read -r wwn module position mount_point; do
        # Преобразуем номер модуля в букву
        local module_letter=$(printf "\\$(printf '%03o' $((module + 64)))")
        local disk_id="${module_letter}${position}"
        echo "$disk_id;$wwn;$module;$position;$mount_point"
    done
}

# Функция для проверки статуса диска (смонтирован/не смонтирован)
check_status() {
    local disk_notation="$1"
    
    if [ -z "$disk_notation" ]; then
        # Проверяем статус всех дисков
        local total_disks=0
        local active_disks=0
        
        tail -n +2 "$CSV_FILE" | while IFS=';' read -r wwn module position mount_point; do
            total_disks=$((total_disks + 1))
            local full_mount_point="/mnt/$mount_point"
            
            # Преобразуем номер модуля в букву
            local module_letter=$(printf "\\$(printf '%03o' $((module + 64)))")
            local disk_id="${module_letter}${position}"
            
            if mountpoint -q "$full_mount_point" >/dev/null 2>&1; then
                active_disks=$((active_disks + 1))
                echo -e "${GREEN}Диск $disk_id (модуль $module, позиция $position) СМОНТИРОВАН в $full_mount_point${NC}"
                # Показываем информацию о свободном месте
                if command -v df >/dev/null 2>&1; then
                    df -h "$full_mount_point" | tail -n +2
                fi
            else
                echo -e "${YELLOW}Диск $disk_id (модуль $module, позиция $position) НЕ СМОНТИРОВАН${NC}"
            fi
        done
        
        echo -e "${BLUE}Общее количество дисков: $total_disks${NC}"
        echo -e "${BLUE}Активных дисков: $active_disks из $MAX_ACTIVE_DISKS${NC}"
        
        return 0
    fi
    
    # Проверяем конкретный диск
    local parsed=$(parse_disk_notation "$disk_notation")
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    local module=$(echo "$parsed" | cut -d' ' -f1)
    local position=$(echo "$parsed" | cut -d' ' -f2)
    
    # Получаем точку монтирования из CSV файла
    local mount_point=$(tail -n +2 "$CSV_FILE" | awk -F';' -v mod="$module" -v pos="$position" '$2==mod && $3==pos {print $4}')
    
    if [ -z "$mount_point" ]; then
        echo -e "${RED}Ошибка: Диск $disk_notation не найден в конфигурации${NC}"
        return 1
    fi
    
    # Формируем полный путь к точке монтирования
    local full_mount_point="/mnt/$mount_point"
    
    if mountpoint -q "$full_mount_point" >/dev/null 2>&1; then
        echo -e "${GREEN}Диск $disk_notation СМОНТИРОВАН в $full_mount_point${NC}"
        # Показываем информацию о свободном месте
        if command -v df >/dev/null 2>&1; then
            df -h "$full_mount_point" | tail -n +2
        fi
    else
        echo -e "${YELLOW}Диск $disk_notation НЕ СМОНТИРОВАН${NC}"
    fi
}

# Функция для включения и монтирования диска одной командой
power_on_and_mount() {
    local disk_notation="$1"
    
    # Проверка аргумента
    if [ -z "$disk_notation" ]; then
        echo -e "${RED}Ошибка: Требуется указать диск (например: A1, B3)${NC}"
        echo "Пример: $0 mount A1"
        return 1
    fi
    
    # Проверяем количество активных дисков
    local active_count=$(check_active_disks)
    if [ $active_count -ge $MAX_ACTIVE_DISKS ]; then
        echo -e "${RED}Ошибка: Достигнуто максимальное количество активных дисков ($MAX_ACTIVE_DISKS)${NC}"
        echo -e "${BLUE}Текущее количество активных дисков: $active_count${NC}"
        return 1
    fi
    
    # Преобразуем нотацию диска
    local parsed=$(parse_disk_notation "$disk_notation")
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    local module=$(echo "$parsed" | cut -d' ' -f1)
    local position=$(echo "$parsed" | cut -d' ' -f2)
    
    echo -e "${YELLOW}Включение диска $disk_notation (Модуль $module, Позиция $position)${NC}"
    local command="#hdd_m${module} n${position} on\r\n"
    if ! send_command "$command"; then
        return 1
    fi
    
    echo -e "${GREEN}Диск $disk_notation успешно включен${NC}"
    
    # Ждем немного, чтобы диск определился системой
    sleep 3
    
    # Монтируем диск
    mount_single_disk "$disk_notation"
}

# Функция для монтирования одного диска (вспомогательная функция)
mount_single_disk() {
    local disk_notation="$1"
    
    # Преобразуем нотацию диска
    local parsed=$(parse_disk_notation "$disk_notation")
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    local module=$(echo "$parsed" | cut -d' ' -f1)
    local position=$(echo "$parsed" | cut -d' ' -f2)
    
    # Получаем WWN и точку монтирования из CSV файла
    local mount_point=$(tail -n +2 "$CSV_FILE" | awk -F';' -v mod="$module" -v pos="$position" '$2==mod && $3==pos {print $4}')
    local wwn=$(tail -n +2 "$CSV_FILE" | awk -F';' -v mod="$module" -v pos="$position" '$2==mod && $3==pos {print $1}')
    
    if [ -z "$mount_point" ] || [ -z "$wwn" ]; then
        echo -e "${RED}Ошибка: Диск $disk_notation не найден в конфигурации${NC}"
        return 1
    fi
    
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
        echo -e "${GREEN}Диск $disk_notation успешно смонтирован в $full_mount_point${NC}"
    else
        echo -e "${RED}Ошибка при монтировании диска $disk_notation${NC}"
        # Показываем последние сообщения ядра
        dmesg | tail -n 10
        return 1
    fi
}

# Функция для отмонтирования диска
umount_disk() {
    local disk_notation="$1"
    
    if [ -z "$disk_notation" ]; then
        echo -e "${RED}Ошибка: Требуется указать диск (например: A1, B3)${NC}"
        return 1
    fi
    
    # Преобразуем нотацию диска
    local parsed=$(parse_disk_notation "$disk_notation")
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    local module=$(echo "$parsed" | cut -d' ' -f1)
    local position=$(echo "$parsed" | cut -d' ' -f2)
    
    # Получаем точку монтирования из CSV файла
    local mount_point=$(tail -n +2 "$CSV_FILE" | awk -F';' -v mod="$module" -v pos="$position" '$2==mod && $3==pos {print $4}')
    
    if [ -z "$mount_point" ]; then
        echo -e "${RED}Ошибка: Диск $disk_notation не найден в конфигурации${NC}"
        return 1
    fi
    
    local full_mount_point="/mnt/$mount_point"
    
    # Проверяем, смонтирован ли диск
    if ! mountpoint -q "$full_mount_point" >/dev/null 2>&1; then
        echo -e "${YELLOW}Диск $disk_notation уже отмонтирован${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}Отмонтирование $full_mount_point...${NC}"
    
    if umount "$full_mount_point"; then
        echo -e "${GREEN}Диск $disk_notation успешно отмонтирован${NC}"
    else
        echo -e "${RED}Ошибка при отмонтировании диска $disk_notation${NC}"
        return 1
    fi
}

# Основная логика
case "$1" in
    poweron)
        power_on_disk "$2"
        ;;
    poweroff)
        power_off_disk "$2"
        ;;
    mount)
        power_on_and_mount "$2"
        ;;
    umount)
        umount_disk "$2"
        ;;
    list)
        list_disks
        ;;
    status)
        check_status "$2"
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
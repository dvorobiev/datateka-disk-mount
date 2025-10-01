#!/bin/bash

export LC_ALL=C.UTF-8

# Use the current directory instead of hardcoded path
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_PYTHON="$PROJECT_DIR/venv/bin/python3"
MAIN_SCRIPT="$PROJECT_DIR/disk_state.py"

echo "=== ДИАГНОСТИКА ЗАПУСКА ==="
echo "Пользователь: $(whoami)"
echo "Группы: $(groups)"
echo "Права на ttyUSB0: $(ls -l /dev/ttyUSB0 2>/dev/null || echo 'НЕ НАЙДЕН')"
echo "Каталог проекта: $PROJECT_DIR"
echo "=========================="

# Проверяем что устройство существует
if [ ! -e "/dev/ttyUSB0" ]; then
    echo "ОШИБКА: /dev/ttyUSB0 не существует!"
    echo "Подключенные USB устройства:"
    ls -l /dev/ttyUSB* 2>/dev/null || echo "Нет USB serial устройств"
    exit 1
fi

# Проверяем существование виртуального окружения
if [ ! -f "$VENV_PYTHON" ]; then
    echo "Виртуальное окружение не найдено, используем системный Python"
    # Запускаем Python скрипт с системным Python
    cd "$PROJECT_DIR" && sudo python3 "$MAIN_SCRIPT"
else
    # Запускаем Python скрипт с виртуальным окружением
    cd "$PROJECT_DIR" && sudo "$VENV_PYTHON" "$MAIN_SCRIPT"
fi
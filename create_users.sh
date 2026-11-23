#!/bin/bash


FILE="$1"

if [ "$EUID" -ne 0 ]; then
    echo "Ошибка: запустите скрипт через sudo"
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo "Ошибка: файл $FILE не найден"
    exit 1
fi

tail -n +2 "$FILE" | while IFS=',' read -r login fullname dept; do

    group="dept_${dept}"

    # Создаем группу отдела, если ее еще нет
    getent group "$group" > /dev/null || groupadd "$group"

    # Проверяем, существует ли пользователь
    if id "$login" &>/dev/null; then
        echo "[ПРОПУСК] $login уже существует"
        continue
    fi

    # Создаем пользователя с домашней папкой
    useradd -m -s /bin/bash -c "$fullname" -G "$group" "$login"

    # Устанавливаем временный пароль
    echo "$login:Temp_$(openssl rand -hex 4)" | chpasswd

    # Требуем сменить пароль при первом входе
    chage -d 0 "$login"

    echo "[OK] $login ($fullname) -> группа $group"

done

echo "Обработка списка сотрудников завершена"

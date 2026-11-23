
#!/bin/bash

LOG="${1:-auth_sample.log}"
LIMIT=2

if [ ! -f "$LOG" ]; then
    echo "Ошибка: файл журнала не найден"
    exit 1
fi

echo "=== АНАЛИЗ ЖУРНАЛА БЕЗОПАСНОСТИ ==="
echo "Файл: $LOG"
echo

echo "--- Статистика входов ---"
echo "Неудачных попыток: $(grep -c 'Failed password' "$LOG")"
echo "Успешных входов: $(grep -c 'Accepted' "$LOG")"
echo

echo "--- IP-адреса с неудачными попытками ---"
grep 'Failed password' "$LOG" |
grep -oE 'from [0-9.]+' |
awk '{print $2}' |
sort | uniq -c | sort -rn

echo
echo "--- Несуществующие пользователи ---"
grep 'invalid user' "$LOG" |
awk '{for(i=1;i<=NF;i++) if($i=="user") print $(i+1)}' |
sort -u

echo
echo "--- Кандидаты на блокировку (2 и более попыток) ---"
grep 'Failed password' "$LOG" |
grep -oE 'from [0-9.]+' |
awk '{print $2}' |
sort | uniq -c |
awk -v limit="$LIMIT" '$1 >= limit {print "IP:", $2, "| Неудачных попыток:", $1}'

echo
echo "--- Попытки sudo без разрешения ---"
grep 'NOT in sudoers' "$LOG" || echo "Не обнаружено"

echo
echo "Анализ завершён"

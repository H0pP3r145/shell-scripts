#!/bin/bash

if [ -z "$1" ]; then
    echo "Использование: $0 email@example.com"
    exit 1
fi

EMAIL="$1"  # Получаем email из аргумента
DOMAIN="${EMAIL#*@}"  # Извлекаем домен
MX_SERVERS=($(nslookup -type=mx $DOMAIN | awk '/mail exchanger/ {print $NF}' | sort))  # Получаем все MX-серверы

if [ ${#MX_SERVERS[@]} -eq 0 ]; then
    echo "Не удалось найти MX-серверы для $DOMAIN"
    exit 1
fi

echo "Найденные MX-серверы для $DOMAIN: ${MX_SERVERS[*]}"
echo "--------------------------------------------------"

for MX_SERVER in "${MX_SERVERS[@]}"; do
    echo -n "$MX_SERVER: "

    START_TIME=$(date +%s%N)  # Фиксируем время начала

    RESPONSE=$(echo -e "HELO example.com\r\nMAIL FROM:<check@example.com>\r\nRCPT TO:<$EMAIL>\r\nQUIT\r\n" | nc -w 5 "$MX_SERVER" 25 2>/dev/null)

    END_TIME=$(date +%s%N)  # Фиксируем время завершения
    DURATION=$(( (END_TIME - START_TIME) / 1000000 ))  # Время в миллисекундах

    if echo "$RESPONSE" | grep -q "250"; then
        RESULT="Email существует"
    elif echo "$RESPONSE" | grep -q "550"; then
        RESULT="Email не существует"
    elif [ -z "$RESPONSE" ]; then
        RESULT="Нет ответа"
    else
        RESULT="Неизвестный ответ"
    fi

    echo "$DURATION мс - $RESULT"
done


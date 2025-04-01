#!/bin/bash

set -e

# --- Дефолты ---
DO_GEN_PRIV=false
DO_GEN_PUB=false
DO_SHOW_PUB=false
DO_SHOW_DKIM=false
KEY_FILE=""
PUB_FILE=""
KEY_SIZE=2048

# --- Парсинг флагов ---
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --generate-private) DO_GEN_PRIV=true ;;
    --generate-public)  DO_GEN_PUB=true ;;
    --show-public)      DO_SHOW_PUB=true ;;
    --show-dkim)        DO_SHOW_DKIM=true ;;
    --key)              KEY_FILE="$2"; shift ;;
    --pub-out)          PUB_FILE="$2"; shift ;;
    --size)             KEY_SIZE="$2"; shift ;;
    --help)
      echo -e "\n\033[1;35mDKIM CLI Utility — Поддерживаемые флаги:\033[0m"
      echo "--generate-private          Сгенерировать приватный ключ"
      echo "--generate-public           Сгенерировать публичный ключ из приватного"
      echo "--show-public               Показать публичный ключ (без сохранения)"
      echo "--show-dkim                 Показать DKIM DNS-запись"
      echo "--key <file>                Указать путь до приватного ключа"
      echo "--pub-out <file>            Указать имя файла для публичного ключа"
      echo "--size <bits>               Размер ключа (1024/2048/4096)"
      exit 0
      ;;
    *)
      echo "❌ Неизвестный аргумент: $1"
      exit 1
      ;;
  esac
  shift
done

# --- Генерация приватного ключа ---
if [ "$DO_GEN_PRIV" = true ]; then
  if [ -z "$KEY_FILE" ]; then
    read -p "📛 Введите имя приватного ключа (например: test.key): " KEY_FILE
  fi
  echo -e "🔧 Генерация приватного ключа $KEY_SIZE бит → $KEY_FILE"
  openssl genrsa -out "$KEY_FILE" -traditional "$KEY_SIZE"
  echo -e "✅ Приватный ключ сохранён: $KEY_FILE"
fi

# --- Проверка наличия приватного ключа ---
if [ "$DO_GEN_PUB" = true ] || [ "$DO_SHOW_PUB" = true ] || [ "$DO_SHOW_DKIM" = true ]; then
  if [ -z "$KEY_FILE" ]; then
    echo "❌ Укажи приватный ключ через --key"
    exit 1
  fi
  if [ ! -f "$KEY_FILE" ]; then
    echo "❌ Приватный ключ $KEY_FILE не найден"
    exit 1
  fi
fi

# --- Генерация публичного ключа в файл ---
if [ "$DO_GEN_PUB" = true ]; then
  if [ -z "$PUB_FILE" ]; then
    PUB_FILE="${KEY_FILE%.key}.public"
  fi
  echo -e "📤 Извлечение публичного ключа → $PUB_FILE"
  openssl rsa -in "$KEY_FILE" -pubout -out "$PUB_FILE"
  echo -e "✅ Публичный ключ сохранён: $PUB_FILE"
fi

# --- Показ публичного ключа ---
if [ "$DO_SHOW_PUB" = true ]; then
  echo -e "\n👁️ Публичный ключ:"
  openssl rsa -in "$KEY_FILE" -pubout
fi

# --- Показ DKIM DNS-записи ---
if [ "$DO_SHOW_DKIM" = true ]; then
  PUB_CONTENT=$(openssl rsa -in "$KEY_FILE" -pubout 2>/dev/null | sed '/^-----/d' | tr -d '\n')
  echo -e "\n🌐 DKIM DNS-запись:"
  echo -e "\033[0;36mv=DKIM1; k=rsa; p=$PUB_CONTENT\033[0m"
fi

#!/bin/bash

# Цвета ANSI
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Параметры
FULL_LOG=false
INPUT_FILE=""
IP_ARG_MODE=false

# Аргументы
for arg in "$@"; do
  case $arg in
    --full-log)
      FULL_LOG=true
      shift
      ;;
    *.txt)
      INPUT_FILE="$arg"
      shift
      ;;
    *)
      IP_ARG_MODE=true
      ;;
  esac
done

# RBL список
RBL_LIST=(
    "b.barracudacentral.org"
    "cbl.abuseat.org"
    "dnsbl.fabel.dk"
    "hostkarma.junkemailfilter.com"
    "rbl.0spam.com"
    "psbl.surriel.com"
    "sbl.spamhaus.org"
    "pbl.spamhaus.org"
    "xbl.spamhaus.org"
    "rbl.schulte.org"
    "tor.dan.me.uk"
    "dnsbl-1.uceprotect.net"
    "dnsbl-2.uceprotect.net"
    "dnsbl-3.uceprotect.net"
    "rbl.usenix.org"
    "dnsbl.dronebl.org"
    "singular.ttk.pte.hu"
    "bl.mailspike.net"
    "backscatter.spameatingmonkey.net"
    "dnsbl.interserver.net"
    "bl.blocklist.de"
    "v4.fullbogons.cymru.com"
    "bogons.cymru.com"
    "rbl.0spam.org"
    "bl.abusero.com"
    "dnsbl.jippg.org"
    "rbl.pedantic.org"
    "dnsbl.anonmails.de"
    "spam.rbl.gweep.ca"
)

# Функция проверки одного IP
check_ip() {
    local IP="$1"
    if [[ ! "$IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "${RED}❌ Неверный формат IP: $IP${NC}"
        return
    fi

    local REVERSED_IP=$(echo "$IP" | awk -F. '{print $4"."$3"."$2"."$1}')
    local HIT_LIST=()

    if $FULL_LOG; then
        echo ""
        echo -e "🕵️ Проверка IP ${YELLOW}$IP${NC} в RBL-базах:"
        echo "--------------------------------------------"
    fi

    for RBL in "${RBL_LIST[@]}"; do
        QUERY="$REVERSED_IP.$RBL"
        START_TIME=$(date +%s%3N)
        A_RESULT=$(dig +short A "$QUERY")
        TXT_RESULT=$(dig +short TXT "$QUERY")
        END_TIME=$(date +%s%3N)
        ELAPSED=$((END_TIME - START_TIME))
        TIME_STR="${GRAY}(${ELAPSED}ms)${NC}"
        FORMATTED_RBL="${YELLOW}$RBL${NC}"

        if [[ -n "$A_RESULT" || -n "$TXT_RESULT" ]]; then
            HIT_LIST+=("$RBL")
            if $FULL_LOG; then
                echo -e "${RED}🚫 $FORMATTED_RBL — ЗАБЛОКИРОВАН $TIME_STR${NC}"
                [[ -n "$A_RESULT" ]] && echo -e "   ↪ A-запись: $A_RESULT"
                [[ -n "$TXT_RESULT" ]] && echo -e "   ↪ TXT: $TXT_RESULT"
            fi
        else
            if $FULL_LOG; then
                echo -e "${GREEN}✅ $FORMATTED_RBL — чисто $TIME_STR${NC}"
            fi
        fi
    done

    if ! $FULL_LOG; then
    if [ ${#HIT_LIST[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ $IP — полностью чист${NC}"
    else
        echo -e "${RED}❌ $IP — найдены попадания:${NC}"
        for hit in "${HIT_LIST[@]}"; do
            RBL_QUERY="$REVERSED_IP.$hit"
            A_RESULT=$(dig +short A "$RBL_QUERY")
            TXT_RESULT=$(dig +short TXT "$RBL_QUERY")
            echo -e "   ${YELLOW}$hit${NC}"
            [[ -n "$A_RESULT" ]] && echo -e "   ↪ A: $A_RESULT"
            [[ -n "$TXT_RESULT" ]] && echo -e "   ↪ TXT: $TXT_RESULT"
        done
    fi
fi
}

# Основная логика
if [[ -n "$INPUT_FILE" && -f "$INPUT_FILE" ]]; then
    echo -e "${YELLOW}📄 Режим: проверка IP из файла: $INPUT_FILE${NC}"
    while IFS= read -r ip; do
        [[ -z "$ip" ]] && continue
        check_ip "$ip"
    done < "$INPUT_FILE"
else
    read -p "Введи IP для проверки: " IP
    check_ip "$IP"
fi


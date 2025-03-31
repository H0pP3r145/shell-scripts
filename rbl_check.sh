#!/bin/bash

# Цвета ANSI
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

read -p "Введи IP для проверки: " IP

if [[ ! "$IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}❌ Неверный формат IP${NC}"
    exit 1
fi

REVERSED_IP=$(echo "$IP" | awk -F. '{print $4"."$3"."$2"."$1}')
echo ""
echo -e "🕵️ Проверка IP ${YELLOW}$IP${NC} в RBL-базах:"
echo "--------------------------------------------"

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

for RBL in "${RBL_LIST[@]}"; do
    QUERY="$REVERSED_IP.$RBL"

    START_TIME=$(date +%s%3N)

    A_RESULT=$(dig +short A "$QUERY")
    TXT_RESULT=$(dig +short TXT "$QUERY")

    END_TIME=$(date +%s%3N)
    ELAPSED=$((END_TIME - START_TIME))

    # Стиль: базу показываем жёлтым и жирным
    FORMATTED_RBL="${YELLOW}$RBL${NC}"
    TIME_STR="${GRAY}(${ELAPSED}ms)${NC}"

    if [[ -n "$A_RESULT" || -n "$TXT_RESULT" ]]; then
        echo -e "${RED}🚫 $FORMATTED_RBL — ЗАБЛОКИРОВАН $TIME_STR${NC}"
        [[ -n "$A_RESULT" ]] && echo -e "   ↪ A-запись: $A_RESULT"
        [[ -n "$TXT_RESULT" ]] && echo -e "   ↪ TXT: $TXT_RESULT"
    else
        echo -e "${GREEN}✅ $FORMATTED_RBL — чисто $TIME_STR${NC}"
    fi
done

echo "--------------------------------------------"
echo "Проверка завершена."


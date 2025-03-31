#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELP_FILE="$SCRIPT_DIR/commands.txt"

COMMAND=$1
shift

case "$COMMAND" in
  rbl_check)
    bash "$SCRIPT_DIR/rbl_check.sh" "$@"
    ;;
  check_smtp_time)
    bash "$SCRIPT_DIR/check_smtp_time.sh" "$@"
    ;;
  -h|--help|"")
    echo "🧰 Доступные команды:"
    column -t "$HELP_FILE"
    ;;
  *)
    echo "❌ Неизвестная команда: $COMMAND"
    echo ""
    echo "💡 Доступные команды:"
    column -t "$HELP_FILE"
    ;;
esac


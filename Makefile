# Установим цель по умолчанию
.DEFAULT_GOAL := help

SCRIPTS_DIR := $(CURDIR)

help: ## Показывает список доступных команд
	@echo "🧰 Доступные команды:"
	@grep -E '^[a-zA-Z_-]+:.*?##' Makefile | awk 'BEGIN {FS=":.*?##"} {printf "  \033[1;33m%-20s\033[0m %s\n", $$1, $$2}'

rbl_check: ## Проверка IP по RBL-базам
	@bash $(SCRIPTS_DIR)/rbl_check.sh

check_smtp_time: ## Проверка отклика SMTP-сервера
	@bash $(SCRIPTS_DIR)/check_smtp_time.sh

# Игнорировать все правила, совпадающие с именами файлов
%:
	@:

.PHONY: help rbl_check check_smtp_time


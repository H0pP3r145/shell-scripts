#!/bin/bash

set -e

SCRIPT_SOURCE="dkimutil.sh"
SCRIPT_TARGET="/usr/local/bin/hdkim"
OPTIONS_FILE="options.txt"

BASH_COMPLETION_FILE="autocomplete/hdkim"
ZSH_COMPLETION_FILE="autocomplete/_hdkim"

echo "📦 Установка hdkim в $SCRIPT_TARGET..."
sudo cp "$SCRIPT_SOURCE" "$SCRIPT_TARGET"
sudo chmod +x "$SCRIPT_TARGET"

# --- Чтение флагов из options.txt ---
if [ ! -f "$OPTIONS_FILE" ]; then
    echo "❌ Файл $OPTIONS_FILE не найден!"
    exit 1
fi

HDKIM_OPTS=()
while IFS= read -r line || [[ -n "$line" ]]; do
    HDKIM_OPTS+=("$line")
done <"$OPTIONS_FILE"

# --- Генерация bash completion ---
echo "⚙️ Генерация bash completion..."

generate_bash_completion() {
    local opts=""
    for item in "${HDKIM_OPTS[@]}"; do
        opt="${item%%:*}"
        opts+="$opt "
    done

    mkdir -p autocomplete
    cat >"$BASH_COMPLETION_FILE" <<EOF
# bash completion for hdkim
_hdkim()
{
    local cur prev opts
    COMPREPLY=()
    cur="\${COMP_WORDS[COMP_CWORD]}"
    opts="$opts"

    if [[ \${cur} == -* ]]; then
        COMPREPLY=( \$(compgen -W "\${opts}" -- \${cur}) )
        return 0
    fi
}
complete -F _hdkim hdkim
EOF
}

# --- Генерация zsh completion ---
echo "⚙️ Генерация zsh completion..."

generate_zsh_completion() {
    mkdir -p autocomplete
    {
        echo "#compdef hdkim"
        echo
        echo "_arguments -s \\"
        for item in "${HDKIM_OPTS[@]}"; do
            opt="${item%%:*}"
            desc="${item#*:}"
            if [[ "$opt" =~ =(.*) ]]; then
                argname="${BASH_REMATCH[1]//[\[\]]/}" # убираем [ ]
                opt_clean="${opt%%=*}"                # убираем =...
                echo "  '$opt_clean[$desc]:$argname' \\"
            else
                echo "  '$opt[$desc]' \\"
            fi
        done
    } >"$ZSH_COMPLETION_FILE"
}

generate_bash_completion
generate_zsh_completion

# --- Установка bash completion ---
echo "🧠 Установка bash автодополнения..."

if [[ "$OSTYPE" == "darwin"* ]]; then
    BASH_COMPLETION_DIR="$(brew --prefix)/etc/bash_completion.d"
else
    BASH_COMPLETION_DIR="/etc/bash_completion.d"
fi

if [ -d "$BASH_COMPLETION_DIR" ]; then
    sudo cp "$BASH_COMPLETION_FILE" "$BASH_COMPLETION_DIR/hdkim"
    echo "✅ Bash автодополнение установлено в $BASH_COMPLETION_DIR/hdkim"
else
    echo "⚠️ Не найдена директория для bash-completion: $BASH_COMPLETION_DIR"
fi

# --- Установка zsh completion ---
echo "🧠 Установка zsh автодополнения..."

ZSH_COMPLETION_DIR="$HOME/.zsh/completion"
mkdir -p "$ZSH_COMPLETION_DIR"
cp "$ZSH_COMPLETION_FILE" "$ZSH_COMPLETION_DIR/_hdkim"

# Обновление ~/.zshrc при необходимости
if ! grep -q 'fpath=(~/.zsh/completion' ~/.zshrc; then
    echo "🛠 Добавляем fpath в ~/.zshrc"
    echo -e "\nfpath=(~/.zsh/completion \$fpath)\nautoload -Uz compinit && compinit" >>~/.zshrc
fi

# --- Финальное сообщение ---
echo -e "\n✅ Установка завершена!"
echo -e "\n🔁 Перезапусти терминал или выполни:"
echo "    source ~/.zshrc                      # для Zsh"
echo "    source $BASH_COMPLETION_DIR/hdkim    # для Bash"

echo -e "\n🚀 Пример:"
echo "    hdkim --generate-private --key test.key --show-public --show-dkim"

#!/bin/bash

set -e

SCRIPT_SOURCE="dkimutil.sh"
SCRIPT_TARGET="/usr/local/bin/hdkim"

if [ ! -f "$SCRIPT_SOURCE" ]; then
  echo "❌ Файл $SCRIPT_SOURCE не найден. Положи рядом dkimutil.sh"
  exit 1
fi

echo "📦 Установка hdkim в $SCRIPT_TARGET..."
sudo cp "$SCRIPT_SOURCE" "$SCRIPT_TARGET"
sudo chmod +x "$SCRIPT_TARGET"

# -------- BASH AUTOCOMPLETE --------
BASH_COMPLETION="/etc/bash_completion.d/hdkim"
echo "🧠 Настройка автодополнения для bash..."
sudo tee "$BASH_COMPLETION" > /dev/null <<'EOF'
_hdkim()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    opts="--generate-private --generate-public --show-public --show-dkim --key --pub-out --size --help"

    if [[ ${cur} == -* ]]; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi
}
complete -F _hdkim hdkim
EOF

# -------- ZSH AUTOCOMPLETE --------
ZSH_DIR="$HOME/.zsh/completion"
ZSH_FILE="${ZSH_DIR}/_hdkim"
echo "🧠 Настройка автодополнения для zsh..."
mkdir -p "$ZSH_DIR"
cat > "$ZSH_FILE" <<'EOF'
#compdef hdkim

_arguments -s \
  '--generate-private[Generate private key]' \
  '--generate-public[Generate public key]' \
  '--show-public[Show public key]' \
  '--show-dkim[Show DKIM DNS record]' \
  '--key=[Path to private key file]' \
  '--pub-out=[Output file for public key]' \
  '--size=[Key size: 1024, 2048, 4096]' \
  '--help[Show help]'
EOF

if ! grep -q 'fpath=(~/.zsh/completion' ~/.zshrc; then
  echo "🛠 Добавляем поддержку fpath в ~/.zshrc"
  echo -e "\nfpath=(~/.zsh/completion \$fpath)\nautoload -Uz compinit && compinit" >> ~/.zshrc
fi

echo -e "\n✅ Установка завершена!"

echo -e "\n🔁 Перезапусти терминал или выполни:"
echo "    source ~/.zshrc  # для Zsh"
echo "    source /etc/bash_completion.d/hdkim  # для Bash"

echo -e "\n🚀 Теперь ты можешь вызывать:"
echo "    hdkim --generate-private --key test.key --show-public --show-dkim"


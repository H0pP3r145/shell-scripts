# HDkim

##№ 🔧 Установка

```bash
git clone https://github.com/H0pP3r145/hdkim.git
cd hdkim
chmod +x install-hdkim.sh
./install-hdkim.sh
```

### 🚀 Примеры использования

#### Сгенерировать приватный ключ (2048 бит по умолчанию)

`hdkim --generate-private --key mail.key`

#### Сгенерировать публичный ключ из приватного

`hdkim --generate-public --key mail.key --pub-out mail.public`

#### Показать публичный ключ (без сохранения)

`hdkim --show-public --key mail.key`

#### Показать готовую DKIM DNS-запись

`hdkim --show-dkim --key mail.key`

#### 🔗 Комбинировать команды

`hdkim --generate-private --key mydomain.key --show-public --show-dkim`

#### ⚙️ Доступные флаги

|Флаг|Описание|
|---|---|
|`--generate-private`|Сгенерировать приватный DKIM-ключ|
|`--generate-public`|Сгенерировать публичный ключ из приватного|
|`--show-public`|Показать публичный ключ без сохранения|
|`--show-dkim`|Вывести DKIM DNS-запись|
|`--key <файл>`|Указать файл приватного ключа|
|`--pub-out <файл>`|Имя файла для сохранения публичного ключа|
|`--size <бит>`|Размер ключа (по умолчанию: 2048)|
|`--help`|Показать справку по флагам

#### 🧠 Автодополнение

 После установки автодополнение работает в:

*Bash* `(/etc/bash_completion.d/hdkim)`

*Zsh* `(~/.zsh/completion/_hdkim)`

Проверь:

`hdkim --<TAB><TAB>`
# Roadmap 
# Этап 1

## Контекст этапа

Первый этап проекта password manager ограничен локальным MVP:

- только локальное хранилище;
- стандартные операции с записями: добавление, удаление, редактирование;
- простой CLI под Linux.

За пределами первого этапа остаются:

- Android-клиент;
- Linux GUI;
- сервер;
- синхронизация;
- поддержка Windows.

---

# Цель первого этапа

Реализовать локальное ядро менеджера паролей и простой CLI-интерфейс под Linux, позволяющий пользователю создать локальное зашифрованное хранилище и выполнять базовые CRUD-операции над записями.

Итоговый пользовательский сценарий:

```bash
pwdctl init --vault ./local.pwd
pwdctl add --vault ./local.pwd
pwdctl list --vault ./local.pwd
pwdctl show --vault ./local.pwd --id <entry-id>
pwdctl edit --vault ./local.pwd --id <entry-id>
pwdctl remove --vault ./local.pwd --id <entry-id>
```

---

# Архитектурная идея первого этапа

На первом этапе приложение лучше разделить на несколько независимых модулей:

```text
apps/
  pwdctl-cli/          # CLI-приложение

libs/
  pwdctl-core/              # доменная модель и CRUD-логика
  pwdctl-crypto/            # KDF, шифрование, расшифрование
  pwdctl-storage/           # работа с файлом хранилища
  pwdctl-serialization/     # сериализация vault
```

---

# Итерация 1. Каркас проекта

## [ ] PWD-001. Зафиксировать scope первого этапа

### Описание

Создать документ, где явно указать, что входит в первый этап, а что не входит.

### Входит

- локальный vault-файл;
- создание vault;
- открытие vault по master password;
- добавление записи;
- просмотр списка записей;
- просмотр конкретной записи;
- редактирование записи;
- удаление записи;
- CLI под Linux;
- базовые unit/integration-тесты.

### Не входит

- сервер;
- синхронизация;
- Android;
- Windows;
- GUI;
- браузерное расширение;
- импорт/экспорт;
- шаринг паролей;
- multi-user режим.

### Критерий готовности

Есть файл:

```text
docs/stage_1_scope.md
```

---

## [ ] PWD-002. Создать структуру репозитория

### Рекомендуемая структура

```text
pwdctl/
├── CMakeLists.txt
├── apps/
│   └── pwdctl-cli/
├── libs/
│   ├── pwdctl-core/
│   ├── pwdctl-application/
│   ├── pwdctl-crypto/
│   ├── pwdctl-storage/
│   └── pwdctl-serialization/
├── tests/
│   ├── core/
│   ├── application/
│   ├── crypto/
│   ├── storage/
│   ├── serialization/
│   └── cli/
├── docs/
└── cmake/
```

---

## [ ] PWD-003. Настроить CMake

### Требования

- C++20 или C++23;
- отдельные CMake targets для библиотек и CLI;
- строгие предупреждения компилятора;
- отдельная сборка тестов.

### Пример targets

```cmake
add_library(pwdctl-core ...)
add_library(pwdctl-application ...)
add_library(pwdctl-crypto ...)
add_library(pwdctl-storage ...)
add_library(pwdctl-serialization ...)
add_executable(pwdctl ...)
```

### Критерий готовности

Команды проходят без ошибок:

```bash
cmake -S . -B build
cmake --build build
ctest --test-dir build
```

---

## [ ] PWD-004. Подключить тестовый фреймворк

### Варианты

- GoogleTest;
- Catch2;
- doctest.

Для проекта на C++ с перспективой роста практично выбрать GoogleTest или Catch2.

### Критерий готовности

Есть один smoke-test, который запускается через `ctest`.

---

# Итерация 2. Доменное ядро

## [ ] PWD-005. Реализовать модель записи пароля

### Минимальная модель

```cpp
struct PasswordEntry {
    std::string id;
    std::string title;
    std::string username;
    std::string password;
    std::string url;
    std::string notes;
    std::int64_t createdAt;
    std::int64_t updatedAt;
};
```

### Ограничения MVP

На первом этапе не добавлять:

- теги;
- вложения;
- TOTP;
- историю изменений;
- избранное;
- категории.

### Критерий готовности

Модель находится в `pwd-core` и используется в тестах CRUD.

---

## [ ] PWD-006. Реализовать модель vault

### Минимальная модель

```cpp
struct Vault {
    std::string id;
    std::string name;
    std::vector<PasswordEntry> entries;
    std::int64_t createdAt;
    std::int64_t updatedAt;
};
```

### Критерий готовности

Vault хранит список записей и обновляет `updatedAt` при изменениях.

---

## [ ] PWD-007. Ввести value types

### Зачем

Чтобы не передавать обычные строки там, где нужен путь, идентификатор или имя vault.

### Пример

```cpp
struct EntryId {
    std::string value;
};

struct VaultPath {
    std::filesystem::path value;
};
```

### Критерий готовности

Публичный API ядра не использует случайные `std::string` для идентификаторов и путей.

---

## [ ] PWD-008. Реализовать добавление записи

### API

```cpp
EntryId addEntry(const AddEntryCommand& command);
```

### Команда

```cpp
struct AddEntryCommand {
    std::string title;
    std::string username;
    std::string password;
    std::string url;
    std::string notes;
};
```

### Проверки

- `title` не пустой;
- `password` не пустой;
- `id` генерируется внутри ядра;
- `createdAt` и `updatedAt` выставляются автоматически.

### Критерий готовности

Запись добавляется в vault и доступна через `getEntry`.

---

## [ ] PWD-009. Реализовать получение списка записей

### API

```cpp
std::vector<EntrySummary> listEntries() const;
```

### Summary-модель

```cpp
struct EntrySummary {
    std::string id;
    std::string title;
    std::string username;
    std::string url;
    std::int64_t updatedAt;
};
```

### Важно

`EntrySummary` не должен содержать пароль.

### Критерий готовности

Список записей можно получить без раскрытия секретных данных.

---

## [ ] PWD-010. Реализовать просмотр конкретной записи

### API

```cpp
PasswordEntry getEntry(const EntryId& id) const;
```

### Проверки

- если записи нет — вернуть ошибку `EntryNotFound`;
- пароль возвращается только на уровне ядра;
- CLI должен раскрывать пароль только по явной команде пользователя.

### Критерий готовности

Запись корректно находится по `id`.

---

## [ ] PWD-011. Реализовать редактирование записи

### API

```cpp
void updateEntry(const EntryId& id, const UpdateEntryCommand& command);
```

### Команда

```cpp
struct UpdateEntryCommand {
    std::optional<std::string> title;
    std::optional<std::string> username;
    std::optional<std::string> password;
    std::optional<std::string> url;
    std::optional<std::string> notes;
};
```

### Критерий готовности

Можно изменить одно поле, не перезаписывая остальные.

---

## [ ] PWD-012. Реализовать удаление записи

### API

```cpp
void removeEntry(const EntryId& id);
```

### Проверки

- если записи нет — вернуть ошибку `EntryNotFound`;
- после удаления запись исчезает из `listEntries`;
- повторное удаление возвращает ошибку.

### Критерий готовности

Запись удаляется из vault.

---

## [ ] PWD-013. Реализовать доменные ошибки

### Пример набора ошибок

```cpp
enum class ErrorCode {
    VaultAlreadyExists,
    VaultNotFound,
    InvalidMasterPassword,
    CorruptedVaultFile,
    UnsupportedVaultVersion,
    EntryNotFound,
    ValidationError,
    IoError
};
```

### Критерий готовности

Ошибки не разбросаны по проекту в виде случайных строк.

---

# Итерация 3. Сериализация и формат vault-файла

## [ ] PWD-014. Спроектировать формат vault-файла

### Рекомендуемая структура файла

```text
[magic header]
[format version]
[kdf params]
[salt]
[nonce]
[encrypted payload]
[auth tag]
```

### Пример

```text
magic: PWDVAULT
version: 1
kdf: argon2id
cipher: xchacha20-poly1305
salt: ...
nonce: ...
ciphertext: ...
```

### Критерий готовности

Есть документ:

```text
docs/vault_format_v1.md
```

---

## [ ] PWD-015. Реализовать сериализацию vault

### Возможные варианты

- JSON — проще отлаживать;
- Protocol Buffers — лучше для версионирования;
- MessagePack/CBOR — компактнее.

Для долгосрочного проекта можно выбрать Protocol Buffers, особенно если в дальнейшем появится сервер и синхронизация.

### Важно

Сериализованный payload должен попадать на диск только в зашифрованном виде.

### Критерий готовности

Vault сериализуется в бинарный буфер и восстанавливается обратно.

---

## [ ] PWD-016. Реализовать версионирование формата

### Минимум

```cpp
constexpr std::uint32_t VaultFormatVersion = 1;
```

### Проверки при чтении

- неизвестный magic header;
- неподдерживаемая версия;
- поврежденный файл;
- пустой файл.

### Критерий готовности

Есть тесты на корректную и некорректную версии файла.

---

# Итерация 4. Криптографический слой

## [ ] PWD-017. Выбрать криптобиблиотеку

### Практичные варианты

- libsodium;
- OpenSSL;
- Botan.

Для первого этапа рекомендуется `libsodium`, так как она предоставляет высокоуровневые примитивы для:

- генерации случайных байтов;
- password hashing/KDF;
- AEAD-шифрования;
- проверки целостности;
- работы с секретными буферами.

### Критерий готовности

Криптобиблиотека подключена к проекту, есть smoke-test encrypt/decrypt.

---

## [ ] PWD-018. Реализовать derivation ключа из master password

### API

```cpp
class KeyDerivationService {
public:
    DerivedKey deriveKey(
        const std::string& masterPassword,
        const KdfParams& params
    );
};
```

### Требования

- для каждого vault генерируется случайная соль;
- параметры KDF сохраняются в header vault-файла;
- один и тот же пароль с одной и той же солью дает один ключ;
- один и тот же пароль с разными salt дает разные ключи.

### Критерий готовности

Тесты проверяют стабильность и различие derivation при разных salt.

---

## [ ] PWD-019. Реализовать шифрование payload

### API

```cpp
EncryptedBlob encrypt(
    const PlainBlob& plaintext,
    const DerivedKey& key
);

PlainBlob decrypt(
    const EncryptedBlob& encrypted,
    const DerivedKey& key
);
```

### Проверки

- правильный пароль расшифровывает vault;
- неправильный пароль не расшифровывает vault;
- изменение одного байта ciphertext ломает расшифрование;
- plaintext не пишется на диск.

### Критерий готовности

Есть тесты:

- round-trip;
- wrong password;
- tampered ciphertext;
- empty payload;
- large payload.

---

## [ ] PWD-020. Ввести минимальную гигиену секретов

### Требования

- не логировать master password;
- не логировать пароли записей;
- не показывать пароль в `list`;
- не хранить master password глобально;
- по возможности очищать временные буферы;
- не писать plaintext vault во временные файлы.

### Критерий готовности

В коде нет debug-вывода секретов.

---

# Итерация 5. Слой хранения

## [ ] PWD-021. Реализовать интерфейс VaultStorage

### API

```cpp
class IVaultStorage {
public:
    virtual void save(const VaultPath& path, const EncryptedVaultFile& file) = 0;
    virtual EncryptedVaultFile load(const VaultPath& path) = 0;
    virtual bool exists(const VaultPath& path) const = 0;
    virtual ~IVaultStorage() = default;
};
```

### Критерий готовности

Можно сохранить и загрузить encrypted vault file.

---

## [ ] PWD-022. Реализовать атомарную запись vault-файла

### Схема

```text
vault.pwd.tmp -> fsync -> rename -> vault.pwd
```

### Зачем

Чтобы не повредить основной vault-файл при падении приложения во время записи.

### Критерий готовности

Основной файл не остается частично записанным.

---

## [ ] PWD-023. Реализовать создание нового vault

### API

```cpp
void createVault(
    const VaultPath& path,
    const std::string& name,
    const std::string& masterPassword
);
```

### Проверки

- если файл уже существует — ошибка;
- master password не пустой;
- vault создается с пустым списком записей;
- файл на диске содержит только зашифрованный payload.

### Критерий готовности

Можно создать новый vault-файл.

---

## [ ] PWD-024. Реализовать открытие существующего vault

### API

```cpp
VaultSession openVault(
    const VaultPath& path,
    const std::string& masterPassword
);
```

### Проверки

- если файла нет — ошибка;
- неправильный master password — ошибка;
- поврежденный файл — ошибка;
- корректный файл открывается.

### Критерий готовности

Vault открывается только с правильным master password.

---

# Итерация 6. Application layer

## [ ] PWD-025. Реализовать VaultService

### Назначение

`VaultService` связывает:

- доменную модель;
- storage;
- crypto;
- serialization.

### Пример API

```cpp
class VaultService {
public:
    void createVault(...);
    VaultSession openVault(...);
    void saveVault(...);
};
```

### Критерий готовности

CLI работает через `VaultService`, а не напрямую через storage/crypto.

---

## [ ] PWD-026. Реализовать VaultSession

### Назначение

`VaultSession` представляет открытый vault в памяти.

### Возможный API

```cpp
class VaultSession {
public:
    EntryId addEntry(const AddEntryCommand& command);
    std::vector<EntrySummary> listEntries() const;
    PasswordEntry getEntry(const EntryId& id) const;
    void updateEntry(const EntryId& id, const UpdateEntryCommand& command);
    void removeEntry(const EntryId& id);
    void save();
};
```

### Критерий готовности

После открытия vault все CRUD-операции доступны через единый session object.

---

# Итерация 7. CLI под Linux

## [ ] PWD-027. Выбрать CLI-библиотеку

### Варианты

- CLI11;
- cxxopts;
- Boost.Program_options.

Для MVP лучше выбрать `CLI11` или `cxxopts`.

### Критерий готовности

Команда работает:

```bash
pwd --help
```

---

## [ ] PWD-028. Реализовать команду init

### Пример

```bash
pwd init --vault ./my.pwd
```

### Поведение

- спросить master password;
- спросить повтор master password;
- проверить совпадение;
- создать vault-файл;
- если файл уже существует — ошибка.

### Критерий готовности

Создается валидный зашифрованный vault-файл.

---

## [ ] PWD-029. Реализовать команду add

### Пример

```bash
pwd add --vault ./my.pwd
```

### Интерактивный ввод

```text
Title:
Username:
Password:
URL:
Notes:
Master password:
```

### Критерий готовности

Запись добавляется и сохраняется.

---

## [ ] PWD-030. Реализовать команду list

### Пример

```bash
pwd list --vault ./my.pwd
```

### Вывод

```text
ID        TITLE       USERNAME          URL
abc123    github      user@example.com  https://github.com
```

### Важно

Пароли не выводить.

### Критерий готовности

Список показывает записи без секретов.

---

## [ ] PWD-031. Реализовать команду show

### Пример

```bash
pwd show --vault ./my.pwd --id abc123
```

### Режимы

Без вывода пароля:

```bash
pwd show --vault ./my.pwd --id abc123
```

С явным выводом пароля:

```bash
pwd show --vault ./my.pwd --id abc123 --password
```

### Критерий готовности

Пароль раскрывается только при явном флаге.

---

## [ ] PWD-032. Реализовать команду edit

### Примеры

```bash
pwd edit --vault ./my.pwd --id abc123 --title github-main
pwd edit --vault ./my.pwd --id abc123 --username new@example.com
pwd edit --vault ./my.pwd --id abc123 --url https://example.com
```

### Отдельно для пароля

```bash
pwd edit --vault ./my.pwd --id abc123 --password
```

После этого CLI должен скрыто запросить новый пароль.

### Критерий готовности

Можно изменить отдельное поле без потери остальных данных.

---

## [ ] PWD-033. Реализовать команду remove

### Пример

```bash
pwd remove --vault ./my.pwd --id abc123
```

### Поведение

Перед удалением показать краткую информацию:

```text
Remove entry "github" [abc123]? yes/no:
```

### Критерий готовности

Запись удаляется только после подтверждения.

---

## [ ] PWD-034. Реализовать скрытый ввод master password

### Linux-реализация

Можно использовать `termios`.

### Пример API

```cpp
class PasswordPrompt {
public:
    std::string askHidden(std::string_view prompt);
};
```

### Критерий готовности

Пароль не отображается в терминале при вводе.

---

## [ ] PWD-035. Реализовать exit codes

### Пример

```text
0  success
1  validation error
2  wrong master password
3  vault not found
4  corrupted vault
5  internal error
```

### Критерий готовности

CLI можно использовать в shell-скриптах.

---

# Итерация 8. Тестирование

## [ ] PWD-036. Unit-тесты доменного ядра

### Покрыть

- add entry;
- list entries;
- get entry;
- update entry;
- remove entry;
- validation errors;
- not found errors.

### Критерий готовности

CRUD ядра покрыт unit-тестами.

---

## [ ] PWD-037. Unit-тесты сериализации

### Покрыть

- empty vault;
- vault с одной записью;
- vault с несколькими записями;
- unicode-строки;
- длинные notes;
- неизвестная версия формата.

### Критерий готовности

Сериализация имеет round-trip тесты.

---

## [ ] PWD-038. Unit-тесты crypto-слоя

### Покрыть

- encrypt/decrypt round-trip;
- wrong password;
- tampered ciphertext;
- разные salt/nonce;
- пустой payload;
- большой payload.

### Критерий готовности

Поврежденный или неправильно расшифрованный vault не принимается как валидный.

---

## [ ] PWD-039. Интеграционные тесты storage/application

### Сценарий

1. Создать vault.
2. Открыть vault.
3. Добавить запись.
4. Сохранить.
5. Открыть снова.
6. Проверить, что запись на месте.
7. Удалить запись.
8. Сохранить.
9. Открыть снова.
10. Проверить, что записи нет.

### Критерий готовности

Данные переживают перезапуск процесса.

---

## [ ] PWD-040. CLI-тесты

### Проверить

```bash
pwd init
pwd add
pwd list
pwd show
pwd edit
pwd remove
```

### Критерий готовности

Основной пользовательский сценарий проходит end-to-end на временном vault-файле.

---

# Итерация 9. Документация

## [ ] PWD-041. README для сборки

### Содержимое

```bash
cmake -S . -B build
cmake --build build
ctest --test-dir build
```

### Критерий готовности

Новый разработчик может собрать проект по README.

---

## [ ] PWD-042. README для CLI

### Документировать

```bash
pwd init
pwd add
pwd list
pwd show
pwd edit
pwd remove
```

### Критерий готовности

Пользователь может создать vault и выполнить CRUD без чтения исходников.

---

## [ ] PWD-043. Описать ограничения MVP

### Пример

```text
На первом этапе приложение не выполняет синхронизацию.
Vault хранится только локально.
Потеря master password означает невозможность восстановления данных.
GUI отсутствует.
Поддерживается только Linux CLI.
```

### Критерий готовности

Ограничения явно описаны в документации.

---

# Сводный порядок выполнения

## Блок 1. Проект

1. [ ] PWD-001 — scope.
2. [ ] PWD-002 — структура репозитория.
3. [ ] PWD-003 — CMake.
4. [ ] PWD-004 — тестовый фреймворк.

## Блок 2. Ядро

5. [ ] PWD-005 — `PasswordEntry`.
6. [ ] PWD-006 — `Vault`.
7. [ ] PWD-007 — value types.
8. [ ] PWD-008 — add.
9. [ ] PWD-009 — list.
10. [ ] PWD-010 — get.
11. [ ] PWD-011 — update.
12. [ ] PWD-012 — remove.
13. [ ] PWD-013 — доменные ошибки.

## Блок 3. Файл и сериализация

14. [ ] PWD-014 — формат vault-файла.
15. [ ] PWD-015 — сериализация.
16. [ ] PWD-016 — версионирование.

## Блок 4. Crypto

17. [ ] PWD-017 — выбор библиотеки.
18. [ ] PWD-018 — derivation ключа.
19. [ ] PWD-019 — encrypt/decrypt.
20. [ ] PWD-020 — гигиена секретов.

## Блок 5. Storage

21. [ ] PWD-021 — `IVaultStorage`.
22. [ ] PWD-022 — атомарная запись.
23. [ ] PWD-023 — создание vault.
24. [ ] PWD-024 — открытие vault.

## Блок 6. Application layer

25. [ ] PWD-025 — `VaultService`.
26. [ ] PWD-026 — `VaultSession`.

## Блок 7. CLI

27. [ ] PWD-027 — CLI parser.
28. [ ] PWD-028 — `init`.
29. [ ] PWD-029 — `add`.
30. [ ] PWD-030 — `list`.
31. [ ] PWD-031 — `show`.
32. [ ] PWD-032 — `edit`.
33. [ ] PWD-033 — `remove`.
34. [ ] PWD-034 — скрытый ввод пароля.
35. [ ] PWD-035 — exit codes.

## Блок 8. Тесты

36. [ ] PWD-036 — unit-тесты ядра.
37. [ ] PWD-037 — тесты сериализации.
38. [ ] PWD-038 — тесты crypto.
39. [ ] PWD-039 — integration-тесты storage/application.
40. [ ] PWD-040 — CLI-тесты.

## Блок 9. Документация

41. [ ] PWD-041 — README сборки.
42. [ ] PWD-042 — README CLI.
43. [ ] PWD-043 — ограничения MVP.

---

# Definition of Done для первого этапа

Первый этап считается завершенным, если:

- проект собирается под Linux;
- есть CLI-приложение `pwd`;
- `pwd --help` показывает список команд;
- можно создать локальный vault;
- vault-файл хранит данные в зашифрованном виде;
- правильный master password открывает vault;
- неправильный master password не открывает vault;
- можно добавить запись;
- можно посмотреть список записей без раскрытия паролей;
- можно посмотреть конкретную запись;
- пароль показывается только по явному флагу;
- можно отредактировать запись;
- можно удалить запись;
- данные сохраняются между запусками;
- поврежденный vault-файл не открывается молча;
- CRUD-логика покрыта unit-тестами;
- crypto-логика покрыта unit-тестами;
- storage/application покрыты интеграционными тестами;
- CLI покрыт хотя бы базовыми end-to-end тестами;
- есть документация по сборке и использованию.

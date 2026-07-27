# Keymaps

Шпаргалка по сочетаниям клавиш этого конфига. `<leader>` = `<Space>`. Авторитативный источник всегда `:WhichKey` (или подержать `<leader>`) и `<leader>sk` (fuzzy-поиск по всем активным маппингам через fzf-lua).

Файлы-источники:

- [`lua/config/keymaps.lua`](lua/config/keymaps.lua) — daily-driver биндинги
- [`lua/config/lsp.lua`](lua/config/lsp.lua) — LSP (через `LspAttach`)
- [`lua/plugins/<name>.lua`](lua/plugins/) — плагин-специфичные биндинги (obsidian, quarto, bufferline, conform, noice, img-clip)

---

## Самое нужное (топ-биндинги для повседневной работы)

| Сочетание | Действие |
|---|---|
| `<leader><space>` | Find files |
| `<leader>,` | Switch buffer |
| `<leader>/` | Live grep по проекту |
| `<leader>:` | История команд |
| `<leader>e` | Файловый explorer (mini.files, по директории буфера) |
| `<leader>E` | Файловый explorer (cwd) |
| `<leader>gg` | LazyGit |
| `<leader>?` | Биндинги текущего буфера (which-key) |
| `<leader>qq` | Quit all |
| `<C-s>` | Save |
| `<Esc>` | Снять подсветку поиска |
| `K` | LSP hover |
| `gd` | Go to definition |
| `gr` | References |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename |
| `<leader>cf` | Format |

---

## Навигация: буферы

`lua/config/keymaps.lua` + bufferline.

| Сочетание | Действие |
|---|---|
| `<Tab>` | Следующий буфер |
| `<S-Tab>` | Предыдущий буфер |
| `<S-l>` | Следующий буфер |
| `<S-h>` | Предыдущий буфер |
| `]b` / `[b` | Следующий / предыдущий буфер |
| `<leader>bd` | Закрыть буфер |
| `<leader>bD` | Закрыть буфер (force) |
| `<leader>bp` | Закрепить (pin) |
| `<leader>bP` | Закрыть все незакреплённые |
| `<leader>bo` | Закрыть все кроме текущего |
| `<leader>bl` | Закрыть всё справа |
| `<leader>bh` | Закрыть всё слева |

---

## Навигация: окна и сплиты

`lua/config/keymaps.lua` + smart-splits.

| Сочетание | Действие |
|---|---|
| `<C-h>` | Окно/панель слева (smart-splits, выходит в WezTerm/Tmux/Kitty) |
| `<C-j>` | Окно/панель снизу |
| `<C-k>` | Окно/панель сверху |
| `<C-l>` | Окно/панель справа |
| `<leader>-` | Сплит снизу |
| `<leader>\|` | Сплит справа |
| `<leader>wd` | Закрыть окно |
| `<C-w>s` / `<C-w>v` | Сплит горизонталь/вертикаль |
| `<C-w>c` / `<C-w>q` | Закрыть окно |
| `<C-w>=` | Уравнять размеры |
| `<C-w>o` | Оставить только это окно |
| `<C-w>+` / `<C-w>-` | Resize по высоте |
| `<C-w>>` / `<C-w><` | Resize по ширине |

---

## Терминал

`lua/config/keymaps.lua`. Нативный `:terminal` в плавающем окне (без плагина), переиспользует одну сессию.

| Сочетание | Режим | Действие |
|---|---|---|
| `<C-/>` | n / t | Toggle плавающего терминала (центр, ~80% экрана) |
| `<C-_>` | n / t | То же (легаси-байт для старых эмуляторов) |
| `<Esc><Esc>` | t | Выйти из terminal mode в normal |

---

## Файловый explorer (mini.files)

Открывается через `<leader>e` (по директории буфера) или `<leader>E` (cwd).

| Клавиша | Действие |
|---|---|
| `l` | Войти (открыть файл / войти в директорию) |
| `<CR>` / `L` | То же + закрыть explorer для файлов |
| `h` | Выйти на уровень выше |
| `H` | То же + ужать колонки слева |
| `q` или `<Esc>` | Закрыть explorer |
| `g?` | Показать **все** биндинги |
| `=` | Синхронизировать изменения с диском |
| `<` / `>` | Ужать / расширить дерево слева |
| `m` `<letter>` | Поставить mark на путь (потом `'<letter>` — jump) |

**CRUD через текст**: редактируй буфер как обычный, потом `=` или `:w`.

- Новая строка с именем → файл создастся
- Новая строка с `/` в конце → создастся директория
- Изменил имя → renamed
- Удалил строку → файл удалится (с подтверждением)

---

## Поиск (fzf-lua)

`lua/config/keymaps.lua`.

| Сочетание | Действие |
|---|---|
| `<leader><space>` | Find files |
| `<leader>ff` | Find files |
| `<leader>fg` | Find git files |
| `<leader>fr` | Recent files |
| `<leader>fb` / `<leader>,` | Buffers |
| `<leader>/` | Live grep |
| `<leader>sg` | Live grep |
| `<leader>sw` | Grep слова под курсором (в visual — по выделению) |
| `<leader>sh` | Help tags |
| `<leader>sk` | Все активные keymaps (fuzzy) |
| `<leader>sd` | Diagnostics в буфере |
| `<leader>sD` | Diagnostics в workspace |
| `<leader>sc` / `<leader>:` | Command history |
| `<leader>sR` | Resume последнего пикера |
| `<leader>sn` | История уведомлений (noice) |

---

## LSP

Активируются через `LspAttach` (`lua/config/lsp.lua`) — работают только когда LSP-сервер привязан к буферу.

| Сочетание | Действие |
|---|---|
| `K` | Hover (документация) |
| `gK` | Signature help |
| `gd` | Go to definition (в TS/JS — go to **source** definition, мимо `.d.ts`) |
| `gD` | Go to declaration |
| `gr` | References (через fzf-lua) |
| `gI` | Go to implementations |
| `gy` | Go to type definition |
| `<leader>ca` (n + v) | Code action |
| `<leader>cr` | Rename (с обновлением ссылок в файлах) |
| `<leader>cf` (n + v) | Format (через conform) |
| `<leader>cs` | LSP-символы в буфере |
| `<leader>cS` | LSP-символы по workspace |
| `<leader>ci` | Incoming calls (кто зовёт) |
| `<leader>co` | Outgoing calls (кого зовёт) |
| `<leader>cl` | LSP-диагностика (`:checkhealth vim.lsp`) |

Inlay hints автоматически включаются для серверов, которые их поддерживают. Toggle: `<leader>uh`.

Иерархию вызовов (`<leader>ci` / `<leader>co`) плоский список ссылок не заменяет: внутри пикера `<CR>` проваливается на уровень глубже. В TypeScript `gd` подменяется на source definition только там, где привязан vtsls; если пакет не публикует исходники, он молча откатывается на обычный definition и приводит в `.d.ts`.

---

## Diagnostics

| Сочетание | Действие |
|---|---|
| `]d` / `[d` | Следующая / предыдущая диагностика |
| `<leader>cd` | Show line diagnostics (float) |
| `<leader>sd` | Diagnostics в буфере (через fzf-lua) |
| `<leader>sD` | Diagnostics по workspace |
| `<leader>ud` | Toggle diagnostics |

---

## Git (gitsigns + lazygit)

`lua/config/keymaps.lua`.

| Сочетание | Действие |
|---|---|
| `<leader>gg` | LazyGit |
| `<leader>gj` | Следующий hunk |
| `<leader>gk` | Предыдущий hunk |
| `]h` / `[h` | Следующий / предыдущий hunk |
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |
| `<leader>ghp` | Preview hunk inline |
| `<leader>ghb` | Blame line |

---

## Completion (blink.cmp)

`lua/plugins/blink.lua`. Базовый пресет `default`.

| Сочетание | Режим | Действие |
|---|---|---|
| `<C-y>` | i | Принять текущий вариант комплита |
| `<C-n>` / `<C-p>` | i | Следующий / предыдущий вариант |
| `<Tab>` / `<S-Tab>` | i | Навигация по snippet jumps / комплиту |
| `<C-Space>` | i | Триггер показа меню |
| `<C-e>` | i | Закрыть меню |

---

## Tests (neotest, `<leader>t`)

`lua/plugins/neotest.lua`. Адаптеры: Go (gotestsum/go test), Python (pytest), Lua (plenary.busted). Rust перехватывается на ft=rust → `:RustLsp testables`.

| Сочетание | Действие |
|---|---|
| `<leader>tt` | Run nearest test |
| `<leader>tT` | Run file |
| `<leader>ta` | Run all (по cwd) |
| `<leader>tl` | Run last |
| `<leader>tS` | Stop |
| `<leader>td` | Debug nearest (через DAP) |
| `<leader>tD` | Debug file (через DAP) |
| `<leader>ts` | Toggle summary (боковая панель) |
| `<leader>to` | Открыть output текущего теста |
| `<leader>tO` | Toggle output panel |
| `<leader>tw` | Watch file (auto-rerun on save) |
| `]t` / `[t` | Следующий / предыдущий failed-тест |

Внутри summary-панели (`<leader>ts`): `<CR>`/`l` expand, `r` run, `u` stop, `d` debug, `i` jump, `o` output, `m` mark.

---

## Debug (nvim-dap, `<leader>d`)

`lua/plugins/dap.lua`. Адаптеры: Go (delve), Python (debugpy), Rust (codelldb через `:RustLsp debuggables`).

| Сочетание | Действие |
|---|---|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint (prompt) |
| `<leader>dL` | Log point (prompt) |
| `<leader>dc` | Continue / start session |
| `<leader>dC` | Run to cursor |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dj` / `<leader>dk` | Down / up по stack frames |
| `<leader>dl` | Run last |
| `<leader>dr` | Toggle REPL |
| `<leader>dq` | Terminate |
| `<leader>du` | Toggle UI (scopes / breakpoints / stacks / watches + repl) |
| `<leader>de` (n / v) | Eval expression под курсором |

В Rust-буферах `<leader>dc` → `:RustLsp debuggables` (выбор Cargo-таргета через codelldb).

---

## Cmdline / messages (noice)

`:` открывает popup в центре, `/` остаётся внизу.

| Сочетание | Действие |
|---|---|
| `<leader>sn` | История noice-сообщений |
| `<leader>un` | Закрыть все notifications |

---

## Obsidian / Templater (`<leader>o`)

`lua/plugins/obsidian.lua`. Активны в markdown/mdx-буферах внутри vault'а.

| Сочетание | Действие |
|---|---|
| `<leader>oo` / `<leader>oq` | Quick switch заметки |
| `<leader>on` | Новая заметка |
| `<leader>os` | Поиск (grep) по vault'у |
| `<leader>ot` | Список тегов |
| `<leader>ob` | Backlinks к текущей заметке |
| `<leader>ol` | Ссылки в заметке |
| `<leader>oL` | Перейти по ссылке под курсором |
| `<leader>op` | Вставить картинку из буфера (obsidian-aware) |
| `<leader>or` | Переименовать заметку (с обновлением ссылок) |
| `<leader>ow` | Переключить workspace |
| `<leader>oc` | Toggle checkbox `- [ ]` ↔ `- [x]` |
| `<leader>od` | Daily (через Templater, с `<% tp.* %>`) |
| `<leader>oy` | Yesterday (Templater) |
| `<leader>oT` | Tomorrow (Templater) |
| `<leader>oD` | Daily (native obsidian.nvim, без tp-синтаксиса) |
| `<leader>oi` | Вставить шаблон (Templater, с рендером) |
| `<leader>oI` | Вставить шаблон (native obsidian.nvim) |

Строчные `od`/`oi` — основной путь (Templater); заглавные `oD`/`oI` — резерв на нативном движке.

---

## Quarto (`<leader>q`)

`lua/plugins/quarto.lua`. Только filetype `quarto`/`markdown`.

| Сочетание | Действие |
|---|---|
| `<leader>qp` | Quarto Preview |
| `<leader>qc` | Close Preview |
| `<leader>qa` | Activate (otter LSP для code chunks) |

---

## Image paste

| Сочетание | Действие |
|---|---|
| `<leader>P` | Вставить картинку из буфера обмена (`:PasteImage`) |

В markdown-буфере вставится как `![cursor](path)`. См. также `<leader>op` для vault'-aware варианта через obsidian.nvim.

---

## Перемещение строк и indent

| Сочетание | Режим | Действие |
|---|---|---|
| `<A-j>` / `<A-k>` | n / v | Сдвинуть строку / выделение вниз / вверх |
| `<` / `>` | v | Indent (остаётся в visual) |

---

## Комментирование (mini.comment + Neovim builtin)

| Сочетание | Действие |
|---|---|
| `gcc` | Toggle комментарий строки |
| `gc{motion}` | Toggle комментарий по motion (например `gcap` — параграф) |
| `gc` (visual) | Toggle комментарий выделения |

---

## Surround (mini.surround)

Префикс `s` в нормальном режиме (не path-search, в этом конфиге `/` используется для grep).

| Сочетание | Действие |
|---|---|
| `sa{motion}{char}` | Add surround (например `saiw"` — обернуть слово в кавычки) |
| `sd{char}` | Delete surround |
| `sr{from}{to}` | Replace surround (например `sr"'` — заменить " на ') |
| `sf` / `sF` | Find right / left surrounding |
| `sh` | Highlight surrounding |
| `sn` | Surround next |
| `sl` | Surround last |

---

## Text objects (mini.ai)

Расширенные `a` / `i` для motion'ов (через mini.ai). Работают как `iw`, `ip` и т.п., но умнее.

Базовые targets: `f` (function), `o` (block), `t` (tag), `q` (any quote), `b` (any bracket), `?` (user-input).

Примеры: `vif` — выделить тело функции, `di"` — удалить содержимое строки в кавычках, `ya)` — yank вызов функции вместе со скобками.

---

## UI-тоглы (`<leader>u`)

| Сочетание | Действие |
|---|---|
| `<leader>uf` | Toggle autoformat (global) |
| `<leader>uF` | Toggle autoformat (buffer) |
| `<leader>us` | Toggle spell |
| `<leader>uw` | Toggle wrap |
| `<leader>uW` | Toggle whitespace (показ space/tab/eol) |
| `<leader>ul` | Toggle line numbers |
| `<leader>uL` | Toggle relativenumber |
| `<leader>ud` | Toggle diagnostics |
| `<leader>uh` | Toggle inlay hints |
| `<leader>un` | Закрыть notifications |

---

## Прочие

| Сочетание | Действие |
|---|---|
| `<C-s>` (n / i / v) | Save |
| `<leader>w` | Save (alias) |
| `<leader>qq` | Quit all |
| `<Esc>` (n / i / v) | Снять подсветку поиска |
| `j` / `k` (без count) | gj / gk — по визуальным строкам (важно для wrap'нутого markdown) |
| `n` / `N` | Следующий / предыдущий поиск (центрирует viewport через nzzzv) |
| `<leader>?` | Биндинги текущего буфера (which-key) |

---

## Security: inline-линтинг (nvim-lint)

`lua/plugins/lint.lua`. Сканеры запускаются **в фоне без терминала** и показываются как обычная диагностика (подчёркивания в коде). Работают на открытии файла и на сохранении (`BufReadPost` / `BufWritePost`); бинарники берутся из mason.

| ft | Линтер | Что ловит |
|---|---|---|
| `python` | bandit | Python SAST |
| `dockerfile` | hadolint + trivy | best-practice + misconfig |
| `terraform` / `hcl` | trivy | misconfig в IaC |
| `yaml` | trivy | misconfig (k8s-манифесты) |
| `go` | golangci-lint | + gosec, если включён в `.golangci.yml` |

| Сочетание | Действие |
|---|---|
| `<leader>cx` | Прогнать security-линтеры сейчас (без сохранения) |
| `]d` / `[d` | Следующая / предыдущая находка (общая диагностика) |
| `<leader>sd` | Список находок в буфере (fzf-lua) |

Находки идут в общий поток диагностики, поэтому `<leader>ud` (toggle diagnostics) их тоже прячет/показывает. `semgrep`, `gitleaks`, `kube-linter` пофайлово не вешаются (репо-широкие) — их гоняй из терминала, см. ниже.

---

## Security-сканеры (mason CLI)

Репо-широкие проверки, которых нет в inline-режиме выше. Это CLI-инструменты из mason (`lua/plugins/mason.lua`), **без keymap'ов** — запускаются из терминала. Проще всего из плавающего терминала nvim (`<C-/>`): там `~/.local/share/nvim/mason/bin` уже в `PATH`. Для запуска из внешнего shell добавь этот путь в `PATH` сам.

`trivy` — швейцарский нож на весь стек (deps + misconfig + secrets + SBOM), включая Rust, где остального почти нет. Начинать проще всего с него.

| Цель / язык | Команда | Инструмент |
|---|---|---|
| **Весь репозиторий за раз** | `trivy fs .` | trivy (deps + secrets + misconfig) |
| **IaC-мисконфиги** (Terraform, k8s YAML, Dockerfile) | `trivy config .` | trivy |
| **Секреты** (все языки) | `gitleaks detect --source . -v` | gitleaks |
| **SAST-паттерны** (Go, Python, JS/TS…) | `semgrep --config auto .` | semgrep |
| **Python** | `bandit -r . -ll` | bandit |
| **Go** | `golangci-lint run` (включает `gosec`) | golangci-lint |
| **Terraform / HCL** | `tfsec .` | tfsec |
| **YAML / k8s / Helm** | `kube-linter lint .` | kube-linter |
| **Dockerfile** | `hadolint Dockerfile` | hadolint |
| **Rust** | `trivy fs .` (Cargo.lock) + `cargo clippy` | trivy / clippy* |

\* `cargo clippy` идёт через `cargo`/rustaceanvim, не через mason. Для Lua security-сканеров нет — `selene`/`luacheck` проверяют стиль, не безопасность.

Полезные флаги: `trivy fs --scanners vuln,secret,misconfig .` (выбор проверок), `trivy fs --severity HIGH,CRITICAL .` (только серьёзное), `semgrep --config auto --json -o out.json .` (машинный вывод для CI). Что установлено — видно в `:Mason` (вкладка Linter).

---

## Подсказки

- `:WhichKey` или подержи `<leader>` — popup со всеми сочетаниями текущего контекста.
- `:WhichKey <leader>o` — конкретная группа (например, Obsidian).
- `<leader>sk` — fuzzy-поиск по всем активным маппингам (fzf-lua).
- `<leader>?` — биндинги, доступные в текущем буфере.
- `:verbose nmap <key>` — узнать, кто и где назначил конкретный биндинг.
- `:lua vim.pack.update()` — интерактивный UI обновления плагинов.

---

## Что есть, но не настроено отдельно

Эти возможности есть, но без специальных биндингов поверх vim-defaults:

- **Tabs (vim-табы, не bufferline)** — `<C-w>T` сделать таб из окна, `gt` / `gT` переключение, `:tabclose`. bufferline не делает табы, он отображает буферы.
- **Quickfix / loclist** — `:copen` / `:lopen`, `]q` / `[q` ходят по qfix (built-in vim).
- **Folding** — `za` toggle, `zR` open all, `zM` close all. Folds через treesitter foldexpr (см. `options.lua`).
- **Sessions** — не настроены. Добавь `folke/persistence.nvim` если нужно.
- **DAP / debugger** — не настроен. Добавь `mfussenegger/nvim-dap` + ui если нужно.
- **Flash / EasyMotion** — не настроен. По умолчанию `s` занят mini.surround. Добавь `folke/flash.nvim` с переназначением если нужно.

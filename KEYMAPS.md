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
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | References (через fzf-lua) |
| `gI` | Go to implementations |
| `gy` | Go to type definition |
| `<leader>ca` (n + v) | Code action |
| `<leader>cr` | Rename (с обновлением ссылок в файлах) |
| `<leader>cf` (n + v) | Format (через conform) |
| `<leader>cs` | LSP-символы в буфере |
| `<leader>cS` | LSP-символы по workspace |
| `<leader>cl` | LSP-диагностика (`:checkhealth vim.lsp`) |

Inlay hints автоматически включаются для серверов, которые их поддерживают. Toggle: `<leader>uh`.

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

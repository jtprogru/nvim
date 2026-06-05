# nvim-new — конфиг для Neovim 0.12.x без LazyVim

Запуск параллельно со старым: `NVIM_APPNAME=nvim-new nvim` (есть alias `vn` в `~/.aliases`).

## Стек

| Слой | Чем заменено | Что отказались |
|---|---|---|
| Plugin manager | `vim.pack` (нативный, 0.12) | lazy.nvim |
| LSP | `vim.lsp.config` + `vim.lsp.enable` (0.11+) | nvim-lspconfig |
| Completion | blink.cmp | nvim-cmp / luasnip |
| Picker | fzf-lua | snacks.picker / telescope |
| Explorer | mini.files | neo-tree |
| Statusline | mini.statusline | lualine |
| Misc | mini.surround / ai / pairs / comment / bufremove / icons | nvim-surround, ts-autotag, Comment.nvim |
| Git | gitsigns + lazygit.nvim | (то же) |
| Treesitter | nvim-treesitter | (то же) |
| Formatting | conform.nvim | LazyVim-овский конформ |
| Rust | rustaceanvim | (то же) |
| Markdown | render-markdown + mdx.nvim + img-clip | (то же) |
| Obsidian | obsidian.nvim + custom templater | (то же) |
| Quarto | quarto-nvim + otter.nvim | (то же) |
| Tools | mason.nvim (опционально, без auto-install) | mason-lspconfig |

## Что сохранено из старого конфига

- **Кастомные кеймапы** (`KEYMAPS.md` → "🔧"):
  - `<Tab>` / `<S-Tab>` — переключение буферов
  - `<C-h/j/k/l>` — smart-splits (Tmux/WezTerm-aware)
  - `<leader>gj` — следующий git-hunk (+ `<leader>gk` prev)
  - `<leader>o*` — Obsidian + Templater (все 18 биндингов)
  - `<leader>q[pca]` — Quarto preview / close / activate
  - `<leader>P` — paste image
  - `<C-y>` — blink.cmp accept
- **Опции**: `colorcolumn=120`, `scrolloff=5`, spell `ru_ru` + `en_us`, helm filetype, gotmpl, python3 host из старого venv.
- **Autocmds**: macOS dark/light sync.
- **Gitsigns**: твои custom signs, blame на eol с форматом `<author> (<date>) - <summary>`.
- **LSP-настройки**: gopls (hints + analyses + codelenses), basedpyright (standard, inlay), ruff (без hover), ltex-plus (ru-RU), marksman (markdown.mdx + mdx), lua_ls.
- **Тема**: gruvbox.
- **Templater**: `lua/util/templater.lua` скопирован как есть.

## Что отвалилось от LazyVim (вернуть по вкусу)

- **Dashboard / start screen** (snacks dashboard).
- **Buffer-line / tabline** — поставь `akinsho/bufferline.nvim`, если нужны "вкладки" сверху.
- **Trouble.nvim** — `<leader>xx` и т.п. Заменено диагностиками + fzf-lua. Если хочешь панель — `folke/trouble.nvim` в `plugins.lua`.
- **Flash.nvim** (`s`/`S`) — добавь `folke/flash.nvim` при желании.
- **Noice.nvim** — нет.
- **Sessions** (`<leader>qs`, `<leader>ql`) — `folke/persistence.nvim` или `rmagatti/auto-session`.
- **DAP** (`<leader>d*`) — `mfussenegger/nvim-dap` + ui по желанию.
- **none-ls** (внешние линтеры) — текущие LSP закрывают почти всё; для остального `mfussenegger/nvim-lint`.
- **Lazy-loading плагинов**: vim.pack грузит всё eager. Для ft-плагинов (obsidian, quarto, mdx, render-md) ft-фильтры внутри плагина срабатывают; стартап-задержка минимальная — измерь `nvim --startuptime /tmp/nv.log` перед оптимизацией.
- **`<leader>?`** (recent keymaps) — у snacks.picker, в fzf-lua нет аналога.

## Первый запуск

```bash
vn  # alias из ~/.aliases
```

vim.pack клонирует все плагины при первом старте (один блокирующий вызов). Это нормально.

Дальше, по необходимости:

```vim
:checkhealth                                  " общая проверка
:checkhealth vim.lsp                          " какие LSP подцепились
:checkhealth vim.pack
:Mason                                        " открыть UI mason
:TSUpdate                                     " обновить TS-парсеры
```

Чтобы поставить пачку инструментов одной командой:

```vim
:MasonInstall ansible-language-server ansible-lint ast-grep bash-language-server codelldb delve gh gitleaks gofumpt goimports golangci-lint gomodifytags gopls gotests gotestsum impl ltex-ls-plus lua-language-server markdown-toc markdownlint-cli2 marksman ruff basedpyright debugpy iferr semgrep shellcheck shfmt stylua taplo tfsec tree-sitter-cli uv yaml-language-server
```

## Структура

```
nvim-new/
├── init.lua
├── lua/
│   ├── config/
│   │   ├── options.lua     # vim.opt, filetype, diagnostic
│   │   ├── keymaps.lua     # все горячие клавиши (вне LSP)
│   │   ├── autocmds.lua    # macOS bg sync, yank highlight, etc.
│   │   ├── plugins.lua     # vim.pack.add + setup всех плагинов
│   │   └── lsp.lua         # vim.lsp.config + LspAttach-keymaps
│   └── util/
│       └── templater.lua   # Obsidian Templater engine (скопирован)
└── README.md
```

## Сравнение с прошлой версией (LazyVim)

| | LazyVim | nvim-new |
|---|---|---|
| Файлов своих | 24 lua | 6 lua |
| Строк своих | ~1100 | ~700 |
| Плагинов в lock | 64 | ~18 (+ зависимости через plenary, web-devicons) |
| Стартап (примерно) | 150-300 мс | < 100 мс ожидается |
| Обновления | LazyVim релизы могут ломать конфиг | только то, что сам обновил |

## Шпаргалки

### LSP-навигация по коду (`gd` / `gr` / `K` и т.д.)

Привязки активируются автоматически когда LSP-сервер подключается к буферу (через `LspAttach` autocmd в `lua/config/lsp.lua`). Если они не работают — LSP-сервер просто не запущен. Открой `:Mason`, проверь что нужный сервер установлен (✓), потом перезапусти nvim.

| Сочетание | Действие |
|---|---|
| `K` | Hover (документация под курсором) |
| `gK` | Signature help |
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | References (через fzf-lua) |
| `gI` | Go to implementations |
| `gy` | Go to type definition |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename |
| `<leader>cs` | Symbols в буфере |
| `<leader>cS` | Symbols по workspace |
| `<leader>cf` | Format |
| `]d` / `[d` | Следующая / предыдущая диагностика |
| `<leader>cd` | Показать диагностику текущей строки |

### mini.files (файловый explorer, `<leader>e`)

| Клавиша | Действие |
|---|---|
| `l` | Войти (открыть файл / войти в директорию) |
| `<CR>` | То же + закрыть explorer для файлов (`go_in_plus`) |
| `L` | То же что `<CR>` |
| `h` | Выйти на уровень выше |
| `H` | То же + ужать колонки слева |
| `q` или `<Esc>` | Закрыть explorer |
| `g?` | Показать **все** дефолтные биндинги |
| `=` | Синхронизировать изменения с диском |
| `<` / `>` | Ужать / расширить дерево слева |
| `m` `<letter>` | Поставить mark на путь (потом `'<letter>` — jump) |

**Создание / удаление / переименование** — редактируешь буфер как обычный текст, потом `=` или `:w` синхронизирует:
- Добавил строку с именем → файл создастся
- Добавил строку с `/` в конце → создастся директория
- Изменил имя в строке → файл/директория переименуется
- Удалил строку → файл удалится (с подтверждением)

### Bufferline (табы сверху)

- `<S-h>` / `<S-l>` или `<Tab>` / `<S-Tab>` — переключение между табами
- `<leader>bd` — закрыть текущий
- `<leader>bp` — закрепить (pin)
- `<leader>bo` — закрыть все кроме текущего
- `<leader>bh` / `<leader>bl` — закрыть всё слева / справа

### Noice (cmdline в центре)

- `:` теперь открывает popup в центре экрана
- `/` остаётся внизу (для классики)
- Сообщения уезжают в notify-окошки в правом верхнем углу
- `<leader>sn` — история сообщений
- `<leader>un` — закрыть все notifications

### which-key

- `<leader>?` — показать все доступные биндинги текущего буфера
- Просто нажми `<leader>` и подожди ~300мс — всплывёт меню с группами
- `:WhichKey <leader>o` — конкретная группа (например, Obsidian)

## Treesitter parsers

Конфиг полагается **только на парсеры из коробки** (`$VIMRUNTIME/parser/`): `c`, `lua`, `markdown`, `markdown_inline`, `query`, `vim`, `vimdoc`, `diff`. Они автоматически активируются ftplugins'ами Neovim — никаких настроек не требуется.

`nvim-treesitter` (плагин) намеренно не подключён: его ветка `main` под 0.12 требует синхронной сборки парсеров через `tree-sitter` CLI на первом старте, ветка `master` мёртвая (использует выпиленный API). Это слишком хрупко для стартового конфига.

Если очень хочется TS-подсветку для конкретного языка (Go, Python, Rust и т.п.), парсер ставится вручную:

```bash
brew install tree-sitter        # CLI компилятор
cd /tmp && git clone --depth 1 https://github.com/tree-sitter/tree-sitter-go
cd tree-sitter-go && tree-sitter build -o ~/.local/share/nvim-new/site/parser/go.so
```

После рестарта nvim 0.12 сам подхватит `go.so` из `site/parser/` и применит свои встроенные queries. Для большинства Go/Python/Rust-кода regex-подсветка `:syntax` тоже работает — она просто менее точная.

Альтернатива на будущее, когда nvim-treesitter `main` устаканится: вернуть его в `plugins.lua` и синхронно вызвать `ts.install(...):wait(120000)` на первом старте.

## TODO / места для шлифовки

- [ ] Проверить совместимость blink.cmp `v1` диапазона с твоим Neovim (`vim.version.range("v1")` в `plugins.lua`).
- [ ] Решить, нужен ли DAP / sessions / trouble — добавить точечно.
- [ ] Если стартап заметно медленный, перевести obsidian/quarto/render-md в ft-autocmd lazy-load.
- [ ] Подровнять mini.statusline под вкус (по умолчанию даёт скромный single-line).
- [ ] Опционально: codeium / copilot, если использовалось (в `blink.lua` была ссылка на codeium).

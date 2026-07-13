# nvim-new — конфиг для Neovim 0.12.x без LazyVim

![Lua LoC](https://img.shields.io/badge/lua-2039%20LoC-blueviolet?logo=lua)

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
├── init.lua                # entry: loads in fixed order
├── lua/
│   ├── config/
│   │   ├── options.lua     # vim.opt, filetype, diagnostic
│   │   ├── pack.lua        # vim.pack.add — what to install (URLs only)
│   │   ├── keymaps.lua     # daily-driver keymaps (LSP/picker/git/UI)
│   │   ├── autocmds.lua    # macOS bg sync, yank hl, spell-on-md
│   │   └── lsp.lua         # vim.lsp.config + LspAttach keymaps
│   ├── plugins/            # per-plugin setup (one file per plugin)
│   │   ├── init.lua        # explicit load order
│   │   ├── mason.lua       # mason + mason-tool-installer (ensure_installed)
│   │   ├── mini.lua        # mini.* family setup (icons/files/statusline/…)
│   │   ├── gruvbox.lua
│   │   ├── which-key.lua
│   │   ├── bufferline.lua
│   │   ├── noice.lua
│   │   ├── fzf-lua.lua
│   │   ├── smart-splits.lua
│   │   ├── gitsigns.lua
│   │   ├── blink.lua
│   │   ├── conform.lua
│   │   ├── render-md.lua
│   │   ├── img-clip.lua
│   │   ├── obsidian.lua    # obsidian + Templater commands + <leader>o*
│   │   ├── quarto.lua      # quarto + filetype-local <leader>q*
│   │   └── rustaceanvim.lua
│   └── util/
│       └── templater.lua   # Obsidian Templater (<% tp.* %>) engine
├── KEYMAPS.md
├── README.md
└── nvim-pack-lock.json     # vim.pack lockfile (commit it)
```

**Принципы**:
- `config/pack.lua` — **что** установлено, единственное место с URL'ами плагинов.
- `plugins/<name>.lua` — **как** настроен конкретный плагин (опции, команды, плагин-специфичные кеймапы).
- `config/keymaps.lua` — daily-driver кеймапы, не привязанные к одному плагину (буферы, окна, LSP-навигация, UI-тоглы).
- Чтобы добавить плагин: 1) дописать URL в `pack.lua`, 2) создать `plugins/<name>.lua`, 3) добавить имя в `order` в `plugins/init.lua`.
- Чтобы удалить плагин: обратное — удалить из `pack.lua`, удалить файл, убрать из `order`. Один файл = одна зона риска.

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

Конфиг использует `nvim-treesitter` (ветка `main`) с **синхронной установкой** парсеров на первом старте. Файл [`lua/plugins/treesitter.lua`](lua/plugins/treesitter.lua) проверяет список нужных парсеров в `~/.local/share/nvim-new/site/parser/`, и если каких-то нет — компилирует их через `tree-sitter` CLI блокирующе. Один раз ~1 минута, дальше моментально.

**Требование**: `tree-sitter` CLI на PATH. Ставится автоматически:
- через Mason: `tree-sitter-cli` в `ensure_installed` ([`lua/plugins/mason.lua`](lua/plugins/mason.lua))
- либо вручную: `cargo install tree-sitter-cli` или `npm install -g tree-sitter-cli`

Текущий набор парсеров (см. список в `treesitter.lua`): bash, c, cpp, css, diff, dockerfile, go (+ gomod/gosum/gotmpl/gowork), helm, hcl, html, ini, json/jsonc, lua (+ luadoc/luap), make, markdown (+ markdown_inline), python, query, regex, rust, sql, terraform, toml, tsx, typescript, vim, vimdoc, yaml.

Чтобы добавить парсер: дописать в `parsers = {...}` в `treesitter.lua`, перезапустить nvim — он сам докомпилит недостающее.

**Почему нельзя только bundled-парсеры**: Neovim 0.12.2 несёт парсеры для c/lua/markdown/query/vim/vimdoc/diff, но queries от nvim-treesitter `main` используют поля (`operator:`, `field:`) которых нет в старых bundled-парсерах — открытие lua-файла падает с `Invalid field name`. Поэтому подменяем bundled-парсеры свежими.

## TODO / места для шлифовки

- [ ] Проверить совместимость blink.cmp `v1` диапазона с твоим Neovim (`vim.version.range("v1")` в `plugins.lua`).
- [ ] Решить, нужен ли DAP / sessions / trouble — добавить точечно.
- [ ] Если стартап заметно медленный, перевести obsidian/quarto/render-md в ft-autocmd lazy-load.
- [ ] Подровнять mini.statusline под вкус (по умолчанию даёт скромный single-line).
- [ ] Опционально: codeium / copilot, если использовалось (в `blink.lua` была ссылка на codeium).

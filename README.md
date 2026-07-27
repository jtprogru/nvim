# nvim — конфиг для Neovim 0.12.x без LazyVim и без lazy.nvim

![Lua LoC](https://img.shields.io/badge/lua-2078%20LoC-blueviolet?logo=lua)

Плагины ставит нативный `vim.pack`, LSP поднимается через `vim.lsp.config`/`vim.lsp.enable`. Никакого фреймворка сверху: всё, что делает конфиг, лежит в этом репозитории и читается за один вечер.

Полная шпаргалка по клавишам — [`KEYMAPS.md`](KEYMAPS.md). Внутри nvim авторитативный источник это `:WhichKey` (или подержать `<leader>`) и `<leader>sk` — fuzzy-поиск по всем активным маппингам.

## Установка

### Требования

Обязательно:

| Что | Зачем | macOS |
|---|---|---|
| Neovim >= 0.12 | `vim.pack`, `vim.lsp.config`, нативный лок-файл | `brew install neovim` |
| git, curl, unzip | клон плагинов, установка пакетов mason | идут из коробки / `brew install curl unzip` |
| C-компилятор | сборка treesitter-парсеров | Xcode CLT: `xcode-select --install` |
| Nerd Font в терминале | иконки mini.icons / bufferline / statusline | `brew install --cask font-jetbrains-mono-nerd-font` |

Сильно желательно (иначе часть биндингов будет мимо):

| Что | Зачем | macOS |
|---|---|---|
| ripgrep, fd | поиск в fzf-lua (`<leader>/`, `<leader><space>`) | `brew install ripgrep fd` |
| lazygit | `<leader>gg` | `brew install lazygit` |
| go, node, python3, cargo | mason ставит часть пакетов их тулчейнами | `brew install go node python cargo` |

Опционально, под конкретные сценарии:

| Что | Зачем |
|---|---|
| `pngpaste` | вставка картинок из буфера обмена, `<leader>P` (img-clip) |
| `quarto` CLI | `<leader>q*` — preview/render Quarto-документов |
| tmux или WezTerm | сквозная навигация `<C-h/j/k/l>` между панелями и сплитами (smart-splits) |
| Obsidian vault | `<leader>o*`; путь к vault прописан в [`lua/plugins/obsidian.lua`](lua/plugins/obsidian.lua) и его надо поправить под себя |

### Быстрый старт

```bash
# 1. Бэкап того, что уже лежит (пропусти, если ставишь с нуля)
mv ~/.config/nvim{,.bak}
mv ~/.local/share/nvim{,.bak}
mv ~/.local/state/nvim{,.bak}
mv ~/.cache/nvim{,.bak}

# 2. Клон
git clone git@github.com:jtprogru/nvim.git ~/.config/nvim
# или по https: git clone https://github.com/jtprogru/nvim.git ~/.config/nvim

# 3. Python-провайдер (нужен для python-плагинов; можно пропустить)
python3 -m venv ~/.config/nvim/venv
~/.config/nvim/venv/bin/pip install pynvim

# 4. Первый старт
nvim
```

`venv/` в `.gitignore`, так что он не улетит в репозиторий. Если venv нет, `lua/config/options.lua` просто не выставит `python3_host_prog` и Neovim возьмёт python3 с PATH.

### Примерка рядом с существующим конфигом

Проще всего не трогать текущий `~/.config/nvim`, а поставить рядом через `NVIM_APPNAME` — под ним разъезжаются и конфиг, и данные, и state, и кэш, и лок-файл:

```bash
git clone git@github.com:jtprogru/nvim.git ~/.config/nvim-jt
NVIM_APPNAME=nvim-jt nvim
```

Удобно завести алиас: `alias vn='NVIM_APPNAME=nvim-jt nvim'`. Конфиг нигде не хардкодит `~/.config/nvim` — все пути идут от `stdpath()`, так что под любым `NVIM_APPNAME` он работает одинаково.

### Что происходит на первом старте

1. **`vim.pack` клонирует 37 плагинов** — одним блокирующим шагом, на минуту-полторы. Ревизии берутся из `nvim-pack-lock.json`, так что ты получаешь ровно тот срез, который закоммичен.
2. **mason через 3 секунды в фоне начинает ставить внешние инструменты** — LSP-серверы, линтеры, форматтеры, дебаг-адаптеры (список в [`lua/plugins/mason.lua`](lua/plugins/mason.lua)). Прогресс виден в `:Mason`.
3. **nvim-treesitter пытается собрать парсеры** — и на совсем чистой машине спотыкается: `tree-sitter` CLI ещё ставится мейсоном. Конфиг честно скажет это в notify.

Отсюда правило чистой установки: **дождись, пока mason доставит всё (`:Mason`, все ✓), и перезапусти nvim**. На втором старте treesitter соберёт парсеры (одноразово, ~1 минута), и дальше запуски мгновенные.

Если ждать не хочется — `brew install tree-sitter` до первого старта, тогда парсеры соберутся сразу.

### Проверка, что всё встало

```vim
:checkhealth              " общая диагностика
:checkhealth vim.pack     " плагины
:checkhealth vim.lsp      " какие серверы подцепились к буферу
:Mason                    " статус внешних инструментов
:PackStatus               " плагины + доступные обновления (pack-ui)
```

Хороший смоук-тест руками: открой `.go`/`.py`/`.lua` файл и проверь `K`, `gd`, `<leader>ca`. Если не работает — почти всегда дело не в кеймапах, а в том, что LSP-сервер не установлен или не запустился; смотри `:Mason` и `:checkhealth vim.lsp`.

Из терминала, без запуска UI:

```bash
make smoke   # загрузить весь конфиг headless и упасть на первой ошибке
```

### Обновление

Плагины (`pack-ui.nvim` поверх `vim.pack`):

```vim
:PackStatus       " <leader>ps — что обновилось, с чейнджлогом
:PackUpdateAll    " <leader>pU — обновить всё
:PackUpdate <name>
```

После обновления `nvim-pack-lock.json` меняется — закоммить его, это часть конфига. Откатиться: `git checkout HEAD -- nvim-pack-lock.json`, затем `:lua vim.pack.update(nil, { target = 'lockfile' })`.

Внешние инструменты — `:Mason` (`U` — обновить всё). Автообновление намеренно выключено, чтобы старт не зависел от сети.

Treesitter-парсеры — `:lua require("nvim-treesitter").update()`.

### Удаление

```bash
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
```

Под `NVIM_APPNAME=foo` те же четыре пути, только с `foo` вместо `nvim`.

## Стек

| Слой | Чем закрыто | Вместо чего |
|---|---|---|
| Plugin manager | `vim.pack` (нативный, 0.12) + `pack-ui.nvim` | lazy.nvim |
| LSP | `vim.lsp.config` + `vim.lsp.enable` (0.11+), конфиги из nvim-lspconfig | ручной lspconfig-сетап |
| Completion | blink.cmp | nvim-cmp / luasnip |
| Picker | fzf-lua | snacks.picker / telescope |
| Explorer | mini.files | neo-tree |
| Statusline | mini.statusline | lualine |
| Tabline | bufferline.nvim | — |
| Cmdline / messages | noice.nvim | — |
| Misc | mini.surround / ai / pairs / comment / bufremove / icons | nvim-surround, ts-autotag, Comment.nvim |
| Git | gitsigns + lazygit.nvim | — |
| Treesitter | nvim-treesitter (ветка `main`) | — |
| Formatting | conform.nvim | none-ls |
| Linting | nvim-lint (security-сканеры как диагностика) | none-ls |
| Tests | neotest (+ golang / python / plenary адаптеры) | — |
| Debug | nvim-dap + dap-ui + virtual-text (+ go / python / codelldb) | — |
| Rust | rustaceanvim (rust-analyzer поднимает он, не `vim.lsp.enable`) | — |
| Markdown | render-markdown + mdx.nvim + img-clip | — |
| Obsidian | obsidian.nvim + свой Templater | — |
| Quarto | quarto-nvim + otter.nvim | — |
| Tools | mason.nvim + mason-tool-installer | mason-lspconfig |
| Тема | «Мишка на сервере» — бренд-слой поверх catppuccin | — |

## Структура

```
~/.config/nvim/
├── init.lua                    # entry: фиксированный порядок загрузки
├── lua/
│   ├── config/
│   │   ├── options.lua         # vim.opt, filetype, diagnostic, python-провайдер
│   │   ├── pack.lua            # vim.pack.add — ЧТО ставим (единственное место с URL'ами)
│   │   ├── keymaps.lua         # daily-driver биндинги (буферы/окна/терминал/git/UI)
│   │   ├── autocmds.lua        # macOS dark/light sync, yank hl, spell для md, trailing ws
│   │   ├── lsp.lua             # vim.lsp.config + enable + LspAttach-кеймапы
│   │   └── statusline.lua      # mini.statusline
│   ├── plugins/                # КАК настроен каждый плагин, один файл на плагин
│   │   ├── init.lua            # явный порядок загрузки
│   │   ├── mason.lua           # mason + ensure_installed
│   │   ├── treesitter.lua      # список парсеров + синхронная доустановка
│   │   ├── mini.lua            # mini.* (icons/files/surround/ai/pairs/comment/bufremove)
│   │   ├── mishka.lua          # бренд-тема поверх catppuccin
│   │   ├── blink.lua           # completion
│   │   ├── conform.lua         # форматтеры + :Format, :FormatToggle
│   │   ├── lint.lua            # nvim-lint: security-сканеры как диагностика
│   │   ├── dap.lua             # nvim-dap + ui + virtual-text + go/python/codelldb
│   │   ├── neotest.lua         # neotest + адаптеры
│   │   ├── obsidian.lua        # obsidian + Templater-команды + <leader>o*
│   │   ├── quarto.lua          # quarto + буферные <leader>q*
│   │   ├── pack-ui.lua         # :PackStatus / :PackUpdate / :PackUpdateAll
│   │   ├── which-key.lua, bufferline.lua, noice.lua, fzf-lua.lua
│   │   ├── smart-splits.lua, gitsigns.lua, render-md.lua
│   │   └── img-clip.lua, rustaceanvim.lua
│   └── util/
│       ├── templater.lua       # движок Obsidian Templater (<% tp.* %>)
│       └── python.lua          # резолв интерпретатора: $VIRTUAL_ENV → .venv → brew
├── tests/                      # plenary busted + smoke
├── .githooks/pre-commit        # обновляет LoC-бейдж в README (нужен tokei)
├── .github/workflows/ci.yml    # stylua --check, selene, unit-тесты
├── Makefile                    # smoke / test / lint / fmt
├── KEYMAPS.md
└── nvim-pack-lock.json         # лок-файл vim.pack — под гитом, коммить его
```

Принципы:

- `config/pack.lua` — **что** установлено. Единственное место с URL'ами.
- `plugins/<name>.lua` — **как** настроен конкретный плагин: опции, команды, его собственные кеймапы.
- `config/keymaps.lua` — то, что не привязано к одному плагину.
- Добавить плагин: URL в `pack.lua` → создать `plugins/<name>.lua` → дописать имя в `order` в `plugins/init.lua`.
- Удалить — обратное, те же три шага. Один плагин = один файл = одна зона риска.

Порядок в `plugins/init.lua` не косметический: mason идёт первым (кладёт свой `bin` в PATH, treesitter оттуда берёт `tree-sitter`), treesitter вторым (блокирует старт на доустановке), blink до `config.lsp` (отдаёт capabilities), dap до neotest (`<leader>td` ходит через dap-стратегию).

## Языки и инструменты

**LSP-серверы** включены в [`lua/config/lsp.lua`](lua/config/lsp.lua): gopls, basedpyright, ruff, lua_ls, bashls, yamlls, taplo, marksman, ltex_plus (ru-RU, словари ru-RU и en-US), ansiblels, terraformls. rust-analyzer поднимает rustaceanvim — включать его через `vim.lsp.enable` нельзя, будет два инстанса.

Свои настройки серверов: gopls с inlay hints, расширенными analyses и codelenses; basedpyright в режиме `standard` с inlay hints; ruff без hover (не перебивает basedpyright); marksman на `markdown.mdx` и `mdx`.

**Форматтеры** ([`conform.lua`](lua/plugins/conform.lua)): stylua, ruff_format + ruff_organize_imports, shfmt, goimports + gofumpt, markdownlint-cli2, jq, yamlfmt, taplo, terraform_fmt. `<leader>cf` форматирует, `<leader>uf` / `<leader>uF` глушат автоформат глобально / для буфера.

**Линтеры** ([`lint.lua`](lua/plugins/lint.lua)) — security-сканеры прямо в диагностике, по `BufReadPost` и `BufWritePost`: bandit (python), hadolint + trivy (dockerfile), trivy (terraform/hcl/yaml), golangci-lint (go). Ручной прогон — `<leader>cx`. Намеренно не на `InsertLeave`: trivy и golangci-lint форкают процесс на каждый вызов.

**Тесты и дебаг**: neotest с адаптерами go/python/plenary (`<leader>t*`), nvim-dap + dap-ui + virtual-text с адаптерами delve, debugpy и codelldb (`<leader>d*`). Подробности — в [`KEYMAPS.md`](KEYMAPS.md).

## Treesitter

Используется `nvim-treesitter` ветки `main` с синхронной доустановкой парсеров на старте. [`lua/plugins/treesitter.lua`](lua/plugins/treesitter.lua) сверяет список нужных парсеров с `stdpath("data") .. "/site/parser/"` и компилирует недостающие через `tree-sitter` CLI, блокируя старт. Один раз ~1 минута, дальше моментально.

Текущий набор: bash, c, cpp, css, diff, dockerfile, go (+ gomod/gosum/gotmpl/gowork), helm, hcl, html, ini, json, lua (+ luadoc/luap), make, markdown (+ markdown_inline), python, query, regex, rust, sql, terraform, toml, tsx, typescript, vim, vimdoc, yaml.

Добавить парсер: дописать в `parsers = {...}`, перезапустить nvim — он сам докомпилит недостающее.

Почему нельзя обойтись bundled-парсерами: Neovim 0.12 несёт парсеры для c/lua/markdown/query/vim/vimdoc/diff, но queries из `main`-ветки nvim-treesitter используют поля (`operator:`, `field:`), которых в этих парсерах нет — открытие lua-файла падает с `Invalid field name`. Поэтому bundled-парсеры подменяются свежими.

## Разработка конфига

```bash
make smoke      # загрузить весь конфиг headless, упасть на любой ошибке
make test       # plenary busted, tests/*_spec.lua
make test-file FILE=tests/templater_spec.lua
make lint       # selene
make fmt        # stylua, с записью
make fmt-check  # stylua --check
make all        # smoke + test + lint + fmt-check
```

`selene` и `stylua` ставятся через `brew install selene stylua` (или mason — stylua там уже есть). Кастомный selene std для Neovim и busted живёт в [`vim.yml`](vim.yml).

CI ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) гоняет `stylua --check`, `selene` и юнит-тесты на nightly Neovim. `make smoke` в CI не гоняется — он тянет весь набор плагинов из сети и собирает парсеры, слишком флаки для гейта. Это локальный гейт.

Pre-commit хук обновляет LoC-бейдж в README (нужен `tokei`), включается один раз:

```bash
git config core.hooksPath .githooks
```

## TODO

- [ ] Подровнять mini.statusline под вкус.
- [ ] Если стартап заметно просядет — перевести obsidian/quarto/render-md на ft-autocmd lazy-load (`nvim --startuptime /tmp/nv.log` перед тем, как что-то оптимизировать).
- [ ] Решить, нужны ли sessions (persistence.nvim) и trouble.nvim.
- [ ] Flash.nvim (`s`/`S`) — попробовать, если не хватает прыжков.

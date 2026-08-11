# nvim — конфиг для Neovim 0.12.x без LazyVim и без lazy.nvim

![Lua LoC](https://img.shields.io/badge/lua-3068%20LoC-blueviolet?logo=lua)

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

1. **`vim.pack` клонирует 39 плагинов** — одним блокирующим шагом, на минуту-полторы. Ревизии берутся из `nvim-pack-lock.json`, так что ты получаешь ровно тот срез, который закоммичен.
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
| Explorer | neo-tree (сайдбар справа) | — |
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
│   │   ├── mini.lua            # mini.* (icons/surround/ai/pairs/comment/bufremove/notify)
│   │   ├── neo-tree.lua        # файловый сайдбар справа + <leader>e / <leader>E
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
│       ├── profile.lua         # профайлер: модули/буферы/LSP/подвисания (NVIM_PROFILE=1)
│       ├── vault.lua           # путь к Obsidian-хранилищу + проверка «внутри ли»
│       └── python.lua          # резолв интерпретатора: $VIRTUAL_ENV → .venv → brew
├── scripts/
│   ├── profile.sh              # headless-прогон профайлера по списку файлов
│   ├── profile_run.lua         # драйвер прогона внутри nvim
│   └── lsplog_stat.py          # разбор ~/.local/state/nvim/lsp.log
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

**LSP-серверы** включены в [`lua/config/lsp.lua`](lua/config/lsp.lua): gopls, basedpyright, ruff, vtsls, eslint, jsonls, lua_ls, bashls, yamlls, taplo, marksman, harper_ls, ansiblels, terraformls. rust-analyzer поднимает rustaceanvim — включать его через `vim.lsp.enable` нельзя, будет два инстанса.

Свои настройки серверов: gopls с inlay hints, расширенными analyses и codelenses; basedpyright в режиме `standard` с inlay hints; ruff без hover (не перебивает basedpyright); marksman на `markdown.mdx` и `mdx`.

**TypeScript — vtsls, а не ts_ls.** Внутри тот же tsserver, но vtsls отдаёт команду `typescript.goToSourceDefinition`, и на неё повешен `gd` (только в буферах, где привязан vtsls). Обычный `textDocument/definition` на импорте из node_modules приводит в сгенерированный `.d.ts`; source-definition находит то же самое в исходнике, если пакет его публикует, и откатывается на обычный definition, когда не находит. Включать ts_ls и vtsls одновременно нельзя — будет два tsserver'а.

`root_dir` намеренно не переопределён: тот, что везёт nvim-lspconfig, цепляется за lock-файл пакетного менеджера, а tsconfig по пакетам vtsls разбирает сам. В монорепе это один сервер на всё дерево вместо одного на воркспейс. Рядом с `deno.json` он не стартует вовсе. Из настроек: inlay hints (у tsserver они по умолчанию выключены, так что автовключение в `LspAttach` без этого показывало бы пустоту), `updateImportsOnFileMove`, `autoUseWorkspaceTsdk` (TypeScript берётся из node_modules проекта, иначе диагностика расходится с `tsc` в CI) и `maxTsServerMemory = 8192` — дефолтные ~3 ГиБ большая монорепа выбирает, после чего tsserver начинает молча ронять запросы, и это читается как «LSP затупил».

**eslint через LSP, а не через nvim-lint.** Сервер даёт не только диагностику, но и code actions с fix-all, и подхватывает eslint из node_modules проекта. В репозиториях без конфига eslint он просто не поднимается. На `BufWritePre` вызывается `:LspEslintFixAll`, и этот автокоманд смотрит на те же `vim.g.disable_autoformat` / `vim.b.disable_autoformat`, что и conform, — `<leader>uf` и `<leader>uF` глушат формат и eslint --fix разом. Штатный `on_attach` из nvim-lspconfig при этом сохраняется (он и создаёт `:LspEslintFixAll`), поэтому он захватывается в переменную **до** `vim.lsp.config("eslint", ...)`: после вызова поле читается уже как наша собственная функция, и обёртка ушла бы в рекурсию.

**jsonls с каталогом схем.** Без схем это проверка синтаксиса и не более. `SchemaStore.nvim` отдаёт каталог schemastore.org — 1384 схемы, включая tsconfig.json, package.json и eslintrc; в tsconfig появляется автодополнение ключей `compilerOptions` и валидация значений по типам.

**Проверка текста — harper_ls, а не ltex.** ltex-ls это LanguageTool на JVM, и в замерах он оказался самым дорогим сервером в конфиге. harper-ls — статический бинарник на Rust:

| | RSS | до готовности | русский (4 ошибки) | английский (5 ошибок) |
| --- | --- | --- | --- | --- |
| ltex-ls-plus | 1405 МиБ | 3657 мс | 4 | 1 |
| harper-ls | 165 МиБ | 110 мс | 0 | 4 |

Ровно единица у ltex на английском — не опечатка в таблице: он был настроен `language = "ru-RU"` и английский текст разбирал как русский, ловя только повтор слова.

Расплата за замену: harper знает только английский. Русская **орфография** при этом не потерялась — встроенный `spell` и так включён на markdown/gitcommit/text/tex ([`autocmds.lua`](lua/config/autocmds.lua)) с `spelllang = en_us,ru_ru`, и на тестовой заметке он пометил все три русские опечатки, которые находил ltex. Потерялась русская **грамматика**: повторы слов, согласование, пунктуация. Если это начнёт мешать — вернуть ltex_plus в `vim.lsp.enable` и в `ensure_installed`, конфиг для него лежит в истории git.

Настройки harper: `dialect = "American"`, `markdown.IgnoreLinkTitle`, и главное — `isolateEnglish = true`. Заметки тут русские с английскими терминами внутри, и на смешанном абзаце этот флаг срезал 6 диагностик до 2: «Alertmanager» читался как опечатка в «Micromanager», а русские заголовки собирали претензии на title case. Настоящая английская опечатка при этом осталась. Обратная сторона — на чисто английском тексте изредка теряется одна находка из пяти.

Список filetypes берётся из того, что везёт nvim-lspconfig (27 штук, включая языки программирования — комментарии и докстринги тоже проверяются), плюс `mdx`, `text` и `rst`, которые раньше держал ltex. Читается из `vim.lsp.config.harper_ls.filetypes`, а не хардкодится, чтобы не разъезжалось с апстримом. Словарь для «add to dictionary» — `~/.config/harper-ls/`.

**marksman не поднимается внутри Obsidian-хранилища.** Он отдаёт диагностику по всему workspace, а не по открытому файлу: одна открытая заметка давала 6165 диагностик от marksman против 81 от проверялки текста. Neovim под каждый URI из `publishDiagnostics` заводит буфер через `vim.uri_to_bufnr`, так что открытие одной заметки молча создавало ~2200 буферов, а bufferline на каждой перерисовке таблайна проходил по ним всем и звал `vim.diagnostic.get()` без фильтра — полный `deepcopy` всех диагностик.

| Заметка 689 строк | буферов | диагностик | перерисовка таблайна | выход из редактора |
| --- | --- | --- | --- | --- |
| было | 2199 | 6246 | 16.95 мс | 1363 мс |
| стало | 2 | 81 | 0.90 мс | 22 мс |

Внутри хранилища ту же навигацию закрывает свой сервер obsidian.nvim: `definition`, `references`, `documentSymbol`, `workspaceSymbol`, `rename`, `codeAction`, `foldingRange`, completion по `[`, `#`, `^`. Не покрываются `hover`, `semanticTokens` и `codeLens` — семантическую подсветку в markdown и так дают treesitter с render-markdown. Вне хранилища marksman работает как раньше и стоит дёшево: 86 МиБ на репозитории с 4 md-файлами, 103 МиБ на репозитории с 183, перерисовка таблайна 0.5–0.6 мс.

Реализовано через `root_dir`-функцию, которая просто не зовёт `on_dir` для путей внутри хранилища (см. [`lsp-root_dir()`](https://neovim.io/doc/user/lsp.html#lsp-root_dir)). Путь к хранилищу лежит в [`lua/util/vault.lua`](lua/util/vault.lua) — единственное место, откуда его читают и `obsidian.lua`, и `lsp.lua`; переопределяется через `$OBSIDIAN_VAULT`.

**ansiblels не мог запуститься.** `:checkhealth vim.lsp` ругался «Unknown filetype 'yaml.ansible'», и это была не косметика: у сервера в списке filetypes стоял только составной `yaml.ansible`, а его в конфиге никто не выставлял. На плейбуке поднимался один yamlls, при том что mason исправно ставил `ansible-language-server` и `ansible-lint`. Теперь он слушает обычный `yaml`, но стартует только когда рядом нашёлся `ansible.cfg`, `.ansible-lint`, `site.yml` или каталог `playbooks` — тем же приёмом с `root_dir`, что и marksman. Без этой калитки `vim.lsp.enable` при ненайденном маркере уходит в single-file режим и поднимал бы сервер на каждом YAML в системе.

Оставшиеся предупреждения про `yaml.docker-compose`, `yaml.gitlab` и `yaml.helm-values` — косметика. yamlls держит в своём списке и простой `yaml`, так что на эти файлы он цепляется в любом случае; составные filetypes нужны только тем, кто их выставляет.

Предупреждение про position encodings тоже никуда не денется: harper-ls отдаёт `utf-16` независимо от того, что ему предлагают (проверено — если объявить только `utf-8`, он всё равно отвечает `utf-16`), а obsidian-ls работает в `utf-8` и поднимается мимо `vim.lsp.config`, так что рычага на него нет. Neovim пересчитывает позиции по `offset_encoding` каждого клиента отдельно, так что на практике это не ломается: прогон с правками по крупным русским заметкам не дал ни одной ошибки декодирования.

**Форматтеры** ([`conform.lua`](lua/plugins/conform.lua)): stylua, ruff_format + ruff_organize_imports, shfmt, goimports + gofumpt, markdownlint-cli2, jq, yamlfmt, taplo, terraform_fmt, prettierd (ts/tsx/js/jsx). `<leader>cf` форматирует, `<leader>uf` / `<leader>uF` глушат автоформат глобально / для буфера.

У prettierd стоит `require_cwd = true`. Без него он в проекте без конфига prettier форматирует по своим умолчаниям и тихо переписывает файлы, которые об этом не просили; с ним conform пропускает такие проекты (его `cwd` для prettierd ищет настоящий `.prettierrc*` / `prettier.config.*` либо ключ `"prettier"` в package.json) и форматирование уходит в LSP.

**Линтеры** ([`lint.lua`](lua/plugins/lint.lua)) — security-сканеры прямо в диагностике, по `BufReadPost` и `BufWritePost`: bandit (python), hadolint + trivy (dockerfile), trivy (terraform/hcl/yaml), golangci-lint (go). Ручной прогон — `<leader>cx`. Намеренно не на `InsertLeave`: trivy и golangci-lint форкают процесс на каждый вызов.

**Тесты и дебаг**: neotest с адаптерами go/python/plenary (`<leader>t*`), nvim-dap + dap-ui + virtual-text с адаптерами delve, debugpy и codelldb (`<leader>d*`). Подробности — в [`KEYMAPS.md`](KEYMAPS.md).

## Treesitter

Используется `nvim-treesitter` ветки `main` с синхронной доустановкой парсеров на старте. [`lua/plugins/treesitter.lua`](lua/plugins/treesitter.lua) сверяет список нужных парсеров с `stdpath("data") .. "/site/parser/"` и компилирует недостающие через `tree-sitter` CLI, блокируя старт. Один раз ~1 минута, дальше моментально.

Текущий набор: bash, c, cpp, css, diff, dockerfile, go (+ gomod/gosum/gotmpl/gowork), helm, hcl, html, ini, javascript, jsdoc, json, lua (+ luadoc/luap), make, markdown (+ markdown_inline), python, query, regex, rust, sql, terraform, toml, tsx, typescript, vim, vimdoc, yaml.

`jsdoc` тут не для JavaScript: он инжектится в блоки `/** */` и в `.ts` тоже, без него это просто серый комментарий.

Добавить парсер: дописать в `parsers = {...}`, перезапустить nvim — он сам докомпилит недостающее.

Почему нельзя обойтись bundled-парсерами: Neovim 0.12 несёт парсеры для c/lua/markdown/query/vim/vimdoc/diff, но queries из `main`-ветки nvim-treesitter используют поля (`operator:`, `field:`), которых в этих парсерах нет — открытие lua-файла падает с `Invalid field name`. Поэтому bundled-парсеры подменяются свежими.

## Профилирование

Встроенный профайлер — [`lua/util/profile.lua`](lua/util/profile.lua). Выключен по умолчанию, включается до загрузки конфига, потому что хукает `require` первым делом:

```bash
NVIM_PROFILE=1 nvim note.md
nvim --cmd 'lua vim.g.nvim_profile = true' note.md
```

Внутри: `:Profile` — отчёт в скретч-буфере, `:ProfileDump [path]` — JSON в `stdpath("state")/profile/`, `:ProfileReset` — сбросить накопленное. `NVIM_PROFILE_DUMP=1` дампит автоматически на выходе.

Что меряется:

| Раздел | Как снимается | Отвечает на вопрос |
| --- | --- | --- |
| `MODULE LOAD` | обёртка над глобальным `require`, self/total время | какой плагин съедает старт |
| `BUFFER OPENS` | `BufReadPre` → `BufReadPost` → `FileType` → `BufWinEnter`+`schedule` | сколько стоит открыть конкретный файл |
| `LSP CLIENTS` | обёртка над `vim.lsp.start` + `LspAttach` | сколько сервер поднимается до готовности |
| `SERVER PROGRESS` | автокоманда `LspProgress` (`$/progress`) | сколько идёт индексация на стороне сервера |
| `DIAGNOSTICS LATENCY` | `LspNotify` (`didOpen`/`didChange`) → per-client хендлер `publishDiagnostics` | сколько сервер думает над правкой |
| `LSP REQUESTS` | автокоманда `LspRequest` (`pending` → `complete`) | какие запросы и к кому тормозят |
| `UI STALLS` | `uv` таймер на 100 мс, ловит опоздания | когда и на чём подвисает главный цикл |
| `LUA SAMPLES` | `jit.profile`, свёрнутые стеки | *где именно* сгорело время (нужен `NVIM_PROFILE_SAMPLE=1`) |
| `SHUTDOWN` | `VimLeavePre` → `VimLeave` | сколько выход ждёт языковые серверы |

`UI STALLS` отвечает на «когда», `LUA SAMPLES` — на «где». Сэмплер видит только Lua-кадры: время внутри C (regex, декодирование RPC, системные вызовы) записывается на тот Lua-кадр, который туда ушёл. Включается отдельно, потому что добавляет несколько процентов накладных.

Всё висит на публичном API (`vim.lsp.start`, автокоманды `LspAttach`/`LspRequest`/`LspNotify`/`LspProgress`, `client.handlers`), внутренностей Neovim профайлер не трогает.

### Автоматический прогон

[`scripts/profile.sh`](scripts/profile.sh) поднимает headless-nvim с полным конфигом, открывает файлы по очереди, ждёт, пока все серверы замолчат, при желании имитирует набор текста и печатает отчёт + пишет JSON:

```bash
make profile FILES="README.md"                 # один файл
make profile FILES="note.md" EDITS=20          # с имитацией набора — так ловится шторм didChange
make profile-vault N=10 EDITS=15               # 10 случайных заметок из Obsidian-хранилища
./scripts/profile.sh --dir ~/notes -n 5 -e 10  # напрямую, со своими путями
./scripts/profile.sh --vault 3 -e 10 --lua     # + сэмплирующий профайлер Lua
```

`EDITS` — ключевой параметр: без правок сервер проверяет документ один раз, а тормоза начинаются именно при наборе. Хранилище берётся из `$OBSIDIAN_VAULT`, по умолчанию — iCloud-путь SecondBrain.

### Разбор `lsp.log` задним числом

Всё, что языковой сервер пишет в stderr, Neovim складывает в `~/.local/state/nvim/lsp.log` с именем клиента и таймстампом. Это бесплатная история за все дни, когда профайлер не был включён:

```bash
make profile-log                    # весь лог
make profile-log SINCE=7d           # последняя неделя
./scripts/lsplog_stat.py --client ltex-ls-plus --top 20
```

Скрипт считает объём stderr по клиентам, разбирает `java.util.logging`-сообщения ltex-ls, склеивает `logTextToBeChecked` → `checkAnnotatedTextFragment` в длительность проверки, сводит `initialize`/`shutdown`/`exit` (расхождение = сервер пережил nvim) и показывает самые busy минуты. Разрешение таймстампов в логе — секунда, так что длительности там снизу.

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
- [ ] Пожить с harper_ls и понять, насколько не хватает русской грамматики (повторы слов, согласование, пунктуация) — её встроенный `spell` не закрывает. Если не хватает, вариант не откатываться целиком, а поднимать ltex_plus только внутри хранилища, тем же приёмом с `root_dir`, что и marksman.
- [ ] Flash.nvim (`s`/`S`) — попробовать, если не хватает прыжков.

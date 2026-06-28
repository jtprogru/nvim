-- Unit tests for lua/util/python.lua
-- Exercises the interpreter-resolution precedence:
--   $VIRTUAL_ENV > upward .venv lookup > Homebrew fallback.

local python = require("util.python")

local function mktemp_dir()
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")
  return dir
end

local function touch(path)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  local f = assert(io.open(path, "w"))
  f:write("")
  f:close()
end

describe("python.path", function()
  local saved_venv

  before_each(function()
    saved_venv = vim.env.VIRTUAL_ENV
    vim.env.VIRTUAL_ENV = nil
  end)

  after_each(function()
    vim.env.VIRTUAL_ENV = saved_venv
  end)

  it("prefers an activated $VIRTUAL_ENV when its python exists", function()
    local venv = mktemp_dir()
    touch(venv .. "/bin/python")
    vim.env.VIRTUAL_ENV = venv
    assert.equals(venv .. "/bin/python", python.path())
  end)

  it("ignores $VIRTUAL_ENV when its python is missing", function()
    vim.env.VIRTUAL_ENV = mktemp_dir() -- empty, no bin/python
    assert.equals("/opt/homebrew/bin/python3", python.path("/"))
  end)

  it("finds a project-local .venv by searching upward", function()
    local root = mktemp_dir()
    touch(root .. "/.venv/bin/python")
    local nested = root .. "/a/b/c"
    vim.fn.mkdir(nested, "p")
    assert.equals(root .. "/.venv/bin/python", python.path(nested))
  end)

  it("falls back to the pinned Homebrew python when nothing else matches", function()
    assert.equals("/opt/homebrew/bin/python3", python.path(mktemp_dir()))
  end)
end)

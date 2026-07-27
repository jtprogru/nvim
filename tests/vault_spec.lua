-- Unit tests for lua/util/vault.lua
-- The containment check gates whether marksman starts, so a false positive
-- silently kills markdown navigation outside the vault and a false negative
-- brings back the 6000-diagnostic storm inside it.

local vault = require("util.vault")

describe("vault", function()
  local root = vault.paths[1]

  it("resolves at least one absolute vault root", function()
    assert.is_true(#vault.paths > 0)
    assert.equals("/", root:sub(1, 1))
  end)

  it("matches the root itself and anything under it", function()
    assert.equals(root, vault.of(root))
    assert.equals(root, vault.of(root .. "/note.md"))
    assert.equals(root, vault.of(root .. "/01. Проекты/deep/note.md"))
    assert.is_true(vault.contains(root .. "/note.md"))
  end)

  it("only matches on a path boundary", function()
    -- A sibling directory whose name merely starts with the vault name must
    -- not count as inside it.
    assert.is_nil(vault.of(root .. "Old/note.md"))
    assert.is_nil(vault.of(root .. "-backup/note.md"))
    assert.is_false(vault.contains(root .. "Old/note.md"))
  end)

  it("rejects paths outside, empty and nil", function()
    assert.is_nil(vault.of("/tmp/README.md"))
    assert.is_nil(vault.of(""))
    assert.is_nil(vault.of(nil))
    assert.is_false(vault.contains("/tmp/README.md"))
  end)

  it("normalizes ~ and redundant separators", function()
    assert.equals(root, vault.of(root .. "//sub/../note.md"))
  end)

  it("has_buf reads the buffer name", function()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, root .. "/note.md")
    assert.is_true(vault.has_buf(buf))

    local outside = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(outside, "/tmp/other.md")
    assert.is_false(vault.has_buf(outside))
  end)
end)

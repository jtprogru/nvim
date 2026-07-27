-- Where the Obsidian vault lives, and whether a given path is inside it.
--
-- Single source of truth for the vault path: obsidian.nvim's workspace list
-- (lua/plugins/obsidian.lua) and the marksman root_dir guard (lua/config/lsp.lua)
-- both read it from here. Override with $OBSIDIAN_VAULT.

local M = {}

--- Absolute, normalized vault roots, longest first so nested vaults resolve
--- to the most specific one.
--- @type string[]
M.paths = (function()
  local raw = vim.env.OBSIDIAN_VAULT or "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/SecondBrain"
  local paths = {}
  for path in vim.gsplit(raw, ":", { trimempty = true }) do
    paths[#paths + 1] = vim.fs.normalize(path)
  end
  table.sort(paths, function(a, b)
    return #a > #b
  end)
  return paths
end)()

--- Is `path` inside one of the vaults?
--- Matches on a path boundary, so ".../SecondBrainOld/note.md" is not a hit.
--- @param path string?
--- @return string? vault the containing vault root, nil if outside
function M.of(path)
  if not path or path == "" then
    return nil
  end
  local norm = vim.fs.normalize(path)
  for _, root in ipairs(M.paths) do
    if norm == root or norm:sub(1, #root + 1) == root .. "/" then
      return root
    end
  end
  return nil
end

--- @param path string?
--- @return boolean
function M.contains(path)
  return M.of(path) ~= nil
end

--- @param bufnr integer?
--- @return boolean
function M.has_buf(bufnr)
  return M.contains(vim.api.nvim_buf_get_name(bufnr or 0))
end

return M

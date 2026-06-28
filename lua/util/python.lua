local M = {}

-- Resolve the Python interpreter for a project:
--   1. an activated virtualenv ($VIRTUAL_ENV),
--   2. a project-local .venv (uv's default), searched upward from `root`,
--   3. the pinned Homebrew python as a fallback.
---@param root? string directory to start the upward search from (defaults to cwd)
---@return string
function M.path(root)
  local venv = os.getenv("VIRTUAL_ENV")
  if venv and vim.uv.fs_stat(venv .. "/bin/python") then
    return venv .. "/bin/python"
  end
  local hit = vim.fs.find(".venv", {
    path = root or vim.fn.getcwd(),
    upward = true,
    type = "directory",
  })[1]
  if hit and vim.uv.fs_stat(hit .. "/bin/python") then
    return hit .. "/bin/python"
  end
  return "/opt/homebrew/bin/python3"
end

return M

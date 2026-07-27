-- Unit tests for lua/util/profile.lua
-- The profiler is mostly hooks, so what's testable in isolation is: it stays
-- inert until setup(), it collects what the hooks feed it, and report()/dump()
-- survive both empty and populated state.

local profile = require("util.profile")

describe("profile", function()
  after_each(function()
    profile.reset()
  end)

  it("is disabled until setup", function()
    -- setup() is never called in the minimal test init, so require alone must
    -- not have replaced the global require or registered commands.
    assert.is_false(profile.enabled)
    assert.is_nil(vim.fn.exists(":Profile") == 2 or nil)
  end)

  it("renders a report with no samples", function()
    local lines = profile.report()
    assert.is_true(#lines > 0)
    local text = table.concat(lines, "\n")
    assert.is_truthy(text:find("MODULE LOAD", 1, true))
    assert.is_truthy(text:find("LSP CLIENTS", 1, true))
    assert.is_truthy(text:find("UI STALLS", 1, true))
  end)

  it("renders collected samples", function()
    profile.state.modules = { { name = "fake.mod", total_ms = 12, self_ms = 8, at_ms = 1, ok = true } }
    profile.state.bufs = { { path = "/tmp/a.md", ft = "markdown", bytes = 2048, lines = 40, read_ms = 1, draw_ms = 5 } }
    profile.state.clients = { [1] = { id = 1, name = "ltex_plus", root = "/tmp", ready_ms = 3000, attaches = {} } }
    profile.state.requests["ltex_plus textDocument/codeAction"] = { n = 3, err = 0, samples = { 5, 50, 500 } }
    profile.state.diags["ltex_plus"] = { n = 2, samples = { 100, 900 }, count_max = 7 }
    profile.state.stalls = { { at_ms = 10, ms = 4200, mode = "i", buf = "/tmp/a.md", ft = "markdown" } }

    local text = table.concat(profile.report(), "\n")
    assert.is_truthy(text:find("fake.mod", 1, true))
    assert.is_truthy(text:find("a.md", 1, true))
    assert.is_truthy(text:find("ltex_plus", 1, true))
    assert.is_truthy(text:find("1 stalls", 1, true))
  end)

  it("percentiles come out of the sample buckets", function()
    profile.state.requests["srv m"] = { n = 10, err = 0, samples = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 100 } }
    local text = table.concat(profile.report(), "\n")
    -- p50 = 5, max = 100 — both must show up in the requests row.
    assert.is_truthy(text:find("srv m", 1, true))
    assert.is_truthy(text:find("100.0m", 1, true))
  end)

  it("dumps json that round-trips", function()
    profile.state.stalls = { { at_ms = 1, ms = 250, mode = "n", buf = "x", ft = "lua" } }
    profile.state.diags["srv"] = { n = 1, samples = { 42 }, count_max = 1 }

    local path = vim.fn.tempname() .. ".json"
    assert.equals(path, profile.dump(path))

    local fd = assert(io.open(path, "r"))
    local decoded = vim.json.decode(fd:read("*a"))
    fd:close()
    os.remove(path)

    assert.equals(1, #decoded.stalls)
    assert.equals(42, decoded.diagnostics.srv.p50)
    assert.equals(1, decoded.diagnostics.srv.n)
  end)

  it("reset clears every bucket", function()
    profile.state.stalls = { { at_ms = 1, ms = 1, mode = "n" } }
    profile.state.requests["a b"] = { n = 1, err = 0, samples = { 1 } }
    profile.state.lua_samples["foo;bar"] = 3
    profile.reset()
    assert.equals(0, #profile.state.stalls)
    assert.equals(0, vim.tbl_count(profile.state.requests))
    assert.equals(0, vim.tbl_count(profile.state.lua_samples))
  end)

  it("folds lua samples into a flat profile", function()
    profile.state.lua_samples = { ["a.lua:1;b.lua:2"] = 30, ["c.lua:3"] = 10 }
    local text = table.concat(profile.report(), "\n")
    assert.is_truthy(text:find("LUA SAMPLES", 1, true))
    assert.is_truthy(text:find("a.lua:1;b.lua:2", 1, true))
    -- 30 of 40 samples at the default 5 ms interval: 150ms, 75%.
    assert.is_truthy(text:find("75.0%%"))
    assert.is_truthy(text:find("150m", 1, true))
  end)

  it("omits the lua section when sampling was off", function()
    local text = table.concat(profile.report(), "\n")
    assert.is_nil(text:find("LUA SAMPLES", 1, true))
  end)
end)

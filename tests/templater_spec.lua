-- Unit tests for lua/util/templater.lua
-- Run: make test  (or: make test-file FILE=tests/templater_spec.lua)
--
-- All assertions use a fixed `now` so dates are deterministic. Timestamps are
-- built with os.time() and compared against os.date() of the same module, so
-- the local timezone cancels out and results don't depend on the host TZ.

local templater = require("util.templater")

-- 2024-01-15 12:00 local time — a Monday, convenient for weekday tests.
local NOW = os.time({ year = 2024, month = 1, day = 15, hour = 12, min = 0, sec = 0 })

local function render(s, ctx)
  ctx = vim.tbl_extend("force", { now = NOW, title = "My File Name", creation = NOW }, ctx or {})
  return templater.render(s, ctx)
end

describe("templater.render", function()
  it("passes through content without tags", function()
    assert.equals("plain text, no tags", render("plain text, no tags"))
  end)

  describe("tp.date", function()
    it("now() defaults to YYYY-MM-DD", function()
      assert.equals("2024-01-15", render("<% tp.date.now() %>"))
    end)

    it("now() honours a moment-style format", function()
      assert.equals("2024/01/15", render('<% tp.date.now("YYYY/MM/DD") %>'))
    end)

    it("now() applies a numeric day offset", function()
      assert.equals("2024-01-16", render('<% tp.date.now("YYYY-MM-DD", 1) %>'))
      assert.equals("2024-01-14", render('<% tp.date.now("YYYY-MM-DD", -1) %>'))
    end)

    it("now() applies an ISO P-style offset", function()
      assert.equals("2023-12-15", render('<% tp.date.now("YYYY-MM-DD", "P-1M") %>'))
      assert.equals("2025-01-15", render('<% tp.date.now("YYYY-MM-DD", "P1Y") %>'))
      assert.equals("2024-01-22", render('<% tp.date.now("YYYY-MM-DD", "P1W") %>'))
    end)

    it("tomorrow() and yesterday()", function()
      assert.equals("2024-01-16", render("<% tp.date.tomorrow() %>"))
      assert.equals("2024-01-14", render("<% tp.date.yesterday() %>"))
    end)

    it("weekday() resolves Mon..Sun of the current week", function()
      assert.equals("2024-01-15", render('<% tp.date.weekday("YYYY-MM-DD", 0) %>')) -- Monday
      assert.equals("2024-01-21", render('<% tp.date.weekday("YYYY-MM-DD", 6) %>')) -- Sunday
    end)

    it("weekday() respects an explicit anchor date", function()
      -- 2024-03-20 is a Wednesday; Monday of that week is 2024-03-18.
      assert.equals("2024-03-18", render('<% tp.date.weekday("YYYY-MM-DD", 0, "2024-03-20") %>'))
    end)
  end)

  describe("tp.file.title", function()
    it("returns the title", function()
      assert.equals("My File Name", render("<% tp.file.title %>"))
    end)

    it("toUpperCase / toLowerCase", function()
      assert.equals("MY FILE NAME", render("<% tp.file.title.toUpperCase() %>"))
      assert.equals("my file name", render("<% tp.file.title.toLowerCase() %>"))
    end)

    it("substring by byte offsets (JS semantics)", function()
      assert.equals("My", render("<% tp.file.title.substring(0, 2) %>"))
      assert.equals("File Name", render("<% tp.file.title.substring(3) %>"))
    end)

    it("split() returns a 0-based-indexed array", function()
      assert.equals("My", render('<% tp.file.title.split(" ")[0] %>'))
      assert.equals("File", render('<% tp.file.title.split(" ")[1] %>'))
    end)

    it("length", function()
      assert.equals("12", render("<% tp.file.title.length %>"))
    end)

    it("replace() replaces every occurrence (regression: count leak)", function()
      -- Guards the bug where gsub's count leaked as a max-replacements limit.
      assert.equals("My_File_Name", render('<% tp.file.title.replace(" ", "_") %>'))
    end)
  end)

  describe("expressions", function()
    it("concatenates strings and numbers with +", function()
      assert.equals("ab12", render('<% "a" + "b" + tp.file.title.length %>'))
    end)

    it("trim()", function()
      assert.equals("hi", render("<% tp.file.title.trim() %>", { title = "  hi  " }))
    end)
  end)

  describe("error handling", function()
    it("leaves the tag intact and does not throw on a bad expression", function()
      local out = render("<% tp.does.not_exist() %>")
      assert.equals("<% tp.does.not_exist() %>", out)
    end)
  end)
end)

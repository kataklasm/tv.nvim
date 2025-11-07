local tv = require("tv")

describe("tv.nvim", function()
  before_each(function()
    -- Reset config to defaults before each test
    tv.config = {
      tv_binary = "tv",
      quickfix = {
        auto_open = true,
      },
      window = {
        width = 0.8,
        height = 0.8,
        border = "none",
        title = " tv.nvim ",
        title_pos = "center",
      },
      files = {
        args = { "--no-remote", "--no-status-bar", "--preview-size", "70", "--layout", "portrait" },
      },
      text = {
        args = { "--no-remote", "--no-status-bar", "--preview-size", "70", "--layout", "portrait" },
      },
      keybindings = {
        files = "<C-p>",
        text = "<leader><leader>",
        channels = "<leader>tv",
        files_qf = "<C-q>",
        text_qf = "<C-q>",
      },
    }
  end)

  describe("setup", function()
    it("works with default config", function()
      tv.setup()
      assert.are.equal("tv", tv.config.tv_binary)
      assert.are.equal(0.8, tv.config.window.width)
      assert.are.equal("<C-p>", tv.config.keybindings.files)
    end)

    it("works without calling setup (defaults available)", function()
      -- Config should have defaults even without calling setup
      assert.are.equal("tv", tv.config.tv_binary)
      assert.are.equal(0.8, tv.config.window.width)
      assert.are.equal("<C-p>", tv.config.keybindings.files)
    end)

    it("merges custom config with defaults", function()
      tv.setup({
        tv_binary = "custom-tv",
        window = {
          width = 0.9,
          border = "single",
        },
        files = {
          args = { "--custom-arg" },
        },
      })

      assert.are.equal("custom-tv", tv.config.tv_binary)
      assert.are.equal(0.9, tv.config.window.width)
      assert.are.equal(0.8, tv.config.window.height) -- should keep default
      assert.are.equal("single", tv.config.window.border)
      assert.are.same({ "--custom-arg" }, tv.config.files.args)
      assert.are.equal("<C-p>", tv.config.keybindings.files) -- should keep default
    end)

    it("allows per-channel window configuration", function()
      tv.setup({
        files = {
          window = {
            width = 0.9,
            title = " Files ",
            border = "rounded",
          },
        },
        text = {
          window = {
            width = 0.7,
            title = " Text Search ",
          },
        },
      })

      -- Files channel should have custom window settings
      assert.are.equal(0.9, tv.config.files.window.width)
      assert.are.equal(" Files ", tv.config.files.window.title)
      assert.are.equal("rounded", tv.config.files.window.border)

      -- Text channel should have custom window settings
      assert.are.equal(0.7, tv.config.text.window.width)
      assert.are.equal(" Text Search ", tv.config.text.window.title)

      -- Global defaults should remain
      assert.are.equal(0.8, tv.config.window.width)
      assert.are.equal("none", tv.config.window.border)
    end)

    it("allows disabling keybindings", function()
      tv.setup({
        keybindings = {
          files = false,
          text = false,
          channels = false,
        },
      })

      assert.are.equal(false, tv.config.keybindings.files)
      assert.are.equal(false, tv.config.keybindings.text)
      assert.are.equal(false, tv.config.keybindings.channels)
    end)
  end)

  describe("configuration", function()
    it("has expected default values", function()
      assert.are.equal("tv", tv.config.tv_binary)
      assert.are.equal(0.8, tv.config.window.width)
      assert.are.equal(0.8, tv.config.window.height)
      assert.are.equal("none", tv.config.window.border)
      assert.are.equal(" tv.nvim ", tv.config.window.title)
      assert.are.equal("center", tv.config.window.title_pos)
    end)

    it("has expected default arguments", function()
      local expected_files_args = { "--no-remote", "--no-status-bar", "--preview-size", "70", "--layout", "portrait" }
      local expected_text_args = { "--no-remote", "--no-status-bar", "--preview-size", "70", "--layout", "portrait" }

      assert.are.same(expected_files_args, tv.config.files.args)
      assert.are.same(expected_text_args, tv.config.text.args)
    end)

    it("has expected default keybindings", function()
      assert.are.equal("<C-p>", tv.config.keybindings.files)
      assert.are.equal("<leader><leader>", tv.config.keybindings.text)
      assert.are.equal("<leader>tv", tv.config.keybindings.channels)
      assert.are.equal("<C-q>", tv.config.keybindings.files_qf)
      assert.are.equal("<C-q>", tv.config.keybindings.text_qf)
    end)

    it("has expected default quickfix config", function()
      assert.are.equal(true, tv.config.quickfix.auto_open)
    end)
  end)

  describe("functions", function()
    it("has tv_files function", function()
      assert.is_function(tv.tv_files)
    end)

    it("has tv_text function", function()
      assert.is_function(tv.tv_text)
    end)

    it("has tv_channels function", function()
      assert.is_function(tv.tv_channels)
    end)

    it("has create_win_and_buf function", function()
      assert.is_function(tv.create_win_and_buf)
    end)

    it("has setup function", function()
      assert.is_function(tv.setup)
    end)
  end)

  describe("_convert_keybinding_to_tv_format", function()
    local convert = tv._convert_keybinding_to_tv_format

    describe("control key combinations", function()
      it("converts <C-q> to ctrl-q", function()
        assert.are.equal("ctrl-q", convert("<C-q>"))
      end)

      it("converts <C-x> to ctrl-x", function()
        assert.are.equal("ctrl-x", convert("<C-x>"))
      end)

      it("converts <C-a> to ctrl-a", function()
        assert.are.equal("ctrl-a", convert("<C-a>"))
      end)

      it("converts uppercase <C-Q> to ctrl-q", function()
        assert.are.equal("ctrl-q", convert("<C-Q>"))
      end)
    end)

    describe("alt key combinations", function()
      it("converts <A-q> to alt-q", function()
        assert.are.equal("alt-q", convert("<A-q>"))
      end)

      it("converts <A-x> to alt-x", function()
        assert.are.equal("alt-x", convert("<A-x>"))
      end)

      it("converts <M-q> to alt-q (meta as alt)", function()
        assert.are.equal("alt-q", convert("<M-q>"))
      end)

      it("converts <M-x> to alt-x (meta as alt)", function()
        assert.are.equal("alt-x", convert("<M-x>"))
      end)
    end)

    describe("shift key combinations", function()
      it("converts <S-f> to shift-f", function()
        assert.are.equal("shift-f", convert("<S-f>"))
      end)

      it("converts <S-x> to shift-x", function()
        assert.are.equal("shift-x", convert("<S-x>"))
      end)
    end)

    describe("special keys", function()
      it("converts <Enter> to enter", function()
        assert.are.equal("enter", convert("<Enter>"))
      end)

      it("converts <Esc> to esc", function()
        assert.are.equal("esc", convert("<Esc>"))
      end)

      it("converts <Tab> to tab", function()
        assert.are.equal("tab", convert("<Tab>"))
      end)

      it("converts <Space> to space", function()
        assert.are.equal("space", convert("<Space>"))
      end)
    end)

    describe("edge cases", function()
      it("returns nil for nil input", function()
        assert.is_nil(convert(nil))
      end)

      it("converts plain text without brackets", function()
        assert.are.equal("ctrl-q", convert("ctrl-q"))
      end)

      it("handles case conversion", function()
        assert.are.equal("ctrl-q", convert("<C-Q>"))
      end)
    end)

    describe("complex combinations", function()
      it("handles multiple modifier keys in sequence", function()
        -- While uncommon, test that the function handles text with multiple patterns
        local input = "<C-a> and <A-b>"
        local expected = "ctrl-a and alt-b"
        assert.are.equal(expected, convert(input))
      end)
    end)
  end)
end)

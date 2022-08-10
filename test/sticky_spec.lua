return function()
  local mock_fs = require("deftest.mock.fs")
  local log = require("modules.log")
  local sticky = require("modules.sticky")

  describe("sticky", function()
    before(function()
      log.set_level(log.FATAL)
      log.set_print(false)

      mock_fs.mock()
    end)

    after(function()
      sticky.reset()

      mock_fs.unmock()
    end)

    describe("load", function()
      it("loads the file if not empty", function()
        local saved_contents = { foo = "bar" }
        sys.load.always_returns(saved_contents)
        local ok, contents = sticky.load("settings")
        assert_true(ok)
        assert_not_nil(contents)
        assert_same(saved_contents, contents)
      end)

      it("loads defaults if the file doesn't exist", function()
        local defaults = { foo = "" }
        sys.load.always_returns({})
        local ok, contents = sticky.load("settings", defaults)
        assert_true(ok)
        assert_not_nil(contents)
        assert_same(defaults, contents)
      end)

      it("loads the backup if the file can't be read", function()
        local saved_backup = { foo = "bar" }
        sys.load.replace(function(path)
          if string.sub(path, -4) == ".bak" then
            return saved_backup
          else
            error("BOOM")
          end
        end)
        local ok, contents = sticky.load("settings")
        assert_true(ok)
        assert_not_nil(contents)
        assert_same(saved_backup, contents)
      end)

      it("loads defaults if neither the file nor the backup can be read", function()
        local defaults = { foo = "" }
        sys.load.replace(function()
          error("BOOM")
        end)
        local ok, contents = sticky.load("settings", defaults)
        assert_false(ok)
        assert_not_nil(contents)
        assert_same(defaults, contents)
      end)

      it("writes a backup after loading a file", function()
        local saved_contents = { foo = "bar" }
        sys.load.always_returns(saved_contents)
        sticky.load("settings")
        assert_equal(1, sys.save.calls)
      end)

      it("doesn't write a backup after loading a backup", function()
        local saved_backup = { foo = "bar" }
        sys.load.replace(function(path)
          if string.sub(path, -4) == ".bak" then
            return saved_backup
          else
            error("BOOM")
          end
        end)
        sticky.load("settings")
        assert_equal(0, sys.save.calls)
      end)
    end)

    describe("save", function()
      it("saves the file if there are changes", function()
        sys.load.always_returns({ foo = "bar" })
        sticky.load("settings")
        sticky.set("settings", "foo", "baz")
        assert_true(sticky.save("settings"))
        assert_equal(2, sys.save.calls)
      end)

      it("doesn't save the file if there aren't changes", function()
        sys.load.always_returns({ foo = "bar" })
        sticky.load("settings")
        assert_false(sticky.save("settings"))
        assert_equal(1, sys.save.calls)
      end)

      it("saves the file if there aren't changes, but force flag is specified", function()
        sys.load.always_returns({ foo = "bar" })
        sticky.load("settings")
        assert_true(sticky.save("settings", true))
        assert_equal(2, sys.save.calls)
      end)

      it("does nothing if the file isn't loaded", function()
        assert_false(sticky.save("settings"))
        assert_equal(0, sys.save.calls)
      end)

      it("returns false if the file can't be written", function()
        sys.save.replace(function(path)
          error("BOOM")
        end)
        sys.load.always_returns({ foo = "bar" })
        sticky.load("settings")
        assert_false(sticky.save("settings", true))
        assert_equal(2, sys.save.calls)
      end)
    end)

    describe("get", function()
      it("returns the value for the specified key if the file is loaded", function()
        sys.load.always_returns({ foo = "bar" })
        sticky.load("settings")
        assert_equal("bar", sticky.get("settings", "foo"))
      end)

      it("returns nil if the file isn't loaded", function()
        assert_nil(sticky.get("settings", "foo"))
      end)
    end)

    describe("set", function()
      it("sets the value for the specified key, and returns true, if the file is loaded", function()
        sys.load.always_returns({ foo = "bar" })
        sticky.load("settings")
        assert_true(sticky.set("settings", "foo", "baz"))
        assert_equal("baz", sticky.get("settings", "foo"))
      end)

      it("returns false if the file isn't loaded", function()
        assert_false(sticky.set("settings", "foo", "baz"))
      end)
    end)

    describe("is_loaded", function()
      it("returns true if the file is loaded", function()
        sys.load.always_returns({ foo = "bar" })
        sticky.load("settings")
        assert_true(sticky.is_loaded("settings"))
      end)

      it("returns false if the file isn't loaded", function()
        assert_false(sticky.is_loaded("settings"))
      end)
    end)
  end)
end

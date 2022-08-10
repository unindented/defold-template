return function()
  local mock = require("deftest.mock.mock")
  local utils = require("modules.utils")

  describe("utils", function()
    before(function()
      mock.mock(os)
      mock.mock(sys)
    end)

    after(function()
      mock.unmock(os)
      mock.unmock(sys)
    end)

    describe("starts_with", function()
      it("returns true if string starts with", function()
        assert_true(utils.starts_with("abcde", "ab"))
      end)

      it("returns false if string doesn't start with", function()
        assert_false(utils.starts_with("abcde", "bc"))
      end)
    end)

    describe("ends_with", function()
      it("returns true if string ends with", function()
        assert_true(utils.ends_with("abcde", "de"))
      end)

      it("returns false if string doesn't end with", function()
        assert_false(utils.ends_with("abcde", "cd"))
      end)
    end)

    describe("map", function()
      it("returns the mapped array", function()
        local function func(i)
          return i * 2
        end
        assert_same({ 2, 4, 6 }, utils.map({ 1, 2, 3 }, func))
      end)
    end)

    describe("merge", function()
      it("returns the merged table", function()
        assert_same({ a = 2, b = 4, c = 6 }, utils.merge({ a = 2, b = 3 }, { b = 4, c = 6 }))
      end)
    end)

    describe("ignore_first", function()
      it("returns a function that ignores its first argument", function()
        local func = utils.ignore_first(function(a)
          return a
        end)
        assert_equal(2, func(1, 2))
      end)
    end)

    describe("memoize", function()
      it("returns a memoized version of a function without arguments", function()
        local m = {
          f1 = function()
            return 1
          end,
        }
        mock.mock(m)
        local f1 = utils.memoize(m.f1)
        assert_equal(1, f1())
        assert_equal(1, f1())
        assert_equal(1, f1())
        assert_equal(1, m.f1.calls)
      end)

      it("returns a memoized version of a function with one argument", function()
        local m = {
          f2 = function(a)
            return 1 + a
          end,
        }
        mock.mock(m)
        local f2 = utils.memoize(m.f2)
        assert_equal(2, f2(1))
        assert_equal(2, f2(1))
        assert_equal(3, f2(2))
        assert_equal(2, m.f2.calls)
      end)

      it("returns a memoized version of a function with multiple arguments", function()
        local m = {
          f3 = function(a, b)
            return 1 + a + b
          end,
        }
        mock.mock(m)
        local f3 = utils.memoize(m.f3)
        assert_equal(4, f3(1, 2))
        assert_equal(4, f3(1, 2))
        assert_equal(5, f3(2, 2))
        assert_equal(2, m.f3.calls)
      end)
    end)

    describe("version", function()
      it("returns a version string", function()
        local pattern = "%w+ v%d%.%d%.%d%-development\nDefold v%d%.%d%.%d %(%w+%)"
        assert_match(pattern, utils.version())
      end)
    end)

    describe("is_debug", function()
      it("returns true if this is a debug build", function()
        sys.get_engine_info.always_returns({ is_debug = true })
        assert_true(utils.is_debug())
      end)

      it("returns false if this isn't a debug build", function()
        sys.get_engine_info.always_returns({ is_debug = false })
        assert_false(utils.is_debug())
      end)
    end)

    describe("platform", function()
      it("returns the platform name", function()
        sys.get_sys_info.always_returns({ system_name = "Linux" })
        assert_equal("Linux", utils.platform())
      end)
    end)

    describe("config_path", function()
      it("returns the config path for a file when platform isn't Linux", function()
        sys.get_config.always_returns("My Awesome App!")
        sys.get_sys_info.always_returns({ system_name = "Windows" })
        sys.get_save_file.replace(function(dirname, filename)
          return "some/path/" .. dirname .. "/" .. filename
        end)
        assert_equal("some/path/MyAwesomeApp/config.dat", utils.config_path("config.dat"))
      end)

      it(
        "returns the config path for a file when platform is Linux and XDG_CONFIG_HOME is defined",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.replace(function(varname)
            return varname == "XDG_CONFIG_HOME" and "home/path/.config" or nil
          end)
          assert_equal("home/path/.config/MyAwesomeApp/config.dat", utils.config_path("config.dat"))
        end
      )

      it(
        "returns the config path for a file when platform is Linux and XDG_CONFIG_HOME isn't defined, but HOME is",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.replace(function(varname)
            return varname == "HOME" and "home/path" or nil
          end)
          assert_equal("home/path/.config/MyAwesomeApp/config.dat", utils.config_path("config.dat"))
        end
      )

      it(
        "returns the config path for a file when platform is Linux and neither XDG_CONFIG_HOME nor HOME are defined",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.always_returns(nil)
          assert_equal("some/path/MyAwesomeApp/config.dat", utils.config_path("config.dat"))
        end
      )
    end)

    describe("data_path", function()
      it("returns the data path for a file when platform isn't Linux", function()
        sys.get_config.always_returns("My Awesome App!")
        sys.get_sys_info.always_returns({ system_name = "Windows" })
        sys.get_save_file.replace(function(dirname, filename)
          return "some/path/" .. dirname .. "/" .. filename
        end)
        assert_equal("some/path/MyAwesomeApp/user.dat", utils.data_path("user.dat"))
      end)

      it(
        "returns the data path for a file when platform is Linux and XDG_DATA_HOME is defined",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.replace(function(varname)
            return varname == "XDG_DATA_HOME" and "home/path/.local/share" or nil
          end)
          assert_equal("home/path/.local/share/MyAwesomeApp/user.dat", utils.data_path("user.dat"))
        end
      )

      it(
        "returns the data path for a file when platform is Linux and XDG_DATA_HOME isn't defined, but HOME is",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.replace(function(varname)
            return varname == "HOME" and "home/path" or nil
          end)
          assert_equal("home/path/.local/share/MyAwesomeApp/user.dat", utils.data_path("user.dat"))
        end
      )

      it(
        "returns the data path for a file when platform is Linux and neither XDG_DATA_HOME nor HOME are defined",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.always_returns(nil)
          assert_equal("some/path/MyAwesomeApp/user.dat", utils.data_path("user.dat"))
        end
      )
    end)

    describe("state_path", function()
      it("returns the state path for a file when platform isn't Linux", function()
        sys.get_config.always_returns("My Awesome App!")
        sys.get_sys_info.always_returns({ system_name = "Windows" })
        sys.get_save_file.replace(function(dirname, filename)
          return "some/path/" .. dirname .. "/" .. filename
        end)
        assert_equal("some/path/MyAwesomeApp/user.log", utils.state_path("user.log"))
      end)

      it(
        "returns the state path for a file when platform is Linux and XDG_DATA_HOME is defined",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.replace(function(varname)
            return varname == "XDG_STATE_HOME" and "home/path/.local/state" or nil
          end)
          assert_equal("home/path/.local/state/MyAwesomeApp/user.log", utils.state_path("user.log"))
        end
      )

      it(
        "returns the state path for a file when platform is Linux and XDG_DATA_HOME isn't defined, but HOME is",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.replace(function(varname)
            return varname == "HOME" and "home/path" or nil
          end)
          assert_equal("home/path/.local/state/MyAwesomeApp/user.log", utils.state_path("user.log"))
        end
      )

      it(
        "returns the state path for a file when platform is Linux and neither XDG_DATA_HOME nor HOME are defined",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.always_returns(nil)
          assert_equal("some/path/MyAwesomeApp/user.log", utils.state_path("user.log"))
        end
      )
    end)

    describe("quit", function()
      it("exits with 0 when platform isn't HTML5", function()
        sys.get_sys_info.always_returns({ system_name = "Linux" })
        utils.quit()
        assert_equal(1, sys.exit.calls)
      end)

      it("does nothing when platform is HTML5", function()
        sys.get_sys_info.always_returns({ system_name = "HTML5" })
        utils.quit()
        assert_equal(0, sys.exit.calls)
      end)
    end)
  end)
end

return function()
  local mock_fs = require("deftest.mock.fs")
  local log = require("modules.log")
  local settings = require("modules.settings")

  describe("settings", function()
    before(function()
      log.set_level(log.FATAL)
      log.set_print(false)

      mock_fs.mock()
    end)

    after(function()
      mock_fs.unmock()
    end)

    describe("init", function()
      it("loads settings from disk", function()
        local saved_contents = {
          __version__ = "1",
          fullscreen = true,
          reduce_motion = true,
          disable_shaders = true,
          master_volume = 0.8,
          music_volume = 0.7,
          effects_volume = 0.6,
          language = "fr",
        }
        sys.load.always_returns(saved_contents)
        settings.init()
        assert_true(settings.get_fullscreen())
        assert_true(settings.get_reduce_motion())
        assert_true(settings.get_disable_shaders())
        assert_equal(0.8, settings.get_master_volume())
        assert_equal(0.7, settings.get_music_volume())
        assert_equal(0.6, settings.get_effects_volume())
        assert_equal("fr", settings.get_language())
      end)

      it("merges settings with defaults", function()
        local saved_contents = {
          __version__ = "1",
          reduce_motion = true,
          disable_shaders = true,
        }
        sys.load.always_returns(saved_contents)
        settings.init()
        assert_false(settings.get_fullscreen())
        assert_true(settings.get_reduce_motion())
        assert_true(settings.get_disable_shaders())
        assert_equal(1, settings.get_master_volume())
        assert_equal(1, settings.get_music_volume())
        assert_equal(1, settings.get_effects_volume())
        assert_nil(settings.get_language())
      end)
    end)

    describe("final", function()
      it("saves settings to disk", function()
        settings.init()
        settings.set_fullscreen(true)
        settings.final()
        assert(1, sys.save.calls)
      end)
    end)
  end)
end

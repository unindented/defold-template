return function()
  local mock_fs = require("deftest.mock.fs")
  local log = require("modules.log")

  local function read(path)
    local file, error = io.open(path, "rb")

    if file == nil or error then
      return nil, error
    end

    local data = file:read("*a")
    file:close()

    return data
  end

  describe("log", function()
    before(function()
      mock_fs.mock()

      log.set_level(log.DEBUG)
      log.set_print(false)
    end)

    after(function()
      mock_fs.unmock()
    end)

    describe("set_level", function()
      it("sets the log level, which prevents lower-level logs from being written", function()
        log.set_level(log.WARN)
        local path = log.info("info message")
        assert_nil(path)

        log.set_level(log.INFO)
        local path = log.info("info message")
        assert_match("info message", read(path))
      end)
    end)

    describe("debug", function()
      it("writes a debug log to disk", function()
        local path = log.debug("debug message")
        assert_match("- DEBUG - .* - debug message", read(path))
      end)
    end)

    describe("info", function()
      it("writes an info log to disk", function()
        local path = log.info("info message")
        assert_match("- INFO  - .* - info message", read(path))
      end)
    end)

    describe("warn", function()
      it("writes a warning log to disk", function()
        local path = log.warn("warning message")
        assert_match("- WARN  - .* - warning message", read(path))
      end)
    end)

    describe("error", function()
      it("writes an error log to disk", function()
        local path = log.error("error message")
        assert_match("- ERROR - .* - error message", read(path))
      end)
    end)

    describe("fatal", function()
      it("writes an fatal log to disk", function()
        local path = log.fatal("fatal message")
        assert_match("- FATAL - .* - fatal message", read(path))
      end)
    end)
  end)
end

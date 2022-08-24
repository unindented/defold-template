return function()
  local mock = require("deftest.mock.mock")
  local analytics = require("modules.analytics")
  local log = require("modules.log")
  local sticky = require("modules.sticky")

  describe("analytics", function()
    local dsn = "https://my-umami.vercel.app"
    local website_id = "ace8426d-8e00-4a2f-bf62-e28d8d5d68cf"

    local http_history
    local http_status

    before(function()
      log.set_level(log.FATAL)
      log.set_print(false)

      mock.mock(sys)
      mock.mock(http)

      sys.load.always_returns({})
      sys.save.always_returns(true)

      local mocked_config_values = {
        ["project.title"] = "Template",
        ["project.version"] = "1.0.0",
        ["display.width"] = "1600",
        ["display.height"] = "900",
        ["umami.dsn"] = dsn,
        ["umami.website_id"] = website_id,
      }
      sys.get_config.replace(function(key)
        return mocked_config_values[key]
      end)

      local mocked_sys_info_values = {
        device_language = "es-ES",
      }
      sys.get_sys_info.replace(function()
        local sys_info = sys.get_sys_info.original()
        for k, v in pairs(mocked_sys_info_values) do
          sys_info[k] = v
        end
        return sys_info
      end)

      local mocked_engine_info_values = {
        version = "1.3.5",
      }
      sys.get_engine_info.replace(function()
        local engine_info = sys.get_engine_info.original()
        for k, v in pairs(mocked_engine_info_values) do
          engine_info[k] = v
        end
        return engine_info
      end)

      http_history = {}
      http_status = 200

      http.request.replace(function(url, method, callback, headers, post_data, options)
        table.insert(http_history, {
          url = url,
          method = method,
          callback = callback,
          headers = headers,
          post_data = post_data,
          options = options,
        })
        if callback then
          callback({}, "id", { status = http_status, response = "", headers = {} })
        end
      end)
    end)

    after(function()
      sticky.reset()

      mock.unmock(sys)
      mock.unmock(http)
    end)

    describe("init", function()
      it("enables automatic error/crash reporting", function()
        analytics.init()
        assert_equal(1, sys.set_error_handler.calls)
      end)
    end)

    describe("final", function()
      it("saves items to disk", function()
        analytics.init()
        analytics.screen("settings")
        analytics.final()
        assert_equal(2, sys.save.calls)
      end)
    end)

    describe("update", function()
      it("auto-saves items every 10s", function()
        analytics.init()
        analytics.screen("settings")
        analytics.update(9)
        assert_equal(1, sys.save.calls)
        analytics.update(1)
        assert_equal(2, sys.save.calls)
      end)
    end)

    describe("screen", function()
      it("reports the screen name", function()
        analytics.init()
        analytics.screen("title")
        analytics.screen("settings")
        assert_equal(0, #http_history)

        analytics.dispatch()
        analytics.dispatch()
        assert_equal(2, #http_history)

        assert_equal(dsn .. "/api/collect", http_history[1].url)
        assert_same(
          json.decode(
            '{"type":"pageview","payload":{'
              .. '"hostname":"template-1-0-0.com",'
              .. '"screen":"1600x900",'
              .. '"url":"/title?project_version=1.0.0&engine_version=1.3.5",'
              .. '"website":"'
              .. website_id
              .. '",'
              .. '"language":"es-ES"'
              .. "}}"
          ),
          json.decode(http_history[1].post_data)
        )
        assert_equal(dsn .. "/api/collect", http_history[2].url)
        assert_same(
          json.decode(
            '{"type":"pageview","payload":{'
              .. '"hostname":"template-1-0-0.com",'
              .. '"screen":"1600x900",'
              .. '"url":"/settings?project_version=1.0.0&engine_version=1.3.5",'
              .. '"website":"'
              .. website_id
              .. '",'
              .. '"language":"es-ES"'
              .. "}}"
          ),
          json.decode(http_history[2].post_data)
        )
      end)
    end)
  end)
end

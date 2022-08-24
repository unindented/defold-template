return function()
  local mock = require("deftest.mock.mock")
  local user_agent = require("modules.user_agent")

  describe("user_agent", function()
    local mocked_sys_info_values

    before(function()
      mock.mock(sys)

      mocked_sys_info_values = {}
      sys.get_sys_info.replace(function()
        local sys_info = sys.get_sys_info.original()
        for k, v in pairs(mocked_sys_info_values) do
          sys_info[k] = v
        end
        return sys_info
      end)
    end)

    after(function()
      mock.unmock(sys)
    end)

    describe("get", function()
      it("provides user agent strings for all platforms", function()
        mocked_sys_info_values["system_name"] = "iPhone OS"
        mocked_sys_info_values["device_model"] = "iPhone5,0"
        local uas = user_agent.get()
        assert_match("Mozilla%/5%.0 %(iPhone;.*", uas)

        mocked_sys_info_values["system_name"] = "iPhone OS"
        mocked_sys_info_values["device_model"] = "iPad5,0"
        local uas = user_agent.get()
        assert_match("Mozilla%/5%.0 %(iPad;.*", uas)

        mocked_sys_info_values["system_name"] = "iPhone OS"
        mocked_sys_info_values["device_model"] = "iPod5,0"
        local uas = user_agent.get()
        assert_match("Mozilla%/5%.0 %(iPod;.*", uas)

        mocked_sys_info_values["system_name"] = "Android"
        mocked_sys_info_values["device_model"] = nil
        local uas = user_agent.get()
        assert_match("Mozilla%/5%.0 %(Linux;.*", uas)

        mocked_sys_info_values["system_name"] = "Darwin"
        mocked_sys_info_values["device_model"] = nil
        local uas = user_agent.get()
        assert_match("Mozilla%/5%.0 %(Macintosh;.*", uas)

        mocked_sys_info_values["system_name"] = "Darwin"
        mocked_sys_info_values["device_model"] = nil
        local uas = user_agent.get()
        assert_match("Mozilla%/5%.0 %(Macintosh;.*", uas)
      end)

      it("provides no user agent string for HTML5", function()
        mocked_sys_info_values["system_name"] = "HTML5"
        mocked_sys_info_values["device_model"] = nil
        local uas = user_agent.get()
        assert_nil(uas)
      end)

      it("handles unknown system names", function()
        mocked_sys_info_values["system_name"] = "Foobar"
        mocked_sys_info_values["device_model"] = nil
        local uas = user_agent.get()
        assert_match("Mozilla%/5%.0 %(Foobar;.*", uas)
      end)
    end)
  end)
end

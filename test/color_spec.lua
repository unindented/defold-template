return function()
  local color = require("modules.color")

  describe("color", function()
    describe("hex_to_rgba", function()
      it("converts hex to RGBA", function()
        local hex = "663399FF"
        local rgba = vmath.vector4(102 / 255, 51 / 255, 153 / 255, 1)
        assert_same(rgba, color.hex_to_rgba(hex))
      end)
    end)
  end)
end

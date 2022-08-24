return function()
  local jason = require("modules.jason")

  describe("jason", function()
    describe("encode", function()
      local data = { a = "string", b = { c = 42 }, d = true }

      it("encodes data", function()
        assert_same(data, jason.decode(jason.encode(data)))
      end)
    end)

    describe("decode", function()
      local str = '{"a":"string","b":{"c":42},"d":true}'

      it("encodes data", function()
        assert_same({ a = "string", b = { c = 42 }, d = true }, jason.decode(str))
      end)
    end)
  end)
end

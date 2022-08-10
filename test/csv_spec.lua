return function()
  local csv = require("modules.csv")

  describe("csv", function()
    describe("parse", function()
      local csv_str = "a,b,c\nd,e,f\ng,h,i"

      it("parses header columns", function()
        local header_columns, _ = csv.parse(csv_str)
        assert_not_nil(header_columns)
        assert_same({ "a", "b", "c" }, header_columns)
      end)

      it("parses data", function()
        local _, data_iter = csv.parse(csv_str)
        assert_same({ "d", "e", "f" }, { data_iter() })
        assert_same({ "g", "h", "i" }, { data_iter() })
        assert_nil(data_iter())
      end)
    end)
  end)
end

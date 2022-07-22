-- Based on Weak preset:
-- https://github.com/levno-710/Prometheus/blob/8119bb6be39e21c6b9f29f83a79b20cce41bffeb/src/presets.lua#L24-L57

return {
  LuaVersion = "Lua51",
  VarNamePrefix = "",
  NameGenerator = "MangledShuffled",
  PrettyPrint = false,
  Seed = 0,
  Steps = {
    {
      Name = "ConstantArray",
      Settings = {
        Treshold = 1,
        StringsOnly = true,
      },
    },
  },
}

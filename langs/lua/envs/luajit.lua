local f = io.popen("luajit -v")
local version = f:read("*a")
f:close()

return {
  title = "LuaJIT",
  description = [[
  ]],
  host_info = version,
  -- build = function(impl_path, tmp_path) return true end,
  run_cmd = function(impl_path, tmp_path, ...) return "luajit", impl_path, ... end
}

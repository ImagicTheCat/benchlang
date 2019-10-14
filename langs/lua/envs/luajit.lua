local path = os.getenv("LUAJIT_PATH") or "luajit"

local f = io.popen(path.." -v")
local version = f:read("*a")
f:close()

return {
  version = 1,
  title = "LuaJIT",
  description = [[
  ]],
  host_info = version,
  build = function(impl_path, tmp_path) return true end,
  run_cmd = function(impl_path, tmp_path, ...) return path, impl_path, ... end
}

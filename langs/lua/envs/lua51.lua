local path = os.getenv("LUA51_PATH") or "lua5.1"

local f = io.popen(path.." -v")
local version = f:read("*a")
f:close()

return {
  title = "PUC-Lua 5.1",
  description = [[
  ]],
  host_info = version,
  -- build = function(impl_path, tmp_path) return true end,
  run_cmd = function(impl_path, tmp_path, ...) return path, impl_path, ... end
}

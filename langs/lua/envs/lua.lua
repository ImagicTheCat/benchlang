local path = os.getenv("LUA_PATH") or "lua"

local f = io.popen(path.." -v")
local version = f:read("*a")
f:close()

return {
  version = 1,
  title = "PUC",
  description = [[
https://www.lua.org/

Official VM implementation (latest).
  ]],
  host_info = version,
  build = function(e) return true end,
  run_cmd = function(e, ...) return path, e.p_impl, ... end
}

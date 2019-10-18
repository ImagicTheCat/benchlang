local path = os.getenv("LUAJIT_PATH") or "luajit"

local f = io.popen(path.." -v"..[[ -e "print(jit.status())"]])
local version = f:read("*a")
f:close()

return {
  version = 1,
  title = "LuaJIT",
  description = [[
http://luajit.org/luajit.html
  ]],
  host_info = version,
  build = function(e) return true end,
  run_cmd = function(e, ...) return path, e.p_impl, ... end
}

local path = os.getenv("LUAJIT_PATH") or "luajit"

local f = io.popen(path.." -v")
local version = f:read("*a")
f:close()

return {
  version = 1,
  title = "LuaJIT -joff",
  description = [[
http://luajit.org/luajit.html

JIT compiler disabled.
  ]],
  host_info = version,
  build = function(impl_path, tmp_path) return true end,
  run_cmd = function(impl_path, tmp_path, ...) return path, "-joff", impl_path, ... end
}

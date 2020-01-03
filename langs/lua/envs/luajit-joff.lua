local path = os.getenv("BL_LUAJIT_PATH") or "luajit"

local f = io.popen(path.." -v -joff"..[[ -e "print(jit.status())"]])
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
  build = function(e) return true end,
  run_cmd = function(e, ...) return path, "-joff", e.p_impl, ... end
}

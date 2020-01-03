local path = os.getenv("BL_GCC_PATH") or "gcc"

local f = io.popen(path.." --version")
local version = f:read("*a")
f:close()

return {
  version = 1,
  title = "GCC -O3",
  description = [[
https://gcc.gnu.org/

Speed optimizations.

IMPL VARS:
- LIBS: GCC lib link flags
  ]],
  host_info = version,
  build = function(e)
    return os.execute(path.." -O3 "..e.p_impl.." -o "..e.p_tmp.."/run "..(e.vars.LIBS or "")) == 0
  end,
  run_cmd = function(e, ...) return e.p_tmp.."/run", ... end
}

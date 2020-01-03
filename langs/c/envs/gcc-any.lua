local path = os.getenv("BL_GCC_PATH") or "gcc"

local f = io.popen(path.." --version")
local version = f:read("*a")
f:close()

return {
  version = 1,
  title = "GCC -?",
  description = [[
https://gcc.gnu.org/

Any custom flags allowed.

IMPL VARS:
- LIBS: GCC lib link flags
- OPTS: GCC options
  ]],
  host_info = version,
  build = function(e)
    return os.execute(path.." "..e.p_impl.." -o "..e.p_tmp.."/run "..(e.vars.LIBS or "").." "..(e.vars.OPTS or "")) == 0
  end,
  run_cmd = function(e, ...) return e.p_tmp.."/run", ... end
}

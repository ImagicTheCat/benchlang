
local c_path = os.getenv("MONO_MCS_PATH") or "mcs"
local r_path = os.getenv("MONO_PATH") or "mono"

local f = io.popen(c_path.." --version")
local info = f:read("*a")
f:close()

f = io.popen(r_path.." --version")
info = info.."\n"..f:read("*a")
f:close()

return {
  version = 1,
  title = "Mono (mcs)",
  description = [[
https://www.mono-project.com/

IMPL VARS:
- OPTS: build options (ex: -unsafe)
  ]],
  host_info = info,
  build = function(e)
    return os.execute(c_path.." "..(e.vars.OPTS or "").." -out:"..e.p_tmp.."/run "..e.p_impl) == 0
  end,
  run_cmd = function(e, ...) return r_path, e.p_tmp.."/run", ... end
}

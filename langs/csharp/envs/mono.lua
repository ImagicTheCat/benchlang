
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
- UNSAFE: yes/no, add runtime -unsafe option (default: no)
  ]],
  host_info = info,
  build = function(e)
    return os.execute(c_path.." -out:"..e.p_tmp.."/run "..e.p_impl) == 0
  end,
  run_cmd = function(e, ...) return r_path, e.vars.UNSAFE == "yes" and "-unsafe" or "", e.p_tmp.."/run", ... end
}

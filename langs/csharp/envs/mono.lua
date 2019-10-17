
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
  ]],
  host_info = info,
  build = function(impl_path, tmp_path)
    return os.execute(c_path.." -out:"..tmp_path.."/run "..impl_path) == 0
  end,
  run_cmd = function(impl_path, tmp_path, ...) return r_path, tmp_path.."/run", ... end
}

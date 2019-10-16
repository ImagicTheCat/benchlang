local path = os.getenv("GCC_PP_PATH") or "g++"

local f = io.popen(path.." --version")
local version = f:read("*a")
f:close()

return {
  version = 1,
  title = "GCC",
  description = [[
https://gcc.gnu.org/
  ]],
  host_info = version,
  build = function(impl_path, tmp_path)
    return os.execute(path.." "..impl_path.." -o "..tmp_path.."/run") == 0
  end,
  run_cmd = function(impl_path, tmp_path, ...) return tmp_path.."/run", ... end
}

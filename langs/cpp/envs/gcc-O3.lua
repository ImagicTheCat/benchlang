local path = os.getenv("GCC_PP_PATH") or "g++"

local f = io.popen(path.." --version")
local version = f:read("*a")
f:close()

return {
  version = 1,
  title = "GCC g++ -O3",
  description = [[
https://gcc.gnu.org/

Optimized.
  ]],
  host_info = version,
  build = function(impl_path, tmp_path)
    os.execute(path.." -O3 "..impl_path.." -o "..tmp_path.."/run")
    return true
  end,
  run_cmd = function(impl_path, tmp_path, ...) return tmp_path.."/run", ... end
}

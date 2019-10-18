local path = os.getenv("PYPY_PATH") or "pypy3"

local f = io.popen(path.." --version")
local version = f:read("*a")
f:close()

return {
  version = 1,
  title = "PyPy",
  description = [[
https://pypy.org/
  ]],
  host_info = version,
  build = function(e) return true end,
  run_cmd = function(e, ...) return path, e.p_impl, ... end
}

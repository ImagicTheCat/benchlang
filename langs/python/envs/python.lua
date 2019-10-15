local path = os.getenv("PYTHON_PATH") or "python"

local f = io.popen(path.." --version")
local version = f:read("*a")
f:close()

return {
  version = 1,
  title = "CPython",
  description = [[
https://www.python.org/
  ]],
  host_info = version,
  build = function(impl_path, tmp_path) return true end,
  run_cmd = function(impl_path, tmp_path, ...) return path, impl_path, ... end
}
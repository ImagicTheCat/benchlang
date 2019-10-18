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
  build = function(e) return true end,
  run_cmd = function(e, ...) return path, e.p_impl, ... end
}


local path = os.getenv("JULIA_PATH") or "julia"

local f = io.popen(path.." -v")
local version = f:read("*a")
f:close()

return {
  version = 1,
  title = "julia",
  description = [[
https://julialang.org/

Official implementation.
  ]],
  host_info = version,
  build = function(impl_path, tmp_path) return true end,
  run_cmd = function(impl_path, tmp_path, ...) return path, impl_path, ... end
}

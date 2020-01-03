
local path = os.getenv("BL_JULIA_PATH") or "julia"

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
  build = function(e) return true end,
  run_cmd = function(e, ...) return path, e.p_impl, ... end
}

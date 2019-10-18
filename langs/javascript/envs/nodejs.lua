local path = os.getenv("NODEJS_PATH") or "node"

local f = io.popen(path.." -v")
local version = f:read("*a")
f:close()

return {
  version = 1,
  title = "Node.js",
  description = [[
https://nodejs.org/
  ]],
  host_info = version,
  build = function(e) return true end,
  run_cmd = function(e, ...) return path, e.p_impl, ... end
}

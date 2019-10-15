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
  build = function(impl_path, tmp_path) return true end,
  run_cmd = function(impl_path, tmp_path, ...) return path, impl_path, ... end
}

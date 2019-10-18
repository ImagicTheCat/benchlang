
local path = os.getenv("PHP_PATH") or "php"

local f = io.popen(path.." -v")
local version = f:read("*a")
f:close()

return {
  version = 1,
  title = "CLI",
  description = [[
https://www.php.net/manual/en/features.commandline.php
  ]],
  host_info = version,
  build = function(e) return true end,
  run_cmd = function(e, ...) return path, e.p_impl, ... end
}

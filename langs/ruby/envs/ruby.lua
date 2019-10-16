
local path = os.getenv("RUBY_PATH") or "ruby"

local f = io.popen(path.." -v")
local version = f:read("*a")
f:close()

return {
  version = 1,
  title = "CRuby",
  description = [[
https://www.ruby-lang.org/

Official VM implementation (latest).
  ]],
  host_info = version,
  build = function(impl_path, tmp_path) return true end,
  run_cmd = function(impl_path, tmp_path, ...) return path, impl_path, ... end
}

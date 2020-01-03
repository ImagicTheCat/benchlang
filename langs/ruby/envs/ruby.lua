
local path = os.getenv("BL_RUBY_PATH") or "ruby"

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
  build = function(e) return true end,
  run_cmd = function(e, ...) return path, e.p_impl, ... end
}

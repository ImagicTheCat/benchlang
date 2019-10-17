local path = os.getenv("GO_PATH") or "go"

local f = io.popen(path.." version")
local version = f:read("*a")
f:close()

return {
  version = 1,
  title = "go",
  description = [[
https://golang.org/

Go tools.
  ]],
  host_info = version,
  build = function(impl_path, tmp_path)
    return os.execute(path.." tool compile -o "..tmp_path.."/go.o "..impl_path.." && go tool link -o "..tmp_path.."/run "..tmp_path.."/go.o") == 0
  end,
  run_cmd = function(impl_path, tmp_path, ...) return tmp_path.."/run", ... end
}

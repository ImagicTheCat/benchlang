local path = os.getenv("BL_GO_PATH") or "go"

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
  build = function(e)
    return os.execute(path.." tool compile -o "..e.p_tmp.."/go.o "..e.p_impl.." && go tool link -o "..e.p_tmp.."/run "..e.p_tmp.."/go.o") == 0
  end,
  run_cmd = function(e, ...) return e.p_tmp.."/run", ... end
}

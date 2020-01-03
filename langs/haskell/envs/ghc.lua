
local path = os.getenv("BL_GHC_PATH") or "ghc"

local f = io.popen(path.." --version")
local version = f:read("*a")
f:close()

return {
  version = 1,
  title = "GHC",
  description = [[
https://www.haskell.org/ghc/
  ]],
  host_info = version,
  build = function(e)
    return os.execute(path.." "..e.p_impl.." -o "..e.p_tmp.."/run") == 0
  end,
  run_cmd = function(e, ...) return e.p_tmp.."/run", ... end
}

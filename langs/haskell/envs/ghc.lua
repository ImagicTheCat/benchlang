
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
    if os.execute("cp "..e.p_impl.." "..e.p_tmp.."/source.hs") == 0 then -- copy
      return os.execute(path.." "..e.p_tmp.."/source.hs -o "..e.p_tmp.."/run") == 0
    end
  end,
  run_cmd = function(e, ...) return e.p_tmp.."/run", ... end
}

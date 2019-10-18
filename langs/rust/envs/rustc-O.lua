
local path = os.getenv("RUSTC_PATH") or "rustc"

local f = io.popen(path.." --version")
local version = f:read("*a")
f:close()

return {
  version = 1,
  title = "rustc -O",
  description = [[
https://doc.rust-lang.org/rustc/what-is-rustc.html

Speed optimizations.
  ]],
  host_info = version,
  build = function(e)
    return os.execute(path.." -O "..e.p_impl.." -o "..e.p_tmp.."/run") == 0
  end,
  run_cmd = function(e, ...) return e.p_tmp.."/run", ... end
}

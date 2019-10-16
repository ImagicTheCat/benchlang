
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
  build = function(impl_path, tmp_path)
    return os.execute(path.." -O "..impl_path.." -o "..tmp_path.."/run") == 0
  end,
  run_cmd = function(impl_path, tmp_path, ...) return tmp_path.."/run", ... end
}

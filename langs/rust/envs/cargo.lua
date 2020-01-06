local path = os.getenv("BL_CARGO_PATH") or "cargo"

local f = io.popen(path.." --version")
local version = f:read("*a")
f:close()

return {
  version = 1,
  title = "Cargo",
  description = [[
https://doc.rust-lang.org/rustc/what-is-rustc.html

IMPL VARS:
- DEPS: Cargo dependencies list (same format as Cargo.toml)
  ]],
  host_info = version,
  build = function(e)
    -- prepare cargo build
    if os.execute("mkdir -p "..e.p_tmp.."/src") ~= 0 then return end
    --- write main
    if os.execute("cp "..e.p_impl.." "..e.p_tmp.."/src/main.rs") ~= 0 then return end

    --- write Cargo.toml
    local f = io.open(e.p_tmp.."/Cargo.toml", "w")
    if f then
      -- write package header
      f:write([=[[package]
name = "benchlang"
version = "1.0.0"
authors = ["benchlang"]

[dependencies]
]=])

      -- write dependencies
      for dep in string.gmatch(e.vars.DEPS or "", "([^\n\r]+)") do
        f:write(dep.."\n")
      end

      f:close()
    end

    -- build
    return os.execute("(cd "..e.p_tmp.." && cargo build)") == 0
  end,
  run_cmd = function(e, ...) return e.p_tmp.."/target/debug/benchlang", ... end
}

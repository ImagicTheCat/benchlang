
local path = os.getenv("OCAMLOPT_PATH") or "ocamlopt"

local f = io.popen(path.." -v")
local info = f:read("*a")
f:close()

return {
  version = 1,
  title = "ocamlopt",
  description = [[
https://ocaml.org/

OCaml native compiler.
  ]],
  host_info = info,
  build = function(e)
    if os.execute("cp "..e.p_impl.." "..e.p_tmp.."/source.ml") == 0 then -- copy
      return os.execute("(cd "..e.p_tmp.." && "..path.." source.ml -o run)") == 0
    end
  end,
  run_cmd = function(e, ...) return e.p_tmp.."/run", ... end
}

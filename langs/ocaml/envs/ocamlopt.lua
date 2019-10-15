
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
  build = function(impl_path, tmp_path)
    if os.execute("cp "..impl_path.." "..tmp_path.."/source.ml") == 0 then -- copy
      return os.execute("(cd "..tmp_path.." && "..path.." source.ml -o run)") == 0
    end
  end,
  run_cmd = function(impl_path, tmp_path, ...) return tmp_path.."/run", ... end
}

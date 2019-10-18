local p_ocamlc = os.getenv("OCAMLC_PATH") or "ocamlc"
local p_ocamlrun = os.getenv("OCAMLRUN_PATH") or "ocamlrun"

local f = io.popen(p_ocamlc.." -v")
local info = f:read("*a")
f:close()

f = io.popen(p_ocamlrun.." -version")
local info = info.."\n"..f:read("*a")
f:close()

return {
  version = 1,
  title = "ocamlrun",
  description = [[
https://ocaml.org/

OCaml bytecode interpreter.
  ]],
  host_info = info,
  build = function(e)
    if os.execute("cp "..e.p_impl.." "..e.p_tmp.."/source.ml") == 0 then -- copy
      return os.execute("(cd "..e.p_tmp.." && "..p_ocamlc.." source.ml -o run)") == 0
    end
  end,
  run_cmd = function(e, ...) return p_ocamlrun, e.p_tmp.."/run", ... end
}

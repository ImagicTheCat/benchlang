
local p_javac = os.getenv("OPENJDK_JAVAC_PATH") or "javac"
local p_java = os.getenv("OPENJDK_JAVA_PATH") or "java"

local f = io.popen(p_javac.." -version 2>&1")
local info = f:read("*a")
f:close()

f = io.popen(p_java.." -version 2>&1")
local info = info.."\n"..f:read("*a")
f:close()


return {
  version = 1,
  title = "OpenJDK",
  description = [[
https://openjdk.java.net/

IMPL VARS:
- CLASS: Java class to run (default: benchlang)
  ]],
  host_info = info,
  build = function(e)
    if os.execute("cp "..e.p_impl.." "..e.p_tmp.."/source.java") == 0 then -- copy file
      return os.execute(p_javac.." "..e.p_tmp.."/source.java") == 0 -- compile
    end
  end,
  run_cmd = function(e, ...) return p_java, "-cp", e.p_tmp, e.vars.CLASS or "benchlang", ... end
}

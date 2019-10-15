
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
  ]],
  host_info = info,
  build = function(impl_path, tmp_path)
    if os.execute("cp "..impl_path.." "..tmp_path.."/benchlang.java") == 0 then -- copy file
      return os.execute(p_javac.." "..tmp_path.."/benchlang.java") == 0 -- compile
    end

    return false
  end,
  run_cmd = function(impl_path, tmp_path, ...) return p_java, "-cp", tmp_path, "benchlang", ... end
}

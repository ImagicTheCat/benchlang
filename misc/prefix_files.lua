-- Lua 5.1
-- prefix files with one
-- ex usage: LICENSE.txt <files...>
local pf = io.open(arg[1], "r")
local pdata = pf:read("*a")
pf:close()

for i=2,#arg do
  local f = io.open(arg[i], "r")
  if f then
    -- read
    local data = f:read("*a")
    f:close()

    -- write
    f = io.open(arg[i], "w")
    f:write(pdata..data)
    f:close()
  end
end

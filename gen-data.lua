-- require LuaJIT
-- generate some data files

local sha2 = require("extern.sha2.sha2")

-- DEF

-- path: output file path
-- seed: number
-- size: bytes
-- hash: (optional) hash check (lowercase hex)
local function gen_file(path, seed, size, hash)
  local f = io.open(path, "wb")
  if f then
    for i=1,size do
      f:write(string.char(math.random(0,255)))
    end
    f:close()


    if hash then -- check
      local hasher = sha2.sha256()

      f = io.open(path, "rb")
      if f then
        local data = f:read(4096)
        while data do
          hasher(data)
          data = f:read(4096)
        end

        local fhash = hasher()
        if fhash ~= hash then error("invalid generated hash: "..path) end
      else
        error("couldn't check "..path)
      end
    end
  else
    error("couldn't write "..path)
  end
end

-- DO

os.execute("mkdir -p data")
gen_file("data/random-1MiB-79421.data", 79421, 2^20, "60a4ce407e3bbedb5ab9d6fad9704d48fe5f72e5d2e9341b2553ef5474d44b89")

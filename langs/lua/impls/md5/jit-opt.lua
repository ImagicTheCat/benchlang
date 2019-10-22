--[[
MIT License

Copyright (c) 2019 ImagicTheCat

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

-- contributed by Imagic for LuaJIT based on https://tools.ietf.org/html/rfc1321
-- more optimized version of jit.lua (may evolve)

local bit = require("bit")
local band, rshift, bnot, bor, bxor, rol, lshift, tobit = bit.band, bit.rshift, bit.bnot, bit.bor, bit.bxor, bit.rol, bit.lshift, bit.tobit
local math_floor, string_byte, string_len, string_sub = math.floor, string.byte, string.len, string.sub

local function word2str(w)
  return string.char(
    band(w, 0xff),
    band(rshift(w, 8), 0xff),
    band(rshift(w, 16), 0xff),
    band(rshift(w, 24), 0xff)
  )
end

local function str2word(str, index)
  local b1,b2,b3,b4 = string_byte(str, index, index+3)
  return lshift(b4,24)+lshift(b3,16)+lshift(b2,8)+b1
end

-- ops
local function F(x,y,z) return bor(band(x,y), band(bnot(x), z)) end
local function G(x,y,z) return bor(band(x,z), band(y, bnot(z))) end
local function H(x,y,z) return bxor(x,y,z) end
local function I(x,y,z) return bxor(y, bor(x, bnot(z))) end

-- rounds
local function RF(a,b,c,d,x,s,k) return b+rol(a+F(b,c,d)+x+k, s) end
local function RG(a,b,c,d,x,s,k) return b+rol(a+G(b,c,d)+x+k, s) end
local function RH(a,b,c,d,x,s,k) return b+rol(a+H(b,c,d)+x+k, s) end
local function RI(a,b,c,d,x,s,k) return b+rol(a+I(b,c,d)+x+k, s) end

local consts = { -- X index, k
   0, 0xd76aa478,
   1, 0xe8c7b756,
   2, 0x242070db,
   3, 0xc1bdceee,
   4, 0xf57c0faf,
   5, 0x4787c62a,
   6, 0xa8304613,
   7, 0xfd469501,
   8, 0x698098d8,
   9, 0x8b44f7af,
  10, 0xffff5bb1,
  11, 0x895cd7be,
  12, 0x6b901122,
  13, 0xfd987193,
  14, 0xa679438e,
  15, 0x49b40821,

   1, 0xf61e2562,
   6, 0xc040b340,
  11, 0x265e5a51,
   0, 0xe9b6c7aa,
   5, 0xd62f105d,
  10, 0x2441453,
  15, 0xd8a1e681,
   4, 0xe7d3fbc8,
   9, 0x21e1cde6,
  14, 0xc33707d6,
   3, 0xf4d50d87,
   8, 0x455a14ed,
  13, 0xa9e3e905,
   2, 0xfcefa3f8,
   7, 0x676f02d9,
  12, 0x8d2a4c8a,

   5, 0xfffa3942,
   8, 0x8771f681,
  11, 0x6d9d6122,
  14, 0xfde5380c,
   1, 0xa4beea44,
   4, 0x4bdecfa9,
   7, 0xf6bb4b60,
  10, 0xbebfbc70,
  13, 0x289b7ec6,
   0, 0xeaa127fa,
   3, 0xd4ef3085,
   6, 0x4881d05,
   9, 0xd9d4d039,
  12, 0xe6db99e5,
  15, 0x1fa27cf8,
   2, 0xc4ac5665,

   0, 0xf4292244,
   7, 0x432aff97,
  14, 0xab9423a7,
   5, 0xfc93a039,
  12, 0x655b59c3,
   3, 0x8f0ccc92,
  10, 0xffeff47d,
   1, 0x85845dd1,
   8, 0x6fa87e4f,
  15, 0xfe2ce6e0,
   6, 0xa3014314,
  13, 0x4e0811a1,
   4, 0xf7537e82,
  11, 0xbd3af235,
   2, 0x2ad7d2bb,
   9, 0xeb86d391
}

local round_params = {
  {RF, 7, 12, 17, 22},
  {RG, 5, 9, 14, 20},
  {RH, 4, 11, 16, 23},
  {RI, 6, 10, 15, 21}
}

local function process_block(self, X)
  local a,b,c,d = self.a,self.b,self.c,self.d
  
  local ci = 0 -- consts index

  for r=1,4 do
    for i=1,4 do
      local R = round_params[r]
      a = R[1](a, b, c, d, X[consts[ci*2+1]], R[2], consts[ci*2+2]) 
      d = R[1](d, a, b, c, X[consts[(ci+1)*2+1]], R[3], consts[(ci+1)*2+2]) 
      c = R[1](c, d, a, b, X[consts[(ci+2)*2+1]], R[4], consts[(ci+2)*2+2]) 
      b = R[1](b, c, d, a, X[consts[(ci+3)*2+1]], R[5], consts[(ci+3)*2+2]) 
      ci = ci+4
    end
  end

  self.a = tobit(self.a+a)
  self.b = tobit(self.b+b)
  self.c = tobit(self.c+c)
  self.d = tobit(self.d+d)
end

local function append(self, data)
  local buffer = self.buffer..data
  local X = {}
  local blocks = math_floor(string_len(buffer)/64)
  for i=1,blocks do
    for j=0,15 do
      X[j] = str2word(buffer, (i-1)*64+j*4+1)
    end

    process_block(self, X)
  end

  self.buffer = string_sub(buffer, blocks*64+1) -- remainder
  self.size = self.size+string_len(data)
end

local function compute(self)
  -- compute padding
  local padding = (56-string.len(self.buffer))%64
  if padding == 0 then padding = 64 end

  self.buffer = self.buffer..string.char(128)..string.rep("\0", padding-1) -- padding
  self.buffer = self.buffer..word2str((self.size*8)%2^32)..word2str((self.size*8)/2^32) -- length

  -- process last block
  local X = {}
  for i=0,15 do
    X[i] = str2word(self.buffer, i*4+1)
  end

  process_block(self, X)

  -- hash
  return word2str(self.a)
    ..word2str(self.b)
    ..word2str(self.c)
    ..word2str(self.d)
end

local mt = {
  __index = {
    append = append,
    compute = compute
  }
}

local function new()
  return setmetatable({
    a = 0x67452301,
    b = 0xefcdab89,
    c = 0x98badcfe,
    d = 0x10325476,
    size = 0,
    buffer = ""
  }, mt)
end

-- helper
--[[
local function md5(str)
  local hasher = new()
  hasher:append(str)
  local hash = hasher:compute()
  local out = {}
  for i=1,string.len(hash) do
    table.insert(out, bit.tohex(string.byte(hash,i,i), 2))
  end
  return table.concat(out)
end
--]]

-- DO
local path, n = ...
n = tonumber(n)

local f = io.open(path, "rb")
if f then
  local data = f:read("*a")
  f:close()

  local hasher = new()
  for i=1,n do
    hasher:append(data)
  end

  io.write(hasher:compute())
end

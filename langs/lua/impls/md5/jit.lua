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

local function process_block(self, X)
  local a,b,c,d = self.a,self.b,self.c,self.d

  a = RF(a, b, c, d, X[ 0], 7, 0xd76aa478) 
  d = RF(d, a, b, c, X[ 1], 12, 0xe8c7b756) 
  c = RF(c, d, a, b, X[ 2], 17, 0x242070db) 
  b = RF(b, c, d, a, X[ 3], 22, 0xc1bdceee) 
  a = RF(a, b, c, d, X[ 4], 7, 0xf57c0faf) 
  d = RF(d, a, b, c, X[ 5], 12, 0x4787c62a) 
  c = RF(c, d, a, b, X[ 6], 17, 0xa8304613) 
  b = RF(b, c, d, a, X[ 7], 22, 0xfd469501) 
  a = RF(a, b, c, d, X[ 8], 7, 0x698098d8) 
  d = RF(d, a, b, c, X[ 9], 12, 0x8b44f7af) 
  c = RF(c, d, a, b, X[10], 17, 0xffff5bb1) 
  b = RF(b, c, d, a, X[11], 22, 0x895cd7be) 
  a = RF(a, b, c, d, X[12], 7, 0x6b901122) 
  d = RF(d, a, b, c, X[13], 12, 0xfd987193) 
  c = RF(c, d, a, b, X[14], 17, 0xa679438e) 
  b = RF(b, c, d, a, X[15], 22, 0x49b40821) 

  a = RG(a, b, c, d, X[ 1], 5, 0xf61e2562) 
  d = RG(d, a, b, c, X[ 6], 9, 0xc040b340) 
  c = RG(c, d, a, b, X[11], 14, 0x265e5a51) 
  b = RG(b, c, d, a, X[ 0], 20, 0xe9b6c7aa) 
  a = RG(a, b, c, d, X[ 5], 5, 0xd62f105d) 
  d = RG(d, a, b, c, X[10], 9,  0x2441453) 
  c = RG(c, d, a, b, X[15], 14, 0xd8a1e681) 
  b = RG(b, c, d, a, X[ 4], 20, 0xe7d3fbc8) 
  a = RG(a, b, c, d, X[ 9], 5, 0x21e1cde6) 
  d = RG(d, a, b, c, X[14], 9, 0xc33707d6) 
  c = RG(c, d, a, b, X[ 3], 14, 0xf4d50d87) 
  b = RG(b, c, d, a, X[ 8], 20, 0x455a14ed) 
  a = RG(a, b, c, d, X[13], 5, 0xa9e3e905) 
  d = RG(d, a, b, c, X[ 2], 9, 0xfcefa3f8) 
  c = RG(c, d, a, b, X[ 7], 14, 0x676f02d9) 
  b = RG(b, c, d, a, X[12], 20, 0x8d2a4c8a) 

  a = RH(a, b, c, d, X[ 5], 4, 0xfffa3942) 
  d = RH(d, a, b, c, X[ 8], 11, 0x8771f681) 
  c = RH(c, d, a, b, X[11], 16, 0x6d9d6122) 
  b = RH(b, c, d, a, X[14], 23, 0xfde5380c) 
  a = RH(a, b, c, d, X[ 1], 4, 0xa4beea44) 
  d = RH(d, a, b, c, X[ 4], 11, 0x4bdecfa9) 
  c = RH(c, d, a, b, X[ 7], 16, 0xf6bb4b60) 
  b = RH(b, c, d, a, X[10], 23, 0xbebfbc70) 
  a = RH(a, b, c, d, X[13], 4, 0x289b7ec6) 
  d = RH(d, a, b, c, X[ 0], 11, 0xeaa127fa) 
  c = RH(c, d, a, b, X[ 3], 16, 0xd4ef3085) 
  b = RH(b, c, d, a, X[ 6], 23,  0x4881d05) 
  a = RH(a, b, c, d, X[ 9], 4, 0xd9d4d039) 
  d = RH(d, a, b, c, X[12], 11, 0xe6db99e5) 
  c = RH(c, d, a, b, X[15], 16, 0x1fa27cf8) 
  b = RH(b, c, d, a, X[ 2], 23, 0xc4ac5665) 

  a = RI(a, b, c, d, X[ 0], 6, 0xf4292244) 
  d = RI(d, a, b, c, X[ 7], 10, 0x432aff97) 
  c = RI(c, d, a, b, X[14], 15, 0xab9423a7) 
  b = RI(b, c, d, a, X[ 5], 21, 0xfc93a039) 
  a = RI(a, b, c, d, X[12], 6, 0x655b59c3) 
  d = RI(d, a, b, c, X[ 3], 10, 0x8f0ccc92) 
  c = RI(c, d, a, b, X[10], 15, 0xffeff47d) 
  b = RI(b, c, d, a, X[ 1], 21, 0x85845dd1) 
  a = RI(a, b, c, d, X[ 8], 6, 0x6fa87e4f) 
  d = RI(d, a, b, c, X[15], 10, 0xfe2ce6e0) 
  c = RI(c, d, a, b, X[ 6], 15, 0xa3014314) 
  b = RI(b, c, d, a, X[13], 21, 0x4e0811a1) 
  a = RI(a, b, c, d, X[ 4], 6, 0xf7537e82) 
  d = RI(d, a, b, c, X[11], 10, 0xbd3af235) 
  c = RI(c, d, a, b, X[ 2], 15, 0x2ad7d2bb) 
  b = RI(b, c, d, a, X[ 9], 21, 0xeb86d391) 

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

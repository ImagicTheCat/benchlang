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
-- FFI/optimized version of jit.lua + jit-opt.lua

local bit = require("bit")
local ffi = require("ffi")
ffi.cdef([[
typedef union{
  int32_t i;
  char c[4];
} MD5_w; // word

typedef struct{
  MD5_w hash[4]; // hash
  MD5_w regs[4]; // registers
  MD5_w buffer[16]; // block buffer
  int buffer_size; // in bytes
  uint64_t size; // total processed data size in bytes
} MD5_state;
]])

local MD5_state = ffi.typeof("MD5_state")

local band, rshift, bnot, bor, bxor, rol, lshift, tobit = bit.band, bit.rshift, bit.bnot, bit.bor, bit.bxor, bit.rol, bit.lshift, bit.tobit
local math_floor, string_byte, string_len, string_sub = math.floor, string.byte, string.len, string.sub

-- detect endianness for int32_t
local i32_LE -- true if little endian
do
  local w = ffi.new("MD5_w")
  w.i = 0xff
  i32_LE = (w.c[0] ~= 0)
end

-- rounds
local function RF(a,b,c,d,x,s,k) return b+rol(a+(bor(band(b,c), band(bnot(b), d)))+x+k, s) end
local function RG(a,b,c,d,x,s,k) return b+rol(a+(bor(band(b,d), band(c, bnot(d))))+x+k, s) end
local function RH(a,b,c,d,x,s,k) return b+rol(a+(bxor(b,c,d))+x+k, s) end
local function RI(a,b,c,d,x,s,k) return b+rol(a+(bxor(c, bor(b, bnot(d))))+x+k, s) end


local function process_block(self)
  local regs = self.regs
  local X = self.buffer

  regs[0].i = self.hash[0].i
  regs[1].i = self.hash[1].i
  regs[2].i = self.hash[2].i
  regs[3].i = self.hash[3].i

  regs[0].i = tobit(RF(regs[0].i, regs[1].i, regs[2].i, regs[3].i, X[ 0].i, 7, 0xd76aa478)) 
  regs[3].i = tobit(RF(regs[3].i, regs[0].i, regs[1].i, regs[2].i, X[ 1].i, 12, 0xe8c7b756)) 
  regs[2].i = tobit(RF(regs[2].i, regs[3].i, regs[0].i, regs[1].i, X[ 2].i, 17, 0x242070db)) 
  regs[1].i = tobit(RF(regs[1].i, regs[2].i, regs[3].i, regs[0].i, X[ 3].i, 22, 0xc1bdceee)) 
  regs[0].i = tobit(RF(regs[0].i, regs[1].i, regs[2].i, regs[3].i, X[ 4].i, 7, 0xf57c0faf)) 
  regs[3].i = tobit(RF(regs[3].i, regs[0].i, regs[1].i, regs[2].i, X[ 5].i, 12, 0x4787c62a)) 
  regs[2].i = tobit(RF(regs[2].i, regs[3].i, regs[0].i, regs[1].i, X[ 6].i, 17, 0xa8304613)) 
  regs[1].i = tobit(RF(regs[1].i, regs[2].i, regs[3].i, regs[0].i, X[ 7].i, 22, 0xfd469501)) 
  regs[0].i = tobit(RF(regs[0].i, regs[1].i, regs[2].i, regs[3].i, X[ 8].i, 7, 0x698098d8)) 
  regs[3].i = tobit(RF(regs[3].i, regs[0].i, regs[1].i, regs[2].i, X[ 9].i, 12, 0x8b44f7af)) 
  regs[2].i = tobit(RF(regs[2].i, regs[3].i, regs[0].i, regs[1].i, X[10].i, 17, 0xffff5bb1)) 
  regs[1].i = tobit(RF(regs[1].i, regs[2].i, regs[3].i, regs[0].i, X[11].i, 22, 0x895cd7be)) 
  regs[0].i = tobit(RF(regs[0].i, regs[1].i, regs[2].i, regs[3].i, X[12].i, 7, 0x6b901122)) 
  regs[3].i = tobit(RF(regs[3].i, regs[0].i, regs[1].i, regs[2].i, X[13].i, 12, 0xfd987193)) 
  regs[2].i = tobit(RF(regs[2].i, regs[3].i, regs[0].i, regs[1].i, X[14].i, 17, 0xa679438e)) 
  regs[1].i = tobit(RF(regs[1].i, regs[2].i, regs[3].i, regs[0].i, X[15].i, 22, 0x49b40821)) 

  regs[0].i = tobit(RG(regs[0].i, regs[1].i, regs[2].i, regs[3].i, X[ 1].i, 5, 0xf61e2562)) 
  regs[3].i = tobit(RG(regs[3].i, regs[0].i, regs[1].i, regs[2].i, X[ 6].i, 9, 0xc040b340)) 
  regs[2].i = tobit(RG(regs[2].i, regs[3].i, regs[0].i, regs[1].i, X[11].i, 14, 0x265e5a51)) 
  regs[1].i = tobit(RG(regs[1].i, regs[2].i, regs[3].i, regs[0].i, X[ 0].i, 20, 0xe9b6c7aa)) 
  regs[0].i = tobit(RG(regs[0].i, regs[1].i, regs[2].i, regs[3].i, X[ 5].i, 5, 0xd62f105d)) 
  regs[3].i = tobit(RG(regs[3].i, regs[0].i, regs[1].i, regs[2].i, X[10].i, 9,  0x2441453)) 
  regs[2].i = tobit(RG(regs[2].i, regs[3].i, regs[0].i, regs[1].i, X[15].i, 14, 0xd8a1e681)) 
  regs[1].i = tobit(RG(regs[1].i, regs[2].i, regs[3].i, regs[0].i, X[ 4].i, 20, 0xe7d3fbc8)) 
  regs[0].i = tobit(RG(regs[0].i, regs[1].i, regs[2].i, regs[3].i, X[ 9].i, 5, 0x21e1cde6)) 
  regs[3].i = tobit(RG(regs[3].i, regs[0].i, regs[1].i, regs[2].i, X[14].i, 9, 0xc33707d6)) 
  regs[2].i = tobit(RG(regs[2].i, regs[3].i, regs[0].i, regs[1].i, X[ 3].i, 14, 0xf4d50d87)) 
  regs[1].i = tobit(RG(regs[1].i, regs[2].i, regs[3].i, regs[0].i, X[ 8].i, 20, 0x455a14ed)) 
  regs[0].i = tobit(RG(regs[0].i, regs[1].i, regs[2].i, regs[3].i, X[13].i, 5, 0xa9e3e905)) 
  regs[3].i = tobit(RG(regs[3].i, regs[0].i, regs[1].i, regs[2].i, X[ 2].i, 9, 0xfcefa3f8)) 
  regs[2].i = tobit(RG(regs[2].i, regs[3].i, regs[0].i, regs[1].i, X[ 7].i, 14, 0x676f02d9)) 
  regs[1].i = tobit(RG(regs[1].i, regs[2].i, regs[3].i, regs[0].i, X[12].i, 20, 0x8d2a4c8a)) 

  regs[0].i = tobit(RH(regs[0].i, regs[1].i, regs[2].i, regs[3].i, X[ 5].i, 4, 0xfffa3942)) 
  regs[3].i = tobit(RH(regs[3].i, regs[0].i, regs[1].i, regs[2].i, X[ 8].i, 11, 0x8771f681)) 
  regs[2].i = tobit(RH(regs[2].i, regs[3].i, regs[0].i, regs[1].i, X[11].i, 16, 0x6d9d6122)) 
  regs[1].i = tobit(RH(regs[1].i, regs[2].i, regs[3].i, regs[0].i, X[14].i, 23, 0xfde5380c)) 
  regs[0].i = tobit(RH(regs[0].i, regs[1].i, regs[2].i, regs[3].i, X[ 1].i, 4, 0xa4beea44)) 
  regs[3].i = tobit(RH(regs[3].i, regs[0].i, regs[1].i, regs[2].i, X[ 4].i, 11, 0x4bdecfa9)) 
  regs[2].i = tobit(RH(regs[2].i, regs[3].i, regs[0].i, regs[1].i, X[ 7].i, 16, 0xf6bb4b60)) 
  regs[1].i = tobit(RH(regs[1].i, regs[2].i, regs[3].i, regs[0].i, X[10].i, 23, 0xbebfbc70)) 
  regs[0].i = tobit(RH(regs[0].i, regs[1].i, regs[2].i, regs[3].i, X[13].i, 4, 0x289b7ec6)) 
  regs[3].i = tobit(RH(regs[3].i, regs[0].i, regs[1].i, regs[2].i, X[ 0].i, 11, 0xeaa127fa)) 
  regs[2].i = tobit(RH(regs[2].i, regs[3].i, regs[0].i, regs[1].i, X[ 3].i, 16, 0xd4ef3085)) 
  regs[1].i = tobit(RH(regs[1].i, regs[2].i, regs[3].i, regs[0].i, X[ 6].i, 23,  0x4881d05)) 
  regs[0].i = tobit(RH(regs[0].i, regs[1].i, regs[2].i, regs[3].i, X[ 9].i, 4, 0xd9d4d039)) 
  regs[3].i = tobit(RH(regs[3].i, regs[0].i, regs[1].i, regs[2].i, X[12].i, 11, 0xe6db99e5)) 
  regs[2].i = tobit(RH(regs[2].i, regs[3].i, regs[0].i, regs[1].i, X[15].i, 16, 0x1fa27cf8)) 
  regs[1].i = tobit(RH(regs[1].i, regs[2].i, regs[3].i, regs[0].i, X[ 2].i, 23, 0xc4ac5665)) 

  regs[0].i = tobit(RI(regs[0].i, regs[1].i, regs[2].i, regs[3].i, X[ 0].i, 6, 0xf4292244)) 
  regs[3].i = tobit(RI(regs[3].i, regs[0].i, regs[1].i, regs[2].i, X[ 7].i, 10, 0x432aff97)) 
  regs[2].i = tobit(RI(regs[2].i, regs[3].i, regs[0].i, regs[1].i, X[14].i, 15, 0xab9423a7)) 
  regs[1].i = tobit(RI(regs[1].i, regs[2].i, regs[3].i, regs[0].i, X[ 5].i, 21, 0xfc93a039)) 
  regs[0].i = tobit(RI(regs[0].i, regs[1].i, regs[2].i, regs[3].i, X[12].i, 6, 0x655b59c3)) 
  regs[3].i = tobit(RI(regs[3].i, regs[0].i, regs[1].i, regs[2].i, X[ 3].i, 10, 0x8f0ccc92)) 
  regs[2].i = tobit(RI(regs[2].i, regs[3].i, regs[0].i, regs[1].i, X[10].i, 15, 0xffeff47d)) 
  regs[1].i = tobit(RI(regs[1].i, regs[2].i, regs[3].i, regs[0].i, X[ 1].i, 21, 0x85845dd1)) 
  regs[0].i = tobit(RI(regs[0].i, regs[1].i, regs[2].i, regs[3].i, X[ 8].i, 6, 0x6fa87e4f)) 
  regs[3].i = tobit(RI(regs[3].i, regs[0].i, regs[1].i, regs[2].i, X[15].i, 10, 0xfe2ce6e0)) 
  regs[2].i = tobit(RI(regs[2].i, regs[3].i, regs[0].i, regs[1].i, X[ 6].i, 15, 0xa3014314)) 
  regs[1].i = tobit(RI(regs[1].i, regs[2].i, regs[3].i, regs[0].i, X[13].i, 21, 0x4e0811a1)) 
  regs[0].i = tobit(RI(regs[0].i, regs[1].i, regs[2].i, regs[3].i, X[ 4].i, 6, 0xf7537e82)) 
  regs[3].i = tobit(RI(regs[3].i, regs[0].i, regs[1].i, regs[2].i, X[11].i, 10, 0xbd3af235)) 
  regs[2].i = tobit(RI(regs[2].i, regs[3].i, regs[0].i, regs[1].i, X[ 2].i, 15, 0x2ad7d2bb)) 
  regs[1].i = tobit(RI(regs[1].i, regs[2].i, regs[3].i, regs[0].i, X[ 9].i, 21, 0xeb86d391)) 

  self.hash[0].i = tobit(self.hash[0].i+regs[0].i)
  self.hash[1].i = tobit(self.hash[1].i+regs[1].i)
  self.hash[2].i = tobit(self.hash[2].i+regs[2].i)
  self.hash[3].i = tobit(self.hash[3].i+regs[3].i)
end

-- add any multiple of bytes to the word buffer
local function buffer_append(self, cdata, index, size)
  local buf = self.buffer
  local buf_size = self.buffer_size
  if i32_LE then
    for i=0,size-1 do
      buf[math_floor((buf_size+i)/4)].c[(buf_size+i)%4] = cdata[index+i]
    end
  else
    for i=0,size-1 do
      buf[math_floor((buf_size+i)/4)].c[3-(buf_size+i)%4] = cdata[index+i]
    end
  end

  self.buffer_size = buf_size+size
end

-- fill a complete buffer block (no size update)
local function buffer_fill(self, cdata, index)
  if i32_LE then
    for i=0,15 do
      self.buffer[i].c[0] = cdata[index+i*4]
      self.buffer[i].c[1] = cdata[index+i*4+1]
      self.buffer[i].c[2] = cdata[index+i*4+2]
      self.buffer[i].c[3] = cdata[index+i*4+3]
    end
  else
    for i=0,15 do
      self.buffer[i].c[0] = cdata[index+i*4+3]
      self.buffer[i].c[1] = cdata[index+i*4+2]
      self.buffer[i].c[2] = cdata[index+i*4+1]
      self.buffer[i].c[3] = cdata[index+i*4]
    end
  end
end

local function append(self, data)
  local cdata = ffi.cast("const char*", data)
  local cdata_size = string_len(data)

  -- try to complete buffer
  local offset = math.min(64-self.buffer_size, cdata_size)
  buffer_append(self, cdata, 0, offset)

  if self.buffer_size == 64 then
    -- process completed block
    process_block(self)

    -- process next blocks
    local blocks = math_floor((cdata_size-offset)/64)
    for i=0,blocks-1 do -- each MD5 block
      buffer_fill(self, cdata, offset+i*64)
      process_block(self)
    end

    -- append remainder to buffer
    self.buffer_size = 0
    buffer_append(self, cdata, offset+blocks*64, cdata_size-(offset+blocks*64))
  end

  self.size = self.size+cdata_size
end

local padding_data = ffi.new("char[64]", string.char(128)..string.rep("\0", 63))

local function compute(self)
  -- compute padding
  local padding = (56-self.buffer_size)%64
  if padding == 0 then padding = 64 end

  buffer_append(self, padding_data, 0, padding) -- padding

  -- append length
  self.buffer[14].i = tobit(tonumber((self.size*8)%2^32))
  self.buffer[15].i = tobit(tonumber((self.size*8)/2^32))

  -- process last block
  process_block(self)

  -- hash
  if i32_LE then
    return ffi.string(self.hash[0].c, 4)
      ..ffi.string(self.hash[1].c, 4)
      ..ffi.string(self.hash[2].c, 4)
      ..ffi.string(self.hash[3].c, 4)
  else
    return string.reverse(ffi.string(self.hash[0].c, 4))
      ..string.reverse(ffi.string(self.hash[1].c, 4))
      ..string.reverse(ffi.string(self.hash[2].c, 4))
      ..string.reverse(ffi.string(self.hash[3].c, 4))
  end
end

local function init(self)
  self.hash[0].i = tobit(0x67452301)
  self.hash[1].i = tobit(0xefcdab89)
  self.hash[2].i = tobit(0x98badcfe)
  self.hash[3].i = tobit(0x10325476)
  self.size = 0
  self.buffer_size = 0
end

ffi.metatype(MD5_state, {
  __index = {
    init = init,
    append = append,
    compute = compute
  }
})

-- helper
--[[
local function md5(str)
  local hasher = MD5_state()
  hasher:init()

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

  local hasher = MD5_state()
  hasher:init()

  for i=1,n do
    hasher:append(data)
  end

  io.write(hasher:compute())
end

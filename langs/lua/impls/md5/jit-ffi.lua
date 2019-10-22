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
-- FFI/optimized version of jit.lua (may evolve)

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

typedef struct{
  int a,b,c,d,x,s;
  int32_t k;
} MD5_it; // iteration data
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

-- consts
local K = ffi.new("const MD5_it[64]", {
  {0, 1, 2, 3,  0, 7, tobit(0xd76aa478)},
  {3, 0, 1, 2,  1, 12, tobit(0xe8c7b756)},
  {2, 3, 0, 1,  2, 17, tobit(0x242070db)},
  {1, 2, 3, 0,  3, 22, tobit(0xc1bdceee)},
  {0, 1, 2, 3,  4, 7, tobit(0xf57c0faf)},
  {3, 0, 1, 2,  5, 12, tobit(0x4787c62a)},
  {2, 3, 0, 1,  6, 17, tobit(0xa8304613)},
  {1, 2, 3, 0,  7, 22, tobit(0xfd469501)},
  {0, 1, 2, 3,  8, 7, tobit(0x698098d8)},
  {3, 0, 1, 2,  9, 12, tobit(0x8b44f7af)},
  {2, 3, 0, 1, 10, 17, tobit(0xffff5bb1)},
  {1, 2, 3, 0, 11, 22, tobit(0x895cd7be)},
  {0, 1, 2, 3, 12, 7, tobit(0x6b901122)},
  {3, 0, 1, 2, 13, 12, tobit(0xfd987193)},
  {2, 3, 0, 1, 14, 17, tobit(0xa679438e)},
  {1, 2, 3, 0, 15, 22, tobit(0x49b40821)},

  {0, 1, 2, 3,  1, 5, tobit(0xf61e2562)},
  {3, 0, 1, 2,  6, 9, tobit(0xc040b340)},
  {2, 3, 0, 1, 11, 14, tobit(0x265e5a51)},
  {1, 2, 3, 0,  0, 20, tobit(0xe9b6c7aa)},
  {0, 1, 2, 3,  5, 5, tobit(0xd62f105d)},
  {3, 0, 1, 2, 10, 9,  tobit(0x2441453)},
  {2, 3, 0, 1, 15, 14, tobit(0xd8a1e681)},
  {1, 2, 3, 0,  4, 20, tobit(0xe7d3fbc8)},
  {0, 1, 2, 3,  9, 5, tobit(0x21e1cde6)},
  {3, 0, 1, 2, 14, 9, tobit(0xc33707d6)},
  {2, 3, 0, 1,  3, 14, tobit(0xf4d50d87)},
  {1, 2, 3, 0,  8, 20, tobit(0x455a14ed)},
  {0, 1, 2, 3, 13, 5, tobit(0xa9e3e905)},
  {3, 0, 1, 2,  2, 9, tobit(0xfcefa3f8)},
  {2, 3, 0, 1,  7, 14, tobit(0x676f02d9)},
  {1, 2, 3, 0, 12, 20, tobit(0x8d2a4c8a)},

  {0, 1, 2, 3,  5, 4, tobit(0xfffa3942)},
  {3, 0, 1, 2,  8, 11, tobit(0x8771f681)},
  {2, 3, 0, 1, 11, 16, tobit(0x6d9d6122)},
  {1, 2, 3, 0, 14, 23, tobit(0xfde5380c)},
  {0, 1, 2, 3,  1, 4, tobit(0xa4beea44)},
  {3, 0, 1, 2,  4, 11, tobit(0x4bdecfa9)},
  {2, 3, 0, 1,  7, 16, tobit(0xf6bb4b60)},
  {1, 2, 3, 0, 10, 23, tobit(0xbebfbc70)},
  {0, 1, 2, 3, 13, 4, tobit(0x289b7ec6)},
  {3, 0, 1, 2,  0, 11, tobit(0xeaa127fa)},
  {2, 3, 0, 1,  3, 16, tobit(0xd4ef3085)},
  {1, 2, 3, 0,  6, 23,  tobit(0x4881d05)},
  {0, 1, 2, 3,  9, 4, tobit(0xd9d4d039)},
  {3, 0, 1, 2, 12, 11, tobit(0xe6db99e5)},
  {2, 3, 0, 1, 15, 16, tobit(0x1fa27cf8)},
  {1, 2, 3, 0,  2, 23, tobit(0xc4ac5665)},

  {0, 1, 2, 3,  0, 6, tobit(0xf4292244)},
  {3, 0, 1, 2,  7, 10, tobit(0x432aff97)},
  {2, 3, 0, 1, 14, 15, tobit(0xab9423a7)},
  {1, 2, 3, 0,  5, 21, tobit(0xfc93a039)},
  {0, 1, 2, 3, 12, 6, tobit(0x655b59c3)},
  {3, 0, 1, 2,  3, 10, tobit(0x8f0ccc92)},
  {2, 3, 0, 1, 10, 15, tobit(0xffeff47d)},
  {1, 2, 3, 0,  1, 21, tobit(0x85845dd1)},
  {0, 1, 2, 3,  8, 6, tobit(0x6fa87e4f)},
  {3, 0, 1, 2, 15, 10, tobit(0xfe2ce6e0)},
  {2, 3, 0, 1,  6, 15, tobit(0xa3014314)},
  {1, 2, 3, 0, 13, 21, tobit(0x4e0811a1)},
  {0, 1, 2, 3,  4, 6, tobit(0xf7537e82)},
  {3, 0, 1, 2, 11, 10, tobit(0xbd3af235)},
  {2, 3, 0, 1,  2, 15, tobit(0x2ad7d2bb)},
  {1, 2, 3, 0,  9, 21, tobit(0xeb86d391)}
})

local rounds = {RF, RG, RH, RI}

local function process_block(self)
  self.regs[0].i = self.hash[0].i
  self.regs[1].i = self.hash[1].i
  self.regs[2].i = self.hash[2].i
  self.regs[3].i = self.hash[3].i

  for i=0,63 do -- perform MD5 iterations
    self.regs[K[i].a].i = tobit(rounds[rshift(i, 4)+1](
      self.regs[K[i].a].i,
      self.regs[K[i].b].i,
      self.regs[K[i].c].i,
      self.regs[K[i].d].i,
      self.buffer[K[i].x].i,
      K[i].s,
      K[i].k
    ))
  end

  self.hash[0].i = tobit(self.hash[0].i+self.regs[0].i)
  self.hash[1].i = tobit(self.hash[1].i+self.regs[1].i)
  self.hash[2].i = tobit(self.hash[2].i+self.regs[2].i)
  self.hash[3].i = tobit(self.hash[3].i+self.regs[3].i)
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

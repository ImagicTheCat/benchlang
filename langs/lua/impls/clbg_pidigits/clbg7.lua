--[[
Revised BSD license

This is a specific instance of the Open Source Initiative (OSI) BSD license template
http://www.opensource.org/licenses/bsd-license.php


Copyright © 2004-2008 Brent Fulgham, 2005-2019 Isaac Gouy
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

   Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

   Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

   Neither the name of "The Computer Language Benchmarks Game" nor the name of "The Computer Language Benchmarks Game Benchmarks" nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

-- The Computer Language Benchmarks Game
-- https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
-- contributed by Wim Couwenberg
--
-- requires LGMP "A GMP package for Lua 5.1"
--
-- 21 September 2008

local gmp, aux = {}, {}
require "c-gmp" (gmp, aux)
local add, mul, div = gmp.mpz_add, gmp.mpz_mul_ui, gmp.mpz_fdiv_q
local addmul, submul = gmp.mpz_addmul_ui, gmp.mpz_submul_ui
local init, get, set = gmp.mpz_init_set_d, gmp.mpz_get_d, gmp.mpz_set

--
-- Production:
--
-- [m11 m12]     [m11 m12][k  4*k+2]
-- [ 0  m22] <-- [ 0  m22][0  2*k+1]
--
local function produce(m11, m12, m22, k)
  local p = 2*k + 1
  mul(m12, p, m12)
  addmul(m12, m11, 2*p)
  mul(m11, k, m11)
  mul(m22, p, m22)
end

--
-- Extraction:
--
-- [m11 m12]     [10 -10*d][m11 m12]
-- [ 0  m22] <-- [ 0   1  ][ 0  m22]
--
local function extract(m11, m12, m22, d)
  submul(m12, m22, d)
  mul(m11, 10, m11)
  mul(m12, 10, m12)
end

--
-- Get integral part of p/q where
--
-- [p]   [m11 m12][d]
-- [q] = [ 0  m22][1]
--
local function digit(m11, m12, m22, d, tmp)
  set(tmp, m12)
  addmul(tmp, m11, d)
  div(tmp, m22, tmp)
  return get(tmp)
end

-- Generate successive digits of PI.
local function pidigits(N)
  local write = io.write
  local m11, m12, m22, tmp = init(1), init(0), init(1), init(0)
  local k, i = 1, 0
  while i < N do
    local d = digit(m11, m12, m22, 3, tmp)
    if d == digit(m11, m12, m22, 4, tmp) then
      write(d)
      extract(m11, m12, m22, d)
      i = i + 1; if i % 10 == 0 then write("\t:", i, "\n") end
    else
      produce(m11, m12, m22, k)
      k = k + 1
    end
  end
  if i % 10 ~= 0 then write(string.rep(" ", 10 - N % 10), "\t:", N, "\n") end
end

local N = tonumber(arg and arg[1]) or 27
pidigits(N)


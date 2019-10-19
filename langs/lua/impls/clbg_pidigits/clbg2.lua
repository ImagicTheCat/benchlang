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
-- contributed by Mike Pall
-- requires LGMP "A GMP package for Lua 5.1"
-- with matrix optimization, courtesy of Wim Couwenberg

local g, aux = {}, {}
require"c-gmp"(g, aux)
local add, mul, div = g.mpz_add, g.mpz_mul_si, g.mpz_tdiv_q
local init, get = g.mpz_init_set_d, g.mpz_get_d

local u, v, w

local function produce(n1, n2, d, k)
  mul(n1, 2*k-1, u)
  add(n2, n2, v)
  mul(n1, k-1, w)
  add(u, v, n1)
  mul(n2, k+2, u)
  add(w, u, n2)
  mul(d, 2*k+1, d)
end

local function extract(n1, n2, d, y)
  mul(d, -10*y, u)
  mul(n1, 10, n1)
  add(n1, u, n1)
  mul(n2, 10, n2)
  add(n2, u, n2)
end

local function digit(n1, n2, d)
  local y = get(div(n1, d, u))
  if y == get(div(n2, d, v)) then return y end
end

-- Generate successive digits of PI.
local function pidigits(N)
  local write = io.write
  local k = 1
  local n1, n2, d = init(4), init(3), init(1)
  u, v, w = init(0), init(0), init(0)
  local i = 0
  while i < N do
    local y = digit(n1, n2, d)
    if y then
      write(y)
      i = i + 1; if i % 10 == 0 then write("\t:", i, "\n") end
      extract(n1, n2, d, y)
    else
      produce(n1, n2, d, k)
      k = k + 1
    end
  end
  if i % 10 ~= 0 then write(string.rep(" ", 10 - N % 10), "\t:", N, "\n") end
end

local N = tonumber(arg and arg[1]) or 27
pidigits(N)

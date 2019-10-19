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

local g, aux = {}, {}
require"c-gmp"(g, aux)
local add, mul, div = g.mpz_add, g.mpz_mul_si, g.mpz_tdiv_q
local init, get = g.mpz_init_set_d, g.mpz_get_d

local q, r, s, t, u, v, w

-- Compose matrix with numbers on the right.
local function compose_r(bq, br, bs, bt)
  mul(r, bs, u)
  mul(r, bq, r)
  mul(t, br, v)
  add(r, v, r)
  mul(t, bt, t)
  add(t, u, t)
  mul(s, bt, s)
  mul(q, bs, u)
  add(s, u, s)
  mul(q, bq, q)
end

-- Compose matrix with numbers on the left.
local function compose_l(bq, br, bs, bt)
  mul(r, bt, r)
  mul(q, br, u)
  add(r, u, r)
  mul(t, bs, u)
  mul(t, bt, t)
  mul(s, br, v)
  add(t, v, t)
  mul(s, bq, s)
  add(s, u, s)
  mul(q, bq, q)
end

-- Extract one digit.
local function extract(j)
  mul(q, j, u)
  add(u, r, u)
  mul(s, j, v)
  add(v, t, v)
  return get(div(u, v, w))
end

-- Generate successive digits of PI.
local function pidigits(N)
  local write = io.write
  local k = 1
  q, r, s, t = init(1), init(0), init(0), init(1)
  u, v, w = init(0), init(0), init(0)
  local i = 0
  while i < N do
    local y = extract(3)
    if y == extract(4) then
      write(y)
      i = i + 1; if i % 10 == 0 then write("\t:", i, "\n") end
      compose_r(10, -10*y, 0, 1)
    else
      compose_l(k, 4*k+2, 0, 2*k+1)
      k = k + 1
    end
  end
  if i % 10 ~= 0 then write(string.rep(" ", 10 - N % 10), "\t:", N, "\n") end
end

local N = tonumber(arg and arg[1]) or 27
pidigits(N)

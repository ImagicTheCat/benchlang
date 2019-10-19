return {
  version = 1,
  title = "CLBG pidigits",
  description = [[
From: https://benchmarksgame-team.pages.debian.net/benchmarksgame/description/pidigits.html#pidigits

--------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------
Background
--------------------------------------------------------------------------------

MathWorld: http://mathworld.wolfram.com/PiDigits.html

--------------------------------------------------------------------------------
Variance
--------------------------------------------------------------------------------

Some language implementations have arbitrary precision arithmetic built-in; some provide an arbitrary precision arithmetic library; some use a third-party library (GMP); some provide built-in arbitrary precision arithmetic by wrapping a third-party library.

--------------------------------------------------------------------------------
The work
--------------------------------------------------------------------------------

The work is to use aribitrary precision arithmetic and the same step-by-step algorithm to generate digits of Pi. Do both extract(3) and extract(4). Don't optimize away the work.

--------------------------------------------------------------------------------
How to implement
--------------------------------------------------------------------------------

We ask that contributed programs not only give the correct result, but also use the same algorithm to calculate that result.

Each program should:
- calculate the first N digits of Pi
- print the digits 10-to-a-line, with the running total of digits calculated

[...]

Adapt the step-by-step algorithm given on pages 4,6 & 7 of [pdf 156KB] Unbounded Spigot Algorithms for the Digits of Pi (http://web.comlab.ox.ac.uk/oucl/work/jeremy.gibbons/publications/spigot.pdf). (Not the deliberately obscure version given on page 2. Not the Rabinowitz-Wagon algorithm.)
  ]],
  steps = { -- list of {params...}
    {"1000"},
    {"5000"},
    {"15000"}
  },
  check = {
    "fffa76efea29ad89ff0bfe661f469218fffa154a1ed8774a7a75dd5e488c6ea1",
    "b3fb0b5d57a3644f3605e535d05a2f3bda25601b110d5e4b8b37590d856678b6",
    "5f50b12ca6f431d3d5577285799dbfcd8116144f38478ff14b49276725fccf53"
  }
}

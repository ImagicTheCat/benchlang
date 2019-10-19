# Revised BSD license
# 
# This is a specific instance of the Open Source Initiative (OSI) BSD license template
# http://www.opensource.org/licenses/bsd-license.php
# 
# 
# Copyright © 2004-2008 Brent Fulgham, 2005-2019 Isaac Gouy
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# 
#    Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
#    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# 
#    Neither the name of "The Computer Language Benchmarks Game" nor the name of "The Computer Language Benchmarks Game Benchmarks" nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
#
# contributed by Rene Bakker
# fixed by Isaac Gouy

import sys
from io import StringIO
from gmpy2 import xmpz,div,mul,add

N = int(sys.argv[1])
f = StringIO()

w = xmpz(0)
k = 1

n1  = xmpz(4)
n2  = xmpz(3)
d   = xmpz(1)
f10 = xmpz(10)
n10 = xmpz(-10)

i = 0
while True:
    # digit
    u = int(div(n1,d))
    v = int(div(n2,d))
    if u == v:
        f.write(chr(48+u))
        i += 1
        if i % 10 == 0:
            f.write("\t:%d\n" % i)

        if i == N:
            break

        # extract
        u  = mul(d, mul(n10, u))
        n1 = mul(n1, f10)
        n1 = add(n1, u)
        n2 = mul(n2, f10)
        n2 = add(n2, u)
    else:
        # produce
        k2 = k << 1
        u  = mul(n1, k2 - 1)
        v  = add(n2, n2)
        w  = mul(n1, k - 1)
        n1 = add(u, v)
        u  = mul(n2, k + 2)
        n2 = add(w, u)
        d  = mul(d, k2 + 1)
        k += 1;

if i % 10 != 0:
    f.write("%s\t:%d\n" % (' ' * (10 - (i%10)),N))
print(f.getvalue(),end="")

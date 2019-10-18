#=
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
=#

# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
#
# contributed by David Campbell
# modified by Jarret Revels, Alex Arslan

const ITER = 50

function ismandel(z::Complex{Float64})
    c = z
    for n = 1:ITER
        if abs2(z) > 4
            return false
        end
        z = z^2 + c
    end
    return true
end

function draw_mandel(M::Array{UInt8, 2}, n::Int)
    for y = 0:n-1
        ci = 2y/n - 1
        for x = 0:n-1
            c = complex(2x/n - 1.5, ci)
            if ismandel(c)
                M[div(x, 8) + 1, y + 1] |= 1 << UInt8(7 - x%8)
            end
        end
    end
end

function perf_mandelbrot(n::Int=200)
    if n%8 != 0
        error("Error: n of $n is not divisible by 8")
    end

    M = zeros(UInt8, div(n, 8), n)
    draw_mandel(M, n)
    write(stdout, "P4\n$n $n\n")
    write(stdout, M)
end

n = parse(Int,ARGS[1])
perf_mandelbrot(n)

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
# contributed by Adam Beckmeyer

const ITER = 50
const CHECKFREQ = 5
const zerotuple8 = ntuple(_ -> 0.0, 8)

function mandelbrot_floats(cr::NTuple{8,T}, ci::T) where {T<:AbstractFloat}
    # Use broadcasting instead of loops because tuples aren't mutable
    zr = zi = zrsq = zisq = absz = zerotuple8
    i = 0
    while i < ITER
        for _ in 1:CHECKFREQ
            # Broadcasting hints compiler to use SIMD at this level
            zi = @. T(2) * zr * zi + ci
            zr = @. zrsq - zisq + cr
            zrsq = zr .* zr
            zisq = zi .* zi
            i += 1
        end#for
        
        absz = zrsq .+ zisq
        all(e -> e > T(4), absz) && break
    end#while

    absz
end#function

function mandelbrot_byte(zsums::NTuple{8,<:AbstractFloat})
    byte = 0xff
    @inbounds for i in 0x01:0x08
        byte &= ifelse(zsums[i] <= 4f0, byte, ~(0x01<<(0x08-i)))
    end#for
    byte
end#function

function main(io::IO, n::Integer)
    byte_n = n ÷ 8

    # Tuples of values instead of vectors to include length in type-signature
    a = Vector{NTuple{8,Float64}}(undef, byte_n)
    @inbounds for j in 1:byte_n
        # Mimic calculations from original Julia code to avoid float errors
        a[j] = ntuple(i -> 2*(8*(j - 1) + i - 1) / n - 1.5, 8)
    end#for
    b = collect(2 * j / n - 1 for j in 0:n-1)
    
    # Can't use Julia BitVector because order is backwards within bytes
    # Not using Matrix since extra precompilation occurs versus Vector
    out = Vector{UInt8}(undef, byte_n*n)
    Threads.@threads for j in 0:n-1
        @inbounds inner(out, a, b[j+1], j)
    end#for
    write_pbm(io, n, out)
    out
end#function

# inner exists because it compiles faster than putting this loop directly in main
Base.@propagate_inbounds function inner(
    out::AbstractVector{UInt8}, a::AbstractVector{NTuple{8,T}}, bval::T, j::Integer
) where T<: AbstractFloat
    for i in 1:length(a)
        out[j * length(a) + i] = mandelbrot_byte(mandelbrot_floats(a[i], bval))
    end#for
end#function

function write_pbm(io::IO, n::Integer, v::AbstractArray{UInt8})
    write(io, "P4\n")
    s = string(n)
    write(io, s, " ", s, "\n")
    write(io, v)
end#function

main(stdout, parse(Int, ARGS[1]))

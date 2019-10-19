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
# contributed by Aaron Tavistock

# Leverage GMP like all the other languages 
require 'gmp'

# Helpers that improve readability
class GMP::Z
  def mul!(a,b)
    GMP::Z.mul(self, a, b)
  end

  def times!(a)
    GMP::Z.mul(self, self, a)
  end
end

# Constants to reduce object instantiation and casting
ZERO = GMP::Z(0)
ONE = GMP::Z(1)
TWO = GMP::Z(2)
THREE = GMP::Z(3)
TEN = GMP::Z(10)

# Allocate these expensive objects once
@display_chunk = GMP::Z(0)
@k = GMP::Z(0)
@a = GMP::Z(0)
@t = GMP::Z(0)
@u = GMP::Z(0)
@k1 = GMP::Z(1)
@n = GMP::Z(1)
@d = GMP::Z(1)
@tmp = GMP::Z(0)

def next_chunk
  @tmp.mul!(@d, @t)
  @a.sub!(@tmp)
  @a.times!(TEN)
  @n.times!(TEN)
end

def produce_chunk
  @k.add!(ONE)
  @t.mul!(@n, TWO)
  @n.times!(@k)

  @a.add!(@t)
  @k1.add!(TWO)
  @a.times!(@k1)
  @d.times!(@k1)
  
  if @a >= @n
    @tmp.mul!(@n, THREE)
    @tmp.add!(@a)
    @t = @tmp.fdiv(@d)
    @u = @tmp.fmod(@d)
    @u.add!(@n)
    if @d > @u
      @display_chunk.times!(TEN)
      @display_chunk.add!(@t)
      return true
    end
  end
  
  false
end  

N = (ARGV[0] || 100).to_i
count = 0
while(count < N) do
  if produce_chunk
    count += 1
    if count % 10 == 0
      STDOUT.write "%010d\t:%d\n" % [@display_chunk.to_i, count]
      @display_chunk.times!(ZERO)
    end 
    next_chunk
  end
end

if @display_chunk.to_i > 0
  STDOUT.write "%s\t:%d\n" % [@display_chunk.to_s.ljust(10), count]
end

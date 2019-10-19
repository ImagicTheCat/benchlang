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
# Use libgmp-ruby_1.0 
#
# contributed by Gabriele Renzi
# modified by Pilho Kim

require 'gmp'

class PiDigitSpigot
    def initialize()
        @ZERO = GMP::Z.new(0)
        @ONE = GMP::Z.new(1)
        @THREE = GMP::Z.new(3)
        @FOUR = GMP::Z.new(4)
        @TEN = GMP::Z.new(10)
        @z = Transformation.new @ONE,@ZERO,@ZERO,@ONE
        @x = Transformation.new @ZERO,@ZERO,@ZERO,@ZERO
        @inverse = Transformation.new @ZERO,@ZERO,@ZERO,@ZERO
    end

    def next!
        @y = @z.extract(@THREE)
        if safe? @y
            @z = produce(@y)
            @y
        else
            @z = consume @x.next!()
            next!()
        end
    end

    def safe?(digit)
        digit == @z.extract(@FOUR)
    end

    def produce(i)
        @inverse.qrst(@TEN,-@TEN*i,@ZERO,@ONE).compose(@z)
    end

    def consume(a)
        @z.compose(a)
    end
end


class Transformation
    attr_reader :q, :r, :s, :t
    def initialize (q, r, s, t)
        @ZERO = GMP::Z.new(0)
        @ONE = GMP::Z.new(1)
        @TWO = GMP::Z.new(2)
        @FOUR = GMP::Z.new(4)
        @q,@r,@s,@t,@k = q,r,s,t,@ZERO
    end

    def next!()
        @q = @k = @k + @ONE
        @r = @FOUR * @k + @TWO
        @s = @ZERO
        @t = @TWO * @k + @ONE
        self
    end

    def extract(j)
        (@q * j + @r).tdiv( @s * j + @t )
    end

    def compose(a)
        self.class.new( @q * a.q,
                        @q * a.r + r * a.t,
                        @s * a.q + t * a.s,
                        @s * a.r + t * a.t
                    )
    end

    def qrst *args
        initialize *args
        self
    end

end


@zero = GMP::Z.new(0)
@one = GMP::Z.new(1)
@two = GMP::Z.new(2)
@four = GMP::Z.new(4)
@ten = GMP::Z.new(10)

WIDTH = 10
n = Integer(ARGV[0] || "27")
j = 0

digits = PiDigitSpigot.new

while n > 0
    if n >= WIDTH
        WIDTH.times {print digits.next!}
        j += WIDTH
    else
        n.times {print digits.next!}
        (WIDTH-n).times {print " "}
        j += n
    end
    puts "\t:"+j.to_s
    n -= WIDTH
end

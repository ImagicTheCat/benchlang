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

#  The Computer Language Benchmarks Game
#  https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
#
#  contributed by Karl von Laudermann
#  modified by Jeremy Echols
#  modified by Detlef Reichl
#  modified by Joseph LaFata
#  modified by Peter Zotov

size = ARGV.shift.to_i

puts "P4\n#{size} #{size}"

byte_acc = 0
bit_num = 0

y = 0
while y < size
  ci = (2.0*y/size)-1.0

  x = 0
  while x < size
    zrzr = zr = 0.0
    zizi = zi = 0.0
    cr = (2.0*x/size)-1.5
    escape = 0b1

    z = 0
    while z < 50
      tr = zrzr - zizi + cr
      ti = 2.0*zr*zi + ci
      zr = tr
      zi = ti
      # preserve recalculation
      zrzr = zr*zr
      zizi = zi*zi
      if zrzr+zizi > 4.0
        escape = 0b0
        break
      end
      z += 1
    end

    byte_acc = (byte_acc << 1) | escape
    bit_num += 1

    # Code is very similar for these cases, but using separate blocks
    # ensures we skip the shifting when it's unnecessary, which is most cases.
    if (bit_num == 8)
      print byte_acc.chr
      byte_acc = 0
      bit_num = 0
    elsif (x == size - 1)
      byte_acc <<= (8 - bit_num)
      print byte_acc.chr
      byte_acc = 0
      bit_num = 0
    end
    x += 1
  end
  y += 1
end

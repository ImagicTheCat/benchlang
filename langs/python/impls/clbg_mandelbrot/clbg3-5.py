"""
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
"""

# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
#
# contributed by Tupteq
# modified by Simon Descarpentries
# modified by Ivan Baldin
# 2to3 plus Daniel Nanz fix

import sys
from array import array
from multiprocessing import Pool

def do_row(fy):
    local_abs = abs
    two_over_size = 2.0 / size
    xr_offs = range(7, -1, -1)
    xr_iter = range(50)

    result = array('B')
    for x in range(7, size, 8):
        byte_acc = 0
        for offset in xr_offs:
            z = 0j
            c = two_over_size * (x - offset) + fy

            for i in xr_iter:
                z = z * z + c
                if local_abs(z) >= 2:
                    break
            else:
                byte_acc += 1 << offset

        result.append(byte_acc)

    if x != size - 1:
        result.append(byte_acc)

    return result.tostring()

def main(out):
    out.write(('P4\n%d %d\n' % (size, size)).encode('ASCII'))

    pool = Pool()
    step = 2.0j / size
    for row in pool.imap(do_row, (step*y-(1.5+1j) for y in range(size))):
        out.write(row)

if __name__ == '__main__':
    size = int(sys.argv[1])
    main(sys.stdout.buffer)

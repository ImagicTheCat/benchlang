/*
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
*/

// The Computer Language Benchmarks Game
// https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
//
// contributed by Elam Kolenovic
//
// Changes (2013-04-07):
//   - removed unnecessary arrays, faster especially on 32 bits
//   - using putchar instead of iostreams, slightly faster
//   - using namespace std for readability
//   - replaced size_t with unsigned
//   - removed some includes

#include <cstdio>
#include <cstdlib>
#include <limits>
#include <vector>

typedef unsigned char Byte;

using namespace std;

int main(int argc, char* argv[])
{
    const unsigned N             = max(0, (argc > 1) ? atoi(argv[1]) : 0);
    const unsigned width         = N;
    const unsigned height        = N;
    const unsigned maxX          = (width + 7) / 8;
    const unsigned maxIterations = 50;
    const double   limit         = 2.0;
    const double   limitSq       = limit * limit;

    vector<Byte> data(height * maxX);

    printf("P4\n%u %u\n", width, height);

    for (unsigned y = 0; y < height; ++y)
    {
        const double ci0 = 2.0 * y / height - 1.0;

        for (unsigned x = 0; x < maxX; ++x)
        {
            double cr0[8];
            for (unsigned k = 0; k < 8; ++k)
            {
                cr0[k] = 2.0 * (8 * x + k) / width - 1.5;
            }

            double cr[8];
            copy(cr0, cr0 + 8, &cr[0]);

            double ci[8];
            fill(ci, ci + 8, ci0);

            Byte bits = 0;
            for (unsigned i = 0; i < maxIterations && bits != 0xFF; ++i)
            {
                for (unsigned k = 0; k < 8; ++k)
                {
                    const Byte mask = (1 << (7 - k));
                    if ((bits & mask) == 0)
                    {
                        const double crk  = cr[k];
                        const double cik  = ci[k];
                        const double cr2k = crk * crk;
                        const double ci2k = cik * cik;

                        cr[k] = cr2k - ci2k + cr0[k];
                        ci[k] = 2.0 * crk * cik + ci0;

                        if (cr2k + ci2k > limitSq)
                        {
                            bits |= mask;
                        }
                    }
                }
            }
            putchar(~bits);
        }
    }

    return 0;
}

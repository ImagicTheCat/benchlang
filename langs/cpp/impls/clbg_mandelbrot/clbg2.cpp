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

#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <iterator>
#include <limits>
#include <sstream>
#include <string>
#include <vector>

int main(int argc, char* argv[])
{
    typedef unsigned char Byte;

    const size_t N             = std::max(0, (argc > 1) ? atoi(argv[1]) : 0);
    const size_t width         = N;
    const size_t height        = N;
    const size_t maxX          = (width + 7) / 8;
    const size_t maxIterations = 50;
    const double limit         = 2.0;
    const double limitSq       = limit * limit;

    std::vector<Byte> data(height * maxX);

    for (size_t y = 0; y < height; ++y)
    {
        const double ci0  = 2.0 * y / height - 1.0;
        Byte*        line = &data[y * maxX];

        for (size_t x = 0; x < maxX; ++x)
        {
            double cr0[8];
            for (size_t k = 0; k < 8; ++k)
            {
                cr0[k] = 2.0 * (8 * x + k) / width - 1.5;
            }

            double cr[8];
            std::copy(cr0, cr0 + 8, &cr[0]);

            double ci[8];
            std::fill(ci, ci + 8, ci0);

            Byte bits = 0;
            for (size_t i = 0; i < maxIterations && bits != 0xFF; ++i)
            {
                double cr2[8];
                double ci2[8];
                double crci[8];

                for (size_t k = 0; k < 8; ++k)
                {
                    const Byte mask = (1 << (7 - k));
                    if ((bits & mask) == 0)
                    {
                        cr2[k]  = cr[k] * cr[k];
                        ci2[k]  = ci[k] * ci[k];
                        crci[k] = cr[k] * ci[k];

                        cr[k] = cr2[k] - ci2[k] + cr0[k];
                        ci[k] = 2.0 * crci[k] + ci0;

                        if (cr2[k] + ci2[k] > limitSq)
                        {
                            bits |= mask;
                        }
                    }
                }
            }
            line[x] = ~bits;
        }
    }

    std::cout << "P4\n" << width << ' ' << height << '\n';
    for (size_t y = 0; y < height; ++y)
    {
        Byte* line = reinterpret_cast<Byte*>(&data[y * maxX]);
        std::copy(line, line + width / 8, std::ostream_iterator<Byte>(std::cout));
    }

    return 0;
}

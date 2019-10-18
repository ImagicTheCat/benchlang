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
// Changes (2013-04-19)
//   - using omp
//   - use buffer and fwrite at end instead of putchar
//   - pre-calculate cr0[]
//   - rename variables and use underscore before the index part of the name
//   - inverted bit tests, better performance under MSVC
//   - optional argument for file output, usefull in windows shell
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
    const unsigned N              = max(0, (argc > 1) ? atoi(argv[1]) : 0);
    const unsigned width          = N;
    const unsigned height         = N;
    const unsigned max_x          = (width + 7) / 8;
    const unsigned max_iterations = 50;
    const double   limit          = 2.0;
    const double   limit_sq       = limit * limit;

    FILE* out = (argc == 3) ? fopen(argv[2], "wb") : stdout;

    vector<Byte> buffer(height * max_x);

    std::vector<double> cr0(8 * max_x);
    for (unsigned x = 0; x < max_x; ++x)
    {
        for (unsigned k = 0; k < 8; ++k)
        {
            const int xk = 8 * x + k;
            cr0[xk] = (2.0 * xk) / width - 1.5;
        }
    }

#pragma omp parallel for
    for (unsigned y = 0; y < height; ++y)
    {
        Byte* line = &buffer[y * max_x];

        const double ci0 = 2.0 * y / height - 1.0;

        for (unsigned x = 0; x < max_x; ++x)
        {
            const double* cr0_x = &cr0[8 * x];

            double cr[8];
            copy(cr0_x, cr0_x + 8, &cr[0]);

            double ci[8];
            fill(ci, ci + 8, ci0);

            Byte bits = 0xFF;
            for (unsigned i = 0; i < max_iterations && bits; ++i)
            {
                Byte bit_k = 0x80;
                for (unsigned k = 0; k < 8; ++k)
                {
                    if (bits & bit_k)
                    {
                        const double cr_k    = cr[k];
                        const double ci_k    = ci[k];
                        const double cr_k_sq = cr_k * cr_k;
                        const double ci_k_sq = ci_k * ci_k;

                        cr[k] = cr_k_sq - ci_k_sq + cr0_x[k];
                        ci[k] = 2.0 * cr_k * ci_k + ci0;

                        if (cr_k_sq + ci_k_sq > limit_sq)
                        {
                            bits ^= bit_k;
                        }
                    }
                    bit_k >>= 1;
                }
            }
            line[x] = bits;
        }
    }

    fprintf(out, "P4\n%u %u\n", width, height);
    fwrite(&buffer[0], buffer.size(), 1, out);

    if (out != stdout)
    {
        fclose(out);
    }

    return 0;
}

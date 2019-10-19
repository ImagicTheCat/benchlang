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

/* The Computer Language Benchmarks Game
 * https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
 *
 * contributed by Alessandro Power
 */

#include <gmpxx.h>
#include <cstdlib>
#include <iostream>

class LFT {
public:
    mpz_class q;
    mpz_class r;
    mpz_class t;
    unsigned k;

public:
    LFT() : q(1), r(0), t(1), k(0){};

    void next() {
        ++k;
        r = (2 * k + 1) * (2 * q + r);
        t = (2 * k + 1) * t;
        q = q * k;
    }

    unsigned extract(unsigned x) const {
        static mpz_class tmp0, tmp1;
        tmp0 = q * x + r;
        tmp1 = tmp0 / t;
        return tmp1.get_ui();
    }

    void produce(unsigned n) {
        q = 10 * q;
        r = 10 * (r - n * t);
    }
};

int main(int, char** argv) {
    std::ios_base::sync_with_stdio(false);

    const std::size_t TOTAL_DIGITS = std::atol(argv[1]);

    LFT lft;
    std::size_t n_digits = 0;
    while (n_digits < TOTAL_DIGITS) {
        std::size_t i = 0;
        while (i < 10 and n_digits < TOTAL_DIGITS) {
            lft.next();
            if (lft.q > lft.r) continue;

            auto digit = lft.extract(3);
            if (digit == lft.extract(4)) {
                std::cout << digit;
                lft.produce(digit);
                ++i;
                ++n_digits;
            }
        }

        // Pad digits with extra spaces if TOTAL_DIGITS was not a
        // multiple of 10.
        for (; i < 10; ++i) std::cout << ' ';
        std::cout << "\t:" << n_digits << '\n';
    }
}

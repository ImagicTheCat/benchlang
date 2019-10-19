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
 * Contributed by Michael Ganss
 * derived from PHP version that was
 * contributed by Oleksii Prudkyi
 * port from pidigits.lua-5.lua (Mike Pall, Wim Couwenberg)
 * modified by Craig Russell
 * 
 * Original C version by Mr Ledrug
*/

#include <stdio.h>
#include <stdlib.h>
#include <gmp.h>

mpz_t n1, n2, d, u, v, w;

int main(int argc, char **argv)
{
    int k = 1, k2, i = 0;
    int n = atoi(argv[1]);

    mpz_init(u);
    mpz_init(v);

    mpz_init_set_si(w, 0);
    mpz_init_set_si(n1, 4);
    mpz_init_set_si(n2, 3);
    mpz_init_set_si(d, 1);

    for (;;)
    {
        mpz_tdiv_q(u, n1, d);
        mpz_tdiv_q(v, n2, d);

        if (mpz_cmp(u, v) == 0)
        {
            putchar('0' + mpz_get_si(u));
            i++;
            if (i % 10 == 0)
                printf("\t:%d\n", i);
            if (i == n)
                break;

            // extract
            mpz_mul_si(u, u, -10);
            mpz_mul(u, d, u);
            mpz_mul_si(n1, n1, 10);
            mpz_add(n1, n1, u);
            mpz_mul_si(n2, n2, 10);
            mpz_add(n2, n2, u);
        }
        else 
        {
            // produce
            k2 = k * 2;
            mpz_mul_si(u, n1, k2 - 1);
            mpz_add(v, n2, n2);
            mpz_mul_si(w, n1, k - 1);
            mpz_add(n1, u, v);
            mpz_mul_si(u, n2, k + 2);
            mpz_add(n2, w, u);
            mpz_mul_si(d, d, k2 + 1);
            k++;
        }
    }

    if (i % 10 != 0)
        printf("%*s\t:%d\n", 10 - n % 10, "", n);
    return 0;
}

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
 * contributed by Marcin Zalewski & Jeremiah Willcock
 */


#include <iostream>
#include <gmpxx.h>
#include <boost/lexical_cast.hpp>
#include <boost/tuple/tuple.hpp>
#include <algorithm>

using namespace boost;

class Digits {
private:
  unsigned int j;
  tuple<mpz_class, mpz_class, mpz_class> nad;
  mpz_class tmp1, tmp2;

public:
  Digits() { j = 0; get<0>(nad) = 1; get<1>(nad) = 0; get<2>(nad) = 1; }

  inline char operator()() {
    ++j;
    next_term();

    if(get<0>(nad) > get<1>(nad)) return (*this)();

    mpz_mul_2exp(tmp1.get_mpz_t(), get<0>(nad).get_mpz_t(), 1);
    tmp1 += get<0>(nad);
    tmp1 += get<1>(nad);

// "Uses only one bigint division instead of two when checking a produced digit's validity."

//    mpz_fdiv_qr(tmp1.get_mpz_t(), tmp2.get_mpz_t(), tmp1.get_mpz_t(), get<2>(nad).get_mpz_t());

    tmp2 += get<0>(nad);

    if(tmp2 >= get<2>(nad)) {
      return (*this)();
    } else {
      unsigned int d = tmp1.get_ui();
      eliminate_digit(d);
      return d + '0';
    }
  }

private:

  inline void next_term() {
    unsigned int y = j * 2 + 1;
    mpz_mul_2exp(tmp1.get_mpz_t(), get<0>(nad).get_mpz_t(), 1);
    get<1>(nad) += tmp1;
    get<1>(nad) *= y;
    get<0>(nad) *= j;
    get<2>(nad) *= y;
  }

  inline void eliminate_digit(unsigned int d) {
    mpz_submul_ui(get<1>(nad).get_mpz_t(), get<2>(nad).get_mpz_t(), d);
    get<0>(nad) *= 10;
    get<1>(nad) *= 10;
  }

};

void pi(unsigned int n) {
  unsigned int i = 0;
  Digits digits;

  while((i += 10) <= n) {
    for(int count = 0; count < 10; ++count) {
      std::cout << digits();
    }
    std::cout << "\t:" << i << '\n';
  }
  
  i -= 10;
  if(n > i) {
    for(int count = 0; count < n - i; ++count) {
      std::cout << digits();
    }
    i += 10;
    for(int count = 0; count < i - n; ++count) {
      std::cout << ' ';
    }
    std::cout << "\t:" << n << '\n';
  }
}

int main(int argc, char** argv) {
  std::cout.sync_with_stdio(false);
  unsigned int count = (argc >= 2 ? boost::lexical_cast<unsigned int>(argv[1]) : 10000);
  pi(count);
  return 0;
}

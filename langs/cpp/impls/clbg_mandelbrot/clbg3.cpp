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
   https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
   contributed by Greg Buchholz
   compile:  g++ -O3
*/

#include <stdio.h>
#include <stdlib.h>
#include<iostream>
#include<complex>

int main (int argc, char **argv)
{
  char  bit_num = 0, byte_acc = 0;
  const int iter = 50;
  const double lim = 2.0 * 2.0;
  
  std::ios_base::sync_with_stdio(false);
  int n = atoi(argv[1]);

  std::cout << "P4\n" << n << " " << n << std::endl;

  for(int y=0; y<n; ++y) 
    for(int x=0; x<n; ++x)
    {
       std::complex<double> Z(0,0),C(2*(double)x/n - 1.5, 2*(double)y/n - 1.0);
       
       //manually inlining "norm" results in a 5x-7x speedup on gcc
       for(int i=0; i<iter and Z.real()*Z.real() + Z.imag()*Z.imag() <= lim; ++i)
         Z = Z*Z + C;
        
       byte_acc = (byte_acc << 1) | ((norm(Z) > lim) ? 0x00:0x01);

       if(++bit_num == 8){ std::cout << byte_acc; bit_num = byte_acc = 0; }
       else if(x == n-1) { byte_acc  <<= (8-n%8);
                           std::cout << byte_acc;
                           bit_num = byte_acc = 0; }
    }
}

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

// !BENCHLANG::gcc-any(OPTS)=[-O3 -mno-fma -march=native -fopenmp]

/* The Computer Language Benchmarks Game
 https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
 contributed by Ralph Ganszky
 modified for Swift 3.0 by Daniel Muellenborn
 modified for C & gcc by Dominic Letz

 Compile with: gcc -O3 -mno-fma -march=native -fopenmp main.c
 */

#include <stdio.h>
#include <stdlib.h>

int Iter = 50;

typedef double Vec __attribute__ ((vector_size(16)));
const int Vec__size = sizeof(Vec)/sizeof(double);
typedef unsigned char Byte;

int bt(Vec lhs, double rhs) {
  for (int i = 0; i < Vec__size; i++)
    if (lhs[i] <= rhs)
      return 0;
  return 1;
}

// Calculate mandelbrot set for one Vec into one byte
Byte mand(Vec cr, Vec ci) {
  Vec Zr = {0.0};
  Vec Zi = {0.0};
  Vec Tr = {0.0};
  Vec Ti = {0.0};

  for (int i = 0; i < Iter/5; i++) {
    for (int j = 0; j < 5; j++) {
      Zi = (Zr + Zr) * Zi + ci;
      Zr = Tr - Ti + cr;
      Tr = Zr * Zr;
      Ti = Zi * Zi;
    }
    if (bt(Tr + Ti, 4.0)) {
       return 0;
    }
  }
  Byte byte = 0;
  Vec t = Tr + Ti;
  for (int i = 0; i < Vec__size; i++) {
    byte |= t[i] <= 4.0 ? (0x80 >> i) : 0;
  }
  return byte;
}

// Parse command line arguments
int main(int argc, char* argv[])
{
  int n = (argc > 1) ? atoi(argv[1]) : 200;
  int N = (n + Vec__size - 1) & ~(Vec__size - 1);
  double inv = 2.0 / ((double)n);
  Vec xvals[N/Vec__size];
  Vec yvals[N];
  Byte *rows = malloc(n*N/8);

  for (int i = 0; i < N; i++) {
    xvals[i/Vec__size][i%Vec__size] = ((double)i) * inv - 1.5;
    for (int j = 0; j < Vec__size; j++) {
      yvals[i][j] = ((double)i) * inv - 1.0;
    }
  }

#pragma omp parallel for schedule(guided)
  for (int y = 0; y < n; y++) {
    for (int x = 0; x < N/Vec__size; x+=8/Vec__size) {
      Byte b = 0;
      for (int v = 0; v < 8/Vec__size; v++) {
        b |= mand(xvals[x + v], yvals[y]) >> (v*Vec__size);
      }
      rows[y*N/8+x/(8/Vec__size)] = b;
    }
  }

  FILE* out = (argc == 3) ? fopen(argv[2], "wb") : stdout;
  fprintf(out, "P4\n%u %u\n", n, n);
  fwrite(&rows[0], n*N/8, 1, out);

  if (out != stdout)
  {
      fclose(out);
  }
  free(rows);
  return 0;
}

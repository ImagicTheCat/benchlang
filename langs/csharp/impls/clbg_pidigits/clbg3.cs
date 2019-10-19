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
 *
 * Port of the Java port that uses native GMP to use native GMP with C#
 * contributed by Miguel de Icaza, based on the Java version, that was:
 * 	contributed by Mike Pall
 * 	java port by Stefan Krause
*/
using System;
using System.Text;
using System.Runtime.InteropServices;

public class pidigits {

   GmpInteger q = new GmpInteger(), r = new GmpInteger(), s = new GmpInteger(), t = new GmpInteger();
   GmpInteger u = new GmpInteger(), v = new GmpInteger(), w = new GmpInteger();

   int i;
   StringBuilder strBuf = new StringBuilder (40);
   int n;

   pidigits (int n)
   {
      this.n=n;
   }

   private void compose_r(int bq, int br, int bs, int bt)
   {
     u.mul(r, bs);
     r.mul(r, bq);
     v.mul(t, br);
     r.add(r, v);
     t.mul(t, bt);
     t.add(t, u);
     s.mul(s, bt);
     u.mul(q, bs);
     s.add(s, u);
     q.mul(q, bq);
   }

   /* Compose matrix with numbers on the left. */
   private void compose_l(int bq, int br, int bs, int bt)
   {
     r.mul(r, bt);
     u.mul(q, br);
     r.add(r, u);
     u.mul(t, bs);
     t.mul(t, bt);
     v.mul(s, br);
     t.add(t, v);
     s.mul(s, bq);
     s.add(s, u);
     q.mul(q, bq);
   }

   /* Extract one digit. */
   private int extract(int j)
   {
     u.mul(q, j);
     u.add(u, r);
     v.mul(s, j);
     v.add(v, t);
     w.div(u, v);
     return w.intValue();
   }

   /* Print one digit. Returns 1 for the last digit. */
   private bool prdigit(int y)
   {
      strBuf.Append(y);
      if (++i % 10 == 0 || i == n) {
         if (i%10!=0) for (int j=10-(i%10);j>0;j--) { strBuf.Append(" "); }
         strBuf.Append("\t:");
         strBuf.Append(i);
         Console.WriteLine(strBuf);
         strBuf = new StringBuilder(40);
      }
      return i == n;
   }

   /* Generate successive digits of PI. */
   void Run()
   {
     int k = 1;
     i = 0;
     q.set(1);
     r.set(0);
     s.set(0);
     t.set(1);
     for (;;) {
       int y = extract(3);
       if (y == extract(4)) {
         if (prdigit(y)) return;
         compose_r(10, -10*y, 0, 1);
       } else {
         compose_l(k, 4*k+2, 0, 2*k+1);
         k++;
       }
     }
   }

   public static void Main(String[] args) {
       pidigits m = new pidigits(Int32.Parse (args[0]));
       m.Run();
   }
}

[StructLayout (LayoutKind.Sequential)]
struct mpz_t {
    public int _mp_alloc;
    public int _mp_size;
    public IntPtr ptr;
}

class GmpInteger {

   // Public methods

   public GmpInteger() {
      mpz_init(ref pointer);
   }

   public GmpInteger(int value) {
      mpz_set_si(ref pointer, value);
   }

   public void set(int value) { mpz_set_si(ref pointer, value); }

   public void mul(GmpInteger src, int val) { mpz_mul_si(ref pointer, ref src.pointer, val); }

   public void add(GmpInteger op1, GmpInteger op2) { mpz_add(ref pointer, ref op1.pointer, ref op2.pointer); }

   public void div(GmpInteger op1, GmpInteger op2) { mpz_tdiv_q(ref pointer, ref op1.pointer, ref op2.pointer); }

   public int intValue() { return mpz_get_si(ref pointer); }

   public double doubleValue() { return mpz_get_d(ref pointer); }

   // Non public stuff

   mpz_t pointer;

    [DllImport ("gmp", EntryPoint="__gmpz_init")]
    extern static void mpz_init(ref mpz_t value);

    [DllImport ("gmp", EntryPoint="__gmpz_mul_si")]
    extern static void mpz_mul_si(ref mpz_t dest, ref mpz_t src, int val);

    [DllImport ("gmp", EntryPoint="__gmpz_add")]
    extern static void mpz_add(ref mpz_t dest, ref mpz_t src, ref mpz_t src2);

    [DllImport ("gmp", EntryPoint="__gmpz_tdiv_q")]
    extern static void mpz_tdiv_q(ref mpz_t dest, ref mpz_t src, ref mpz_t src2);

    [DllImport ("gmp", EntryPoint="__gmpz_set_si")]
    extern static void mpz_set_si(ref mpz_t src, int value);

    [DllImport ("gmp", EntryPoint="__gmpz_get_si")]
    extern static int mpz_get_si(ref mpz_t src);

    [DllImport ("gmp", EntryPoint="__gmpz_get_d")]
    extern static double mpz_get_d(ref mpz_t src);
}

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
 * Adapted by Antti Lankila from the earlier Isaac Gouy's implementation
 */

using System;
using System.IO;

class Mandelbrot {

   public static void Main(String[] args) {

      int width = 100;
      if (args.Length > 0)
	 width = Int32.Parse(args[0]);

      int height = width;
      int maxiter = 50;
      double limit = 4.0;

      Console.WriteLine("P4");
      Console.WriteLine("{0} {1}", width,height);
      Stream s = Console.OpenStandardOutput(1024);

      for (int y = 0; y < height; y++) {
	 int bits = 0;
	 int xcounter = 0;
	 double Ci = 2.0*y/height - 1.0;

         for (int x = 0; x < width; x++){
	    double Zr = 0.0;
	    double Zi = 0.0;
	    double Cr = 2.0*x/width - 1.5;
            int i = maxiter;

            bits = bits << 1;
            do {
               double Tr = Zr*Zr - Zi*Zi + Cr;
               Zi = 2.0*Zr*Zi + Ci;
               Zr = Tr;
               if (Zr*Zr + Zi*Zi > limit) {
		  bits |= 1;
		  break;
	       }
            } while (--i > 0);

            if (++xcounter == 8) {
	       s.WriteByte((byte) (bits ^ 0xff));
	       bits = 0;
	       xcounter = 0;
            }
         }
         if (xcounter != 0)
	    s.WriteByte((byte) ((bits << (8 - xcounter)) ^ 0xff));
      }
   }
}

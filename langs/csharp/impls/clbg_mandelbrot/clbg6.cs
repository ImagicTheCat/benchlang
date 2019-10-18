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
    
   started with Java #2 program (Krause/Whipkey/Bennet/AhnTran/Enotus/Stalcup)
   adapted for C# by Jan de Vaan
   simplified and optimised to use TPL by Anthony Lloyd
   simplified to compute Cib alongside Crb by Tanner Gooding
*/

using System;
using System.Threading.Tasks;
using System.Runtime.CompilerServices;
using System.Globalization;

public class MandelBrot
{
    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    static byte getByte(double[] Crb, double Ciby, int x, int y)
    {
        int res = 0;

        for (int i = 0; i < 8; i += 2)
        {
            double Crbx0 = Crb[x + i], Crbx1 = Crb[x + i + 1];

            double Zr1 = Crbx0, Zr2 = Crbx1;
            double Zi1 = Ciby, Zi2 = Ciby;

            int b = 0, j = 49;

            do
            {
                double nZr1 = Zr1 * Zr1 - Zi1 * Zi1 + Crbx0;
                Zi1 = Zr1 * Zi1 + Zr1 * Zi1 + Ciby;
                Zr1 = nZr1;

                double nZr2 = Zr2 * Zr2 - Zi2 * Zi2 + Crbx1;
                Zi2 = Zr2 * Zi2 + Zr2 * Zi2 + Ciby;
                Zr2 = nZr2;

                if (Zr1 * Zr1 + Zi1 * Zi1 > 4) { b |= 2; if (b == 3) break; }
                if (Zr2 * Zr2 + Zi2 * Zi2 > 4) { b |= 1; if (b == 3) break; }
            } while (--j > 0);

            res = (res << 2) + b;
        }

        return (byte)(res ^ -1);
    }

    public static void Main(String[] args)
    {
        var n = args.Length > 0 ? int.Parse(args[0], CultureInfo.CurrentCulture) : 16000;

        var Crb = new double[n + 7];
        var Cib = new double[n + 7];

        var invN = 2.0 / n;
        
        for (int i = 0; i < n; i++)
        {
            var tmp = i * invN;

            Crb[i] = tmp - 1.5;
            Cib[i] = tmp - 1.0;
        }

        int lineLen = (n - 1) / 8 + 1;
        var data = new byte[n * lineLen];

        Parallel.For(0, n, y =>
        {
            var offset = y * lineLen;
            for (int x = 0; x < lineLen; x++)
            {
                data[offset + x] = getByte(Crb, Cib[y], x * 8, y);
            }
        });

        Console.Out.WriteLine("P4\n{0} {0}", n);
        Console.OpenStandardOutput().Write(data, 0, data.Length);
    }
}

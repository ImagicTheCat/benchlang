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

// !BENCHLANG::(UNSAFE)=[yes]

/* The Computer Language Benchmarks Game
   https://salsa.debian.org/benchmarksgame-team/benchmarksgame/

   started with Java #2 program (Krause/Whipkey/Bennet/AhnTran/Enotus/Stalcup)
   adapted for C# by Jan de Vaan
   simplified and optimised to use TPL by Anthony Lloyd
   simplified to compute Cib alongside Crb by Tanner Gooding
   optimized to use Vector<double> by Tanner Gooding
*/

using System;
using System.Numerics;
using System.Runtime.CompilerServices;
using System.Threading.Tasks;

public class MandelBrot
{
    // Vector<double>.Count is treated as a constant by the JIT, don't bother
    // storing it in a temporary variable anywhere below.

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    private static unsafe byte GetByte(double* pCrb, double Ciby, int x, int y)
    {
        var res = 0;

        for (var i = 0; i < 8; i += 2)
        {
            var Crbx = Unsafe.Read<Vector<double>>(pCrb + x + i);
            var Zr = Crbx;
            var vCiby = new Vector<double>(Ciby);
            var Zi = vCiby;

            var b = 0;
            var j = 49;

            do
            {
                var nZr = Zr * Zr - Zi * Zi + Crbx;
                Zi = Zr * Zi + Zr * Zi + vCiby;
                Zr = nZr;

                var t = Zr * Zr + Zi * Zi;

                if (t[0] > 4)
                {
                    b |= 2;

                    if (b == 3)
                    {
                        break;
                    }
                }

                if (t[1] > 4)
                {
                    b |= 1;

                    if (b == 3)
                    {
                        break;
                    }
                }

            } while (--j > 0);

            res = (res << 2) + b;
        }

        return (byte)(res ^ -1);
    }

    public static unsafe void Main(string[] args)
    {
        var size = (args.Length > 0) ? int.Parse(args[0]) : 200;

        var adjustedSize = size + (Vector<double>.Count * 8);
        adjustedSize &= ~(Vector<double>.Count * 8);

        var Crb = new double[adjustedSize];
        var Cib = new double[adjustedSize];

        fixed (double* pCrb = &Crb[0])
        fixed (double* pCib = &Cib[0])
        {
            var invN = new Vector<double>(2.0 / size);

            var onePtFive = new Vector<double>(1.5);
            var step = new Vector<double>(Vector<double>.Count);

            Vector<double> value;

            if (Vector<double>.Count == 2)
            {
                value = new Vector<double>(new double[] {
                    0, 1
                });
            }
            else if (Vector<double>.Count == 4)
            {
                value = new Vector<double>(new double[] {
                    0, 1, 2, 3
                });
            }
            else
            {
                value = new Vector<double>(new double[] {
                    0, 1, 2, 3, 4, 5, 6, 7
                });
            }

            for (var i = 0; i < size; i += Vector<double>.Count)
            {
                var t = value * invN;

                Unsafe.Write(pCrb + i, t - onePtFive);
                Unsafe.Write(pCib + i, t - Vector<double>.One);

                value += step;
            }
        }

        var lineLength = size >> 3;
        var data = new byte[adjustedSize * lineLength];

        fixed (double* pCrb = &Crb[0])
        {
            var _Crb = pCrb;

            Parallel.For(0, size, y => {
                var offset = y * lineLength;

                for (var x = 0; x < lineLength; x++)
                {
                    data[offset + x] = GetByte(_Crb, Cib[y], x * 8, y);
                }
            });
        }

        // generate the bitmap header
        Console.Out.Write("P4\n{0} {0}\n", size);
        Console.OpenStandardOutput().Write(data, 0, size * lineLength);
    }
}

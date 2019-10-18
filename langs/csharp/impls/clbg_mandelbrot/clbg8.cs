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
   optimized to use Vector<double> by Tanner Gooding
   small optimisations by Anthony Lloyd
*/

using System;
using System.Numerics;
using System.Runtime.CompilerServices;
using System.Threading.Tasks;

public class MandelBrot
{
    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    static unsafe byte GetByte(double* pCrb, double Ciby)
    {
        var res = 0;
        for (var i=0; i<8; i+=2)
        {
            var vCrbx = Unsafe.Read<Vector<double>>(pCrb+i);
            var vCiby = new Vector<double>(Ciby);
            var Zr = vCrbx;
            var Zi = vCiby;
            int b = 0, j = 49;
            do
            {
                var nZr = Zr * Zr - Zi * Zi + vCrbx;
                var ZrZi = Zr * Zi; 
                Zi = ZrZi + ZrZi + vCiby;
                Zr = nZr;
                var t = Zr * Zr + Zi * Zi;
                if (t[0]>4.0) { b|=2; if (b==3) break; }
                if (t[1]>4.0) { b|=1; if (b==3) break; }
            } while (--j>0);
            res = (res << 2) + b;
        }
        return (byte)(res^-1);
    }
    public static unsafe void Main(string[] args)
    {
        var size = args.Length==0 ? 200 : int.Parse(args[0]);
        Console.Out.WriteAsync(String.Concat("P4\n",size," ",size,"\n"));
        var Crb = new double[size+2];
        var lineLength = size >> 3;
        var data = new byte[size * lineLength];
        fixed (double* pCrb = &Crb[0])
        fixed (byte* pdata = &data[0])
        {
            var value = new Vector<double>(
                  new double[] {0,1,0,0,0,0,0,0}
            );
            var invN = new Vector<double>(2.0/size);
            var onePtFive = new Vector<double>(1.5);
            var step = new Vector<double>(2);
            for (var i=0; i<size; i+=2)
            {
                Unsafe.Write(pCrb+i, value*invN-onePtFive);
                value += step;
            }
            var _Crb = pCrb;
            var _pdata = pdata;
            Parallel.For(0, size, y =>
            {
                var Ciby = _Crb[y]+0.5;
                for (var x=0; x<lineLength; x++)
                {
                    _pdata[y*lineLength+x] = GetByte(_Crb+x*8, Ciby);
                }
            });
            Console.OpenStandardOutput().Write(data, 0, data.Length);
        }
    }
}

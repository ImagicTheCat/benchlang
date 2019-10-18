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

   Adapted by Antti Lankila from the earlier Isaac Gouy's implementation
   Add multithread & tweaks from C++ by The Anh Tran
   Simplified bit logic and cleaned code by Robert F. Tobler
*/

using System;
using System.Threading;
using System.IO;

public class MandelBrot
{
    private static int n = 200;
    private static byte[][] data;
    private static int lineCount = -1;
    private static double[] xa;

    public static void Main (String[] args)
    {
        if (args.Length > 0) n = Int32.Parse(args[0]);
        Console.Out.WriteLine("P4\n{0} {0}", n);
        
        int lineLen = (n-1)/8 + 1;
        data = new byte[n][];
        for (int i = 0; i < n; i++) data[i] = new byte[lineLen];

        xa = new double[n];
        for (int x = 0; x < n; x++) xa[x] = x * 2.0/n - 1.5;

        var threads = new Thread[Environment.ProcessorCount];
        for (int i = 0; i < threads.Length; i++)
            (threads[i] = new Thread(MandelBrot.Calculate)).Start();

        foreach (var t in threads) t.Join();

        var s = Console.OpenStandardOutput();
        for (int y = 0; y < n; y++) s.Write(data[y], 0, lineLen);
    }

    private static void Calculate()
    {
        int y;
        while ((y = Interlocked.Increment(ref lineCount)) < n)
        {
            var line = data[y];
            int xbyte = 0, bits = 1;
            double ci = y * 2.0/n - 1.0;

            for (int x = 0; x < n; x++)
            {
                double cr = xa[x];
                if (bits > 0xff) { line[xbyte++] = (byte)bits; bits = 1; }
                double zr = cr, zi = ci, tr = cr * cr, ti = ci * ci;  
                int i = 49;
                do
                {
                    zi = zr * zi + zr * zi + ci; zr = tr - ti + cr;
                    tr = zr * zr; ti = zi * zi;
                }
                while ((tr + ti <= 4.0) && (--i > 0));
                bits = (bits << 1) | (i == 0 ? 1 : 0);
            }
            while (bits < 0x100) bits = (bits << 1);
            line[xbyte] = (byte)bits;
        }
    }
}

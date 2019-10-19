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

// !BENCHLANG::(CLASS)=[mandelbrot]

/* The Computer Language Benchmarks Game
   https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
 
   contributed by Stefan Krause
   slightly modified by Chad Whipkey
   parallelized by Colin D Bennett 2008-10-04
   reduce synchronization cost by The Anh Tran
  */

//package mandelbrot;

import java.io.*;
import java.io.IOException;
import java.util.concurrent.atomic.AtomicInteger;

public final class mandelbrot
{
    public static void main(String[] args) throws Exception
    {
        int size = 200;
        if (args.length >= 1)
            size = Integer.parseInt(args[0]);
        
        System.out.format("P4\n%d %d\n", size, size);
        
        int width_bytes = size /8 +1;
        byte[][] output_data = new byte[size][width_bytes];
        int[] bytes_per_line = new int[size];
        
        Compute(size, output_data, bytes_per_line);
        
        BufferedOutputStream ostream = new BufferedOutputStream(System.out);
        for (int i = 0; i < size; i++)
            ostream.write(output_data[i], 0, bytes_per_line[i]);
        ostream.close();
    }
    
    private static final void Compute(final int N, final byte[][] output, final int[] bytes_per_line)
    {
        final double inverse_N = 2.0 / N;
        final AtomicInteger current_line = new AtomicInteger(0);
        
        final Thread[] pool = new Thread[Runtime.getRuntime().availableProcessors()];
        for (int i = 0; i < pool.length; i++)
        {
            pool[i] = new Thread()
            {
                public void run()
                {
                    int y;
                    while ((y = current_line.getAndIncrement()) < N)
                    {
                        byte[] pdata = output[y];
                        
                        int bit_num = 0;
                        int byte_count = 0;
                        int byte_accumulate = 0;
                        
                        double Civ = (double)y * inverse_N - 1.0;
                        for (int x = 0; x < N; x++)
                        {
                            double Crv = (double)x * inverse_N - 1.5;
                            
                            double Zrv = Crv;
                            double Ziv = Civ;
                            
                            double Trv = Crv * Crv;
                            double Tiv = Civ * Civ;
                            
                            int i = 49;
                            do
                            {
                                Ziv = (Zrv * Ziv) + (Zrv * Ziv) + Civ;
                                Zrv = Trv - Tiv + Crv;
                                
                                Trv = Zrv * Zrv;
                                Tiv = Ziv * Ziv;
                            } while ( ((Trv + Tiv) <= 4.0) && (--i > 0));

                            byte_accumulate <<= 1;
                            if (i == 0)
                                byte_accumulate++;
                            
                            if (++bit_num == 8)
                            {
                                pdata[ byte_count++ ] = (byte)byte_accumulate;
                                bit_num = byte_accumulate = 0;
                            }
                        } // end foreach column
                        
                        if (bit_num != 0)
                        {
                            byte_accumulate <<= (8 - (N & 7));
                            pdata[ byte_count++ ] = (byte)byte_accumulate;
                        }
                        
                        bytes_per_line[y] = byte_count;
                    } // end while (y < N)
                } // end void run()
            }; // end inner class definition
            
            pool[i].start();
        }
        
        for (Thread t : pool)
        {
            try
            {
                t.join();
            }
            catch (InterruptedException e)
            {
                e.printStackTrace();
            }
        }
    }
}

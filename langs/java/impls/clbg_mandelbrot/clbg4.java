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
   
   modified by Henco Appel
*/

import java.io.*;
import java.util.concurrent.atomic.*;
import java.util.stream.*;

public final class mandelbrot {

   static final byte getByte(final double[] Crb, final double CibY, final int x){
      int res=0;
      for(int i=0;i<8;i+=2){
         double Zr1=Crb[x+i];
         double Zi1=CibY;

         double Zr2=Crb[x+i+1];
         double Zi2=CibY;

         int b=0;
         int j=49;do{
            double nZr1=Zr1*Zr1-Zi1*Zi1+Crb[x+i];
            Zi1=Zr1*Zi1+Zr1*Zi1+CibY;
            Zr1=nZr1;

            double nZr2=Zr2*Zr2-Zi2*Zi2+Crb[x+i+1];
            Zi2=Zr2*Zi2+Zr2*Zi2+CibY;
            Zr2=nZr2;

            if(Zr1*Zr1+Zi1*Zi1>4){b|=2;if(b==3)break;}
            if(Zr2*Zr2+Zi2*Zi2>4){b|=1;if(b==3)break;}
         }while(--j>0);
         res=(res<<2)+b;
      }
      return (byte)(res^-1);
   }

   public static void main(String[] args) throws Exception {
      int N=6000;
      if (args.length>=1)
		  N=Integer.parseInt(args[0]);

      double[] Crb=new double[N+7];
      double invN=2.0/N;
	  for(int i=0;i<N;i++){  Crb[i]=i*invN-1.5; }
	  int lineLen = (N-1)/8 + 1;
	  byte[] data = new byte[N*lineLen];
	  IntStream.range(0,N).parallel().forEach(y -> {
		  double Ciby = y*invN-1.0;
		  int offset = y*lineLen;
		  for(int x=0; x<lineLen; x++)
			  data[offset+x] = getByte(Crb, Ciby, x*8);
	  });

      OutputStream stream = new BufferedOutputStream(System.out);
      stream.write(("P4\n"+N+" "+N+"\n").getBytes());
      stream.write(data);
      stream.close();
   }
}


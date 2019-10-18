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
 * https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
 *
 * Contributed by Martin Koistinen
 * Based on mandelbrot.c contributed by Greg Buchholz and The Go Authors
 * flag.Arg hack by Isaac Gouy
 *
 * Large changes by Bill Broadley, including:
 * 1) Switching the one goroutine per line to one per CPU
 * 2) Replacing gorouting calls with channels
 * 3) Handling out of order results in the file writer.
 */

package main

import (
   "bufio"
   "flag"
   "fmt"
   "os"
   "strconv"
   "runtime"
)

/* targeting a q6600 system, one cpu worker per core */
const pool = 4

const ZERO float64 = 0
const LIMIT = 2.0
const ITER = 50   // Benchmark parameter
const SIZE = 16000

var rows []byte
var bytesPerRow int

// This func is responsible for rendering a row of pixels,
// and when complete writing it out to the file.

func renderRow(w, h, bytes int, workChan chan int,iter int, finishChan chan bool) {

   var Zr, Zi, Tr, Ti, Cr float64
   var x,i int

   for y := range workChan {

      offset := bytesPerRow * y
      Ci := (2*float64(y)/float64(h) - 1.0)

      for x = 0; x < w; x++ {
         Zr, Zi, Tr, Ti = ZERO, ZERO, ZERO, ZERO
         Cr = (2*float64(x)/float64(w) - 1.5)

         for i = 0; i < iter && Tr+Ti <= LIMIT*LIMIT; i++ {
            Zi = 2*Zr*Zi + Ci
            Zr = Tr - Ti + Cr
            Tr = Zr * Zr
            Ti = Zi * Zi
         }

         // Store the value in the array of ints
         if Tr+Ti <= LIMIT*LIMIT {
            rows[offset+x/8] |= (byte(1) << uint(7-(x%8)))
         }
      }
   }
   /* tell master I'm finished */
   finishChan <- true
}

func main() {
   runtime.GOMAXPROCS(pool) 

   size := SIZE   // Contest settings
   iter := ITER

   // Get input, if any...
   flag.Parse()
   if flag.NArg() > 0 {
      size, _ = strconv.Atoi(flag.Arg(0))
   }
   w, h := size, size
   bytesPerRow =  w / 8

   out := bufio.NewWriter(os.Stdout)
   defer out.Flush()
   fmt.Fprintf(out, "P4\n%d %d\n", w, h)

   rows = make([]byte, bytesPerRow*h)

   /* global buffer of work for workers, ideally never runs dry */
   workChan := make(chan int, pool*2+1)
   /* global buffer of results for output, ideally never blocks */
   finishChan := make(chan bool)
   // start pool workers, and assign all work
   for y := 0; y < size; y++ {
      if y < pool {
         go renderRow(w, h, bytesPerRow, workChan, iter,finishChan)
      }
      workChan <- y
   }
   /* tell the workers all done */
   close(workChan)
   /* write for the file workers to finish */
   for i:=0;i<pool;i++ {
      <- finishChan
   }
   out.Write(rows)
}

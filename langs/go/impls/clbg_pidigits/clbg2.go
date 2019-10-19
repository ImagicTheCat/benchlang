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
 * based on pidigits.c (by Paolo Bonzini & Sean Bartlett,
 *                      modified by Michael Mellor)
 *
 * contributed by The Go Authors.
 * flag.Arg hack by Isaac Gouy
 * line printer hack by Sean Lake
 * "math/big" package replaced by "github.com/ncw/gmp" by pav5000
 * modified by Bert Gijsbers
 */

package main

import (
    "bufio"
    "flag"
    "fmt"
    big "github.com/ncw/gmp"
    "os"
    "runtime"
    "strconv"
)

var n = 0
var silent = false

var (
    tmp1  = big.NewInt(0)
    tmp2  = big.NewInt(0)
    y2    = big.NewInt(1)
    bigk  = big.NewInt(0)
    accum = big.NewInt(0)
    denom = big.NewInt(1)
    numer = big.NewInt(1)
    ten   = big.NewInt(10)
    three = big.NewInt(3)
    four  = big.NewInt(4)
)

func next_term(k int64) int64 {
    for {
        k++
        y2.SetInt64(k*2 + 1)
        bigk.SetInt64(k)

        tmp1.Lsh(numer, 1)
        accum.Add(accum, tmp1)
        accum.Mul(accum, y2)
        denom.Mul(denom, y2)
        numer.Mul(numer, bigk)

        if accum.Cmp(numer) > 0 {
            return k
        }
    }
}

func extract_digit(nth *big.Int) int64 {
    tmp1.Mul(nth, numer)
    tmp2.Add(tmp1, accum)
    tmp1.Div(tmp2, denom)
    return tmp1.Int64()
}

func next_digit(k int64) (int64, int64) {
    for {
        k = next_term(k)
        d3 := extract_digit(three)
        d4 := extract_digit(four)
        if d3 == d4 {
            return d3, k
        }
    }
}

func eliminate_digit(d int64) {
    tmp1.SetInt64(d)
    accum.Sub(accum, tmp1.Mul(denom, tmp1))
    accum.Mul(accum, ten)
    numer.Mul(numer, ten)
}

func init() {
    runtime.GOMAXPROCS(1)
    flag.Parse()
    if flag.NArg() > 0 {
        n, _ = strconv.Atoi(flag.Arg(0))
    }
}

func main() {
    w := bufio.NewWriter(os.Stdout)
    defer w.Flush()
    line := make([]byte, 0, 10)
    var d, k int64
    for i := 1; i <= n; i++ {
        d, k = next_digit(k)
        line = append(line, byte(d)+'0')
        if len(line) == 10 {
            if silent != true {
                fmt.Fprintf(w, "%s\t:%d\n", string(line), i)
            }
            line = line[:0]
        }
        eliminate_digit(d)
    }
    if len(line) > 0 && silent != true {
        fmt.Fprintf(w, "%-10s\t:%d\n", string(line), n)
    }
}

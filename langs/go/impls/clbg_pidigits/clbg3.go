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
 *    modified by Michael Mellor)
 *
 * contributed by Zhao Zhiqiang.
 */

package main

/*
#cgo LDFLAGS: -lgmp
#include <gmp.h>
#include <stdlib.h>
*/
import "C"

import (
    "bufio"
    "flag"
    "fmt"
    "os"
    "runtime"
    "strconv"
)

var n = 0

func extract_digit(nth uint32) uint32 {
    C.mpz_mul_ui(&tmp1[0], &num[0], C.ulong(nth))
    C.mpz_add   (&tmp2[0], &tmp1[0], &acc[0])
    C.mpz_tdiv_q(&tmp1[0], &tmp2[0], &den[0])

    return uint32(C.mpz_get_ui(&tmp1[0]))
}

func eliminate_digit(d uint32) {
    C.mpz_submul_ui(&acc[0], &den[0], C.ulong(d))
    C.mpz_mul_ui(&acc[0], &acc[0], 10)
    C.mpz_mul_ui(&num[0], &num[0], 10)    
}

func next_term(k uint32) {
    k2 := C.ulong(k*2+1)

    C.mpz_addmul_ui(&acc[0], &num[0], 2)
    C.mpz_mul_ui(&acc[0], &acc[0], k2)
    C.mpz_mul_ui(&den[0], &den[0], k2)
    C.mpz_mul_ui(&num[0], &num[0], C.ulong(k))        
}

func init() {
    runtime.GOMAXPROCS(1)
    flag.Parse()
    if flag.NArg() > 0 {
        n, _ = strconv.Atoi(flag.Arg(0))
    }
}

var tmp1, tmp2, acc, den, num C.mpz_t

func main() {
    w := bufio.NewWriter(os.Stdout)
    defer w.Flush()

    C.mpz_init(&tmp1[0])
    C.mpz_init(&tmp2[0])

    C.mpz_init_set_ui(&acc[0], 0)
    C.mpz_init_set_ui(&den[0], 1)
    C.mpz_init_set_ui(&num[0], 1)

    k := uint32(0)
    d := uint32(0)
    for i := 0; i < n; {
        k++
        next_term(k)

        if C.mpz_cmp(&num[0], &acc[0]) > 0 {
            continue
        }

        d = extract_digit(3)
        if d != extract_digit(4) {
            continue
        }

        fmt.Printf("%d", d)

        i++
        if i % 10 == 0 {
            fmt.Printf("\t:%d\n", i)
        }

        eliminate_digit(d)
    } 
}

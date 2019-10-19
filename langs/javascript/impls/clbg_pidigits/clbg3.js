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
 * contributed by Denis Gribov
 *    a translation of the C program contributed by Mr Ledhug
 */

(function main() {

    // Int32
    let n = +process.argv[2] || 10000,
        i = 0,
        k = 0,
        d = 0,
        k2 = 0,
        d3 = 0,
        d4 = 0;

    // BigInt
    let tmp1 = 0n, // mpz_init(tmp1)
        tmp2 = 0n, // mpz_init(tmp2)
        acc = 0n, // mpz_init_set_ui(acc, 0)
        den = 1n, // mpz_init_set_ui(den, 1)
        num = 1n; // mpz_init_set_ui(num, 1)

    const chr_0 = "0".charCodeAt(),
        chr_t = "\t".charCodeAt(),
        chr_n = "\n".charCodeAt(),
        chr_c = ":".charCodeAt();

    // preallocated buffer size
    let bufsize = (10/*value of pi*/ + 2/*\t:*/ + n.toString().length/*index of slice*/ + 1/*\n*/) * (n / 10)/*line count*/;
    // croped buffer size
    for (let i = 10, length = 10 ** (Math.log10(n) >>> 0); i < length; i *= 10) {
        bufsize -= i - 1;
    }

    let buf = Buffer.allocUnsafe(bufsize),
        bufoffs = 0;

    while (i < n) {
        k++;

        //#region inline nextTerm(k)
        k2 = k * 2 + 1;
        acc += num * 2n; // mpz_addmul_ui(acc, num, 2)
        acc *= BigInt(k2); // mpz_mul_ui(acc, acc, k2)
        den *= BigInt(k2); // mpz_mul_ui(den, den, k2)
        num *= BigInt(k); // mpz_mul_ui(num, num, k)
        //#endregion inline nextTerm(k)

        if (num > acc/* mpz_cmp(num, acc) > 0 */) continue;

        //#region inline extractDigit(3);
        tmp1 = num * 3n; // mpz_mul_ui(tmp1, num, nth);
        tmp2 = tmp1 + acc; // mpz_add(tmp2, tmp1, acc);
        tmp1 = tmp2 / den; // mpz_tdiv_q(tmp1, tmp2, den);
        d3 = Number(tmp1) >>> 0; // mpz_get_ui(tmp1)
        //#region inline extractDigit(3);

        d = d3;

        //#region inline extractDigit(4);
        tmp1 = num * 4n; // mpz_mul_ui(tmp1, num, nth);
        tmp2 = tmp1 + acc; // mpz_add(tmp2, tmp1, acc);
        tmp1 = tmp2 / den; // mpz_tdiv_q(tmp1, tmp2, den);
        d4 = Number(tmp1) >>> 0; // mpz_get_ui(tmp1)
        //#region inline extractDigit(4);

        if (d !== d4) continue;

        buf.writeInt8(d + chr_0, bufoffs++);

        if (++i % 10 === 0) {
            buf.writeInt8(chr_t, bufoffs++);
            buf.writeInt8(chr_c, bufoffs++);

            let str = i.toString();
            buf.write(str, bufoffs, bufoffs += str.length);

            buf.writeInt8(chr_n, bufoffs++);
        }

        //#region inline eliminateDigit(d)
        acc -= den * BigInt(d); // mpz_submul_ui(acc, den, d)
        acc *= 10n; // mpz_mul_ui(acc, acc, 10)
        num *= 10n; // mpz_mul_ui(num, num, 10)
        //#endregion inline eliminateDigit(d)
    }

    process.stdout.write(buf);
})();

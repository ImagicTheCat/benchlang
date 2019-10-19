(*
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
*)

(*
 * The Computer Language Benchmarks Game 
 * https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
 *
 * contributed by Christophe TROESTLER
 * modified by Mat�as Giovannini
 * using Zarith with modifications inspired by C solution, by Tony Tavener
 *)

let big_3  = Z.of_int 3
let big_4  = Z.of_int 4
let big_10 = Z.of_int 10

let init = (Z.one, Z.one, Z.zero)

let extract (num,den,acc) nth = Z.((nth * num + acc) / den |> to_int)

let next z = extract z big_3

let safe z n = extract z big_4 = n

let prod (num,den,acc) d =
  Z.(big_10 * num,
     den,
     big_10 * (acc - den * of_int d))

let cons (num,den,acc) k =
  let k2 = Z.of_int (k * 2 + 1) in
  Z.(of_int k * num,
     k2 * den,
     k2 * (acc + num + num))

let columns = 10

let rec digit k z n row col =
  if n = 0 then Printf.printf "%*s\t:%i\n" (columns-col) "" (row+col) else
  let d = next z in
  if safe z d then
    if col = columns then begin
      let row = row + col in
      Printf.printf "\t:%i\n%i" row d;
      digit k (prod z d) (n-1) row 1
    end else begin 
      print_int d;
      digit k (prod z d) (n-1) row (col+1)
    end
  else digit (k+1) (cons z k) n row col

let digits n = digit 1 init n 0 0

let () = digits (try int_of_string (Array.get Sys.argv 1) with _ -> 27)



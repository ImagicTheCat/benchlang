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
 * Contributed by Paolo Ribeca
 *
 * (Very loosely based on previous version Ocaml #3,
 *  which had been contributed by
 *   Christophe TROESTLER
 *  and enhanced by
 *   Christian Szegedy and Yaron Minsky)
 *)

let niter = 50
let limit = 4.

let () =
  let w = int_of_string (Array.get Sys.argv 1) in
  let h = w in
  let fw = float w /. 2. and fh = float h /. 2. in
  Printf.printf "P4\n%i %i\n" w h;
  let red_h = h - 1 and red_w = w - 1 and byte = ref 0 in
  for y = 0 to red_h do
    let ci = float y /. fh -. 1. in
    for x = 0 to red_w do
      let cr = float x /. fw -. 1.5
      and zr = ref 0. and zi = ref 0. and trmti = ref 0. and n = ref 0 in
      begin try
	while true do
	  zi := 2. *. !zr *. !zi +. ci;
	  zr := !trmti +. cr;
	  let tr = !zr *. !zr and ti = !zi *. !zi in
	  if tr +. ti > limit then begin
	    byte := !byte lsl 1;
	    raise Exit
	  end else if incr n; !n = niter then begin
	    byte := (!byte lsl 1) lor 0x01;
	    raise Exit
	  end else
	    trmti := tr -. ti
	done
      with Exit -> ()
      end;
      if x mod 8 = 7 then output_byte stdout !byte
    done;
    let rem = w mod 8 in
    if rem != 0 then (* the row doesnt divide evenly by 8 *)
      output_byte stdout (!byte lsl (8 - rem)) (* output last few bits *)
  done

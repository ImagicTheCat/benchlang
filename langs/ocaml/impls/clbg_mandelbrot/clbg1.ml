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
 *
 * fix compile errors by using Bytes instead of String, by Tony Tavener
 *)

let niter = 50
let limit = 4.
let workers = 64

let worker w h_lo h_hi =
  let buf =
    Bytes.create ((w / 8 + (if w mod 8 > 0 then 1 else 0)) * (h_hi - h_lo))
  and ptr = ref 0 in
  let fw = float w /. 2. in
  let fh = fw in
  let red_w = w - 1 and red_h_hi = h_hi - 1 and byte = ref 0 in
  for y = h_lo to red_h_hi do
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
      if x mod 8 = 7 then begin
	Bytes.set buf !ptr (Char.chr !byte);
	incr ptr;
	byte := 0
      end
    done;
    let rem = w mod 8 in
    if rem != 0 then begin
      Bytes.set buf !ptr (Char.chr (!byte lsl (8 - rem)));
      incr ptr;
      byte := 0
    end
  done;
  buf

let _ =
  let w = int_of_string (Array.get Sys.argv 1) in
  let rows = w / workers and rem = w mod workers in
  Printf.printf "P4\n%i %i\n%!" w w;
  let rec spawn i =
    if i > 0 then
      let red_i = i - 1 in
      match Unix.fork () with
      | 0 -> spawn red_i
      | pid ->
	  let buf =
	    worker w (red_i * rows + min red_i rem) (i * rows + min i rem) in
	  match Unix.waitpid [] pid with
	  | _, Unix.WEXITED 0 ->
	      Printf.printf "%a%!" output_bytes buf;
	      exit 0
	  | _ -> assert false
    else
      exit 0 in
  spawn workers


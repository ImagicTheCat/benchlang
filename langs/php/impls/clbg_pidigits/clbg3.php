<?php 
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

   contributed by Oleksii Prudkyi
   port from pidigits.lua-5.lua (Mike Pall, Wim Couwenberg)
*/

$u = gmp_init(0);
$v = gmp_init(0);
$w = gmp_init(0);

function produce(&$n1, &$n2, &$d, $k) 
{
   global $u, $v, $w;
   $u = gmp_mul($n1, 2*$k-1);
   $v = gmp_add($n2, $n2);
   $w = gmp_mul($n1, $k-1);
   $n1 = gmp_add($u, $v);
   $u = gmp_mul($n2, $k+2);
   $n2 = gmp_add($w, $u);
   $d = gmp_mul($d, 2*$k+1);
}

function extractd(&$n1, &$n2, $d, $y)
{
   global $u;
   $u = gmp_mul($d, gmp_mul(-10, $y));
   $n1 = gmp_mul($n1, 10);
   $n1 = gmp_add($n1, $u);
   $n2 = gmp_mul($n2, 10);
   $n2 = gmp_add($n2, $u);
}

function digit($n1, $n2, $d)
{
   global $u, $v;
   $u = gmp_div_q($n1, $d);
   $v = gmp_div_q($n2, $d);
   if(gmp_cmp($u, $v) == 0) {
      return $u;
   }
   return false;
}

//Generate successive digits of PI.
function pidigits($N)
{
   $k = 1;
   $n1 = gmp_init(4);
   $n2 = gmp_init(3);
   $d = gmp_init(1);
   
   $i = 0;
   while($i < $N) {
      $y = digit($n1, $n2, $d);
      if($y !== false) {
         echo gmp_strval($y);
         $i++;
         if($i % 10 == 0) {
            echo "\t:" , $i , "\n";
         }
         extractd($n1, $n2, $d, $y);
      } else {
         produce($n1, $n2, $d, $k);
         $k++;
      }
   }
   if($i % 10 != 0) {
      echo str_repeat(' ', 10 - $N % 10), "\t:", $N, "\n";
   }
}

$N = (int) $argv[1];
ob_start();
pidigits($N);
ob_end_flush();




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

   contributed by Peter Baltruschat
*/
function Transformation_Compose($tr, $a)
{
   return array(
      gmp_mul($tr[0], $a[0]),
      gmp_add(gmp_mul($tr[0], $a[1]), gmp_mul($tr[1], $a[3])),
      gmp_add(gmp_mul($tr[2], $a[0]), gmp_mul($tr[3], $a[2])),
      gmp_add(gmp_mul($tr[2], $a[1]), gmp_mul($tr[3], $a[3]))
   );
}
function Transformation_Compose2($y, $a)
{
   return array(
      gmp_mul(10, $a[0]),
      gmp_add(gmp_mul(10, $a[1]), gmp_mul(gmp_mul(-10, $y), $a[3])),
      $a[2],
      $a[3]
   );
}
function Transformation_Extract($tr, $j)
{
   return gmp_div_q(
      gmp_add(gmp_mul($tr[0], $j), $tr[1]),
      gmp_add(gmp_mul($tr[2], $j), $tr[3])
   );
}
function Transformation_Next(&$tr)
{
   $tr[3] = (++$tr[0]<<1) + 1;
   $tr[1] = $tr[3]<<1;
   $tr[2] = 0;
   return $tr;
}
function Pidigit_Next(&$pd, $times)
{
   $digits = '';
   $z = $pd[0];
   do
   {
      $y = Transformation_Extract($z, 3);
      do
      {
         $z = Transformation_Compose($z, Transformation_Next($pd[1]));
         $y = Transformation_Extract($z, 3);
      }
      while(0 != gmp_cmp(Transformation_Extract($z, 4), $y));
      $z = Transformation_Compose2($y, $z);
      $digits .= gmp_strval($y);
   }
   while(--$times);
   $pd[0] = $z;
   return $digits;
}

$n = (int) $argv[1];
$i = 0;
$pidigit = array(array(1, 0, 0, 1), array(0, 0, 0, 0));

while($n)
{
   if($n < 10)
   {
      printf("%s%s\t:%d\n", Pidigit_Next($pidigit, $n), str_repeat(' ', 10 - $n), $i + $n);
      break;
   }
   else
   {
      printf("%s\t:%d\n", Pidigit_Next($pidigit, 10), $i += 10);
   }
   $n -= 10;
}
?>

<?php
function fib($n)
{
  if($n < 2)
    return $n;
  else
    return fib($n-2)+fib($n-1);
}

$r = fib($argv[1]);
print "$r\n";
?>

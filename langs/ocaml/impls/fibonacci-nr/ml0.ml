let rec fib n =
  if n < 2 then n
  else fib (n - 2) + fib (n - 1)

let _ =
  let n =
    try int_of_string Sys.argv.(1)
    with Invalid_argument _ -> 1 in
  Printf.printf "%d\n" (fib n)

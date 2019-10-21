return {
  version = 1,
  title = "MD5",
  description = [[
The goal is to measure implementations of the MD5 hash algorithm.
Third-party MD5 implementation dependencies are not allowed.

https://en.wikipedia.org/wiki/MD5

It is recommended to read the file once and stream the repeating data to the algorithm.

args: <filepath> <n>
- filepath: path to a binary data file
- n: number of data repetitions/concatenations
output: hash (16 bytes)
  ]],
  steps = { -- list of {params...}
    {"data/random-1MiB-79421.data", "10"},
    {"data/random-1MiB-79421.data", "50"},
    {"data/random-1MiB-79421.data", "100"}
  },
  check = {
    "d5b365bded8b4852b17d72c49192cf0faff291d3cf08bf2341767e09f19a2e76",
    "5075db6b67a49d89b58b3a0dd2627e38751de060fa0b3ae761940cedd3b850ba",
    "5bd32e05285245f01bc437a41ba3966efdda958148c397cad815c6670c6f92be"
  }
}

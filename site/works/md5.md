# MD5

`version 1`

```
The goal is to measure implementations of the MD5 hash algorithm.
Third-party MD5 implementation dependencies are not allowed.

https://en.wikipedia.org/wiki/MD5

It is recommended to read the file once and stream the repeating data to the algorithm.

args: <filepath> <n>
- filepath: path to a binary data file
- n: number of data repetitions/concatenations
output: hash (16 bytes)
  
```

## Steps

* `(data/random-1MiB-0.data, 10)`
* `(data/random-1MiB-0.data, 50)`
* `(data/random-1MiB-0.data, 100)`

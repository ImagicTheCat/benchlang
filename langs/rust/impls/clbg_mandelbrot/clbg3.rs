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

// The Computer Language Benchmarks Game
// https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
//
// contributed by Matt Watson
// contributed by TeXitoi

extern crate futures;
extern crate futures_cpupool;

use std::io::Write;
use std::ops::{Add, Mul, Sub};
use std::sync::Arc;
use futures::Future;
use futures_cpupool::{CpuPool, CpuFuture};

const MAX_ITER: usize = 50;
const VLEN: usize = 8;
const ZEROS: Vecf64 = Vecf64([0.; VLEN]);

macro_rules! for_vec {
    ( in_each [ $( $val:tt ),* ] do $from:ident $op:tt $other:ident ) => {
        $( $from.0[$val] $op $other.0[$val]; )*
    };
    ( $from:ident $op:tt $other:ident ) => {
        for_vec!(in_each [0, 1, 2, 3, 4, 5, 6, 7] do $from $op $other);
    };
}

#[derive(Clone, Copy)]
pub struct Vecf64([f64; VLEN]);
impl Mul for Vecf64 {
    type Output = Vecf64;
    fn mul(mut self, other: Vecf64) -> Vecf64 {
        for_vec!(self *= other);
        self
    }
}
impl Add for Vecf64 {
    type Output = Vecf64;
    fn add(mut self, other: Vecf64) -> Vecf64 {
        for_vec!(self += other);
        self
    }
}
impl Sub for Vecf64 {
    type Output = Vecf64;
    fn sub(mut self, other: Vecf64) -> Vecf64 {
        for_vec!(self -= other);
        self
    }
}

pub fn mbrot8(cr: Vecf64, ci: Vecf64) -> u8 {
    let mut zr = ZEROS;
    let mut zi = ZEROS;
    let mut tr = ZEROS;
    let mut ti = ZEROS;
    for _ in 0..MAX_ITER / 5 {
        for _ in 0..5 {
            zi = (zr + zr) * zi + ci;
            zr = tr - ti + cr;
            tr = zr * zr;
            ti = zi * zi;
        }
        if (tr + ti).0.iter().all(|&t| t > 4.) {
            return 0;
        }
    }
    (tr + ti).0.iter()
        .enumerate()
        .map(|(i, &t)| if t <= 4. { 0x80 >> i } else { 0 })
        .fold(0, |accu, b| accu | b)
}

fn main() {
    let size = std::env::args().nth(1).and_then(|n| n.parse().ok()).unwrap_or(200);
    let size = size / VLEN * VLEN;
    let inv = 2. / size as f64;
    let mut xloc = vec![ZEROS; size / VLEN];
    for i in 0..size {
        xloc[i / VLEN].0[i % VLEN] = i as f64 * inv - 1.5;
    }
    let xloc = Arc::new(xloc);
    let pool = CpuPool::new_num_cpus();

    let future_rows: Vec<CpuFuture<Vec<_>, ()>> = (0..size).map(|y| {
        let xloc = xloc.clone();
        let ci = Vecf64([y as f64 * inv - 1.; VLEN]);
        pool.spawn_fn(move || Ok((0..size / VLEN).map(|x| mbrot8(xloc[x], ci)).collect()))
    }).collect();

    println!("P4\n{} {}", size, size);
    let stdout_unlocked = std::io::stdout();
    let mut stdout = stdout_unlocked.lock();
    for row in future_rows {
        stdout.write_all(&row.wait().unwrap()).unwrap();
    }
}

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

/* !BENCHLANG::(DEPS)=[
rayon = "*"
]
*/

// The Computer Language Benchmarks Game
// https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
//
// contributed by Matt Watson
// contributed by TeXitoi
// contributed by Cristi Cobzarenco

extern crate rayon;

use std::io::Write;
use std::ops::{Add, Mul, Sub};
use rayon::prelude::*;

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

pub struct Mandelbrot8 {
    zr: Vecf64,
    zi: Vecf64,
    tr: Vecf64,
    ti: Vecf64,

    cr: Vecf64,
    ci: Vecf64,
    ci2: Vecf64,
}

impl Mandelbrot8 {
    pub fn new(ci: Vecf64) -> Self {
        Mandelbrot8 {
            zr: ZEROS,
            zi: ZEROS,
            tr: ZEROS,
            ti: ZEROS,

            cr: ZEROS,
            ci: ci,
            ci2: ci * ci,
        }
    }

    pub fn run(&mut self, cr: Vecf64, cr2: Vecf64) -> u8 {
        self.zr = cr;
        self.zi = self.ci;
        self.tr = cr2;
        self.ti = self.ci2;
        self.cr = cr;

        self.advance(4);
        for _ in 0..MAX_ITER / 5 - 1 {
            if self.all_diverged() {
                return 0;
            }
            self.advance(5);
        }
        self.to_byte()
    }

    fn advance(&mut self, iterations: usize) {
        for _ in 0..iterations {
            self.zi = (self.zr + self.zr) * self.zi + self.ci;
            self.zr = self.tr - self.ti + self.cr;
            self.tr = self.zr * self.zr;
            self.ti = self.zi * self.zi;
        }
    }

    fn all_diverged(&self) -> bool {
        (self.tr + self.ti).0.iter().all(|&t| t > 4.)
    }

    fn to_byte(&self) -> u8 {
        (self.tr + self.ti)
            .0
            .iter()
            .enumerate()
            .map(|(i, &t)| if t <= 4. { 0x80 >> i } else { 0 })
            .fold(0, |accu, b| accu | b)
    }
}


fn main() {
    let size = std::env::args().nth(1).and_then(|n| n.parse().ok()).unwrap_or(200);
    let size = size / VLEN * VLEN;
    let inv = 2. / size as f64;
    let mut xloc = vec![(ZEROS, ZEROS); size / VLEN];
    for i in 0..size {
        let x = i as f64 * inv - 1.5;
        (xloc[i / VLEN].0).0[i % VLEN] = x;
        (xloc[i / VLEN].1).0[i % VLEN] = x * x;
    }

    let mut output = vec![0u8; size * size / VLEN];
    output.par_chunks_mut(size / VLEN)
        .weight_max()
        .enumerate()
        .for_each(|(y, chunk)| {
            let mut m = Mandelbrot8::new(Vecf64([y as f64 * inv - 1.; VLEN]));
            for (&(x, x2), c) in xloc.iter().zip(chunk) {
                *c = m.run(x, x2);
            }
        });

    println!("P4\n{} {}", size, size);
    let stdout_unlocked = std::io::stdout();
    let mut stdout = stdout_unlocked.lock();
    stdout.write_all(&output).unwrap();
}

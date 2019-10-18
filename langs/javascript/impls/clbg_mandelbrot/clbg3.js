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

/*
 * The Computer Language Benchmarks Game
 * https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
 *
 * contributed by Andrey Filatkin
 * based on mandelbrot.go-4.go contributed by Martin Koistinen and others
 */

const { Worker, isMainThread, parentPort, workerData } = require('worker_threads');
const os = require('os');

const limit = 4;
const maxIter = 50;
const bytesPerFloat = Float64Array.BYTES_PER_ELEMENT;

if (isMainThread) {
    mainThread(+process.argv[2]);
} else {
    workerThread(workerData);
}

async function mainThread(size) {
    const bytesPerRow = size >> 3;

    const nextYSize = bytesPerFloat;
    const initialSize = size * bytesPerFloat;
    const rowsStart = nextYSize + 2 * initialSize;
    const rowsSize = size * bytesPerRow;

    const sab = new SharedArrayBuffer(nextYSize + 2 * initialSize + rowsSize);
    const initialR = new Float64Array(sab, nextYSize, size);
    const initialI = new Float64Array(sab, nextYSize + initialSize, size);
    const inv = 2 / size;
    for (let xy = 0; xy < size; xy++) {
        const i = inv * xy;
        initialR[xy] = i - 1.5;
        initialI[xy] = i - 1.0;
    }

    await work();

    process.stdout.write(`P4\n${size} ${size}\n`);
    process.stdout.write(new Uint8Array(sab, rowsStart, rowsSize));

    async function work() {
        return new Promise(resolve => {
            const cpus = os.cpus().length;
            let wait = 0;
            for (let i = 0; i < cpus; i++) {
                const worker = new Worker(__filename, {workerData: {size, bytesPerRow}});
                worker.postMessage({name: 'sab', data: sab});
                worker.on('exit', () => {
                    wait--;
                    if (wait === 0) {
                        resolve();
                    }
                });
                wait++;
            }
        });
    }
}

function workerThread({size, bytesPerRow}) {
    const nextYSize = bytesPerFloat;
    const initialSize = size * bytesPerFloat;
    const rowsStart = nextYSize + 2 * initialSize;

    let sab;
    let nextY;
    let initialR;
    let initialI;

    parentPort.on('message', message => {
        if (message.name === 'sab') {
            sab = message.data;
            nextY = new Int32Array(sab, 0, 1);
            initialR = new Float64Array(sab, nextYSize, size);
            initialI = new Float64Array(sab, nextYSize + initialSize, size);

            renderRows();
        }
    });

    function renderRows() {
        let y;
        while ((y = Atomics.load(nextY, 0)) < size) {
            if (Atomics.compareExchange(nextY, 0, y, y + 1) === y) {
                const row = new Uint8Array(sab, rowsStart + y * bytesPerRow, bytesPerRow);
                renderRow(row, y);
            }
        }
        process.exit();
    }

    function renderRow(row, y0) {
        for (let xByte = 0; xByte < bytesPerRow; xByte++) {
            const ci = initialI[y0];
            let res = 0;
            for (let i = 0; i < 8; i += 2) {
                const x = xByte << 3;
                const cr1 = initialR[x + i];
                const cr2 = initialR[x + i + 1];

                let zr1 = cr1;
                let zi1 = ci;

                let zr2 = cr2;
                let zi2 = ci;

                let b = 0;

                for (let j = 0; j < maxIter; j++) {
                    const tr1 = zr1 * zr1;
                    const ti1 = zi1 * zi1;
                    zi1 = 2 * zr1 * zi1 + ci;
                    zr1 = tr1 - ti1 + cr1;

                    if (tr1 + ti1 > limit) {
                        b |= 2;
                        if (b === 3) {
                            break;
                        }
                    }

                    const tr2 = zr2 * zr2;
                    const ti2 = zi2 * zi2;
                    zi2 = 2 * zr2 * zi2 + ci;
                    zr2 = tr2 - ti2 + cr2;

                    if (tr2 + ti2 > limit) {
                        b |= 1;
                        if (b === 3) {
                            break;
                        }
                    }
                }
                res = (res << 2) | b;
            }
            row[xByte] = ~res;
        }
    }
}

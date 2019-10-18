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

   contributed by Andreas Schmelz 2016-02-14
*/

const cluster = require('cluster');
const numCPUs = require('os').cpus().length * 2;
var fs = require('fs');

const d = parseInt(process.argv[2]) || 200;

if (d % 8 != 0) {
  console.error('d must be multiple of 8');
  process.exit(-1);
}
if (d * d / numCPUs % 8 != 0) {
  console.error('cannot distribute equal across cpus');
  process.exit(-1);
}

if (cluster.isMaster) {
  var alive = numCPUs;
  var part_buffer = new Array(numCPUs);
  for (var i = 0; i < numCPUs; i++) {
    var worker = cluster.fork();
    var j = i;

    worker.on('message', function(e) {
      part_buffer[this.id - 1] = new Buffer(e.data);
      this.kill();
      alive--;
      if (alive == 0) {
        //var fd = fs.openSync('test3.pbm', 'w');
        //fs.writeSync(fd, 'P4\n'+d+' '+d+'\n');
        process.stdout.write('P4\n'+d+' '+d+'\n')
        for (var i = 0; i < numCPUs; i++) {
          process.stdout.write(part_buffer[i]);
          //fs.writeSync(fd, part_buffer[i], 0, part_buffer[i].length);
        }
      }

    });
  }
} else if (cluster.isWorker) {
  var id = cluster.worker.id;
  var start = Math.floor((id - 1) * d / numCPUs), // incl
      end = Math.floor(id * d / numCPUs);   // excl

  var byte_acc = 0,
      bit_num = 0,
      iter = 50,
      limit = 4;

  //console.log('create buffer with '+(d * d / 8 / numCPUs));
  var buff = new Buffer(d * d / 8 / numCPUs);

  (function() {
    var xd = 2 / d;
    var it = 0;
    for (var y = start; y < end; y++) {
      var yd = 2 * y / d - 1;
      for (var x = 0; x < d; x++) {

        var sum = doCalc(
          xd * x - 1.5,
          yd
        );

        byte_acc |= (sum <= limit);
        bit_num++;

        if (bit_num === 8) {
          buff[it++] = byte_acc;
          byte_acc = 0,
          bit_num = 0;
        } else {
          byte_acc <<= 1;
        }
      }
    }
  })();

  process.send(buff);
}

function doCalc(Cr, Ci) {
  var Zr = 0,
      Zi = 0,
      Tr = 0,
      Ti = 0;
  for (var i = 0; i < iter && Tr + Ti <= limit; i++ ) {
    Zi = 2 * Zr * Zi + Ci,
    Zr = Tr - Ti + Cr,
    Tr = Zr * Zr,
    Ti = Zi * Zi;
  }
  return Tr + Ti;
};

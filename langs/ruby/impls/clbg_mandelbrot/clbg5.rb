# Revised BSD license
# 
# This is a specific instance of the Open Source Initiative (OSI) BSD license template
# http://www.opensource.org/licenses/bsd-license.php
# 
# 
# Copyright © 2004-2008 Brent Fulgham, 2005-2019 Isaac Gouy
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# 
#    Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
#    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# 
#    Neither the name of "The Computer Language Benchmarks Game" nor the name of "The Computer Language Benchmarks Game Benchmarks" nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
#
#  contributed by Karl von Laudermann
#  modified by Jeremy Echols
#  modified by Detlef Reichl
#  modified by Joseph LaFata
#  modified by Peter Zotov
#  parallelised by Scott Leggett

module MiniParallel
    class Worker
        def initialize(read, write)
            @read, @write = read, write
        end

        def close_pipes
            @read.close
            @write.close
        end

        def work(index)
            Marshal.dump(index, @write)
            Marshal.load(@read)
        end
    end

    def self.map(array, &block)
        work_in_processes(
            array,
            [array.size, core_count].min,
            &block
        )
    end

    def self.core_count
        @@core_count ||= IO.read("/proc/cpuinfo").scan(/^processor/).size
    end

    private

    def self.work_in_processes(array, count, &block)
        index = -1
        results, threads = [], []

        workers = create_workers(array, count, &block)

        workers.each do |worker|
            threads << Thread.new do
              loop do
                Thread.exclusive{ index += 1 }
                break if index >= array.size
                results[index] = worker.work(index)
              end
              worker.close_pipes
            end
        end

        threads.each(&:join)
        Process.waitall

        results
    end

    def self.create_workers(array, count, &block)
        workers = []
        count.times do
            workers << create_worker(array, workers, &block)
        end
        workers
    end

    def self.create_worker(array, started_workers, &block)
        child_read, parent_write = IO.pipe
        parent_read, child_write = IO.pipe

        Process.fork do
            started_workers.each(&:close_pipes)

            parent_write.close
            parent_read.close

            process_incoming_jobs(child_read, child_write, array, &block)

            child_read.close
            child_write.close
        end

        child_read.close
        child_write.close

        Worker.new(parent_read, parent_write)
    end

    def self.process_incoming_jobs(read, write, array, &block)
        until read.eof?
            index = Marshal.load(read)
            Marshal.dump(block.call(array[index]), write)
        end
    end
end

Size = ARGV.shift.to_i

puts "P4\n#{Size} #{Size}"

def row y
    byte_acc = 0
    bit_num = 0
    res = []
    ci = (2.0*y/Size)-1.0
    x = 0
    while x < Size
        zrzr = zr = 0.0
        zizi = zi = 0.0
        cr = (2.0*x/Size)-1.5
        escape = 0b1

        z = 0
        while z < 50
            tr = zrzr - zizi + cr
            ti = 2.0*zr*zi + ci
            zr = tr
            zi = ti
            # preserve recalculation
            zrzr = zr*zr
            zizi = zi*zi
            if zrzr+zizi > 4.0
                escape = 0b0
                break
            end
            z += 1
        end

        byte_acc = (byte_acc << 1) | escape
        bit_num += 1

        # Code is very similar for these cases, but using separate blocks
        # ensures we skip the shifting when it's unnecessary, which is most
        # cases.
        if (bit_num == 8)
            res << byte_acc.chr
            byte_acc = 0
            bit_num = 0
        elsif (x == Size - 1)
            byte_acc <<= (8 - bit_num)
            res << byte_acc.chr
            byte_acc = 0
            bit_num = 0
        end
        x += 1
    end
    res.join
end

if MiniParallel.core_count > 1
    if RUBY_PLATFORM == 'java'
        threads = []
        out = []
        (0...Size).each do |w|
            threads << Thread.new do
                out[w] = row w
            end
        end
        threads.all?(&:join)
        print out.join
    else
        print MiniParallel.map((0...Size).to_a){|y|row y}.join
    end
else
    (0...Size).each{|i|print row i}
end

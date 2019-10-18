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
# Contributed by Aaron Tavistock

WORKER_COUNT = begin
  cpu_count = if File.readable?('/proc/cpuinfo') # Linux
    %x(cat /proc/cpuinfo | grep -c processor).chomp.to_i
  elsif File.executable?('/usr/sbin/sysctl')  #OS/X
    %x(/usr/sbin/sysctl -n hw.ncpu).chomp.to_i
  else
    1
  end
  [(cpu_count * 2.0).to_i, 2].max
rescue
  2
end

class WorkerPool

  def initialize
    @work = Queue.new
    @pool = Array.new(WORKER_COUNT) do |i|
      Thread.new do
        Thread.current[:id] = i
        catch(:exit) do
          while(true) do
            work, args = @work.pop
            work.call(*args)
          end
        end
      end
    end
  end

  def schedule(*args, &block)
    @work << [block, args]
  end

  def shutdown
    @pool.size.times do
      schedule { throw :exit }
    end
    @pool.each do |t|
      t.join
    end
  end

end

class Mandel

  attr_reader :output

  def initialize(size)
    @size = size.to_i
    @output = Array.new(@size)
    @two_over_size = 2.0 / @size.to_f
  end

  def process
    workers = WorkerPool.new
    @size.times do |row|
      workers.schedule(row) do |y|
        @output[y] = process_row(y)
      end
    end
    workers.shutdown
  end

  def process_row(y)
    ci = (@two_over_size * y.to_f) - 1.0
    render_row(ci)
  end

  def forking_process_row(y)
    read, write = IO.pipe
    Process.fork do
      read.close
      ci = (@two_over_size * y.to_f) - 1.0
      write.print( render_row(ci) )
    end
    Process.wait
    write.close
    read.read
  end

  if RUBY_PLATFORM != 'java'
    alias_method :original_process_row, :process_row
    alias_method :process_row, :forking_process_row
  end

  def header
    "P4\n#{@size} #{@size}"
  end

  private

  def render_row(ci)
    row_bits = Array.new(@size) do |col|
      cr = (@two_over_size * col.to_f) - 1.5
      get_bit(cr, ci)
    end

    row = ''
    row_bits.each_slice(8) do |byte|
      if byte.size < 8
        byte = byte.fill(0, byte.size, 8 - byte.size)
      end
      row << byte.join.to_i(2).chr
    end
    row
  end

  def get_bit(cr, ci)
    zrzr = 0.0
    zizi = 0.0
    zrzi = 0.0

    count = 50
    while count > 0

      zr = zrzr - zizi + cr
      zi = 2.0 * zrzi + ci

      zrzr = zr * zr
      zizi = zi * zi
      zrzi = zr * zi

      if zrzr + zizi > 4.0
        return 0b0
      end

      count -= 1
    end

    0b1
  end

end

size = ARGV.shift || 1000
m = Mandel.new(size)
m.process
print "#{m.header}\n#{m.output.join}"

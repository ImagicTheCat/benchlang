--[[
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
]]

-- The Computer Language Benchmarks Game
-- https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
-- contributed by Mike Pall
-- modified by Rob Kendrick to be parallel
-- modified by Isaac Gouy
-- modified by ImagicTheCat (fix popen args)

-- called with the following arguments on the command line;
-- 1: size of mandelbrot to generate
-- 2: number of children to spawn (defaults to 6, which works well on 4-way)
-- If this is a child, then there will be additional parameters;
-- 3: start row
-- 4: end row
--
-- Children buffer up their output and emit it to stdout when
-- finished, to avoid stalling due to a full pipe.

local width = tonumber(arg and arg[1]) or 100
local children = tonumber(arg and arg[2]) or 6
local srow = tonumber(arg and arg[3])
local erow = tonumber(arg and arg[4])

local height, wscale = width, 2/width
local m, limit2 = 50, 4.0
local write, char = io.write, string.char

local pre_args = {}
do
  local i = -1
  while arg[i] ~= nil do
    table.insert(pre_args, 1, arg[i])
    i = i-1
  end
end

if not srow then
   -- we are the parent process.  emit the header, and then spawn children
   
   local workunit = math.floor(width / (children + 1))
   local handles = { }
   
   write("P4\n", width, " ", height, "\n")
   
   children = children - 1
   
   for i = 0, children do
      local cs, ce
      
      if i == 0 then
         cs = 0
         ce = workunit
      elseif i == children then
         cs = (workunit * i) + 1
         ce = width - 1
      else
         cs = (workunit * i) + 1
         ce = cs + workunit - 1
      end
      
      handles[i + 1] = io.popen(("%s %s %d %d %d %d"):format(
         table.concat(pre_args, " "), arg[0], width, children + 1, cs, ce))
   end
   
   -- collect answers, and emit
   for i = 0, children do
      write(handles[i + 1]:read "*a")
   end
   
else
   -- we are a child process.  do the work allocated to us.
   local obuff = { }
   for y=srow,erow do
     local Ci = 2*y / height - 1
     for xb=0,width-1,8 do
      local bits = 0
      local xbb = xb+7
      for x=xb,xbb < width and xbb or width-1 do
        bits = bits + bits
        local Zr, Zi, Zrq, Ziq = 0.0, 0.0, 0.0, 0.0
        local Cr = x * wscale - 1.5
        for i=1,m do
         local Zri = Zr*Zi
         Zr = Zrq - Ziq + Cr
         Zi = Zri + Zri + Ci
         Zrq = Zr*Zr
         Ziq = Zi*Zi
         if Zrq + Ziq > limit2 then
           bits = bits + 1
           break
         end
        end
      end
      if xbb >= width then
        for x=width,xbb do bits = bits + bits + 1 end
      end
      obuff[#obuff + 1] = char(255 - bits)
     end
   end
   
   write(table.concat(obuff))
end

-- requires LuaJIT

-- DEF

-- return (true, ...) or (false, err) on failure
local function loadconfig(path)
  local f, err = loadfile(path)
  if f then
    return pcall(f)
  else
    return false, err
  end
end

local ffi = require("ffi")
local C = ffi.C
ffi.cdef([[
typedef struct{
  long int pid;
  int fd_read;
  bool running;
  int status;
  double start_time;
  double time, utime, stime;
  long maxrss;
} subproc_t;

bool subproc_create(char * const argv[], subproc_t *data);
int subproc_step(subproc_t *p, void *buf, size_t count, int timeout);
void subproc_kill(subproc_t *p);
void subproc_close(subproc_t *p);
double mclock();
void set_signal_handler(void (*handler)(int));
]])
local lib = ffi.load("./libbenchmark.so")

local subproc = ffi.new("subproc_t")

-- capture end of child (subproc) process
lib.set_signal_handler(function(signal)
  subproc.time = lib.mclock()-subproc.start_time
end)

-- return output string or nil on failure
local function measure_subproc(args, timeout, step_delay)
  -- convert to C args
  if #args < 1 then return end
  local cargs = ffi.new("const char*[?]", #args+1, args)
  cargs[#args] = nil

  -- create sub process
  if lib.subproc_create(ffi.cast("char * const*", cargs), subproc) then
    print(tonumber(subproc.pid), unpack(args)) -- debug
    local outs = {}
    local data = ffi.new("char[4096]")

    -- read output, check for timeout
    local n = lib.subproc_step(subproc, data, 4096, step_delay)

    while n ~= 0 or subproc.running do -- read all output and wait end of process
      print("read",n,subproc.running) -- debug
      if n > 0 then table.insert(outs, ffi.string(data, n)) end -- append output

      -- timeout check
      if lib.mclock()-subproc.start_time > timeout then
        lib.subproc_kill(subproc)
      end

      n = lib.subproc_step(subproc, data, 4096, step_delay)
    end

    lib.subproc_close(subproc)

    print(subproc.status, subproc.time, subproc.utime, subproc.stime, tonumber(subproc.maxrss)) -- debug

    if subproc.status == 0 then
      return table.concat(outs)
    end
  end
end

local function compute_work(host, lang, work, env, impl)
end

-- EXEC

-- params
local phost, plang, penv, pwork, pimpl = ...
if not phost then error("missing host") end

-- load host
local ok, host = loadconfig("hosts/"..phost..".lua")
if not ok then error(host) end

-- load langs
local langs = {}
local p_langs = {plang}
if #p_langs == 0 then -- all langs
  local f = io.popen("find langs/ -mindepth 1 -maxdepth 1 -type d")
  local line = f:read("*l")
  while line do
    local lang = string.match(line, "^langs/(.*)$")
    if lang then table.insert(p_langs, lang) end
    line = f:read("*l")
  end
  f:close()

  for _, lang in ipairs(p_langs) do
    local ok, cfg = loadconfig("langs/"..lang.."/config.lua")
    if ok then
      langs[lang] = cfg
    else
      print(cfg)
    end
  end
end

print("host", host.title)

measure_subproc({"ls", "-a"}, 5, host.step_delay)
measure_subproc({"sleep", "3"}, 5, host.step_delay)
measure_subproc({"sleep", "20"}, 5, host.step_delay)
measure_subproc({"luajit", "-e", "while true do end"}, 5, host.step_delay)
measure_subproc({"dsfslfdkjflk", "3"}, 5, host.step_delay)

-- require LuaJIT
-- generate some site data files

local msgpack = require("MessagePack")
local sha2 = require("./extern/sha2/sha2")

-- consts
local FP = 3 -- float precision, number of decimals

print("generate site")

-- popen followed by string match for each line
-- return list of captures {...}
local function popen_match(cmd, pattern)
  local r = {}

  local f = io.popen(cmd)
  local line = f:read("*l")
  while line do
    local captures = {string.match(line, pattern)}
    if #captures > 0 then table.insert(r, captures) end
    line = f:read("*l")
  end
  f:close()

  return r
end

-- return (true, ...) or (false, err) on failure
local function loadconfig(path)
  local f, err = loadfile(path)
  if f then
    return pcall(f)
  else
    return false, err
  end
end

local hosts = {}
local langs = {}
local works = {}

local function getHost(host)
  local cfg = hosts[host]
  if cfg == nil then
    local ok
    print("load host: "..host)
    ok, cfg = loadconfig("hosts/"..host..".lua")
    if not ok then print(cfg) end
    cfg = (ok and cfg or false)
    if cfg then
      cfg.env_infos = {}
      cfg.works_results = {}
    end
    hosts[host] = cfg
  end

  return cfg
end

local function getLang(lang)
  local cfg = langs[lang]
  if cfg == nil then
    local ok
    print("load lang: "..lang)
    ok, cfg = loadconfig("langs/"..lang.."/config.lua")
    if not ok then print(cfg) end
    cfg = (ok and cfg or false)
    if cfg then cfg.envs = {} end
    langs[lang] = cfg
  end

  return cfg
end

local function getEnv(lang, env)
  local lcfg = getLang(lang)
  if lcfg then
    local cfg = lcfg.envs[env]
    if cfg == nil then
      local ok
      print("load env: "..lang.."/"..env)
      ok, cfg = loadconfig("langs/"..lang.."/envs/"..env..".lua")
      if not ok then print(cfg) end
      cfg = (ok and cfg or false)
      lcfg.envs[env] = cfg
    end

    return cfg
  end
end

local function getWork(work)
  local cfg = works[work]
  if cfg == nil then
    local ok
    print("load work: "..work)
    ok, cfg = loadconfig("works/"..work..".lua")
    if not ok then print(cfg) end
    cfg = (ok and cfg or false)
    works[work] = cfg
  end

  return cfg
end

-- GENERATE

local results = popen_match("find results/ -type f", "^results/(.-)/(.-)/(.-)/(.-)/(.-)%.data$")
for _, captures in ipairs(results) do
  local host, lang, env, work, impl = unpack(captures)
  local hcfg, lcfg, ecfg, wcfg = getHost(host), getLang(lang), getEnv(lang, env), getWork(work)

  print("load result: ", table.concat(captures, "/"))
  local f, err = io.open("results/"..table.concat(captures,"/",1,#captures-1).."/"..impl..".data", "rb")
  if f then
    local result = msgpack.unpack(f:read("*a"))
    f:close()

    -- compute implementation hash
    local impl_hash
    local i_f, err = io.open("langs/"..lang.."/impls/"..work.."/"..impl)
    if i_f then
      impl_hash = sha2.sha256(i_f:read("*a"))
      i_f:close()
    end

    -- index env infos
    if hcfg and lcfg and ecfg then hcfg.env_infos[lang.."/"..env] = result.host_info end

    -- index valid results
    if hcfg and lcfg and ecfg and wcfg
      and result.env_version == ecfg.version and result.work_version == wcfg.version -- check versions
      and result.impl_hash == impl_hash then -- check hash

      -- aggregate measures for each work step
      local steps = {}
      for step in ipairs(wcfg.steps) do
        local measures = result.steps[step]
        local ag = {}

        for _, measure in ipairs(measures) do
          if not measure.err then
            ag.min_time = math.min(ag.min_time or measure.time, measure.time)
            ag.min_stime = math.min(ag.min_stime or measure.stime, measure.stime)
            ag.min_utime = math.min(ag.min_utime or measure.utime, measure.utime)
            ag.max_maxrss = math.max(ag.max_maxrss or measure.maxrss, measure.maxrss)
          else -- error
            ag.err = measure.err
            ag.status = measure.status

            -- add available measures for more insight
            ag.min_time = measure.time
            ag.min_stime = measure.stime
            ag.min_utime = measure.utime
            ag.max_maxrss = measure.maxrss

            break
          end
        end

        table.insert(steps, ag)
      end

      local work_results = hcfg.works_results[work]
      if not work_results then
        work_results = {}
        hcfg.works_results[work] = work_results
      end

      table.insert(work_results, {
        data = result,
        steps = steps,

        host = host,
        lang = lang,
        env = env,
        impl = impl
      })
    end
  else
    print(err)
  end
end

-- write index
do
  print("gen index")
  os.execute("mkdir -p site/")

  local f, err = io.open("site/index.md", "w")
  if f then
    -- hosts index
    f:write("# Benchlang\n\n"..[[
This project aims to be a tool, a collection of measures and a website about benchmarking languages and their implementations. Measures are nice; interpretation of those measures is up to human beings.

More informations on the [project]({{site.github.repository_url}}) page.
    ]])
    f:write("\n\n## Hosts\n\n")
    for host, cfg in pairs(hosts) do
      f:write("* ["..cfg.title.."]({{site.baseurl}}/hosts/"..host..") - [results]({{site.baseurl}}/results/"..host..")\n")
    end

    -- langs index
    f:write("\n\n## Languages\n\n")
    for lang, cfg in pairs(langs) do
      f:write("* ["..cfg.title.."]({{site.baseurl}}/langs/"..lang..")\n")
    end

    -- works index
    f:write("\n\n## Works\n\n")
    for work, cfg in pairs(works) do
      f:write("* ["..cfg.title.."]({{site.baseurl}}/works/"..work..")\n")
    end
  else
    print(err)
  end
end

-- write host files
os.execute("mkdir -p site/hosts")
for host, cfg in pairs(hosts) do
  print("gen host: "..host)
  local f, err = io.open("site/hosts/"..host..".md", "w")
  if f then
    f:write("# "..cfg.title.."\n\n```\n"..cfg.description.."\n```\n\n## Parameters\n\n")
    f:write("```\nmeasures: "..cfg.measures.."\ntimeout: "..cfg.timeout.." s\ncheck delay: "..cfg.check_delay.." ms\n```\n\n")
    f:write("## Environments\n\n")
    for lang_env, info in pairs(cfg.env_infos) do
      local lang, env = string.match(lang_env, "^(.-)/(.-)$")
      local lcfg = getLang(lang)
      local ecfg = getEnv(lang, env)
      f:write("### ["..lcfg.title.."]({{site.baseurl}}/langs/"..lang..") / ["..ecfg.title.."]({{site.baseurl}}/langs/"..lang.."/envs/"..env..")\n\n```\n"..info.."\n```\n\n")
    end

    f:close()
  else
    print(err)
  end
end

-- write work files
os.execute("mkdir -p site/works")

for work, cfg in pairs(works) do
  print("gen work: "..work)
  local f, err = io.open("site/works/"..work..".md", "w")
  if f then
    f:write("# "..cfg.title.."\n\n`version "..cfg.version.."`\n\n```\n"..cfg.description.."\n```\n\n## Steps\n\n")
    for i, args in ipairs(cfg.steps) do
      f:write("* `("..table.concat(args, ",")..")`\n")
    end
    f:close()
  else
    print(err)
  end
end

-- write lang/env files

for lang, cfg in pairs(langs) do
  print("gen lang: "..lang)
  os.execute("mkdir -p site/langs/"..lang.."/envs")

  -- write lang file
  local f, err = io.open("site/langs/"..lang.."/index.md", "w")
  if f then
    f:write("# "..cfg.title.."\n\n```\n"..cfg.description.."\n```\n\n## Environments\n\n")

    -- write env files and lang-env index
    for env, ecfg in pairs(cfg.envs) do
      print("gen env: "..env)

      f:write("* ["..ecfg.title.."]({{site.baseurl}}/langs/"..lang.."/envs/"..env..")\n")

      local e_f, err = io.open("site/langs/"..lang.."/envs/"..env..".md", "w")
      if e_f then
        e_f:write("# "..ecfg.title.."\n\n`version "..ecfg.version.."`\n\n```\n"..ecfg.description.."\n```")
        e_f:close()
      else
        print(err)
      end
    end

    f:close()
  else
    print(err)
  end
end

-- write aggregated results per host/work

do
  local function sort_results(a, b)
    return a.err_mod < b.err_mod or (a.err_mod == b.err_mod and a.min_time < b.min_time)
  end

  for host, hcfg in pairs(hosts) do -- each host
    -- write host works index
    os.execute("mkdir -p site/results/"..host)
    print("gen host results: "..host)
    local h_f = io.open("site/results/"..host.."/index.md", "w")
    h_f:write("# ["..hcfg.title.."]({{site.baseurl}}/hosts/"..host..") work results\n\n## Works\n\n")

    for work, results in pairs(hcfg.works_results) do -- each work => results
      local wcfg = getWork(work)

      os.execute("mkdir -p site/results/"..host.."/"..work)
      -- host work index: link to first step results
      h_f:write("* ["..wcfg.title.."]({{site.baseurl}}/results/"..host.."/"..work.."/1-2)\n")

      for step, args in ipairs(wcfg.steps) do -- each step
        local step_results = {}

        for _, result in ipairs(results) do
          local measure = result.steps[step]

          table.insert(step_results, {
            err_mod = measure.err and 1 or 0,
            min_time = measure.min_time or 0,
            result = result
          })
        end

        -- sort results
        table.sort(step_results, sort_results)

        -- write step results
        print("gen host/work/step results: "..host.."/"..work.."/"..step)
        local s_fs = {} -- lang, env, impl depth files
        table.insert(s_fs, io.open("site/results/"..host.."/"..work.."/"..step.."-1.md", "w"))
        table.insert(s_fs, io.open("site/results/"..host.."/"..work.."/"..step.."-2.md", "w"))
        table.insert(s_fs, io.open("site/results/"..host.."/"..work.."/"..step.."-3.md", "w"))

        for depth, s_f in ipairs(s_fs) do -- each depth file
          --- host / work title / header
          s_f:write("# ["..hcfg.title.."]({{site.baseurl}}/hosts/"..host..") / ["..wcfg.title.."]({{site.baseurl}}/works/"..work..") results\n\n")
          s_f:write("[< back]({{site.baseurl}}/results/"..host..")\n")
          --- steps navigation
          for s_step, args in ipairs(wcfg.steps) do
            local title = "("..table.concat(args, ",")..")"
            if s_step == step then -- active page
              s_f:write("* "..title.."\n")
            else
              s_f:write("* ["..title.."]({{site.baseurl}}/results/"..host.."/"..work.."/"..s_step.."-"..depth..")\n")
            end
          end
          --- depth navigation
          s_f:write("\n**depth:** ")
          s_f:write(depth ~= 1 and "[lang]({{site.baseurl}}/results/"..host.."/"..work.."/"..step.."-1) | " or "lang | ")
          s_f:write(depth ~= 2 and "[env]({{site.baseurl}}/results/"..host.."/"..work.."/"..step.."-2) | " or "env | ")
          s_f:write(depth ~= 3 and "[impl]({{site.baseurl}}/results/"..host.."/"..work.."/"..step.."-3)" or "impl")
          --- results
          s_f:write("\n\nrank | lang | env | status | time (s) | CPU user (s) | CPU sys (s) | mem (KB) | impl\n")
          s_f:write("--- | --- | --- | --- | --- | --- | --- | --- | ---\n")
        end

        local lang_ignores = {}
        local lang_env_ignores = {}

        -- generate entries
        for rank, entry in ipairs(step_results) do
          local r = entry.result
          local measure = r.steps[step]
          local lcfg = getLang(r.lang)
          local ecfg = getEnv(r.lang,r.env)

          local err_str
          if measure.err then
            err_str = "err: "..(measure.err == "status" and measure.err.." "..measure.status or measure.err)
          else
            err_str = "OK"
          end

          for depth, s_f in ipairs(s_fs) do
            local display = false
            if depth == 1 and not lang_ignores[r.lang] then
              lang_ignores[r.lang] = true
              display = true
            elseif depth == 2 and not lang_env_ignores[r.lang.."/"..r.env] then
              lang_env_ignores[r.lang.."/"..r.env] = true
              display = true
            elseif depth == 3 then
              display = true
            end

            if display then
              s_f:write(rank.." | ["..lcfg.title.."]({{site.baseurl}}/langs/"..r.lang..")"
                .." | ["..ecfg.title.."]({{site.baseurl}}/langs/"..r.lang.."/envs/"..r.env..")"
                .." | "..err_str
                .." | "..(measure.min_time and string.format("%."..FP.."f", measure.min_time) or "--")
                .." | "..(measure.min_utime and string.format("%."..FP.."f", measure.min_utime) or "--")
                .." | "..(measure.min_stime and string.format("%."..FP.."f", measure.min_stime) or "--")
                .." | "..(measure.max_maxrss or "--")
                .." | ["..r.impl.."]({{site.github.repository_url}}/blob/master/langs/"..r.lang.."/impls/"..work.."/"..r.impl..")\n")
            end
          end
        end

        for depth, s_f in ipairs(s_fs) do
          s_f:close()
        end
      end
    end

    h_f:close()
  end
end

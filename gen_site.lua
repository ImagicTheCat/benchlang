-- require LuaJIT
-- generate some site data files

local msgpack = require("MessagePack")
local sha2 = require("./extern/sha2/sha2")

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
    local i_f = io.open(table.concat({lang, env, impl}, "/"))
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

        for measure in ipairs(measures) do
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
            ag.max_maxrss = measure.max_maxrss

            break
          end
        end

        table.insert(steps, ag)
      end

      hcfg.works_results[work] = {
        data = result,
        steps = steps,

        host = host,
        lang = lang,
        env = env,
        impl = impl
      }
    end
  else
    print(err)
  end
end

-- write index
do
  print("gen index")
  local f, err = io.open("site/index.md", "w")
  if f then
    -- hosts index
    f:write("# Benchlang\n\n## Hosts\n\n")
    for host, cfg in pairs(hosts) do
      f:write("* ["..cfg.title.."]({{site.baseurl}}/hosts/"..host..") - [results]({{site.baseurl}}/results/hosts/"..host..")\n")
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
  end

  for host, hcfg in pairs(hosts) do
    for work, results in pairs(hcfg.works_results) do
      local wcfg = getWork(work)
      for step in ipairs(wcfg.steps) do -- each work step
        local work_results = {}
        table.insert(work_results, {
          measure = results.steps[step], -- ...
        })
      end
    end
  end
end

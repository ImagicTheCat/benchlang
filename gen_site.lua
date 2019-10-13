-- require LuaJIT
-- generate some site data files

local msgpack = require("MessagePack")

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
    if cfg then cfg.env_infos = {} end
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

    -- index env infos
    if hcfg and lcfg and ecfg then hcfg.env_infos[lang.."/"..env] = result.host_info end
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
    f:write("# "..cfg.title.."\n\n```\n"..cfg.description.."\n```\n\n## Steps\n\n")
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
        e_f:write("# "..ecfg.title.."\n\n```\n"..ecfg.description.."\n```")
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

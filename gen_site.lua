-- require LuaJIT
-- generate some site data files

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
    print("load host "..host)
    ok, cfg = loadconfig("hosts/"..host..".lua")
    if not ok then print(cfg) end
    hosts[host] = (ok and cfg or false)
  end

  return cfg
end

local function getLang(lang)
  local cfg = langs[lang]
  if cfg == nil then
    local ok
    print("load lang "..lang)
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
      print("load env "..lang.."/"..env)
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
    print("load work "..work)
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

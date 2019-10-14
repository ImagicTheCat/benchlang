return {
  version = 1,
  title = "test",
  description = [[
Test work.
  ]],
  steps = { -- list of {params...}
    {"1"},
    {"2"},
    {"3"}
  },
  check = function(output, n)
    return tonumber(output) == tonumber(n)*10
  end
}

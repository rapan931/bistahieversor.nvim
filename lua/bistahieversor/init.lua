local M = {}

local api = vim.api
local fn = vim.fn

---@class bistahieversorConfig
---@field maxcount number
---@field timeout number
local config = {
  maxcount = 99,
  timeout = 0
}

---@param override bistahieversorConfig
M.setup = function(override)
  config = vim.tbl_extend('force', config, override)
end

M.echo = function()
  local result = fn.searchcount({
    recompute = 1,
    maxcount = config.maxcount,
    timeout = config.timeout
  })

  local current, total = result.current, result.total
  local word = fn.getreg('/')

  local str = ''
  if result.incomplete == 1 then
    str = string.format('%s[?/?]', word)
  elseif result.incomplete == 2 then
    if result.total > result.maxcount and result.current > result.maxcount then
      str = string.format('%s[>%d/>%d]', word, current, total)
    elseif result.total > result.maxcount then
      str = string.format('%s[%d/>%d]', word, current, total)
    end
  else
    str = string.format('%s[%d/%d]', word, current, total)
  end

  api.nvim_echo({{str}}, false, {})
end

M.n_and_echo = function()
  vim.cmd[[normal! n]]
  M.echo()
end

M.N_and_echo = function()
  vim.cmd[[normal! N]]
  M.echo()
end

return M

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

---@param key 'n' | 'N'
local function do_jump_cmd(key)
  local ok, result = pcall(
    vim.cmd,
    'normal! ' .. key
  )

  if ok == false then
    result = string.gsub(result, '^Vim%(normal%):', '')
    api.nvim_echo({{result, 'ErrorMsg'}}, true, {})
  end

  return ok
end

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
  if do_jump_cmd('n') == false then
    return
  end

  M.echo()
end

M.N_and_echo = function()
  if do_jump_cmd('N') == false then
    return
  end

  M.echo()
end

return M

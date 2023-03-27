local M = {}

local api = vim.api
local fn = vim.fn

---@class bistahieversorConfig
---@field maxcount number
---@field timeout number
---@field echo_wrapscan boolean
---@field search_hit_bottom_msg string[]
---@field search_hit_top_msg string[]
local config = {
  maxcount = 500,
  timeout = 0,
  echo_wrapscan = false,
  search_hit_bottom_msg = { "search hit BOTTOM, continuing at TOP", "ErrorMsg" },
  search_hit_top_msg = { "search hit TOP, continuing at BOTTOM", "ErrorMsg" },
}

local function get_search_count_msg()
  local result = fn.searchcount({
    recompute = 1,
    maxcount = config.maxcount,
    timeout = config.timeout,
  })

  local current, total = result.current, result.total
  local word = fn.getreg("/")

  local str = ""
  if result.incomplete == 1 then
    str = string.format("%s[?/?]", word)
  elseif result.incomplete == 2 then
    if result.total > result.maxcount and result.current > result.maxcount then
      str = string.format("%s[>%d/>%d]", word, current, total)
    elseif result.total > result.maxcount then
      str = string.format("%s[%d/>%d]", word, current, total)
    end
  else
    str = string.format("%s[%d/%d]", word, current, total)
  end

  return str
end

---@param before_pos string[]
---@param current_pos string[]
---@return boolean whether or not you jumped to the back
local function jumped_back(before_pos, current_pos)
  if current_pos[2] < before_pos[2] then
    return true
  elseif current_pos[2] > before_pos[2] then
    return false
  else
    if current_pos[3] < before_pos[3] then
      return true
    else
      return false
    end
  end
end

---@param before_pos string[]
---@param current_pos string[]
---@return boolean whether or not you jumped to the forward
local function jumped_forward(before_pos, current_pos)
  if current_pos[2] > before_pos[2] then
    return true
  elseif current_pos[2] < before_pos[2] then
    return false
  else
    if current_pos[3] > before_pos[3] then
      return true
    else
      return false
    end
  end
end

---@param key 'n' | 'N'
---@param before_pos table<number> getpos() result
---@return string[]  search_hit_bottom_msg or search_hit_top_msg or empty
local function get_wrapscan_msg(key, before_pos)
  local current_pos = fn.getpos(".")
  if key == "n" and jumped_back(before_pos, current_pos) then
    return config.search_hit_bottom_msg
  elseif key == "N" and jumped_forward(before_pos, current_pos) then
    return config.search_hit_top_msg
  end

  return {}
end

---@param key 'n' | 'N'
local function jump_and_echo(key)
  local before_pos = fn.getpos(".")
  local ok, result = pcall(vim.cmd, "normal! " .. key)

  if ok == false and result ~= nil then
    api.nvim_echo({ { string.gsub(result, "^.*Vim%(normal%):", ""), "ErrorMsg" } }, true, {})
    return
  end

  local search_count_msg = get_search_count_msg()

  if config.echo_wrapscan == true then
    local wrapscan_msg = get_wrapscan_msg(key, before_pos)
    if #wrapscan_msg == 0 then
      api.nvim_echo({ { search_count_msg } }, false, {})
    else
      api.nvim_echo({ { search_count_msg }, { " " }, wrapscan_msg }, false, {})
    end
  else
    api.nvim_echo({ { search_count_msg } }, false, {})
  end
end

---@param override bistahieversorConfig
M.setup = function(override) config = vim.tbl_extend("force", config, override) end

M.echo = function()
  local search_count_msg = get_search_count_msg()
  api.nvim_echo({ { search_count_msg } }, false, {})
end

M.n_and_echo = function() jump_and_echo("n") end

M.N_and_echo = function() jump_and_echo("N") end

return M

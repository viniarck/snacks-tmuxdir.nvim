local M = {}

function M.is_in_tmux()
  local t = vim.env.TMUX
  return t ~= nil and t ~= ""
end

function M.list_sessions()
  local output = vim.fn.systemlist("tmux list-sessions -F '#S' 2>/dev/null")
  local sessions = {}
  for _, s in ipairs(output) do
    if s ~= "" then
      table.insert(sessions, s)
    end
  end
  return sessions
end

function M.mapped_sessions()
  local set = {}
  for _, name in ipairs(M.list_sessions()) do
    set[name] = true
  end
  return set
end

function M.new_session(name, start_dir, shell_cmd)
  shell_cmd = shell_cmd or "nvim -c 'e .'"
  local cmd = string.format(
    "tmux new-session -d -s %s -c %s %s",
    vim.fn.shellescape(name),
    vim.fn.shellescape(start_dir),
    shell_cmd
  )
  vim.fn.system(cmd)
end

function M.kill_session(name)
  vim.fn.system("tmux kill-session -t " .. vim.fn.shellescape(name))
end

function M.switch_client(name)
  vim.fn.system("tmux switch-client -t " .. vim.fn.shellescape(name))
end

return M

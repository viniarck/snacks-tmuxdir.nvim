local M = {}

function M.ensure_trailing_sep(dir)
  if dir:sub(-1) ~= "/" then
    return dir .. "/"
  end
  return dir
end

function M.replace_dots(name)
  return (name:gsub("%.", "-"))
end

function M.dir_to_session_name(dir)
  local abbreviated = vim.fn.fnamemodify(dir, ":~")
  return M.replace_dots(abbreviated)
end

function M.find_git_repos(find_cmd, base_dir)
  local dir = M.ensure_trailing_sep(vim.fn.expand(base_dir))
  local cmd = vim.list_extend(vim.deepcopy(find_cmd), { dir })
  local output = vim.fn.systemlist(table.concat(
    vim.tbl_map(vim.fn.shellescape, cmd), " "
  ))
  local repos = {}
  for _, line in ipairs(output) do
    if line ~= "" then
      if line:sub(-1) == "/" then
        line = line:sub(1, -2)
      end
      local repo = vim.fn.fnamemodify(line, ":h")
      if repo ~= "" then
        if repo:sub(1, 1) ~= "/" then
          repo = dir .. repo
        end
        table.insert(repos, repo)
      end
    end
  end
  return repos
end

return M

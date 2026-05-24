local M = {}

local config = {
  base_dirs = {},
  find_cmd  = { "fd", "-HI", "^.git$", "-d", "2" },
  shell_cmd = "nvim -c 'e .'",
}

local function merge_opts(base, override)
  local result = vim.deepcopy(base)
  if override then
    for k, v in pairs(override) do
      result[k] = v
    end
  end
  return result
end

local function guard_tmux()
  local tmux = require("snacks_tmuxdir.tmux")
  if not tmux.is_in_tmux() then
    vim.notify("snacks-tmuxdir: not inside a tmux session", vim.log.levels.WARN)
    return false
  end
  return true
end

local function build_sessions_source()
  return {
    finder = function(opts, ctx)
      local tmux = require("snacks_tmuxdir.tmux")
      local items = {}
      for _, name in ipairs(tmux.list_sessions()) do
        table.insert(items, { text = name, name = name })
      end
      return items
    end,

    format = function(item, ctx)
      return { { item.text, "Normal" } }
    end,

    confirm = "sessions_switch",

    actions = {
      sessions_switch = function(picker, item)
        if not item then return end
        local tmux = require("snacks_tmuxdir.tmux")
        picker:close()
        tmux.switch_client(item.name)
      end,

      sessions_delete = function(picker, item)
        if not item then return end
        local tmux = require("snacks_tmuxdir.tmux")
        tmux.kill_session(item.name)
        picker:refresh()
      end,
    },

    win = {
      input = {
        keys = {
          ["<C-d>"] = { "sessions_delete", mode = { "i", "n" } },
          ["d"]     = { "sessions_delete", mode = { "n" } },
        },
      },
    },
  }
end

local function build_dirs_source()
  return {
    finder = function(opts, ctx)
      local utils = require("snacks_tmuxdir.utils")
      local items = {}
      local base_dirs = opts.base_dirs or {}
      local find_cmd  = opts.find_cmd  or config.find_cmd
      for _, base_dir in ipairs(base_dirs) do
        local repos = utils.find_git_repos(find_cmd, base_dir)
        for _, repo in ipairs(repos) do
          table.insert(items, {
            text = repo,
            dir  = repo,
            name = utils.dir_to_session_name(repo),
          })
        end
      end
      return items
    end,

    format = function(item, ctx)
      return { { item.text, "Normal" } }
    end,

    confirm = "dirs_switch",

    actions = {
      dirs_switch = function(picker, item)
        if not item then return end
        local tmux      = require("snacks_tmuxdir.tmux")
        local sessions  = tmux.mapped_sessions()
        local name      = item.name
        local shell_cmd = picker.opts.shell_cmd or config.shell_cmd
        if not sessions[name] then
          tmux.new_session(name, item.dir, shell_cmd)
        end
        picker:close()
        tmux.switch_client(name)
      end,

      dirs_extra = function(picker, item)
        if not item then return end
        local dir = item.dir
        local base_name = item.name
        local shell_cmd = picker.opts.shell_cmd or config.shell_cmd
        picker:close()
        vim.ui.input({ prompt = "Session suffix: " }, function(suffix)
          if not suffix or suffix == "" then return end
          local tmux     = require("snacks_tmuxdir.tmux")
          local utils    = require("snacks_tmuxdir.utils")
          local extra    = utils.replace_dots(base_name .. "-" .. suffix)
          local sessions = tmux.mapped_sessions()
          if not sessions[extra] then
            tmux.new_session(extra, dir, shell_cmd)
          end
          tmux.switch_client(extra)
        end)
      end,
    },

    win = {
      input = {
        keys = {
          ["<C-e>"] = { "dirs_extra", mode = { "i", "n" } },
          ["e"]     = { "dirs_extra", mode = { "n" } },
        },
      },
    },
  }
end

function M.setup(opts)
  config = merge_opts(config, opts)
  Snacks.picker.sources.tmuxdir_sessions = build_sessions_source()
  Snacks.picker.sources.tmuxdir_dirs     = build_dirs_source()
end

function M.sessions(opts)
  if not guard_tmux() then return end
  Snacks.picker("tmuxdir_sessions", merge_opts(config, opts))
end

function M.dirs(opts)
  if not guard_tmux() then return end
  Snacks.picker("tmuxdir_dirs", merge_opts(config, opts))
end

return M

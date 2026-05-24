# snacks-tmuxdir.nvim

A [snacks.nvim](https://github.com/folke/snacks.nvim) picker plugin for tmux workflow — switch sessions and create sessions from git repositories.

Port of [telescope-tmuxdir.nvim](https://github.com/viniarck/telescope-tmuxdir.nvim) for the Snacks picker.

## Pickers

### `sessions`

Lists active tmux sessions.

| Key | Action |
|-----|--------|
| `<Enter>` | Switch to session |
| `<C-d>` / `d` | Kill (delete) session |

### `dirs`

Discovers git repositories under configured `base_dirs` and creates tmux sessions in them.

| Key | Action |
|-----|--------|
| `<Enter>` | Create session (if absent) and switch |
| `<C-e>` / `e` | Prompt for a suffix, create `<name>-<suffix>` session and switch |

## Requirements

- [snacks.nvim](https://github.com/folke/snacks.nvim)
- [fd](https://github.com/sharkdp/fd) (default `find_cmd`) or any other find command
- Must be run from inside a tmux session

## Installation

### lazy.nvim

```lua
{
  "viniarck/snacks-tmuxdir.nvim",
  dependencies = { "folke/snacks.nvim" },
  opts = {
    base_dirs = { "~/repos", "~/work" },
    -- find_cmd = { "fd", "-HI", "^.git$", "-d", "2" },  -- default
    -- shell_cmd = "nvim -c 'e .'",                        -- default
  },
  config = function(_, opts)
    require("snacks_tmuxdir").setup(opts)
  end,
  keys = {
    { "<leader>ts", function() require("snacks_tmuxdir").sessions() end, desc = "Tmux sessions" },
    { "<leader>td", function() require("snacks_tmuxdir").dirs() end,     desc = "Tmux dirs" },
  },
}
```

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `base_dirs` | `string[]` | `{}` | Root directories to search for git repos |
| `find_cmd` | `string[]` | `{"fd", "-HI", "^.git$", "-d", "2"}` | Command used to locate `.git` directories |
| `shell_cmd` | `string` | `"nvim -c 'e .'"` | Command run when creating a new session |

You can also pass any option per-call to override the setup defaults:

```lua
require("snacks_tmuxdir").dirs({
  base_dirs = { "~/personal" },
  shell_cmd = "bash",
})
```

## Session Naming

Session names are derived from the directory basename, with dots replaced by dashes (tmux does not allow dots in session names). For example, `my.project` becomes `my-project`.

-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Dedicated venv for remote-plugin deps (pynvim, jupyter_client, ...). Created
-- by bootstrap.sh so Molten works without polluting project venvs.
vim.g.python3_host_prog = vim.fn.expand("~/.virtualenvs/neovim/bin/python3")

-- Molten: run code in a Jupyter kernel and see the output inline.
-- https://github.com/benlubas/molten-nvim
--
-- Molten is a remote plugin, so it needs pynvim + jupyter_client in the python
-- that `vim.g.python3_host_prog` (see config/options.lua) points at. That venv
-- is created by bootstrap.sh. Run `:checkhealth molten` if something is off.
return {
  {
    "benlubas/molten-nvim",
    version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
    dependencies = { "3rd/image.nvim" },
    build = ":UpdateRemotePlugins",
    lazy = false, -- remote plugins need to be on the rtp at startup
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = true
      vim.g.molten_wrap_output = true
      -- Show output as virtual text below the cell so it stays visible after
      -- the cursor leaves the cell
      vim.g.molten_virt_text_output = true
      -- Place virt text output below the closing ``` when running markdown cells
      vim.g.molten_virt_lines_off_by_1 = true
    end,
    keys = {
      { "<localleader>mi", ":MoltenInit<CR>", desc = "Molten init kernel", silent = true },
      -- Start the kernel matching the active venv, falling back to python3
      {
        "<localleader>ip",
        function()
          local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
          if venv ~= nil then
            venv = string.match(venv, "/.+/(.+)")
            vim.cmd(("MoltenInit %s"):format(venv))
          else
            vim.cmd("MoltenInit python3")
          end
        end,
        desc = "Molten init python kernel",
        silent = true,
      },
      { "<localleader>e", ":MoltenEvaluateOperator<CR>", desc = "Molten evaluate operator", silent = true },
      { "<localleader>rl", ":MoltenEvaluateLine<CR>", desc = "Molten evaluate line", silent = true },
      { "<localleader>rr", ":MoltenReevaluateCell<CR>", desc = "Molten re-evaluate cell", silent = true },
      { "<localleader>r", ":<C-u>MoltenEvaluateVisual<CR>gv", mode = "v", desc = "Molten evaluate selection", silent = true },
      { "<localleader>rd", ":MoltenDelete<CR>", desc = "Molten delete cell", silent = true },
      { "<localleader>oh", ":MoltenHideOutput<CR>", desc = "Molten hide output", silent = true },
      { "<localleader>os", ":noautocmd MoltenEnterOutput<CR>", desc = "Molten show/enter output", silent = true },
      { "<localleader>mx", ":MoltenOpenInBrowser<CR>", desc = "Molten open output in browser", silent = true },
    },
  },
  {
    -- Renders images in the terminal. Needs imagemagick on the system and a
    -- terminal that speaks the kitty graphics protocol (WezTerm does with
    -- enable_kitty_graphics = true).
    "3rd/image.nvim",
    build = false, -- use the imagemagick CLI instead of building the lua rock
    opts = {
      backend = "kitty",
      processor = "magick_cli",
      -- Snacks already handles markdown images in LazyVim, so leave the
      -- document integrations off and let Molten drive this plugin
      integrations = {},
      -- max_width/max_height must be set or large images can crash the terminal
      max_width = 100,
      max_height = 12,
      -- Let Molten size its output windows without percentage caps
      max_height_window_percentage = math.huge,
      max_width_window_percentage = math.huge,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    },
  },
}

-- Quarto notebooks (.qmd): LSP inside code cells via otter.nvim, and cell
-- runner keymaps that send code to Molten. `quarto render` turns the same
-- file into a PDF (typst) with outputs. Needs the quarto CLI on PATH.
-- https://github.com/quarto-dev/quarto-nvim
return {
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "quarto", "markdown" },
    opts = {
      lspFeatures = {
        enabled = true,
        chunks = "curly", -- only ```{python} fences get LSP, plain ``` ones don't
        languages = { "python", "bash" },
        diagnostics = { enabled = true, triggers = { "BufWritePost" } },
        completion = { enabled = true },
      },
      codeRunner = {
        enabled = true,
        default_method = "molten",
      },
    },
    -- Buffer-local to notebook filetypes so Molten's own maps still apply in .py files
    keys = {
      { "<localleader>rc", function() require("quarto.runner").run_cell() end, desc = "Quarto run cell", silent = true, ft = { "quarto", "markdown" } },
      { "<localleader>ra", function() require("quarto.runner").run_above() end, desc = "Quarto run cell and above", silent = true, ft = { "quarto", "markdown" } },
      { "<localleader>rb", function() require("quarto.runner").run_below() end, desc = "Quarto run cell and below", silent = true, ft = { "quarto", "markdown" } },
      { "<localleader>rA", function() require("quarto.runner").run_all() end, desc = "Quarto run all cells", silent = true, ft = { "quarto", "markdown" } },
      { "<localleader>rl", function() require("quarto.runner").run_line() end, desc = "Quarto run line", silent = true, ft = { "quarto", "markdown" } },
      { "<localleader>r", function() require("quarto.runner").run_range() end, mode = "v", desc = "Quarto run visual range", silent = true, ft = { "quarto", "markdown" } },
      { "<localleader>qp", function() require("quarto").quartoPreview() end, desc = "Quarto preview", silent = true, ft = { "quarto", "markdown" } },
    },
  },
  {
    "jmbuhr/otter.nvim",
    opts = {},
  },
  {
    -- .qmd needs the markdown grammars (already pulled in by the markdown extra)
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "markdown", "markdown_inline", "python", "yaml" } },
  },
}

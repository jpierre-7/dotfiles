# Notebook workflow

How to start, work on, and submit a notebook-style project (homework, data
analysis) with this setup. The stack:

| Piece | Role |
|-------|------|
| `.qmd` file ([Quarto markdown](https://quarto.org/docs/get-started/hello/text-editor.html)) | The notebook: prose, ```` ```{python} ```` cells, YAML header |
| Project venv + Jupyter kernel | Where your packages live; the kernel is a pointer to the venv's Python |
| [Molten](https://github.com/benlubas/molten-nvim) | Runs cells interactively in Neovim, shows output under the cell |
| [quarto-nvim](https://github.com/quarto-dev/quarto-nvim) + otter | Completion/diagnostics inside cells, `\rc`-style run keys |
| `quarto render` | Re-executes the whole file from a clean kernel and writes the PDF (typst engine, no LaTeX) |

`~/.virtualenvs/neovim` is Molten's own venv (created by `bootstrap.sh`). Never
install project packages there.

## 1. New project

```fish
mkdir ~/Projects/hw2; cd ~/Projects/hw2
python -m venv venv
source venv/bin/activate.fish

# kernel + what quarto needs to execute cells, then whatever the project needs
pip install ipykernel jupyter-core nbclient nbformat pyyaml
pip install numpy matplotlib pandas

# register a kernel that points at THIS venv, named after the project dir
python -m ipykernel install --user --name hw2 --display-name "Python (hw2)"

cp ~/.config/nvim/templates/notebook.qmd hw2.qmd
```

Then edit the header of `hw2.qmd`: set `title`, and set `jupyter: hw2` so Quarto
renders with the same kernel.

Why the kernel name matters: `\ip` in Neovim reads `$VIRTUAL_ENV`. If the venv
dir is named `venv`/`.venv` it uses the *project directory name* as the kernel,
so `~/Projects/hw2/venv` -> kernel `hw2`. Match that and `\ip` just works.

## 2. Working

**Always activate the venv first**, then open the file:

```fish
cd ~/Projects/hw2; source venv/bin/activate.fish
nvim hw2.qmd
```

Activation is what makes Quarto, Pyright (otter) and `\ip` all agree on which
Python to use. Without it Pyright reports missing imports and `quarto render`
falls back to the system Python.

`<localleader>` is `\`.

| Keys | Action |
|------|--------|
| `\ip` | Start the kernel for the active venv (`:MoltenInit hw2` does the same from anywhere) |
| `\rc` | Run the cell under the cursor |
| `\ra` / `\rb` | Run this cell and everything above / below |
| `\rA` | Run all cells |
| `\rl` / visual `\r` | Run the current line / selection |
| `\os` / `\oh` | Enter / hide the floating output window (scroll long output, copy text) |
| `\rr` | Re-run the Molten cell under the cursor after editing it |
| `\rd` | Delete a Molten cell's output |
| `\mx` | Open an HTML output (e.g. a pandas DataFrame) in the browser |
| `\qp` | Live HTML preview of the whole document in the browser |
| `:MoltenInfo` | Which kernels exist / are running |
| `:MoltenRestart!` | Restart the kernel and clear outputs |

Output appears as virtual text under the closing ```` ``` ````. Plots render
inline (image.nvim over WezTerm's kitty graphics).

Cell options go on `#|` lines at the top of a cell:

````markdown
```{python}
#| echo: false        # hide the code in the PDF, keep the output
#| fig-cap: "Figure 1: sin(x)"
#| label: fig-sin
plt.plot(x, y)
```
````

Installing a new package mid-session: `pip install` in the activated venv, then
`:MoltenRestart` so the kernel picks it up.

## 3. Submitting

```fish
quarto render hw2.qmd        # -> hw2.pdf next to it
```

This starts a fresh kernel and runs every cell top to bottom, so the PDF can
never contain stale output, and a cell that only worked because of something
you ran earlier in the session will fail here. That is the point: if it
renders, the notebook is reproducible.

Useful variations:

```fish
quarto render hw2.qmd --to html      # HTML instead
quarto preview hw2.qmd               # auto-rerender on save, opens in browser
quarto check jupyter                 # diagnose "which Python/kernel is this using"
```

Header knobs live under `format: typst:` (see the template): `papersize`,
`margin`, `toc`, `number-sections`, `fontsize`, `mainfont`.

## 4. Housekeeping

- `quarto render` leaves a `.quarto/` cache dir and, for some formats, a
  `hw2_files/` dir. Git-ignore both.
- Kernels are plain files in `~/.local/share/jupyter/kernels/<name>/`. If you
  delete or move a venv, re-run the `ipykernel install` line (or
  `jupyter kernelspec remove <name>` for a dead one).
- If Molten misbehaves: `:checkhealth molten`, then `:UpdateRemotePlugins` and
  restart Neovim (needed after Molten updates).

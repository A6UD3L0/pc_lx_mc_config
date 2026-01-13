# Portable ML Lab - Environment Summary

## System Overview

| Component | Version/Details |
|-----------|-----------------|
| **Base Image** | Ubuntu 22.04 |
| **Python** | 3.11.14 (via uv) |
| **Neovim** | 0.11.5 (LazyVim) |
| **Tmux** | 3.2a |
| **Shell** | Zsh + Oh My Zsh |

---

## Python Packages

### Core ML/Data Science
| Package | Purpose |
|---------|---------|
| **torch** | Deep learning framework |
| **numpy** | Numerical computing |
| **pandas** | Data manipulation |
| **scikit-learn** | Machine learning |
| **matplotlib** | Visualization |

### MLOps Tools
| Package | Purpose |
|---------|---------|
| **dvc** | Data version control |
| **kedro** | ML pipeline framework |

### Jupyter Ecosystem
| Package | Purpose |
|---------|---------|
| **jupyterlab** | Web-based notebooks |
| **jupyter-console** | Terminal-based REPL |
| **ipykernel** | Jupyter kernel |
| **ipywidgets** | Interactive widgets |

### Development
| Package | Purpose |
|---------|---------|
| **pynvim** | Neovim Python support |
| **basedpyright** | Python LSP |
| **ruff** | Fast Python linter |

---

## Jupyter Kernels

| Kernel | Display Name |
|--------|--------------|
| `pde-kernel` | PDE Python 3.11 |
| `python3` | Python 3 |

---

## Tmux Windows Layout

```
┌─────────────────────────────────────────────────────────┐
│ Window 1: Editor                                        │
│ ┌─────────────────────────┬───────────────────────────┐ │
│ │                         │   Terminal (zsh)          │ │
│ │    Neovim               ├───────────────────────────┤ │
│ │    (70%)                │   Python REPL             │ │
│ │                         │   (>>>)                   │ │
│ └─────────────────────────┴───────────────────────────┘ │
├─────────────────────────────────────────────────────────┤
│ Window 2: Pipeline                                      │
│ ┌───────────────────────┬─────────────────────────────┐ │
│ │   DVC Shell           │   Kedro Shell              │ │
│ │   (dvc commands)      │   (kedro commands)         │ │
│ └───────────────────────┴─────────────────────────────┘ │
├─────────────────────────────────────────────────────────┤
│ Window 3: Jupyter                                       │
│ ┌─────────────────────────────────────────────────────┐ │
│ │   Jupyter Console (In [1]:)                         │ │
│ ├─────────────────────────────────────────────────────┤ │
│ │   Shell (zsh)                                       │ │
│ └─────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────┤
│ Window 4: Git                                           │
│ ┌─────────────────────────────────────────────────────┐ │
│ │   Lazygit                                           │ │
│ └─────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────┤
│ Window 5: Logs                                          │
│ ┌─────────────────────────────────────────────────────┐ │
│ │   Shell (zsh)                                       │ │
│ ├─────────────────────────────────────────────────────┤ │
│ │   htop                                              │ │
│ └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

## Key Bindings Quick Reference

### Tmux (Prefix: Ctrl-a)

| Key | Action |
|-----|--------|
| `Ctrl-a d` | Detach |
| `Ctrl-a 1-5` | Switch window |
| `Ctrl-a h/j/k/l` | Navigate panes |
| `Ctrl-a z` | Zoom pane |
| `Ctrl-a [` | Copy mode |

### Neovim (Leader: Space)

| Key | Action |
|-----|--------|
| `Space f f` | Find files |
| `Space f g` | Live grep |
| `Space e` | File explorer |
| `Space l g` | Lazygit |
| `K` | Hover docs |
| `gd` | Go to definition |

### Molten (Jupyter in Neovim)

| Key | Action |
|-----|--------|
| `Space m i` | Init kernel |
| `Space m c` | **Evaluate cell (# %%)** |
| `Space m l` | Evaluate line |
| `Space m v` | Evaluate visual |
| `Space m n` | Next cell |
| `Space m p` | Previous cell |
| `Space m a` | Run cell & advance |
| `Space m o` | Show output |
| `Space m h` | Hide output |
| `Space m r` | Restart kernel |

---

## Cell-Based Workflow (# %% markers)

Create Python files with `# %%` cell markers:

```python
# %% Imports
import numpy as np
import pandas as pd

# %% Load Data  
df = pd.read_csv('data.csv')
print(df.head())

# %% Analysis
result = df.describe()
print(result)

# %% Visualization
import matplotlib.pyplot as plt
plt.plot(df['x'], df['y'])
plt.show()
```

**Workflow:**
1. Open file: `:e notebook_demo.py`
2. Init kernel: `Space m i` → select `pde-kernel`
3. Navigate cells: `Space m n` / `Space m p`
4. Run cell: `Space m c`
5. Run & advance: `Space m a`

---

## Directory Structure

```
/projects/          ← Your mounted project folder
/workspace/         ← Persistent workspace
/home/dev/          ← User home directory
  ├── .config/
  │   ├── nvim/     ← Neovim config (LazyVim)
  │   └── tmuxp/    ← Tmux session configs
  ├── .tmux.conf    ← Tmux configuration
  └── .zshrc        ← Shell configuration
/opt/venv/          ← Python virtual environment
```

---

## Common Commands

### Start & Stop
```bash
# Start environment
docker compose up -d
docker compose exec -u dev mlops-env tmuxp load -d ~/.config/tmuxp/lab.yaml
docker compose exec -u dev mlops-env tmux attach -t mlops

# Stop environment
docker compose down

# Full rebuild
docker compose down && docker compose build --no-cache && docker compose up -d
```

### Python
```bash
python script.py          # Run script
python                    # Interactive REPL
jupyter console --kernel=pde-kernel   # Jupyter console
```

### DVC
```bash
dvc init                  # Initialize DVC
dvc add data/             # Track data
dvc repro                 # Reproduce pipeline
dvc dag                   # Show DAG
dvc push                  # Push to remote
dvc pull                  # Pull from remote
```

### Kedro
```bash
kedro new                 # Create project
kedro run                 # Run pipeline
kedro viz                 # Visualize pipeline
kedro catalog list        # List data catalog
```

### Git (Lazygit)
```
Space   Stage/unstage
c       Commit
P       Push
p       Pull
b       New branch
?       Help
q       Quit
```

---

## Network & Ports

| Service | Port | Binding |
|---------|------|---------|
| SSH | 2222 | 127.0.0.1 |
| Jupyter | 8888 | 127.0.0.1 |

All ports bound to localhost for security.

---

## Neovim Plugins (LazyVim)

### Core
- **lazy.nvim** - Plugin manager
- **telescope.nvim** - Fuzzy finder
- **nvim-treesitter** - Syntax highlighting
- **nvim-lspconfig** - LSP support
- **nvim-cmp** - Autocompletion

### Data Science
- **molten-nvim** - Jupyter integration
- **image.nvim** - Image rendering
- **quarto-nvim** - Quarto support
- **otter.nvim** - Embedded code LSP

### Utilities
- **oil.nvim** - File explorer
- **undotree** - Undo history
- **nvim-osc52** - Clipboard (SSH/Docker)

---

## Files Created by Tutorial

| File | Description |
|------|-------------|
| `/projects/hello.py` | Hello World script |
| `/projects/plot_demo.py` | Matplotlib demo |
| `/projects/notebook_demo.py` | Cell-based notebook demo |
| `/projects/plot_test.png` | Generated plot |
| `/projects/histogram_test.png` | Generated histogram |

---

## Troubleshooting

### Molten not working
```bash
# Re-register remote plugins
nvim -c "UpdateRemotePlugins" -c "qa"
```

### Kernel not found
```bash
jupyter kernelspec list
```

### Permission issues
```bash
# Check user ID matches host
id
```

### Tmux session lost
```bash
tmuxp load -d ~/.config/tmuxp/lab.yaml
tmux attach -t mlops
```

---

## Quick Start Checklist

- [ ] Start container: `docker compose up -d`
- [ ] Load tmux: `docker compose exec -u dev mlops-env tmuxp load -d ~/.config/tmuxp/lab.yaml`
- [ ] Attach: `docker compose exec -u dev mlops-env tmux attach -t mlops`
- [ ] Open file: `:e notebook_demo.py`
- [ ] Init Molten: `Space m i` → `pde-kernel`
- [ ] Run cell: `Space m c`
- [ ] Navigate: `Space m n` / `Space m p`

---

**Environment built and verified on:** January 2026

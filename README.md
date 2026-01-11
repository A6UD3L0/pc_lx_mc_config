# 🧪 Portable ML Lab - Docker IDE

A portable, containerized Neovim IDE for MLOps and Data Science.  
All configs are **baked into the Docker image** - no setup required.

---

## 🚀 Quick Start (New Computer)

### Step 1: Install Prerequisites

| OS | Install |
|----|---------|
| **macOS** | [Docker Desktop](https://www.docker.com/products/docker-desktop) |
| **Windows** | [Docker Desktop](https://www.docker.com/products/docker-desktop) (enable WSL2) |
| **Linux** | `sudo apt install docker.io docker-compose` |

### Step 2: Clone This Repo

```bash
git clone https://github.com/yourusername/portable-ml-lab.git
cd portable-ml-lab
```

### Step 3: Set Your Project Folder

Edit `.env` file:
```bash
# macOS/Linux
HOST_PROJECTS_PATH=~/Desktop/my-project

# Windows (use forward slashes)
HOST_PROJECTS_PATH=C:/Users/YourName/Desktop/my-project
```

### Step 4: Build & Start

```bash
# Build the image (first time only, takes ~5 min)
docker compose build

# Start container
docker compose up -d

# Start tmux session
docker compose exec -u dev mlops-env tmuxp load -d /home/dev/.config/tmuxp/lab.yaml

# Attach to IDE
docker compose exec -u dev mlops-env tmux attach -t mlops
```

**Done!** You're now in the IDE.

---

## 📋 Daily Usage

### Start IDE
```bash
cd portable-ml-lab
docker compose up -d
docker compose exec -u dev mlops-env tmuxp load -d /home/dev/.config/tmuxp/lab.yaml
docker compose exec -u dev mlops-env tmux attach -t mlops
```

### Detach (Keep Running)
```
Ctrl-a d
```

### Reattach
```bash
docker compose exec -u dev mlops-env tmux attach -t mlops
```

### Stop Container
```bash
docker compose stop
```

### Resume Later
```bash
docker compose start
docker compose exec -u dev mlops-env tmux attach -t mlops
```

---

## ⌨️ Key Bindings

### Neovim (LazyVim)

| Key | Action |
|-----|--------|
| `Space` | Show command menu |
| `Space e` | File Explorer |
| `Space ff` | Find Files |
| `Space fg` | Live Grep |
| `Space gg` | LazyGit |
| `jk` | Exit insert mode |
| `gd` | Go to Definition |
| `K` | Hover docs |

### Tmux Windows

| Key | Window | Description |
|-----|--------|-------------|
| `Ctrl-a 1` | Editor | Neovim + 2 terminals |
| `Ctrl-a 2` | Pipeline | DVC + Kedro panes |
| `Ctrl-a 3` | Jupyter | Kernel + Molten help |
| `Ctrl-a 4` | Git | LazyGit |
| `Ctrl-a 5` | Logs | System logs + htop |

### Tmux Commands

| Key | Action |
|-----|--------|
| `Ctrl-a d` | Detach (keep running) |
| `Ctrl-a h/j/k/l` | Navigate panes |
| `Ctrl-a \|` | Split vertical |
| `Ctrl-a -` | Split horizontal |

### Molten (Jupyter in Neovim)

| Key | Action |
|-----|--------|
| `<leader>mi` | Init kernel |
| `<leader>ml` | Evaluate line |
| `<leader>mv` | Evaluate visual selection |
| `<leader>mc` | Re-evaluate cell |
| `<leader>mo` | Show output |
| `<leader>mh` | Hide output |
| `<leader>mx` | Interrupt kernel |

---

## 📁 Folder Structure

```
Your Computer                    Inside Container
─────────────                    ────────────────
~/Desktop/my-project    →        /projects/
./workspace             →        /workspace/
```

Your project folder is mounted at `/projects` inside the container.

---

## 🐍 Python Environment

Pre-installed packages:
- PyTorch 2.9+
- Kedro 1.1+
- DVC 3.66+
- pandas, numpy, matplotlib
- jupyter, pynvim

### Create Project venv
```bash
cd /projects
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

---

## 🪟 Windows Setup

1. Install **Docker Desktop** with WSL2 backend
2. Clone repo in PowerShell:
   ```powershell
   git clone https://github.com/yourusername/portable-ml-lab.git
   cd portable-ml-lab
   ```
3. Edit `.env`:
   ```
   HOST_PROJECTS_PATH=C:/Users/YourName/Desktop/cs303
   ```
4. Run:
   ```powershell
   docker compose build
   docker compose up -d
   docker compose exec -u dev mlops-env tmuxp load -d /home/dev/.config/tmuxp/lab.yaml
   docker compose exec -u dev mlops-env tmux attach -t mlops
   ```

---

## 🔧 Troubleshooting

### Container won't start
```bash
docker compose logs mlops-env
```

### Tmux session not found
```bash
docker compose exec -u dev mlops-env tmuxp load -d /home/dev/.config/tmuxp/lab.yaml
```

### Files not visible in /projects
Check your `HOST_PROJECTS_PATH` in `.env` and restart:
```bash
docker compose down && docker compose up -d
```

### Neovim plugins not working
```bash
docker compose exec -u dev mlops-env nvim --headless "+Lazy! sync" +qa
```

---

## 📜 One-Liner Commands

```bash
# Start fresh
docker compose up -d && docker compose exec -u dev mlops-env tmuxp load -d /home/dev/.config/tmuxp/lab.yaml && docker compose exec -u dev mlops-env tmux attach -t mlops

# Quick reattach
docker compose exec -u dev mlops-env tmux attach -t mlops

# Full reset
docker compose down && docker compose build --no-cache && docker compose up -d
```

---

## 📂 What's Included

- **LazyVim** - Full Neovim distribution
- **Tmux** - Terminal multiplexer with 5 windows
- **Python 3.11** - With ML packages
- **Git + LazyGit** - Version control
- **Kedro + DVC** - ML pipelines
- **Image.nvim** - Inline image rendering
- **Molten.nvim** - Jupyter notebook support

All configs are **permanently baked into the Docker image**.

---

## 📚 Full Tutorial

See **[TUTORIAL.md](TUTORIAL.md)** for:
- Step-by-step Hello World
- Creating plots with Molten
- DVC data versioning guide
- Kedro ML pipelines tutorial
- Git/Lazygit workflow
- Complete command reference

# Portable ML Lab - Windows Setup Guide

Complete step-by-step guide for running Portable ML Lab on Windows.

---

## Prerequisites

| Requirement | Version | Download |
|-------------|---------|----------|
| Windows | 10/11 (64-bit) | - |
| Docker Desktop | 4.x+ | [docker.com](https://www.docker.com/products/docker-desktop) |
| WSL2 | Enabled | Built into Windows |
| Git | Any | [git-scm.com](https://git-scm.com/download/win) |

---

## Step 1: Install Docker Desktop

### 1.1 Download Docker Desktop

Go to: https://www.docker.com/products/docker-desktop

Click **"Download for Windows"**

### 1.2 Run Installer

1. Double-click `Docker Desktop Installer.exe`
2. **IMPORTANT**: Check ✅ "Use WSL 2 instead of Hyper-V"
3. Click "Ok" and wait for installation
4. Restart your computer when prompted

### 1.3 Complete Setup

1. After restart, Docker Desktop will launch
2. Accept the license agreement
3. Wait for Docker to start (whale icon in system tray)
4. Open PowerShell and verify:

```powershell
docker --version
# Should show: Docker version 24.x.x or higher
```

---

## Step 2: Enable WSL2 (if not already)

### 2.1 Open PowerShell as Administrator

Right-click Start → "Windows Terminal (Admin)" or "PowerShell (Admin)"

### 2.2 Enable WSL

```powershell
wsl --install
```

If already installed, update it:

```powershell
wsl --update
```

### 2.3 Set WSL2 as Default

```powershell
wsl --set-default-version 2
```

### 2.4 Restart Computer

```powershell
shutdown /r /t 0
```

---

## Step 3: Clone the Repository

### Option A: Using PowerShell

```powershell
# Navigate to where you want the project
cd C:\Users\YourName\Desktop

# Clone the repository
git clone https://github.com/yourusername/portable-ml-lab.git

# Enter the directory
cd portable-ml-lab
```

### Option B: Using Git Bash

```bash
cd ~/Desktop
git clone https://github.com/yourusername/portable-ml-lab.git
cd portable-ml-lab
```

---

## Step 4: Configure Environment

### 4.1 Copy Example Config

**PowerShell:**
```powershell
Copy-Item .env.example .env
```

**Or Git Bash:**
```bash
cp .env.example .env
```

### 4.2 Edit .env File

Open `.env` in any text editor (Notepad, VS Code, etc.):

```powershell
notepad .env
```

### 4.3 Set Your Project Path

Find and edit this line:

```env
# BEFORE
HOST_PROJECTS_PATH=~/Desktop

# AFTER (use forward slashes!)
HOST_PROJECTS_PATH=C:/Users/YourName/Desktop/my-projects
```

**IMPORTANT:** 
- Use **forward slashes** `/` not backslashes `\`
- Use full path starting with `C:/`

### 4.4 Get Your User ID (Optional but Recommended)

This prevents permission issues. In PowerShell:

```powershell
# Usually 1000 for WSL, but check:
wsl -e id -u
wsl -e id -g
```

Update in `.env`:
```env
HOST_UID=1000
HOST_GID=1000
```

---

## Step 5: Build the Docker Image

### 5.1 Ensure Docker is Running

Check the whale icon in system tray. If not running, start Docker Desktop.

### 5.2 Build (First Time Only)

**PowerShell:**
```powershell
docker compose build
```

This takes 5-10 minutes. You'll see progress like:
```
[+] Building 300.0s (17/17) FINISHED
```

---

## Step 6: Start the Environment

### Option A: Using start.bat (Easiest)

Double-click `start.bat` or run in PowerShell:

```powershell
.\start.bat
```

### Option B: Manual Commands

```powershell
# Start container
docker compose up -d

# Create tmux session
docker compose exec -u dev mlops-env tmuxp load -d /home/dev/.config/tmuxp/lab.yaml

# Attach to session
docker compose exec -u dev mlops-env tmux attach -t mlops
```

---

## Step 7: Using the Environment

### You're Now Inside the Container!

You should see a tmux session with 5 windows:

```
┌─────────────────────────────────────────┐
│ 1:Editor  2:Pipeline  3:Jupyter  4:Git  │
│ 5:Logs                                  │
└─────────────────────────────────────────┘
```

### Navigation

| Key | Action |
|-----|--------|
| `Ctrl-a 1` | Editor (Neovim) |
| `Ctrl-a 2` | Pipeline (DVC/Kedro) |
| `Ctrl-a 3` | Jupyter Console |
| `Ctrl-a 4` | Git (Lazygit) |
| `Ctrl-a 5` | Logs (htop) |
| `Ctrl-a d` | **Detach** (keep running) |

### Detach and Reattach

**Detach:** Press `Ctrl-a` then `d`

**Reattach:**
```powershell
docker compose exec -u dev mlops-env tmux attach -t mlops
```

Or just run `start.bat` again.

---

## Step 8: Verify Everything Works

### 8.1 Test Python

In the Editor window (Ctrl-a 1), go to terminal pane and run:

```bash
python --version
# Python 3.11.14

python -c "import torch; print(torch.__version__)"
# 2.x.x
```

### 8.2 Test Jupyter

Go to Jupyter window (Ctrl-a 3):

```python
In [1]: 2 + 2
Out[1]: 4

In [2]: import numpy as np; np.random.rand(3)
```

### 8.3 Test Molten in Neovim

1. Go to Editor window: `Ctrl-a 1`
2. In Neovim, open demo file: `:e /projects/notebook_demo.py`
3. Initialize kernel: `Space m i` → select `pde-kernel`
4. Run a cell: `Space m c`

---

## Step 9: Stop the Environment

### Stop but Keep Data

```powershell
docker compose stop
```

### Stop and Remove

```powershell
docker compose down
```

### Resume Later

```powershell
docker compose start
docker compose exec -u dev mlops-env tmux attach -t mlops
```

---

## Quick Reference Card

```
╔═══════════════════════════════════════════════════════════╗
║            WINDOWS QUICK REFERENCE                        ║
╠═══════════════════════════════════════════════════════════╣
║  START         .\start.bat                                ║
║                 or: docker compose up -d                  ║
║                                                           ║
║  ATTACH        docker compose exec -u dev mlops-env       ║
║                tmux attach -t mlops                       ║
║                                                           ║
║  DETACH        Ctrl-a d                                   ║
║                                                           ║
║  STOP          docker compose stop                        ║
║                                                           ║
║  REBUILD       docker compose build --no-cache            ║
╠═══════════════════════════════════════════════════════════╣
║  WINDOWS       Ctrl-a 1-5                                 ║
║  PANES         Ctrl-a h/j/k/l                             ║
║  ZOOM          Ctrl-a z                                   ║
╠═══════════════════════════════════════════════════════════╣
║  NEOVIM        Space ff (find) Space fg (grep)            ║
║  MOLTEN        Space mi (init) Space mc (run cell)        ║
║  GIT           Space lg (lazygit)                         ║
╚═══════════════════════════════════════════════════════════╝
```

---

## Troubleshooting

### Docker Not Starting

**Error:** "Docker Desktop requires WSL 2"

**Fix:**
```powershell
# Run as Administrator
wsl --install
wsl --set-default-version 2
# Restart computer
```

### Permission Denied on Volumes

**Error:** Files created in container are owned by root

**Fix:** Set correct UID/GID in `.env`:
```env
HOST_UID=1000
HOST_GID=1000
```

Then rebuild:
```powershell
docker compose down
docker compose build
docker compose up -d
```

### Path Issues

**Error:** "no such file or directory"

**Fix:** Use forward slashes in `.env`:
```env
# WRONG
HOST_PROJECTS_PATH=C:\Users\Name\Desktop

# CORRECT
HOST_PROJECTS_PATH=C:/Users/Name/Desktop
```

### Container Won't Start

**Check logs:**
```powershell
docker compose logs mlops-env
```

**Full reset:**
```powershell
docker compose down -v
docker compose build --no-cache
docker compose up -d
```

### Tmux Session Not Found

```powershell
# Recreate session
docker compose exec -u dev mlops-env tmuxp load -d /home/dev/.config/tmuxp/lab.yaml

# Then attach
docker compose exec -u dev mlops-env tmux attach -t mlops
```

### Git Bash Path Mangling

If using Git Bash and paths look wrong:

```bash
export MSYS_NO_PATHCONV=1
docker compose up -d
```

The `start.bat` script handles this automatically.

---

## VS Code Integration (Optional)

### Connect to Running Container

1. Install "Dev Containers" extension in VS Code
2. Press `F1` → "Dev Containers: Attach to Running Container"
3. Select `mlops-env`

### Use Remote SSH

1. Container exposes SSH on port 2222
2. Connect: `ssh dev@localhost -p 2222`
3. Add your SSH key first:
   ```powershell
   # Your key is mounted read-only from ~/.ssh
   ```

---

## Windows Terminal Recommendation

For the best experience, use **Windows Terminal** with a Nerd Font:

1. Install from Microsoft Store: "Windows Terminal"
2. Install font: [Nerd Fonts](https://www.nerdfonts.com/) (e.g., "JetBrainsMono Nerd Font")
3. Set in Windows Terminal settings:
   - Settings → Profiles → Defaults → Appearance
   - Font face: "JetBrainsMono Nerd Font"

This enables icons in Neovim and proper rendering.

---

## Summary: One-Liner Start

After initial setup, just run:

```powershell
cd C:\Users\YourName\Desktop\portable-ml-lab
.\start.bat
```

That's it! You're in your ML development environment.

---

**Happy Coding on Windows!** 

# Portable ML Lab - Ultimate Tutorial

The complete guide to using your Dockerized Machine Learning Development Environment.

---

## Table of Contents

1. [Quick Start](#1-quick-start)
2. [Main Commands Reference](#2-main-commands-reference)
3. [Tutorial: Hello World](#3-tutorial-hello-world)
4. [Tutorial: Creating Plots with Molten](#4-tutorial-creating-plots-with-molten)
5. [Tutorial: DVC Data Versioning](#5-tutorial-dvc-data-versioning)
6. [Tutorial: Kedro ML Pipelines](#6-tutorial-kedro-ml-pipelines)
7. [Tutorial: Git with Lazygit](#7-tutorial-git-with-lazygit)
8. [Neovim Essential Commands](#8-neovim-essential-commands)
9. [Tmux Navigation](#9-tmux-navigation)
10. [Troubleshooting](#10-troubleshooting)

---

## 1. Quick Start

### Start the Environment

```bash
# From the portable-ml-lab directory
./start.sh

# Or manually:
docker compose up -d
docker compose exec -u dev mlops-env tmux attach -t mlops
```

### Stop the Environment

```bash
docker compose down
```

### Detach Without Stopping

Press `Ctrl-a` then `d` to detach from tmux (container keeps running).

### Reattach

```bash
docker compose exec -u dev mlops-env tmux attach -t mlops
```

---

## 2. Main Commands Reference

### Tmux Commands (prefix: Ctrl-a)

| Command | Action |
|---------|--------|
| `Ctrl-a d` | Detach from session |
| `Ctrl-a 1` | Go to Editor window |
| `Ctrl-a 2` | Go to Pipeline window |
| `Ctrl-a 3` | Go to Jupyter window |
| `Ctrl-a 4` | Go to Git window |
| `Ctrl-a 5` | Go to Logs window |
| `Ctrl-a h/j/k/l` | Navigate panes (vim-style) |
| `Ctrl-a z` | Zoom current pane (toggle) |
| `Ctrl-a c` | Create new window |
| `Ctrl-a x` | Kill current pane |

### Neovim Commands (leader: Space)

| Command | Action |
|---------|--------|
| `Space f f` | Find files (Telescope) |
| `Space f g` | Live grep (search in files) |
| `Space f b` | Browse buffers |
| `Space f r` | Recent files |
| `Space e` | File explorer (Oil.nvim) |
| `-` | Parent directory (Oil.nvim) |
| `Space l g` | Open Lazygit |
| `K` | Show hover documentation |
| `gd` | Go to definition |
| `gr` | Go to references |
| `Space c a` | Code actions |
| `Space u` | Toggle Undotree |
| `jk` | Exit insert mode |

### Molten (Jupyter) Commands

| Command | Action |
|---------|--------|
| `Space m i` | Initialize kernel |
| `Space m l` | Evaluate current line |
| `Space m v` | Evaluate visual selection |
| `Space m e` | Evaluate operator (motion) |
| `Space m c` | Re-evaluate cell |
| `Space m o` | Show output |
| `Space m h` | Hide output |
| `Space m x` | Interrupt kernel |
| `Space m r` | Restart kernel |
| `Space m s` | Save outputs |
| `Space m L` | Load outputs |

### Shell Commands

| Command | Action |
|---------|--------|
| `dvc init` | Initialize DVC in project |
| `dvc add <file>` | Track file with DVC |
| `dvc repro` | Reproduce pipeline |
| `kedro new` | Create new Kedro project |
| `kedro run` | Run Kedro pipeline |
| `lazygit` | Open Git TUI |
| `python` | Python REPL |
| `jupyter console --kernel=pde-kernel` | Jupyter console |

---

## 3. Tutorial: Hello World

### Step 1: Navigate to Projects

```bash
# You start in /projects directory
cd /projects
```

### Step 2: Create a Python File

In the Editor window (Ctrl-a 1), create a new file:

```
:e hello.py
```

Press `i` to enter insert mode and type:

```python
#!/usr/bin/env python3
"""Hello World - Your first script in Portable ML Lab"""

def greet(name: str) -> str:
    """Return a greeting message."""
    return f"Hello, {name}! Welcome to Portable ML Lab!"

if __name__ == "__main__":
    message = greet("Data Scientist")
    print(message)
    
    # Simple calculation
    numbers = [1, 2, 3, 4, 5]
    print(f"Sum: {sum(numbers)}")
    print(f"Average: {sum(numbers) / len(numbers)}")
```

Press `Esc` then `:w` to save.

### Step 3: Run the Script

**Option A: From terminal pane**
Navigate to terminal pane (Ctrl-a + arrow or h/j/k/l) and run:
```bash
python hello.py
```

**Option B: Using Molten (interactive)**
1. Press `Space m i` to initialize kernel
2. Select `pde-kernel`
3. Position cursor on a line and press `Space m l` to evaluate

### Expected Output

```
Hello, Data Scientist! Welcome to Portable ML Lab!
Sum: 15
Average: 3.0
```

---

## 4. Tutorial: Creating Plots with Molten

### Step 1: Create Plot Script

Create a new file:
```
:e plot_demo.py
```

Enter this code:

```python
# %% Cell 1: Imports
import matplotlib.pyplot as plt
import numpy as np

# %% Cell 2: Generate Data
x = np.linspace(0, 2 * np.pi, 100)
y_sin = np.sin(x)
y_cos = np.cos(x)

# %% Cell 3: Create Plot
plt.figure(figsize=(10, 6))
plt.plot(x, y_sin, label='sin(x)', color='blue', linewidth=2)
plt.plot(x, y_cos, label='cos(x)', color='red', linewidth=2)
plt.xlabel('x')
plt.ylabel('y')
plt.title('Sine and Cosine Functions')
plt.legend()
plt.grid(True, alpha=0.3)
plt.show()

# %% Cell 4: Histogram
data = np.random.randn(1000)
plt.figure(figsize=(8, 5))
plt.hist(data, bins=30, edgecolor='black', alpha=0.7)
plt.xlabel('Value')
plt.ylabel('Frequency')
plt.title('Normal Distribution (1000 samples)')
plt.show()

# %% Cell 5: Scatter Plot
n = 50
x_scatter = np.random.rand(n)
y_scatter = np.random.rand(n)
colors = np.random.rand(n)
sizes = 1000 * np.random.rand(n)

plt.figure(figsize=(8, 6))
plt.scatter(x_scatter, y_scatter, c=colors, s=sizes, alpha=0.5, cmap='viridis')
plt.colorbar()
plt.title('Random Scatter Plot')
plt.show()
```

### Step 2: Initialize Molten

1. Save the file: `:w`
2. Press `Space m i`
3. Select `pde-kernel` from the list

### Step 3: Evaluate Cells

**Evaluate single line:**
- Position cursor on a line
- Press `Space m l`

**Evaluate selection:**
- Visual select lines with `V` then move with `j`
- Press `Space m v`

**Evaluate by cell (using `# %%` markers):**
- Position cursor in a cell
- Press `Space m c`

### Step 4: View Output

- Press `Space m o` to show output window
- Press `Space m h` to hide output

> **Note**: Image rendering requires a terminal that supports Sixel (Kitty, WezTerm, iTerm2) and SSH connection (not Mosh).

---

## 5. Tutorial: DVC Data Versioning

### Step 1: Initialize DVC Project

```bash
# Create project directory
mkdir -p /projects/ml-experiment
cd /projects/ml-experiment

# Initialize git and DVC
git init
dvc init
```

### Step 2: Create Sample Data

```bash
# Create data directory
mkdir -p data

# Generate sample data
python -c "
import pandas as pd
import numpy as np

np.random.seed(42)
df = pd.DataFrame({
    'feature1': np.random.randn(1000),
    'feature2': np.random.randn(1000),
    'target': np.random.randint(0, 2, 1000)
})
df.to_csv('data/dataset.csv', index=False)
print('Created data/dataset.csv with 1000 rows')
"
```

### Step 3: Track Data with DVC

```bash
# Add data file to DVC tracking
dvc add data/dataset.csv

# This creates:
# - data/dataset.csv.dvc (metadata file)
# - data/.gitignore (to ignore the actual data)
```

### Step 4: Commit to Git

```bash
git add data/dataset.csv.dvc data/.gitignore
git commit -m "Add dataset with DVC tracking"
```

### Step 5: Create a DVC Pipeline

Create `dvc.yaml`:

```yaml
stages:
  prepare:
    cmd: python src/prepare.py
    deps:
      - data/dataset.csv
      - src/prepare.py
    outs:
      - data/prepared.csv

  train:
    cmd: python src/train.py
    deps:
      - data/prepared.csv
      - src/train.py
    outs:
      - models/model.pkl
    metrics:
      - metrics.json:
          cache: false
```

### Step 6: Create Pipeline Scripts

```bash
mkdir -p src models
```

Create `src/prepare.py`:

```python
import pandas as pd
from sklearn.model_selection import train_test_split

df = pd.read_csv('data/dataset.csv')
train, test = train_test_split(df, test_size=0.2, random_state=42)
train.to_csv('data/prepared.csv', index=False)
print(f"Prepared {len(train)} training samples")
```

Create `src/train.py`:

```python
import pandas as pd
import json
import pickle
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score

df = pd.read_csv('data/prepared.csv')
X = df[['feature1', 'feature2']]
y = df['target']

model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X, y)

accuracy = accuracy_score(y, model.predict(X))

with open('models/model.pkl', 'wb') as f:
    pickle.dump(model, f)

with open('metrics.json', 'w') as f:
    json.dump({'accuracy': accuracy}, f)

print(f"Model trained with accuracy: {accuracy:.4f}")
```

### Step 7: Run the Pipeline

```bash
dvc repro
```

### Step 8: View Pipeline DAG

```bash
dvc dag
```

### DVC Commands Reference

| Command | Action |
|---------|--------|
| `dvc init` | Initialize DVC |
| `dvc add <file>` | Track file |
| `dvc push` | Push data to remote |
| `dvc pull` | Pull data from remote |
| `dvc repro` | Reproduce pipeline |
| `dvc dag` | Show pipeline DAG |
| `dvc metrics show` | Show metrics |
| `dvc plots show` | Show plots |

---

## 6. Tutorial: Kedro ML Pipelines

### Step 1: Create New Kedro Project

```bash
cd /projects
kedro new
```

Follow prompts:
- Project name: `iris_classifier`
- Repository name: `iris-classifier`
- Python package name: `iris_classifier`

### Step 2: Navigate to Project

```bash
cd iris-classifier
```

### Step 3: Install Dependencies

Edit `requirements.txt` and add:
```
scikit-learn
pandas
matplotlib
```

### Step 4: Add Data Catalog Entry

Edit `conf/base/catalog.yml`:

```yaml
iris_data:
  type: pandas.CSVDataset
  filepath: data/01_raw/iris.csv

model:
  type: pickle.PickleDataset
  filepath: data/06_models/classifier.pkl

predictions:
  type: pandas.CSVDataset
  filepath: data/07_model_output/predictions.csv
```

### Step 5: Create Sample Data

```bash
mkdir -p data/01_raw
python -c "
from sklearn.datasets import load_iris
import pandas as pd

iris = load_iris()
df = pd.DataFrame(iris.data, columns=iris.feature_names)
df['target'] = iris.target
df.to_csv('data/01_raw/iris.csv', index=False)
print('Created iris.csv')
"
```

### Step 6: Create Pipeline Nodes

Edit `src/iris_classifier/pipelines/data_science/nodes.py`:

```python
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score

def split_data(data: pd.DataFrame):
    """Split data into train and test sets."""
    X = data.drop('target', axis=1)
    y = data['target']
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    return X_train, X_test, y_train, y_test

def train_model(X_train, y_train):
    """Train a Random Forest classifier."""
    model = RandomForestClassifier(n_estimators=100, random_state=42)
    model.fit(X_train, y_train)
    return model

def evaluate_model(model, X_test, y_test):
    """Evaluate the model."""
    predictions = model.predict(X_test)
    accuracy = accuracy_score(y_test, predictions)
    print(f"Model accuracy: {accuracy:.4f}")
    return {"accuracy": accuracy}
```

### Step 7: Run Kedro Pipeline

```bash
kedro run
```

### Step 8: Visualize Pipeline (optional)

```bash
kedro viz
```

### Kedro Commands Reference

| Command | Action |
|---------|--------|
| `kedro new` | Create new project |
| `kedro run` | Run default pipeline |
| `kedro run --pipeline=<name>` | Run specific pipeline |
| `kedro catalog list` | List catalog entries |
| `kedro viz` | Visualize pipeline |
| `kedro test` | Run tests |
| `kedro package` | Package project |

---

## 7. Tutorial: Git with Lazygit

### Step 1: Open Lazygit

**Option A:** Press `Ctrl-a 4` to go to Git window (lazygit is running)

**Option B:** From Neovim, press `Space l g`

**Option C:** From terminal: `lazygit`

### Step 2: Lazygit Interface

```
┌─────────────────────────────────────────────────┐
│ [1] Status    │ [2] Files    │ [3] Branches    │
├───────────────┼──────────────┼─────────────────┤
│ [4] Commits   │ [5] Stash    │                 │
└─────────────────────────────────────────────────┘
```

### Step 3: Basic Workflow

**Stage files:**
1. Navigate to Files panel (press `2`)
2. Move to file with `j/k`
3. Press `Space` to stage/unstage

**Commit:**
1. Press `c` to commit
2. Type commit message
3. Press `Enter`

**Push:**
1. Press `P` (capital P) to push

**Pull:**
1. Press `p` (lowercase p) to pull

### Lazygit Keybindings

| Key | Action |
|-----|--------|
| `1-5` | Switch panels |
| `j/k` | Move up/down |
| `Space` | Stage/unstage file |
| `c` | Commit |
| `P` | Push |
| `p` | Pull |
| `b` | Create branch |
| `Enter` | View file/commit |
| `/` | Search |
| `?` | Help |
| `q` | Quit |

### Step 4: Create a Branch

1. Go to Branches panel (`3`)
2. Press `n` for new branch
3. Enter branch name
4. Press `Enter`

### Step 5: Merge Branch

1. Checkout target branch (press `Space` on it)
2. Press `M` to merge
3. Select branch to merge from

---

## 8. Neovim Essential Commands

### Navigation

| Command | Action |
|---------|--------|
| `h j k l` | Left, Down, Up, Right |
| `w / b` | Next/previous word |
| `0 / $` | Start/end of line |
| `gg / G` | Start/end of file |
| `Ctrl-d / Ctrl-u` | Half page down/up |
| `%` | Jump to matching bracket |
| `*` | Search word under cursor |

### Editing

| Command | Action |
|---------|--------|
| `i / a` | Insert before/after cursor |
| `I / A` | Insert at start/end of line |
| `o / O` | New line below/above |
| `x` | Delete character |
| `dd` | Delete line |
| `yy` | Yank (copy) line |
| `p / P` | Paste after/before |
| `u` | Undo |
| `Ctrl-r` | Redo |
| `.` | Repeat last change |

### Search & Replace

| Command | Action |
|---------|--------|
| `/pattern` | Search forward |
| `?pattern` | Search backward |
| `n / N` | Next/previous match |
| `:%s/old/new/g` | Replace all in file |
| `:%s/old/new/gc` | Replace with confirmation |

### Window Management

| Command | Action |
|---------|--------|
| `:sp` | Horizontal split |
| `:vsp` | Vertical split |
| `Ctrl-w h/j/k/l` | Navigate windows |
| `Ctrl-w =` | Equal window sizes |
| `:q` | Close window |
| `:qa` | Close all |

### LSP Features (Python)

| Command | Action |
|---------|--------|
| `K` | Hover documentation |
| `gd` | Go to definition |
| `gr` | Go to references |
| `gi` | Go to implementation |
| `Space c a` | Code actions |
| `Space r n` | Rename symbol |
| `[d / ]d` | Previous/next diagnostic |

---

## 9. Tmux Navigation

### Window Management

| Command | Action |
|---------|--------|
| `Ctrl-a c` | Create window |
| `Ctrl-a n` | Next window |
| `Ctrl-a p` | Previous window |
| `Ctrl-a 0-9` | Go to window N |
| `Ctrl-a ,` | Rename window |
| `Ctrl-a &` | Kill window |

### Pane Management

| Command | Action |
|---------|--------|
| `Ctrl-a %` | Split vertical |
| `Ctrl-a "` | Split horizontal |
| `Ctrl-a h/j/k/l` | Navigate panes |
| `Ctrl-a z` | Zoom pane (toggle) |
| `Ctrl-a x` | Kill pane |
| `Ctrl-a {` | Move pane left |
| `Ctrl-a }` | Move pane right |
| `Ctrl-a Space` | Cycle layouts |

### Copy Mode

| Command | Action |
|---------|--------|
| `Ctrl-a [` | Enter copy mode |
| `v` | Start selection |
| `y` | Copy selection |
| `Ctrl-a ]` | Paste |
| `q` | Exit copy mode |

---

## 10. Troubleshooting

### Container Won't Start

```bash
# Check Docker is running
docker info

# Check logs
docker compose logs mlops-env

# Restart container
docker compose down && docker compose up -d
```

### Neovim Plugins Not Working

```bash
# Inside container, sync plugins
nvim --headless "+Lazy! sync" +qa

# Update remote plugins for Molten
nvim -c "lua require('lazy').load({plugins = {'molten-nvim'}})" -c "UpdateRemotePlugins" -c "qa"
```

### Molten Kernel Not Found

```bash
# List available kernels
jupyter kernelspec list

# Reinstall kernel
python -m ipykernel install --name "pde-kernel" --display-name "PDE Python 3.11"
```

### Permission Issues

```bash
# Check current user
id

# Files should be owned by your user (UID matching host)
ls -la /projects
```

### Tmux Session Lost

```bash
# Check if session exists
docker compose exec -u dev mlops-env tmux ls

# Recreate session
docker compose exec -u dev mlops-env tmuxp load -d /home/dev/.config/tmuxp/lab.yaml

# Attach
docker compose exec -u dev mlops-env tmux attach -t mlops
```

### Images Not Rendering

1. Use SSH connection (not Mosh)
2. Use supported terminal (Kitty, WezTerm, iTerm2)
3. Check tmux passthrough:
   ```bash
   tmux show-options -g allow-passthrough
   ```

---

## Quick Reference Card

```
╔══════════════════════════════════════════════════════════════╗
║                    PORTABLE ML LAB                           ║
╠══════════════════════════════════════════════════════════════╣
║  START        ./start.sh                                     ║
║  STOP         docker compose down                            ║
║  ATTACH       docker compose exec -u dev mlops-env tmux      ║
║               attach -t mlops                                ║
║  DETACH       Ctrl-a d                                       ║
╠══════════════════════════════════════════════════════════════╣
║  WINDOWS      Ctrl-a 1:Editor 2:Pipeline 3:Jupyter 4:Git     ║
║               5:Logs                                         ║
║  PANES        Ctrl-a h/j/k/l (navigate)  Ctrl-a z (zoom)     ║
╠══════════════════════════════════════════════════════════════╣
║  NEOVIM       Space ff (find)  Space fg (grep)  Space e      ║
║               (explorer)                                     ║
║  MOLTEN       Space mi (init)  Space ml (line)  Space mv     ║
║               (visual)                                       ║
║  GIT          Space lg (lazygit)  c (commit)  P (push)       ║
╠══════════════════════════════════════════════════════════════╣
║  DVC          dvc init → dvc add → dvc repro → dvc push      ║
║  KEDRO        kedro new → kedro run → kedro viz              ║
╚══════════════════════════════════════════════════════════════╝
```

---

**Happy Coding!** 

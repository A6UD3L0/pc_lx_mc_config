# PDE Manual Validation Checklist

Interactive validation protocol for the Dockerized MLOps workspace.

> **Prerequisites**: Run `./verify_env.sh` first for automated checks.

---

## 1. Tmuxp Layout Validation

### Load the Session

```bash
# Inside the container
tmuxp load /home/dev/.config/tmuxp/lab.yaml
```

### Verification Checklist

- [ ] **Session Created**: Tmux session named `mlops` is created
- [ ] **Window 1 (Editor)**: 
  - [ ] Window name shows "Editor"
  - [ ] Main pane (65% width) has Neovim open
  - [ ] Right-top pane has shell ready
  - [ ] Right-bottom pane has IPython REPL running
- [ ] **Window 2 (Pipeline)**:
  - [ ] Window name shows "Pipeline"
  - [ ] Layout is tiled (equal panes)
  - [ ] nvtop or htop is running
  - [ ] DVC status pane is present
  - [ ] Kedro pane is present
- [ ] **Window 3 (Git)**:
  - [ ] Lazygit is running (or git status shown)
- [ ] **Window 4 (Logs)**:
  - [ ] Two log viewer panes present

### Navigation Test

- [ ] `Ctrl-a + 1` switches to Editor window
- [ ] `Ctrl-a + 2` switches to Pipeline window
- [ ] `Ctrl-h/j/k/l` navigates between panes (vim-tmux-navigator)

---

## 2. Mosh Connectivity & Experience

### Connection Test

```bash
# From host machine (outside container)
mosh --ssh="ssh -p 2222" dev@localhost
```

### Verification Checklist

- [ ] **Initial Connection**: Mosh connects successfully
- [ ] **Firewall Check**: If connection hangs, verify UDP ports 60000-60005 are exposed
  ```bash
  docker compose ps  # Check port mappings
  ```

### Roaming Test

1. [ ] Start a Mosh session
2. [ ] Type some text in the terminal
3. [ ] Disconnect from WiFi for 10 seconds
4. [ ] Reconnect to WiFi
5. [ ] **Expected**: Session resumes automatically without reconnecting

### Latency Test

1. [ ] In Mosh session, type rapidly
2. [ ] **Expected**: Characters appear instantly (Local Echo)
3. [ ] **Note**: This is Mosh's predictive local echo feature

### Graphics Limitation Acknowledgment

> **IMPORTANT**: Mosh does NOT support Sixel/Kitty graphics protocols.

- [ ] **Acknowledged**: Inline images in Neovim will NOT render via Mosh
- [ ] **Workaround**: Use SSH for image-heavy workflows:
  ```bash
  ssh -p 2222 dev@localhost
  ```

---

## 3. SSH Connectivity

### Connection Test

```bash
# First, add your SSH key to the container
docker compose exec mlops-env bash -c "cat >> ~/.ssh/authorized_keys" < ~/.ssh/id_rsa.pub

# Connect via SSH
ssh -p 2222 dev@localhost
```

### Verification Checklist

- [ ] **SSH Connection**: Connects successfully
- [ ] **Key-based Auth**: No password prompt (key auth works)
- [ ] **Agent Forwarding**: `ssh-add -l` shows keys from host

---

## 4. Neovim Graphics Rendering (Visual Test)

### Prerequisites

> This depends on:
> 1. **Terminal Emulator**: Kitty, WezTerm, or iTerm2 (NOT standard Terminal.app)
> 2. **Tmux Passthrough**: `set -g allow-passthrough on` in tmux.conf
> 3. **Connection Protocol**: SSH (NOT Mosh)

### Test 1: Image File Rendering

1. [ ] Connect via SSH (not Mosh)
2. [ ] Start tmux: `tmux new -s test`
3. [ ] Create a test image:
   ```bash
   convert -size 100x100 xc:red /tmp/test.png
   ```
4. [ ] Open in Neovim:
   ```bash
   nvim /tmp/test.png
   ```
5. [ ] **Expected**: Red square renders inline

### Test 2: Molten-nvim Plot Rendering

1. [ ] Open a Python file in Neovim
2. [ ] Initialize Molten: `<leader>mi` (Space + m + i)
3. [ ] Select kernel: `pde-kernel`
4. [ ] Add plotting code:
   ```python
   import matplotlib.pyplot as plt
   import numpy as np
   x = np.linspace(0, 10, 100)
   plt.plot(x, np.sin(x))
   plt.show()
   ```
5. [ ] Evaluate with `<leader>ml` (evaluate line) or visual select + `<leader>mv`
6. [ ] **Expected**: Plot renders inline below the code

### Verification Checklist

- [ ] **Image renders clearly** within the text grid
- [ ] **No garbage text** (raw escape sequences) visible on screen
- [ ] **Colors are correct** (not distorted)

### Troubleshooting

If images don't render:

1. [ ] Verify terminal supports graphics:
   ```bash
   # In Kitty/WezTerm:
   kitty +kitten icat /tmp/test.png
   # or
   wezterm imgcat /tmp/test.png
   ```

2. [ ] Verify tmux passthrough:
   ```bash
   tmux show-options -g allow-passthrough
   # Should output: allow-passthrough on
   ```

3. [ ] Verify NOT using Mosh:
   ```bash
   echo $MOSH_SERVER_SIGNAL_TMOUT
   # Should be empty if not in Mosh
   ```

4. [ ] Check Neovim health:
   ```vim
   :checkhealth image
   ```

---

## 5. LSP & Autocompletion

### Test basedpyright LSP

1. [ ] Open a Python file in Neovim
2. [ ] Type `import nump` and wait
3. [ ] **Expected**: Autocomplete suggestions appear
4. [ ] Type `np.` after `import numpy as np`
5. [ ] **Expected**: numpy methods appear in completion menu

### Verification Checklist

- [ ] **Hover works**: Press `K` on a symbol to see documentation
- [ ] **Go to definition**: Press `gd` on a function to jump to source
- [ ] **Diagnostics**: Type errors are underlined/highlighted
- [ ] **Code actions**: `<leader>ca` shows available actions

---

## 6. Undotree

### Test Undo History Visualization

1. [ ] Open any file in Neovim
2. [ ] Make several edits (add lines, delete, modify)
3. [ ] Press `<leader>u` to toggle Undotree
4. [ ] **Expected**: Undo tree panel appears on the left
5. [ ] Navigate the tree with `j/k`
6. [ ] Press Enter to restore a previous state

### Verification Checklist

- [ ] **Undotree opens**: Panel visible on left side
- [ ] **History visible**: Multiple undo states shown
- [ ] **Restoration works**: Can restore to any previous state
- [ ] **Persistent undo**: After closing and reopening file, history is preserved

---

## 7. Git Integration

### Test Lazygit

1. [ ] In Neovim, press `<leader>lg`
2. [ ] **Expected**: Lazygit opens in a floating window
3. [ ] Navigate with `h/j/k/l`
4. [ ] Press `q` to close

### Test Gitsigns

1. [ ] Open a file in a git repository
2. [ ] Make a change to a line
3. [ ] **Expected**: Sign column shows change indicator (colored bar)
4. [ ] Undo the change
5. [ ] **Expected**: Sign disappears

---

## 8. File Navigation

### Test Telescope

- [ ] `<leader>ff`: Find files dialog opens
- [ ] `<leader>fg`: Live grep dialog opens
- [ ] `<leader>fb`: Buffer list opens
- [ ] `<leader>fr`: Recent files list opens

### Test Oil.nvim

1. [ ] Press `-` in normal mode
2. [ ] **Expected**: File browser opens in current directory
3. [ ] Navigate with `j/k`
4. [ ] Press Enter to open file/directory
5. [ ] Press `-` again to go up a directory

---

## Summary

| Component | Status | Notes |
|-----------|--------|-------|
| Tmuxp Layout | ☐ | |
| Mosh Connection | ☐ | |
| SSH Connection | ☐ | |
| Image Rendering | ☐ | |
| Molten-nvim | ☐ | |
| LSP/Autocomplete | ☐ | |
| Undotree | ☐ | |
| Git Integration | ☐ | |
| File Navigation | ☐ | |

**Date Validated**: _______________

**Validated By**: _______________

**Notes**: 

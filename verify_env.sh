#!/bin/bash
# =============================================================================
# PDE Environment Verification Suite
# Comprehensive health check for Dockerized MLOps workspace
# =============================================================================

set -uo pipefail

# -----------------------------------------------------------------------------
# Logging Functions with Colors
# -----------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

log_pass() {
    echo -e "${GREEN}[✓ PASS]${NC} $1"
    ((PASS_COUNT++))
}

log_fail() {
    echo -e "${RED}[✗ FAIL]${NC} $1"
    ((FAIL_COUNT++))
}

log_warn() {
    echo -e "${YELLOW}[! WARN]${NC} $1"
    ((WARN_COUNT++))
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_section() {
    echo ""
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}  $1${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
}

# -----------------------------------------------------------------------------
# 1. System & Dependency Layer
# -----------------------------------------------------------------------------
check_system_dependencies() {
    log_section "1. SYSTEM & DEPENDENCY LAYER"
    
    local binaries=("git" "curl" "wget" "tmux" "tmuxp" "mosh-server" "nvim" "python3" "uv")
    
    for bin in "${binaries[@]}"; do
        if command -v "$bin" &> /dev/null; then
            local version=""
            case "$bin" in
                git) version=$(git --version 2>/dev/null | head -1) ;;
                nvim) version=$(nvim --version 2>/dev/null | head -1) ;;
                python3) version=$(python3 --version 2>/dev/null) ;;
                tmux) version=$(tmux -V 2>/dev/null) ;;
                *) version="found" ;;
            esac
            log_pass "$bin: $version"
        else
            log_fail "$bin: NOT FOUND"
        fi
    done
    
    # Check Docker/container permissions
    echo ""
    log_info "Checking permissions..."
    
    if [ "$(id -u)" -eq 0 ]; then
        log_warn "Running as root (UID 0). This may cause permission mismatches with host volumes."
    else
        log_pass "Running as non-root user: $(whoami) (UID: $(id -u))"
    fi
    
    # Check workspace write permissions
    local workspace="/workspace"
    if [ -d "$workspace" ]; then
        if [ -w "$workspace" ]; then
            log_pass "Write permission to $workspace: OK"
        else
            log_fail "Write permission to $workspace: DENIED"
        fi
    else
        log_warn "$workspace directory does not exist"
    fi
    
    # Check home directory
    if [ -w "$HOME" ]; then
        log_pass "Write permission to $HOME: OK"
    else
        log_fail "Write permission to $HOME: DENIED"
    fi
}

# -----------------------------------------------------------------------------
# 2. GPU Hardware Layer (NVIDIA)
# -----------------------------------------------------------------------------
check_gpu_layer() {
    log_section "2. GPU HARDWARE LAYER (NVIDIA)"
    
    # Check nvidia-smi presence
    if ! command -v nvidia-smi &> /dev/null; then
        log_warn "nvidia-smi not found in PATH (expected on macOS/ARM64)"
        log_info "GPU checks skipped - running in CPU-only mode"
        return
    fi
    
    log_pass "nvidia-smi found in PATH"
    
    # Check nvidia-smi functionality
    if nvidia-smi &> /dev/null; then
        log_pass "nvidia-smi execution: OK"
        
        # Parse GPU metrics
        local gpu_info
        gpu_info=$(nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader 2>/dev/null)
        if [ -n "$gpu_info" ]; then
            log_pass "GPU detected: $gpu_info"
        fi
    else
        log_fail "nvidia-smi execution failed"
    fi
    
    # Deep Learning Integration - PyTorch CUDA check
    echo ""
    log_info "Checking PyTorch CUDA integration..."
    
    local pytorch_cuda_check
    pytorch_cuda_check=$(python3 -c "
import sys
try:
    import torch
    if torch.cuda.is_available():
        print(f'CUDA available: {torch.cuda.get_device_name(0)}')
        sys.exit(0)
    else:
        print('CUDA not available in PyTorch')
        sys.exit(1)
except ImportError:
    print('PyTorch not installed')
    sys.exit(2)
except Exception as e:
    print(f'Error: {e}')
    sys.exit(3)
" 2>&1)
    
    local exit_code=$?
    case $exit_code in
        0) log_pass "PyTorch CUDA: $pytorch_cuda_check" ;;
        1) log_warn "PyTorch CUDA: $pytorch_cuda_check (CPU mode active)" ;;
        2) log_fail "PyTorch: NOT INSTALLED" ;;
        3) log_fail "PyTorch CUDA check error: $pytorch_cuda_check"
           log_info "This may indicate a mismatch between Host Driver and Container CUDA toolkit" ;;
    esac
}

# -----------------------------------------------------------------------------
# 3. Neovim & IDE Layer
# -----------------------------------------------------------------------------
check_neovim_layer() {
    log_section "3. NEOVIM & IDE LAYER"
    
    # Basic Neovim check
    if ! command -v nvim &> /dev/null; then
        log_fail "Neovim not found"
        return
    fi
    
    local nvim_version
    nvim_version=$(nvim --version | head -1)
    log_pass "Neovim version: $nvim_version"
    
    # Headless health check
    echo ""
    log_info "Running Neovim health check (headless)..."
    
    local health_log="/tmp/nvim_health.log"
    rm -f "$health_log"
    
    # Run checkhealth and capture output
    timeout 30 nvim --headless "+checkhealth" "+w! $health_log" "+qa" 2>/dev/null || true
    
    if [ -f "$health_log" ]; then
        log_pass "Health check log generated: $health_log"
        
        # Analyze the log
        echo ""
        log_info "Analyzing health check results..."
        
        # Check for Python provider
        if grep -q "pynvim" "$health_log"; then
            if grep -qi "ERROR.*pynvim\|pynvim.*ERROR" "$health_log"; then
                log_fail "Python provider (pynvim): ERROR detected"
            elif grep -qi "pynvim.*OK\|OK.*pynvim" "$health_log"; then
                log_pass "Python provider (pynvim): OK"
            else
                log_warn "Python provider (pynvim): Status unclear"
            fi
        fi
        
        # Check for Node provider
        if grep -qi "ERROR.*node\|node.*ERROR" "$health_log"; then
            log_warn "Node provider: ERROR detected (may affect some plugins)"
        fi
        
        # Check for LSP
        if grep -qi "basedpyright\|pyright" "$health_log"; then
            if grep -qi "ERROR.*pyright\|pyright.*ERROR" "$health_log"; then
                log_warn "basedpyright LSP: ERROR detected"
            else
                log_pass "basedpyright LSP: configured"
            fi
        fi
        
        # Count errors and warnings
        local error_count
        local warn_count
        error_count=$(grep -ci "ERROR" "$health_log" 2>/dev/null || echo "0")
        warn_count=$(grep -ci "WARNING" "$health_log" 2>/dev/null || echo "0")
        
        log_info "Health check summary: $error_count errors, $warn_count warnings"
        
    else
        log_warn "Health check log not generated (timeout or error)"
    fi
    
    # Check for pynvim installation
    echo ""
    log_info "Checking Python Neovim integration..."
    
    if python3 -c "import pynvim" 2>/dev/null; then
        log_pass "pynvim module: installed"
    else
        log_fail "pynvim module: NOT INSTALLED (required for Python plugins like molten-nvim)"
    fi
    
    # Check for jupyter_client (required for molten-nvim)
    if python3 -c "import jupyter_client" 2>/dev/null; then
        log_pass "jupyter_client module: installed"
    else
        log_warn "jupyter_client module: NOT INSTALLED (required for molten-nvim)"
    fi
}

# -----------------------------------------------------------------------------
# 4. Tmux Configuration
# -----------------------------------------------------------------------------
check_tmux_config() {
    log_section "4. TMUX CONFIGURATION"
    
    if ! command -v tmux &> /dev/null; then
        log_fail "Tmux not found"
        return
    fi
    
    local tmux_version
    tmux_version=$(tmux -V)
    log_pass "Tmux version: $tmux_version"
    
    # Check for graphics passthrough (CRITICAL for image.nvim)
    echo ""
    log_info "Checking graphics passthrough configuration..."
    
    # Check if tmux server is running
    if tmux list-sessions &>/dev/null; then
        local passthrough
        passthrough=$(tmux show-options -g allow-passthrough 2>/dev/null | awk '{print $2}')
        
        if [ "$passthrough" = "on" ]; then
            log_pass "allow-passthrough: ON (image.nvim will work)"
        else
            log_warn "allow-passthrough: OFF or not set"
            log_info "  → Image rendering in Neovim will fail"
            log_info "  → Add 'set -g allow-passthrough on' to ~/.tmux.conf"
        fi
    else
        # Check config file directly
        if [ -f "$HOME/.tmux.conf" ]; then
            if grep -q "allow-passthrough on" "$HOME/.tmux.conf"; then
                log_pass "allow-passthrough: configured in .tmux.conf"
            else
                log_warn "allow-passthrough: NOT configured in .tmux.conf"
                log_info "  → Add 'set -g allow-passthrough on' to ~/.tmux.conf"
            fi
        else
            log_warn "No .tmux.conf found"
        fi
    fi
    
    # Check for tmuxp config
    echo ""
    log_info "Checking tmuxp configuration..."
    
    local tmuxp_config="$HOME/.config/tmuxp/lab.yaml"
    if [ -f "$tmuxp_config" ]; then
        log_pass "tmuxp config found: $tmuxp_config"
    else
        log_warn "tmuxp config not found: $tmuxp_config"
    fi
}

# -----------------------------------------------------------------------------
# 5. Connectivity (Mosh)
# -----------------------------------------------------------------------------
check_connectivity() {
    log_section "5. CONNECTIVITY & PROTOCOLS"
    
    # Check Mosh server
    if command -v mosh-server &> /dev/null; then
        log_pass "mosh-server: installed"
    else
        log_warn "mosh-server: NOT INSTALLED"
    fi
    
    # Check if running inside Mosh session
    echo ""
    log_info "Checking session type..."
    
    if [ -n "${MOSH_SERVER_SIGNAL_TMOUT:-}" ] || pgrep -P $$ mosh-server &>/dev/null 2>&1; then
        log_warn "Running inside Mosh session"
        log_info "  → Mosh does NOT support Sixel/Kitty graphics protocols"
        log_info "  → Inline images in Neovim will NOT render"
        log_info "  → Use SSH for image-heavy workflows"
    else
        log_pass "Not running inside Mosh (SSH or direct connection)"
    fi
    
    # Check SSH daemon
    if pgrep sshd &>/dev/null; then
        log_pass "SSH daemon: running"
    else
        log_warn "SSH daemon: not running"
    fi
    
    # Check terminal capabilities
    echo ""
    log_info "Terminal environment..."
    log_info "  TERM=$TERM"
    log_info "  COLORTERM=${COLORTERM:-not set}"
    log_info "  TERM_PROGRAM=${TERM_PROGRAM:-not set}"
}

# -----------------------------------------------------------------------------
# 6. Python & MLOps Tools
# -----------------------------------------------------------------------------
check_mlops_tools() {
    log_section "6. PYTHON & MLOPS TOOLS"
    
    # Python version
    local python_version
    python_version=$(python3 --version 2>&1)
    log_pass "Python: $python_version"
    
    # Virtual environment
    if [ -n "${VIRTUAL_ENV:-}" ]; then
        log_pass "Virtual environment active: $VIRTUAL_ENV"
    else
        log_warn "No virtual environment active"
    fi
    
    # Check key packages
    echo ""
    log_info "Checking MLOps packages..."
    
    local packages=("kedro" "dvc" "torch" "numpy" "pandas" "matplotlib" "jupyter_client" "basedpyright")
    
    for pkg in "${packages[@]}"; do
        if python3 -c "import $pkg" 2>/dev/null; then
            local version
            version=$(python3 -c "import $pkg; print(getattr($pkg, '__version__', 'installed'))" 2>/dev/null || echo "installed")
            log_pass "$pkg: $version"
        else
            # Try command-line tools
            if command -v "$pkg" &>/dev/null; then
                log_pass "$pkg: available (CLI)"
            else
                log_warn "$pkg: NOT INSTALLED"
            fi
        fi
    done
}

# -----------------------------------------------------------------------------
# 7. Image Rendering Dependencies
# -----------------------------------------------------------------------------
check_image_rendering() {
    log_section "7. IMAGE RENDERING DEPENDENCIES"
    
    log_info "Checking image.nvim dependencies..."
    
    # Check ImageMagick
    if command -v convert &>/dev/null; then
        local im_version
        im_version=$(convert --version 2>/dev/null | head -1)
        log_pass "ImageMagick: $im_version"
    else
        log_fail "ImageMagick (convert): NOT FOUND"
    fi
    
    # Check for MagickWand library
    if ldconfig -p 2>/dev/null | grep -q libMagickWand || [ -f /usr/lib/libMagickWand* ] || [ -f /usr/lib/*/libMagickWand* ]; then
        log_pass "libMagickWand: found"
    else
        log_warn "libMagickWand: may not be properly installed"
    fi
    
    # Check sixel support
    if command -v img2sixel &>/dev/null; then
        log_pass "Sixel encoder (img2sixel): installed"
    else
        log_warn "Sixel encoder (img2sixel): NOT INSTALLED"
    fi
    
    # Check cairosvg
    if python3 -c "import cairosvg" 2>/dev/null; then
        log_pass "cairosvg: installed"
    else
        log_warn "cairosvg: NOT INSTALLED"
    fi
}

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
print_summary() {
    log_section "VERIFICATION SUMMARY"
    
    echo ""
    echo -e "  ${GREEN}Passed:${NC}  $PASS_COUNT"
    echo -e "  ${RED}Failed:${NC}  $FAIL_COUNT"
    echo -e "  ${YELLOW}Warnings:${NC} $WARN_COUNT"
    echo ""
    
    if [ $FAIL_COUNT -eq 0 ]; then
        echo -e "${GREEN}${BOLD}✓ Environment verification completed successfully!${NC}"
    else
        echo -e "${RED}${BOLD}✗ Environment has $FAIL_COUNT critical issues that need attention.${NC}"
    fi
    
    echo ""
    echo "For interactive validation, see: MANUAL_CHECKLIST.md"
    echo ""
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    echo ""
    echo -e "${BOLD}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║     PDE Environment Verification Suite                        ║${NC}"
    echo -e "${BOLD}║     Dockerized MLOps Workspace Health Check                   ║${NC}"
    echo -e "${BOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Timestamp: $(date)"
    echo "Hostname:  $(hostname)"
    echo "User:      $(whoami) (UID: $(id -u))"
    
    check_system_dependencies
    check_gpu_layer
    check_neovim_layer
    check_tmux_config
    check_connectivity
    check_mlops_tools
    check_image_rendering
    print_summary
    
    # Exit with error code if there were failures
    [ $FAIL_COUNT -eq 0 ]
}

main "$@"

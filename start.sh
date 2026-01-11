#!/bin/bash
# =============================================================================
# Portable ML Lab - Quick Start Script
# 
# Usage:
#   ./start.sh                     # Use path from .env or default
#   ./start.sh /path/to/project    # Open specific project folder
#   ./start.sh ~/my-ml-project     # Supports ~ expansion
#
# Examples:
#   ./start.sh ~/Desktop/my-project
#   ./start.sh /Users/john/code/ml-experiment
#   ./start.sh C:/Users/john/projects  # Windows Git Bash
# =============================================================================

set -e

# Windows Git Bash compatibility - prevent path mangling
export MSYS_NO_PATHCONV=1
export MSYS2_ARG_CONV_EXCL="*"

PROJECT_PATH="${1:-}"

# =============================================================================
# GPU Auto-Detection: nvidia, amd, or cpu
# =============================================================================
detect_gpu() {
    # Check for NVIDIA GPU
    if command -v nvidia-smi &> /dev/null && nvidia-smi &> /dev/null; then
        echo "nvidia"
        return
    fi
    
    # Check for AMD GPU (Linux)
    if [ -d "/sys/class/drm" ]; then
        if ls /sys/class/drm/card*/device/vendor 2>/dev/null | xargs cat 2>/dev/null | grep -q "0x1002"; then
            echo "amd"
            return
        fi
    fi
    
    # Check for AMD GPU (macOS - no ROCm support, use CPU)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if system_profiler SPDisplaysDataType 2>/dev/null | grep -qi "AMD"; then
            echo "cpu"  # macOS AMD uses Metal, not ROCm
            return
        fi
    fi
    
    # Check via lspci (Linux)
    if command -v lspci &> /dev/null; then
        if lspci 2>/dev/null | grep -i "vga\|3d\|display" | grep -qi "nvidia"; then
            echo "nvidia"
            return
        elif lspci 2>/dev/null | grep -i "vga\|3d\|display" | grep -qi "amd\|radeon"; then
            echo "amd"
            return
        fi
    fi
    
    echo "cpu"
}

# Detect GPU and export
export GPU_TYPE=$(detect_gpu)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Show help
if [ "$PROJECT_PATH" = "-h" ] || [ "$PROJECT_PATH" = "--help" ]; then
    echo "Usage: ./start.sh [project_path]"
    echo ""
    echo "Arguments:"
    echo "  project_path    Path to your project folder (mounted as /projects)"
    echo ""
    echo "Examples:"
    echo "  ./start.sh ~/Desktop/my-project"
    echo "  ./start.sh /home/user/ml-experiments"
    echo ""
    exit 0
fi

# Check Docker prerequisites
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed or not in PATH"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "❌ Docker daemon is not running"
    exit 1
fi

cd "$SCRIPT_DIR"

# Create .env from example if it doesn't exist
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "Created .env from .env.example"
    fi
fi

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     🧪 Portable ML Lab - Docker IDE       ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
echo -e "${GREEN}🖥️  Detected GPU: ${GPU_TYPE}${NC}"

# Update project path if provided
if [ -n "$PROJECT_PATH" ]; then
    # Expand ~ to full path
    PROJECT_PATH="${PROJECT_PATH/#\~/$HOME}"
    
    # Convert to absolute path if relative
    if [[ "$PROJECT_PATH" != /* ]]; then
        PROJECT_PATH="$(cd "$PROJECT_PATH" 2>/dev/null && pwd)" || PROJECT_PATH="$(pwd)/$PROJECT_PATH"
    fi
    
    if [ -d "$PROJECT_PATH" ]; then
        echo -e "${GREEN}📁 Project path: $PROJECT_PATH${NC}"
    else
        echo -e "${YELLOW}⚠️  Directory not found: $PROJECT_PATH${NC}"
        echo "Creating directory..."
        mkdir -p "$PROJECT_PATH"
        echo -e "${GREEN}📁 Created: $PROJECT_PATH${NC}"
    fi
    
    # Update .env file
    if grep -q "HOST_PROJECTS_PATH" .env 2>/dev/null; then
        # Cross-platform sed (works on both GNU and BSD sed)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|HOST_PROJECTS_PATH=.*|HOST_PROJECTS_PATH=$PROJECT_PATH|" .env
        else
            sed -i "s|HOST_PROJECTS_PATH=.*|HOST_PROJECTS_PATH=$PROJECT_PATH|" .env
        fi
    else
        echo "HOST_PROJECTS_PATH=$PROJECT_PATH" >> .env
    fi
else
    # Show current project path from .env
    if [ -f .env ]; then
        CURRENT_PATH=$(grep "HOST_PROJECTS_PATH" .env 2>/dev/null | cut -d'=' -f2)
        if [ -n "$CURRENT_PATH" ]; then
            echo -e "${GREEN}📁 Project path: $CURRENT_PATH${NC}"
        fi
    fi
fi

# Check if container is running
if docker compose ps --status running 2>/dev/null | grep -q mlops-env; then
    echo -e "${GREEN}✓ Container already running${NC}"
else
    echo -e "${BLUE}🔨 Building/starting container (GPU_TYPE=${GPU_TYPE})...${NC}"
    docker compose build
    docker compose up -d
fi

# Wait for container to be ready
sleep 2

# Check if tmux session exists
if docker compose exec -u dev mlops-env tmux has-session -t mlops 2>/dev/null; then
    echo -e "${GREEN}✓ Tmux session 'mlops' exists${NC}"
else
    echo -e "${BLUE}📺 Creating tmux session...${NC}"
    docker compose exec -u dev mlops-env tmuxp load -d /home/dev/.config/tmuxp/lab.yaml
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Ready! Attaching to tmux session...${NC}"
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo ""
echo -e "  ${YELLOW}Detach:${NC} Ctrl-a d"
echo -e "  ${YELLOW}Reattach:${NC} ./start.sh"
echo ""

# Attach to tmux session
docker compose exec -u dev mlops-env tmux attach -t mlops

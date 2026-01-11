#!/bin/bash
# =============================================================================
# Portable ML Lab - Quick Start Script
# Usage: ./start.sh [project_path]
# =============================================================================

set -e

# Windows Git Bash compatibility - prevent path mangling
export MSYS_NO_PATHCONV=1
export MSYS2_ARG_CONV_EXCL="*"

PROJECT_PATH="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

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

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     🧪 Portable ML Lab - Docker IDE       ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"

# Update project path if provided
if [ -n "$PROJECT_PATH" ]; then
    # Expand ~ to full path
    PROJECT_PATH="${PROJECT_PATH/#\~/$HOME}"
    
    if [ -d "$PROJECT_PATH" ]; then
        echo -e "${GREEN}📁 Project path: $PROJECT_PATH${NC}"
        
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
        echo -e "${YELLOW}⚠️  Directory not found: $PROJECT_PATH${NC}"
        echo "Creating directory..."
        mkdir -p "$PROJECT_PATH"
    fi
fi

# Check if container is running
if docker compose ps --status running 2>/dev/null | grep -q mlops-env; then
    echo -e "${GREEN}✓ Container already running${NC}"
else
    echo -e "${BLUE}🔨 Starting container...${NC}"
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

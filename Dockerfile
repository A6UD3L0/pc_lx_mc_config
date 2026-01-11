# Portable ML Lab - Multi-Architecture Dockerfile
# Build args: GPU_TYPE=cpu (default), nvidia, or amd
ARG TARGETARCH
ARG GPU_TYPE=cpu

# Base images for different GPU types
FROM nvidia/cuda:12.4.1-devel-ubuntu22.04 AS base-nvidia
FROM rocm/dev-ubuntu-22.04:6.0 AS base-amd
FROM ubuntu:22.04 AS base-cpu

# Select base image based on GPU_TYPE
FROM base-${GPU_TYPE} AS base

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    TZ=UTC

# System packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake pkg-config curl git wget unzip ca-certificates gnupg \
    openssh-server mosh sudo locales \
    libmagickwand-dev imagemagick libsixel-bin libsixel-dev \
    ripgrep fd-find fzf xclip htop tmux zsh \
    lua5.1 liblua5.1-0-dev luarocks \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
    libncursesw5-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
    libcairo2-dev libpango1.0-dev gosu \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

# SSH config
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Neovim (URL format: nvim-linux-x86_64.tar.gz / nvim-linux-arm64.tar.gz)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"; \
    elif [ "$ARCH" = "aarch64" ]; then NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz"; \
    else echo "Unsupported architecture: $ARCH" && exit 1; fi && \
    curl -fsSL -o /tmp/nvim.tar.gz "$NVIM_URL" && \
    mkdir -p /opt/nvim && tar -xzf /tmp/nvim.tar.gz -C /opt/nvim --strip-components=1 && rm /tmp/nvim.tar.gz
ENV PATH="/opt/nvim/bin:$PATH"

# Lazygit
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then LG_ARCH="x86_64"; else LG_ARCH="arm64"; fi && \
    LAZYGIT_VERSION=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') && \
    curl -fsSL -o /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_${LG_ARCH}.tar.gz" && \
    tar -xzf /tmp/lazygit.tar.gz -C /tmp lazygit && install /tmp/lazygit /usr/local/bin && rm -rf /tmp/lazygit*

# Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && rm -rf /var/lib/apt/lists/*

# uv + Python
ENV UV_INSTALL_DIR="/opt/uv" \
    VIRTUAL_ENV=/opt/venv \
    UV_PYTHON_INSTALL_DIR=/opt/python
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/opt/venv/bin:/opt/uv:$PATH"

# Re-declare ARG after FROM (Docker requirement)
ARG GPU_TYPE=cpu

# Base Python packages (no GPU deps)
RUN /opt/uv/uv python install 3.11 && \
    /opt/uv/uv venv $VIRTUAL_ENV --python 3.11 && \
    /opt/uv/uv pip install --python $VIRTUAL_ENV/bin/python \
    pynvim jupyter_client ipykernel jupyterlab jupyter-console ipywidgets cairosvg matplotlib \
    basedpyright kedro dvc numpy pandas scikit-learn ruff tmuxp \
    mlflow tensorboard wandb

# PyTorch: Install based on GPU_TYPE (nvidia=CUDA, amd=ROCm, cpu=CPU-only)
RUN if [ "$GPU_TYPE" = "nvidia" ]; then \
        echo "Installing PyTorch with CUDA support..." && \
        /opt/uv/uv pip install --python $VIRTUAL_ENV/bin/python torch torchvision torchaudio; \
    elif [ "$GPU_TYPE" = "amd" ]; then \
        echo "Installing PyTorch with ROCm support (AMD GPU)..." && \
        /opt/uv/uv pip install --python $VIRTUAL_ENV/bin/python torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.0; \
    else \
        echo "Installing PyTorch CPU-only (fastest build)..." && \
        /opt/uv/uv pip install --python $VIRTUAL_ENV/bin/python torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu; \
    fi

RUN python -m ipykernel install --name "pde-kernel" --display-name "PDE Python 3.11"

# User setup
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/zsh && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && \
    mkdir -p /home/$USERNAME/.ssh /home/$USERNAME/.config/nvim /home/$USERNAME/.config/tmuxp \
             /home/$USERNAME/.local/share/nvim /workspace && \
    chown -R $USERNAME:$USERNAME /home/$USERNAME /workspace

WORKDIR /workspace

# Copy configs
COPY --chown=dev:dev config/nvim/ /home/$USERNAME/.config/nvim/
COPY --chown=dev:dev config/tmux.conf /home/$USERNAME/.tmux.conf
COPY --chown=dev:dev config/lab.yaml /home/$USERNAME/.config/tmuxp/lab.yaml

# User setup
USER $USERNAME
WORKDIR /home/$USERNAME
ENV PATH="/opt/venv/bin:/opt/nvim/bin:/opt/uv:$PATH" \
    VIRTUAL_ENV="/opt/venv"

RUN git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    echo 'source /opt/venv/bin/activate' >> ~/.zshrc && \
    echo 'export EDITOR=nvim' >> ~/.zshrc && \
    nvim --headless "+Lazy! sync" +qa 2>/dev/null || true && \
    nvim --headless -c 'lua require("lazy").load({plugins = {"molten-nvim"}})' -c 'UpdateRemotePlugins' -c 'qa' 2>/dev/null || true

# Entrypoint (convert CRLF to LF for Windows compatibility)
USER root
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN sed -i 's/\r$//' /usr/local/bin/entrypoint.sh && chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 22 8888
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/zsh"]

#!/bin/bash
set -e

USERNAME="dev"
USER_HOME="/home/$USERNAME"

# UID/GID mapping with idempotency check
map_user() {
    if [ "$(id -u)" = "0" ]; then
        local host_uid="${HOST_UID:-1000}"
        local host_gid="${HOST_GID:-1000}"
        local current_uid=$(id -u "$USERNAME" 2>/dev/null || echo "")
        local current_gid=$(id -g "$USERNAME" 2>/dev/null || echo "")
        
        # Only modify if UID/GID differs (idempotency)
        if [ "$current_gid" != "$host_gid" ]; then
            echo "Updating GID: $current_gid -> $host_gid"
            groupmod -g "$host_gid" "$USERNAME" 2>/dev/null || true
        fi
        
        if [ "$current_uid" != "$host_uid" ]; then
            echo "Updating UID: $current_uid -> $host_uid"
            usermod -u "$host_uid" "$USERNAME" 2>/dev/null || true
        fi
        
        # Only chown home directory (not /workspace - too slow for large dirs)
        # /workspace ownership is handled by bind mount permissions
        if [ "$current_uid" != "$host_uid" ] || [ "$current_gid" != "$host_gid" ]; then
            chown -R "$host_uid:$host_gid" "$USER_HOME" 2>/dev/null || true
        fi
    fi
}

# SSH host keys
setup_ssh() {
    if [ "$(id -u)" = "0" ]; then
        [ ! -f /etc/ssh/ssh_host_rsa_key ] && ssh-keygen -A
        chmod 600 /etc/ssh/ssh_host_*_key 2>/dev/null || true
        [ "${START_SSHD:-true}" = "true" ] && /usr/sbin/sshd
    fi
}

# Main
echo "=== Portable ML Lab ==="
map_user
setup_ssh
echo "=== Ready ==="

if [ $# -eq 0 ]; then
    exec gosu "$USERNAME" /bin/zsh
else
    exec gosu "$USERNAME" "$@"
fi

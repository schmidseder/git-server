#!/bin/sh
set -eu

echo "Starting Git SSH server..."

# Prepare SSH directory for the git user
mkdir -p /home/git/.ssh
chown git:git /home/git/.ssh
chmod 700 /home/git/.ssh

# Write authorised_keys from environment variable
if [ -n "${AUTHORIZED_KEYS:-}" ] && [ ! -f /home/git/.ssh/authorized_keys ]; then
  printf "%s\n" "$AUTHORIZED_KEYS" > /home/git/.ssh/authorized_keys
  chown git:git /home/git/.ssh/authorized_keys
  chmod 600 /home/git/.ssh/authorized_keys
fi

# write sshd_config
cat <<EOF > /etc/ssh/sshd_config
Port 22
HostKey /etc/ssh/ssh_host_ed25519_key
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
KbdInteractiveAuthentication no
AllowUsers git
AllowTcpForwarding no
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 30
MaxAuthTries 3
MaxSessions 2
EOF

# Generate SSH host keys only if they do not exist
if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
  echo "Generating SSH host keys..."
  ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N '' 
fi

# Validate SSH configuration before starting the server
echo "Checking SSH configuration..."
sshd -t

# SSH-Dienst starten
exec /usr/sbin/sshd -D

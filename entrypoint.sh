#!/bin/sh
set -eu

handle_error() {
  echo "Ere $1: $2"
  exit 1
}

run() {
  LINE=$1
  shift
  "$@" || handle_error "$LINE" "$*"
}

run $LINENO echo "Starting SSH-Server"

# Write authorised_keys from environment variable
if [ -n "${AUTHORIZED_KEYS:-}" ]; then
  printf "%s\n" "$AUTHORIZED_KEYS" > /home/git/.ssh/authorized_keys
  chown git:git /home/git/.ssh/authorized_keys
  chmod 600 /home/git/.ssh/authorized_keys
fi

# write sshd_config
cat <<EOF > /etc/ssh/sshd_config
Port 22
Protocol 2
HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_rsa_key
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
ChallengeResponseAuthentication no
AllowUsers git
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org
X11Forwarding no
AllowTcpForwarding no
PermitTunnel no
UseDNS no
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 30
MaxAuthTries 3
MaxSessions 2
EOF

# SSH-Dienst starten
exec /usr/sbin/sshd -D

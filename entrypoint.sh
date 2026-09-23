#!/bin/bash
set -e
H=/home/maell

# Volume kosong saat pertama mount -> isi default shell files
cp -rn /etc/skel/. "$H"/ 2>/dev/null || true

# Host key disimpan di volume supaya tidak berubah tiap redeploy
mkdir -p "$H/.hostkeys" "$H/.ssh"
[ -f "$H/.hostkeys/ssh_host_ed25519_key" ] || ssh-keygen -q -t ed25519 -N "" -f "$H/.hostkeys/ssh_host_ed25519_key"
[ -f "$H/.hostkeys/ssh_host_rsa_key" ]     || ssh-keygen -q -t rsa -b 3072 -N "" -f "$H/.hostkeys/ssh_host_rsa_key"

# Public key dari environment variable bunny.net
if [ -z "$SSH_PUBKEY" ]; then echo "ERROR: SSH_PUBKEY kosong" >&2; exit 1; fi
echo "$SSH_PUBKEY" > "$H/.ssh/authorized_keys"

chown -R maell:maell "$H" 2>/dev/null || true
chown root:root "$H/.hostkeys" "$H"/.hostkeys/*
chmod 755 "$H/.hostkeys"; chmod 600 "$H"/.hostkeys/ssh_host_*_key
chmod 700 "$H/.ssh";      chmod 600 "$H/.ssh/authorized_keys"

# --- auto-start bot (aktif kalau file ~/.autostart ada) ---
if [ -f "$H/.autostart" ]; then
  mkdir -p "$H/bot"
  ( runuser -u maell -- bash -c 'while true; do /home/maell/bot/workplace/run.sh; sleep 10; done' >> "$H/bot/supervisor.log" 2>&1 & )
fi

exec /usr/sbin/sshd -D -e

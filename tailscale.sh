
#!/usr/bin/env bash
set -euo pipefail

echo "[+] Hardening tailscaled service"

SERVICE_OVERRIDE_DIR="/etc/systemd/system/tailscaled.service.d"
POLKIT_RULE="/etc/polkit-1/rules.d/49-resolved-tailscale.rules"

# -----------------------------

# Ensure tailscale user exists

# -----------------------------

if ! id tailscale &>/dev/null; then
echo "[+] Creating system user: tailscale"
useradd --system --no-create-home --shell /usr/sbin/nologin tailscale
else
echo "[+] User tailscale already exists"
fi

# -----------------------------

# Install polkit rule

# -----------------------------

echo "[+] Installing polkit rule for systemd-resolved DNS control"

cat > "$POLKIT_RULE" <<'EOF'
polkit.addRule(function(action, subject) {
if (subject.user == "tailscale" &&
action.id.indexOf("org.freedesktop.resolve1.") == 0) {
return polkit.Result.YES;
}
});
EOF

chmod 644 "$POLKIT_RULE"

# -----------------------------

# Install systemd override

# -----------------------------

echo "[+] Installing systemd sandbox override"

mkdir -p "$SERVICE_OVERRIDE_DIR"

cat > "$SERVICE_OVERRIDE_DIR/override.conf" <<'EOF'
[Service]
User=tailscale
Group=tailscale

AmbientCapabilities=CAP_NET_RAW CAP_NET_ADMIN
CapabilityBoundingSet=CAP_NET_RAW CAP_NET_ADMIN

DeviceAllow=/dev/tun
DeviceAllow=/dev/net/tun

NoNewPrivileges=yes
PrivateTmp=yes
PrivateMounts=yes
RestrictNamespaces=yes
RestrictRealtime=yes
RestrictSUIDSGID=yes
MemoryDenyWriteExecute=yes
LockPersonality=yes

ProtectKernelModules=no
ProtectHome=yes
ProtectControlGroups=yes
ProtectKernelLogs=yes
ProtectSystem=full
ProtectProc=noaccess

SystemCallArchitectures=native
SystemCallFilter=@known
SystemCallFilter=~@clock @cpu-emulation @raw-io @reboot @mount @obsolete @swap @debug @keyring @pkey
EOF

# -----------------------------

# Reload services

# -----------------------------

echo "[+] Reloading systemd configuration"

systemctl daemon-reload

echo "[+] Restarting services"

systemctl restart tailscaled

echo "[✓] tailscaled hardening complete"

# 🌐 CLOUDFLARE TUNNEL FIX GUIDE

## 🔴 Masalah yang Anda Alami

**Symptom**: Domain pertama (utama & netdata) berhasil, tapi semua domain baru gagal semua meskipun sudah di systemd.

**Root Cause**: Kemungkinan besar ada 3 hal:
1. Systemd cache tidak di-reload setelah config berubah
2. Service yang ditunjuk tidak benar-benar listening di port yang disebutkan
3. Cloudflare DNS atau tunnel configuration tidak sync

---

## 🔧 FIX CLOUDFLARE TUNNEL - Step by Step

### Step 1: Cek Service yang Sedang Berjalan

```bash
# Cek semua port yang listening
netstat -tulpn | grep LISTEN

# Yang harus ada:
# :80    -> nginx
# :8012  -> triforce (berhasil)
# :19999 -> netdata (berhasil)
# :8766  -> telkom cup (yang mau kita fix)
```

**Jika port 8766 TIDAK muncul**, berarti Docker container belum jalan!

### Step 2: Fix Cloudflare Config

Edit config:
```bash
sudo nano ~/.cloudflared/config.yml
```

**Config yang BENAR:**
```yaml
tunnel: 59eee031-f3bf-4475-a76c-4f4a7a75e560
credentials-file: /root/.cloudflared/59eee031-f3bf-4475-a76c-4f4a7a75e560.json

ingress:
  - hostname: kagayakuverse.my.id
    service: http://localhost:80
  - hostname: triforce.kagayakuverse.my.id
    service: http://localhost:8012
  - hostname: netdata.kagayakuverse.my.id
    service: http://localhost:19999
  - hostname: telkomcup.kagayakuverse.my.id
    service: http://localhost:8766
  - service: http_status:404
```

**PENTING**: Pastikan:
- ✅ Tidak ada typo di hostname
- ✅ Service URL menggunakan `http://` bukan `https://`
- ✅ Port sesuai dengan yang benar-benar listening
- ✅ Ada catch-all rule di akhir (`http_status:404`)

### Step 3: Reload Systemd & Restart Cloudflared

```bash
# Stop cloudflared
sudo systemctl stop cloudflared

# Reload systemd daemon (PENTING!)
sudo systemctl daemon-reload

# Start cloudflared
sudo systemctl start cloudflared

# Check status
sudo systemctl status cloudflared

# Check logs
sudo journalctl -u cloudflared -f
```

**Apa yang harus muncul di logs:**
```
Registered tunnel connection
```

**Jika ada error**, biasanya:
- `dial tcp: connection refused` → Service tidak berjalan di port tersebut
- `config error` → Syntax error di config.yml
- `authentication failed` → Credentials file salah

### Step 4: Cek Permission Files

```bash
# Cek ownership
ls -la ~/.cloudflared/

# Seharusnya:
# -rw------- root root config.yml
# -rw------- root root *.json

# Jika salah, fix:
sudo chown -R root:root ~/.cloudflared/
sudo chmod 600 ~/.cloudflared/config.yml
sudo chmod 600 ~/.cloudflared/*.json
```

### Step 5: Verify Tunnel Status

```bash
# Check tunnel connections
cloudflared tunnel info 59eee031-f3bf-4475-a76c-4f4a7a75e560

# List all tunnels
cloudflared tunnel list

# Check route
cloudflared tunnel route dns 59eee031-f3bf-4475-a76c-4f4a7a75e560
```

---

## 🎯 DEBUGGING CLOUDFLARE TUNNEL

### Test Local First

```bash
# Test if service is reachable locally
curl http://localhost:8766/health

# If this fails, Docker container is the problem, NOT Cloudflare!
```

### Check Cloudflare Dashboard

1. Login ke Cloudflare Dashboard
2. Go to **Zero Trust** → **Access** → **Tunnels**
3. Click your tunnel (59eee031...)
4. Check **Public Hostname** tab
5. Make sure `telkomcup.kagayakuverse.my.id` is listed

**If NOT listed:**
```bash
# Add route manually
cloudflared tunnel route dns 59eee031-f3bf-4475-a76c-4f4a7a75e560 telkomcup.kagayakuverse.my.id
```

### Check DNS Resolution

```bash
# Check if DNS is pointing to tunnel
dig telkomcup.kagayakuverse.my.id

# Should return CNAME pointing to *.cfargotunnel.com
```

### Monitor Cloudflared Logs

```bash
# Live logs
sudo journalctl -u cloudflared -f

# Last 50 lines
sudo journalctl -u cloudflared -n 50

# Filter errors only
sudo journalctl -u cloudflared | grep -i error
```

---

## 🚨 COMMON ISSUES & FIXES

### Issue 1: "Connection Refused"

**Symptom**: Cloudflared logs show `dial tcp: connection refused`

**Cause**: Service tidak berjalan di port yang disebutkan

**Fix**:
```bash
# Check if port is listening
netstat -tulpn | grep 8766

# If not listening, start the service
cd /opt/telkom-cup
docker-compose up -d

# Wait and check again
sleep 10
netstat -tulpn | grep 8766
```

### Issue 2: "Only First 2 Domains Work"

**Symptom**: Domain lama work, domain baru fail

**Cause**: Systemd tidak reload config baru

**Fix**:
```bash
# Force reload everything
sudo systemctl stop cloudflared
sudo systemctl daemon-reload
sudo systemctl reset-failed cloudflared
sudo systemctl start cloudflared

# Verify
sudo systemctl status cloudflared
```

### Issue 3: "502 Bad Gateway"

**Symptom**: Domain accessible tapi return 502

**Cause**: Service down atau port salah

**Fix**:
```bash
# Test local service first
curl http://localhost:8766/health

# If works locally, problem is Cloudflare config
# Check config.yml port matches actual port

# If fails locally, fix the service
cd /opt/telkom-cup
bash fix-all.sh
```

### Issue 4: "Tunnel Not Connecting"

**Symptom**: `cloudflared` running tapi tidak connect

**Cause**: Credential file issue atau network

**Fix**:
```bash
# Verify credentials
cat ~/.cloudflared/59eee031-f3bf-4475-a76c-4f4a7a75e560.json

# Should be valid JSON with AccountTag, TunnelSecret, TunnelID

# Re-authenticate if needed
cloudflared tunnel login

# Test connection
cloudflared tunnel run 59eee031-f3bf-4475-a76c-4f4a7a75e560
# (Ctrl+C to stop)

# If works, restart service
sudo systemctl restart cloudflared
```

---

## 📋 COMPLETE FIX CHECKLIST

Use this checklist untuk systematically fix your tunnel:

```bash
# ✅ 1. Check Service Running
docker ps | grep telkom_app
# Expected: Container running

# ✅ 2. Check Port Listening
netstat -tulpn | grep 8766
# Expected: Something listening on 8766

# ✅ 3. Check Local Access
curl http://localhost:8766/health
# Expected: {"status":"ok",...}

# ✅ 4. Check Cloudflare Config
cat ~/.cloudflared/config.yml | grep telkomcup
# Expected: telkomcup.kagayakuverse.my.id with http://localhost:8766

# ✅ 5. Check File Permissions
ls -la ~/.cloudflared/
# Expected: 600 permissions, root:root owner

# ✅ 6. Restart Cloudflared Properly
sudo systemctl stop cloudflared
sudo systemctl daemon-reload
sudo systemctl start cloudflared
sudo systemctl status cloudflared
# Expected: active (running)

# ✅ 7. Check Cloudflared Logs
sudo journalctl -u cloudflared -n 20
# Expected: "Registered tunnel connection"

# ✅ 8. Test DNS
dig telkomcup.kagayakuverse.my.id
# Expected: CNAME to *.cfargotunnel.com

# ✅ 9. Test External Access
curl https://telkomcup.kagayakuverse.my.id/health
# Expected: {"status":"ok",...}
```

---

## 🔄 PROPER WORKFLOW: Adding New Domain to Tunnel

**Correct sequence untuk add domain baru:**

```bash
# 1. Make sure service is running locally
curl http://localhost:PORT/test

# 2. Edit Cloudflare config
sudo nano ~/.cloudflared/config.yml
# Add new hostname + service

# 3. Add DNS route
cloudflared tunnel route dns TUNNEL-ID subdomain.domain.com

# 4. Stop cloudflared
sudo systemctl stop cloudflared

# 5. Reload systemd (CRITICAL!)
sudo systemctl daemon-reload

# 6. Start cloudflared
sudo systemctl start cloudflared

# 7. Check status
sudo systemctl status cloudflared

# 8. Monitor logs
sudo journalctl -u cloudflared -f
# Look for "Registered tunnel connection" for new hostname

# 9. Test
curl https://subdomain.domain.com
```

---

## 🎯 RECOMMENDED FIX FOR YOUR SITUATION

Berdasarkan info Anda, ini step-by-step fix:

```bash
# 1. Fix Docker Container
cd /opt/telkom-cup
bash fix-all.sh

# 2. Verify local service
curl http://localhost:8766/health

# 3. Fix Cloudflare config (if port mismatch)
sudo nano ~/.cloudflared/config.yml
# Change line:
#   service: http://localhost:8765  # WRONG
# To:
#   service: http://localhost:8766  # CORRECT

# 4. Properly restart Cloudflared
sudo systemctl stop cloudflared
sudo systemctl daemon-reload
sudo systemctl start cloudflared

# 5. Check logs
sudo journalctl -u cloudflared -n 50

# 6. Test external
curl https://telkomcup.kagayakuverse.my.id/health
```

---

## 💡 PRO TIPS

1. **Always test local first**: Jika `curl localhost:8766` fail, jangan harap Cloudflare bisa akses!

2. **Systemd cache is real**: Selalu `daemon-reload` setelah edit config

3. **Monitor logs**: `journalctl -u cloudflared -f` adalah best friend Anda

4. **Use explicit ports**: Jangan rely on default ports, always specify

5. **DNS propagation**: Kadang butuh 5-10 menit untuk DNS update

6. **Config validation**: Cloudflared tidak validate config saat start, dia baru error pas routing

---

## 🆘 EMERGENCY: Reset Cloudflare Tunnel

Jika semuanya gagal, nuclear option:

```bash
# 1. Stop cloudflared
sudo systemctl stop cloudflared
sudo systemctl disable cloudflared

# 2. Backup config
cp ~/.cloudflared/config.yml ~/.cloudflared/config.yml.backup

# 3. Clean install cloudflared
cloudflared update

# 4. Restore config
cp ~/.cloudflared/config.yml.backup ~/.cloudflared/config.yml

# 5. Re-enable systemd
sudo cloudflared service install
sudo systemctl enable cloudflared
sudo systemctl start cloudflared

# 6. Check
sudo systemctl status cloudflared
```

---

**Key Takeaway**: Masalah "domain lama works, baru fail" = **systemd cache issue**. Solution: Always `daemon-reload`!

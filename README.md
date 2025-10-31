# cash-flow-telcup

Aplikasi transparansi pengelolaan dana Telkom Cup TRI.

## 🚀 Quick Deployment

### Jika Muncul Error MongoDB "unhealthy"

```bash
cd /opt/telkom-cup
bash fix-mongodb.sh
```

### Deploy Normal

```bash
bash deploy.sh
```

## � DEBUGGING TOOLS (NEW!)

Untuk yang vibes coding tapi susah debugging, ada tools lengkap:

### 1. **debug.sh** - Master Debugger 🎯
```bash
bash debug.sh
```
Comprehensive system check: containers, health, logs, database, network, auto-detect issues!

### 2. **status.sh** - Quick Dashboard 📊
```bash
bash status.sh
```
Quick overview: status, health, resources, database stats.

### 3. **view-logs.sh** - Log Viewer 📋
```bash
bash view-logs.sh
```
Interactive menu untuk view logs (live/historical/error only).

### 4. **monitor.sh** - Auto Health Check 🤖
```bash
bash setup-monitoring.sh  # Setup once
```
Auto-check every minute, auto-restart if down!

### 5. **fix-mongodb.sh** - MongoDB Fixer 🔧
```bash
bash fix-mongodb.sh
```
Fix MongoDB unhealthy issues automatically.

📖 **Full Guide**: Baca [DEBUGGING-GUIDE.md](DEBUGGING-GUIDE.md) untuk tutorial lengkap!

## �🔧 Manual Fix

Jika `fix-mongodb.sh` tidak berhasil:

```bash
cd /opt/telkom-cup

# 1. Stop semua container
docker-compose down

# 2. Start MongoDB dulu
docker-compose up -d mongodb

# 3. Tunggu 30 detik
sleep 30

# 4. Cek MongoDB
docker logs telkom_mongodb

# 5. Start App
docker-compose up -d app

# 6. Lihat logs
docker-compose logs -f
```

## 📝 Access URLs

- **Public**: http://localhost:8766
- **Admin**: http://localhost:8766/admin

## 🔐 Default Credentials

- Username: `admin`
- Password: `telkomcup2024`

⚠️ **PENTING**: Ubah password setelah login pertama!

## 📚 Documentation

- [DEBUGGING-GUIDE.md](DEBUGGING-GUIDE.md) - Complete debugging guide untuk vibes coders
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues & solutions
- [CLOUDFLARE-TUNNEL-FIX.md](CLOUDFLARE-TUNNEL-FIX.md) - Fix Cloudflare Tunnel issues
- [CHEAT-SHEET.md](CHEAT-SHEET.md) - Quick reference commands

## 🛠️ Useful Commands

```bash
# Debug & Status
bash debug.sh              # Full system check
bash status.sh             # Quick status
bash view-logs.sh          # Interactive log viewer

# Lihat logs
docker-compose logs -f     # Live logs
docker logs telkom_app     # App logs only

# Restart
docker-compose restart     # Restart all
docker-compose restart app # Restart app only

# Stop & Start
docker-compose down        # Stop all
docker-compose up -d       # Start all

# Fresh start
docker-compose down -v     # Stop & remove volumes
docker-compose up -d       # Start fresh
```

## 🎯 Quick Troubleshooting

**Container tidak start?**
```bash
bash debug.sh              # Identify the issue
docker logs telkom_app     # Check logs
```

**MongoDB unhealthy?**
```bash
bash fix-mongodb.sh        # Auto fix
```

**Port conflict?**
```bash
netstat -tulpn | grep 8766 # Find what's using the port
```

**App restart terus?**
```bash
docker logs --tail 50 telkom_app  # Check why
```

## 💡 Pro Tips

1. **Always check status first**: `bash status.sh`
2. **Setup monitoring**: `bash setup-monitoring.sh` (one-time setup)
3. **Read logs**: `bash view-logs.sh` or `docker-compose logs -f`
4. **Test endpoints**: `curl http://localhost:8766/health`
5. **Use debug.sh**: It auto-detects 90% of issues!

## 🆘 Need Help?

1. Run `bash debug.sh` - it will tell you what's wrong
2. Check [DEBUGGING-GUIDE.md](DEBUGGING-GUIDE.md)
3. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
4. View logs with `bash view-logs.sh`

---

**Made with ❤️ for vibes coders who hate debugging** 🎨✨


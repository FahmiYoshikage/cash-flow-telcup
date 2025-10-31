# 🎯 DEBUGGING GUIDE - For Vibes Coders

Panduan lengkap debugging untuk yang suka vibes coding tapi bingung troubleshooting! 🚀

## 🔥 TOOLS DEBUGGING YANG HARUS KAMU PUNYA

### 1. **debug.sh** - The Master Debugger ⭐
```bash
bash debug.sh
```

**Apa yang dicek:**
- ✅ System info (OS, Docker version, disk space)
- ✅ Container status (running/stopped)
- ✅ Health checks (MongoDB & App)
- ✅ Port usage
- ✅ Recent logs
- ✅ Environment files
- ✅ Database connection & data
- ✅ Network status
- ✅ **Auto-detect common issues!**

**Kapan dipake:** Setiap kali ada masalah atau mau ngecek status!

---

### 2. **status.sh** - Quick Dashboard 📊
```bash
bash status.sh
```

**Apa yang ditampilkan:**
- 📦 Container status
- 🏥 Health checks
- 💻 CPU & RAM usage
- 💾 Database statistics
- 🔗 Access URLs

**Kapan dipake:** Mau cek cepat tanpa detail berlebihan

---

### 3. **view-logs.sh** - Interactive Log Viewer 📋
```bash
bash view-logs.sh
```

**Pilihan menu:**
1. App logs (live stream)
2. MongoDB logs (live stream)
3. Both logs (live stream)
4. App logs (last 100 lines)
5. MongoDB logs (last 100 lines)
6. Monitor log
7. Error logs only

**Kapan dipake:** Pas mau lihat apa yang terjadi di dalam container

---

### 4. **monitor.sh** - Auto Health Check 🤖
```bash
bash monitor.sh
```

**Apa yang dilakukan:**
- ✅ Check MongoDB status setiap menit
- ✅ Check App status setiap menit
- ✅ Check health endpoint
- ✅ **Auto-restart jika ada yang down!**
- ✅ Log semua aktivitas

**Kapan dipake:** 
- Setup sekali pakai `setup-monitoring.sh`
- Atau jalankan manual

---

### 5. **fix-mongodb.sh** - MongoDB Fixer 🔧
```bash
bash fix-mongodb.sh
```

**Apa yang dilakukan:**
- Stop all containers
- Start MongoDB first
- Wait until healthy
- Start App
- Verify everything works

**Kapan dipake:** Setiap kali MongoDB error "unhealthy"

---

## 🎮 QUICK COMMANDS - Copy Paste Aja!

### Cek Status Cepat
```bash
# Lihat semua container
docker ps

# Lihat yang telkom aja
docker ps | grep telkom

# Lihat semua (termasuk yang mati)
docker ps -a
```

### Lihat Logs
```bash
# App logs (live)
docker logs -f telkom_app

# App logs (last 100)
docker logs --tail 100 telkom_app

# MongoDB logs
docker logs -f telkom_mongodb

# All logs
cd /opt/telkom-cup && docker-compose logs -f
```

### Restart Services
```bash
cd /opt/telkom-cup

# Restart semua
docker-compose restart

# Restart app aja
docker-compose restart app

# Restart mongodb aja
docker-compose restart mongodb
```

### Stop & Start
```bash
cd /opt/telkom-cup

# Stop semua
docker-compose down

# Start semua
docker-compose up -d

# Start specific service
docker-compose up -d mongodb
docker-compose up -d app
```

### Masuk ke Container
```bash
# Masuk ke MongoDB shell
docker exec -it telkom_mongodb mongosh telkom_cup_transparency

# Masuk ke App shell
docker exec -it telkom_app sh
```

### Test Endpoints
```bash
# Health check
curl http://localhost:8766/health

# Get expenses summary
curl http://localhost:8766/api/expenses/summary

# Check if app is listening
curl -I http://localhost:8766
```

### Database Commands
```bash
# Connect to MongoDB
docker exec -it telkom_mongodb mongosh telkom_cup_transparency

# Inside mongosh:
db.admins.find()              # List all admins
db.expenses.find()            # List all expenses
db.admins.countDocuments()    # Count admins
db.expenses.countDocuments()  # Count expenses
```

---

## 🚨 COMMON PROBLEMS & SOLUTIONS

### Problem 1: Container tidak mau start
```bash
# Lihat error message
docker logs telkom_app

# Cek apakah ada port conflict
netstat -tulpn | grep 8766

# Restart paksa
docker-compose down
docker-compose up -d --force-recreate
```

### Problem 2: MongoDB unhealthy
```bash
# Use the fix script
bash fix-mongodb.sh

# Or manual:
docker-compose down
docker-compose up -d mongodb
sleep 30
docker-compose up -d app
```

### Problem 3: App restart terus-terusan
```bash
# Lihat logs untuk tau kenapa
docker logs --tail 50 telkom_app

# Biasanya karena MongoDB belum ready
# Wait longer atau restart MongoDB dulu
```

### Problem 4: Port 8766 sudah dipakai
```bash
# Cari siapa yang pakai
netstat -tulpn | grep 8766

# Kill process
kill -9 <PID>

# Or ubah port di docker-compose.yml
# Ganti 8766:3000 jadi 8767:3000
```

### Problem 5: Tidak bisa akses dari browser
```bash
# Cek apakah app running
docker ps | grep telkom_app

# Test local
curl http://localhost:8766/health

# Cek nginx config (kalau pakai reverse proxy)
sudo nginx -t
sudo systemctl status nginx
```

### Problem 6: Database kosong/hilang
```bash
# Cek volume
docker volume ls | grep mongodb

# Cek isi database
docker exec -it telkom_mongodb mongosh telkom_cup_transparency
db.admins.find()
db.expenses.find()

# Kalau hilang, recreate admin
docker-compose exec app node scripts/createAdmin.js
```

---

## 🎯 WORKFLOW DEBUGGING - Step by Step

### Step 1: Identifikasi Masalah
```bash
# Jalankan debug tool
bash debug.sh

# Atau quick status
bash status.sh
```

### Step 2: Lihat Logs
```bash
# Interactive viewer
bash view-logs.sh

# Atau manual
docker logs --tail 100 telkom_app
```

### Step 3: Coba Fix
```bash
# Restart dulu
docker-compose restart

# Kalau masih error, check specific issue
# MongoDB issue?
bash fix-mongodb.sh

# Port issue?
netstat -tulpn | grep 8766

# Permission issue?
sudo chown -R 1001:1001 /opt/telkom-cup
```

### Step 4: Nuclear Option (Last Resort)
```bash
# Hapus semua dan mulai dari awal
cd /opt/telkom-cup
docker-compose down -v
docker system prune -a
bash deploy.sh
```

---

## 📊 MONITORING TIPS

### Setup Auto-Monitoring
```bash
# Install monitoring
bash setup-monitoring.sh

# Pilih 'y' untuk add to crontab
# Sekarang system akan auto-check setiap menit!
```

### Manual Check
```bash
# Run manual monitoring
bash monitor.sh

# View monitoring log
tail -f /opt/telkom-cup/logs/monitor.log
```

### Resource Monitoring
```bash
# Live resource usage
docker stats

# Only telkom containers
docker stats $(docker ps --format '{{.Names}}' | grep telkom)
```

---

## 🎨 BEST PRACTICES untuk Vibes Coders

### 1. **Selalu Check Status Sebelum Coding**
```bash
bash status.sh
```

### 2. **Logs is Your Best Friend**
```bash
# Buka 2 terminal
# Terminal 1: Coding
# Terminal 2: Watch logs
docker-compose logs -f
```

### 3. **Test Setelah Deploy**
```bash
# Always test endpoints
curl http://localhost:8766/health
curl http://localhost:8766/api/expenses/summary
```

### 4. **Backup Database Regularly**
```bash
# Backup
docker exec telkom_mongodb mongodump --out /data/backup

# Restore
docker exec telkom_mongodb mongorestore /data/backup
```

### 5. **Use Debug Tools FIRST Before Google**
```bash
bash debug.sh  # This will tell you what's wrong!
```

---

## 🔗 Quick Reference Card

**Print this and paste di monitor! 😄**

```
╔══════════════════════════════════════════════╗
║        TELKOM CUP - QUICK COMMANDS          ║
╚══════════════════════════════════════════════╝

🔍 DEBUG
  bash debug.sh              Full system check
  bash status.sh             Quick dashboard
  
📋 LOGS
  bash view-logs.sh          Interactive viewer
  docker logs -f telkom_app  Live app logs
  
🔧 FIX
  bash fix-mongodb.sh        Fix MongoDB
  docker-compose restart     Restart all
  
🎯 ENDPOINTS
  curl localhost:8766/health
  curl localhost:8766/api/expenses/summary
  
💾 DATABASE
  docker exec -it telkom_mongodb mongosh
  
🚀 RESTART
  cd /opt/telkom-cup
  docker-compose restart
  
🛑 EMERGENCY (Nuclear)
  docker-compose down -v
  bash deploy.sh
╚══════════════════════════════════════════════╝
```

---

## 💡 PRO TIPS

1. **Bookmark Commands**: Save frequent commands di `~/.bash_aliases`
2. **Setup Monitoring**: Jalankan `setup-monitoring.sh` sekali aja, terus auto-check
3. **Keep Tools Updated**: Update debug tools kalau ada improvement
4. **Read Logs First**: 90% masalah bisa solved dari logs
5. **Don't Panic**: Gunakan `debug.sh` untuk identify masalah dulu

---

**Remember**: Every bug is just a feature waiting to be discovered! 🐛➡️✨

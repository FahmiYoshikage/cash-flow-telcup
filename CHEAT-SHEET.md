# 🎯 TELKOM CUP - CHEAT SHEET

Quick reference untuk copy-paste commands! ⚡

## 🚀 DEPLOYMENT

```bash
# First time deploy
bash deploy.sh

# Fix MongoDB issues
bash fix-mongodb.sh

# Sync from local to VPS
bash sync-to-vps.sh
```

## 🔍 DEBUGGING (MOST IMPORTANT!)

```bash
# Full system check (USE THIS FIRST!)
bash debug.sh

# Quick status
bash status.sh

# View logs interactively
bash view-logs.sh

# Setup auto-monitoring
bash setup-monitoring.sh
```

## 📋 LOGS

```bash
# Live logs - all services
docker-compose logs -f

# Live logs - app only
docker logs -f telkom_app

# Live logs - mongodb only
docker logs -f telkom_mongodb

# Last 100 lines
docker logs --tail 100 telkom_app

# Error logs only
docker-compose logs | grep -i error
```

## 🔄 RESTART

```bash
# Restart all
docker-compose restart

# Restart app only
docker-compose restart app

# Restart mongodb only
docker-compose restart mongodb

# Hard restart
docker-compose down && docker-compose up -d
```

## 🛑 STOP / START

```bash
# Stop all
docker-compose down

# Start all
docker-compose up -d

# Start specific service
docker-compose up -d mongodb
docker-compose up -d app

# Remove volumes too (CAREFUL!)
docker-compose down -v
```

## 🧪 TESTING

```bash
# Health check
curl http://localhost:8766/health

# Summary endpoint
curl http://localhost:8766/api/expenses/summary

# Check response headers
curl -I http://localhost:8766

# Test with verbose
curl -v http://localhost:8766/health
```

## 📊 STATUS

```bash
# All containers
docker ps

# Telkom containers only
docker ps | grep telkom

# All containers (including stopped)
docker ps -a

# Container stats (CPU, RAM)
docker stats

# Telkom stats only
docker stats $(docker ps --format '{{.Names}}' | grep telkom)
```

## 💾 DATABASE

```bash
# Connect to MongoDB
docker exec -it telkom_mongodb mongosh telkom_cup_transparency

# Quick queries (one-liner from shell)
docker exec telkom_mongodb mongosh telkom_cup_transparency --eval "db.admins.find()"
docker exec telkom_mongodb mongosh telkom_cup_transparency --eval "db.expenses.find()"
docker exec telkom_mongodb mongosh telkom_cup_transparency --eval "db.admins.countDocuments()"
docker exec telkom_mongodb mongosh telkom_cup_transparency --eval "db.expenses.countDocuments()"

# Backup database
docker exec telkom_mongodb mongodump --out /data/backup

# Restore database
docker exec telkom_mongodb mongorestore /data/backup
```

## 🐚 SHELL ACCESS

```bash
# Enter app container
docker exec -it telkom_app sh

# Enter mongodb container
docker exec -it telkom_mongodb bash

# Run command without entering
docker exec telkom_app ls -la
docker exec telkom_app node -v
```

## 🔧 MAINTENANCE

```bash
# View disk usage
docker system df

# Clean unused images
docker image prune

# Clean everything (CAREFUL!)
docker system prune -a

# View volumes
docker volume ls

# Remove specific volume
docker volume rm telkom-cup_mongodb_data
```

## 🌐 NETWORK

```bash
# List networks
docker network ls

# Inspect network
docker network inspect telkom-cup_telkom_network

# Check port usage
netstat -tulpn | grep 8766

# Check if port is accessible
curl -v telnet://localhost:8766
```

## 🔍 TROUBLESHOOTING ONE-LINERS

```bash
# Container keeps restarting?
docker logs --tail 50 telkom_app

# MongoDB unhealthy?
bash fix-mongodb.sh

# Port already in use?
netstat -tulpn | grep 8766 && echo "Port is in use!"

# Cannot connect to DB?
docker exec telkom_mongodb mongosh --eval "db.adminCommand('ping')"

# Check container health
docker inspect telkom_app | grep -A 10 Health

# Check environment variables
docker exec telkom_app env | grep MONGODB

# File permissions issue?
sudo chown -R 1001:1001 /opt/telkom-cup

# Fresh start (nuclear option)
docker-compose down -v && docker system prune -af && bash deploy.sh
```

## 📤 FILE OPERATIONS

```bash
# Copy file TO container
docker cp local-file.txt telkom_app:/app/

# Copy file FROM container
docker cp telkom_app:/app/file.txt ./

# View file inside container
docker exec telkom_app cat /app/server.js

# Edit file (enter shell first)
docker exec -it telkom_app sh
vi /app/server.js
```

## 🔐 ADMIN OPERATIONS

```bash
# Create new admin
docker-compose exec app node scripts/createAdmin.js

# Reset admin password (connect to MongoDB first)
docker exec -it telkom_mongodb mongosh telkom_cup_transparency
db.admins.updateOne(
  {username: "admin"},
  {$set: {password: "$2a$10$..."}}  # Hash the password first!
)
```

## ⚡ EMERGENCY COMMANDS

```bash
# Everything is down!
bash debug.sh  # Check what's wrong first!

# MongoDB won't start!
bash fix-mongodb.sh

# App won't start!
docker logs --tail 100 telkom_app
docker-compose restart app

# Port conflict!
netstat -tulpn | grep 8766
kill -9 <PID>

# Out of disk space!
docker system prune -a
docker volume prune

# Start from scratch!
cd /opt/telkom-cup
docker-compose down -v
docker system prune -af
bash deploy.sh
```

## 🎨 DEVELOPER MODE

```bash
# Watch logs while developing
docker-compose logs -f app

# Rebuild without cache
docker-compose build --no-cache app

# Restart after code change
docker-compose restart app

# Live tail monitoring log
tail -f /opt/telkom-cup/logs/monitor.log

# Check what changed
git status
git diff
```

## 📱 MONITORING

```bash
# Manual health check
bash monitor.sh

# View monitoring history
tail -50 /opt/telkom-cup/logs/monitor.log

# Watch monitoring (live)
watch -n 5 'bash monitor.sh'

# Setup cron monitoring
bash setup-monitoring.sh
```

## 🔗 QUICK ALIASES (Add to ~/.bashrc)

```bash
# Add these to your ~/.bashrc for super quick access
alias tc-status='cd /opt/telkom-cup && bash status.sh'
alias tc-debug='cd /opt/telkom-cup && bash debug.sh'
alias tc-logs='cd /opt/telkom-cup && bash view-logs.sh'
alias tc-restart='cd /opt/telkom-cup && docker-compose restart'
alias tc-up='cd /opt/telkom-cup && docker-compose up -d'
alias tc-down='cd /opt/telkom-cup && docker-compose down'
alias tc-fix='cd /opt/telkom-cup && bash fix-mongodb.sh'

# Then just use:
# tc-status
# tc-debug
# tc-logs
# etc...
```

## 💡 PRO TIPS

```bash
# Chain commands with &&
docker-compose down && docker-compose up -d && bash status.sh

# Use watch for live updates
watch -n 2 'docker ps | grep telkom'

# Grep multiple patterns
docker logs telkom_app | grep -i 'error\|warn\|fail'

# Save logs to file
docker-compose logs > logs_$(date +%Y%m%d_%H%M%S).txt

# Run command on remote VPS
ssh root@your-vps "cd /opt/telkom-cup && bash debug.sh"
```

---

## 🎯 MOST USED COMMANDS (TOP 5)

```bash
1. bash debug.sh              # When something is wrong
2. bash status.sh             # Quick check
3. docker-compose logs -f     # Watch what's happening
4. docker-compose restart     # Turn it off and on again
5. bash fix-mongodb.sh        # MongoDB issues
```

---

**Print this and put it next to your monitor!** 📋✨

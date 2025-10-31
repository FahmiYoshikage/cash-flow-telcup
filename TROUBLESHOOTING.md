# 🔧 Troubleshooting Guide - Telkom Cup

## MongoDB Container Unhealthy

### Masalah
```
dependency failed to start: container telkom_mongodb is unhealthy
```

### Solusi

#### 1. Cek Log MongoDB
```bash
docker logs telkom_mongodb
```

#### 2. Stop dan Hapus Container Lama
```bash
cd /opt/telkom-cup
docker-compose down -v
```

#### 3. Hapus Volume Lama (Opsional)
```bash
docker volume rm telkom-cup_mongodb_data
```

#### 4. Deploy Ulang
```bash
bash deploy.sh
```

### Alternatif: Deploy Manual Step by Step

Jika deploy.sh gagal, coba manual:

```bash
cd /opt/telkom-cup

# 1. Stop semua
docker-compose down

# 2. Build ulang
docker-compose build --no-cache

# 3. Start MongoDB dulu
docker-compose up -d mongodb

# 4. Tunggu MongoDB siap (30-60 detik)
sleep 30

# 5. Cek status MongoDB
docker exec telkom_mongodb mongosh --eval "db.adminCommand('ping')"

# 6. Jika sudah OK, start app
docker-compose up -d app

# 7. Cek logs
docker-compose logs -f
```

## Port Already in Use

### Masalah
```
address already in use
```

### Solusi

#### 1. Cek Port yang Terpakai
```bash
netstat -tulpn | grep 8766
```

#### 2. Matikan Service yang Menggunakan Port
```bash
# Cari PID
lsof -i :8766

# Stop service
kill -9 <PID>
```

#### 3. Atau Ubah Port Lain
Edit `docker-compose.yml`:
```yaml
ports:
  - "8767:3000"  # Ubah ke port lain
```

## App Container Restart Terus

### Cek Logs
```bash
docker logs telkom_app
```

### Kemungkinan Masalah:

#### 1. MongoDB Connection Gagal
Pastikan MongoDB sudah running:
```bash
docker ps | grep mongo
```

#### 2. Missing Dependencies
Rebuild:
```bash
docker-compose build --no-cache app
docker-compose up -d app
```

## Tidak Bisa Akses dari Browser

### 1. Cek Container Running
```bash
docker ps
```

### 2. Cek Health Check
```bash
curl http://localhost:8766/health
```

### 3. Cek Nginx Config
```bash
sudo nginx -t
sudo cat /etc/nginx/sites-available/your-config
```

### 4. Reload Nginx
```bash
sudo systemctl reload nginx
```

## Database Error

### Reset Database
```bash
cd /opt/telkom-cup
docker-compose down
docker volume rm telkom-cup_mongodb_data
docker-compose up -d
```

## Permission Denied

### Masalah
```
permission denied
```

### Solusi
```bash
sudo chown -R 1001:1001 /opt/telkom-cup
```

## Perintah Berguna

### Lihat Semua Container
```bash
docker ps -a
```

### Lihat Logs Real-time
```bash
cd /opt/telkom-cup
docker-compose logs -f
```

### Restart Service
```bash
cd /opt/telkom-cup
docker-compose restart
```

### Masuk ke Container
```bash
# MongoDB
docker exec -it telkom_mongodb mongosh

# App
docker exec -it telkom_app sh
```

### Hapus Semua dan Mulai Fresh
```bash
cd /opt/telkom-cup
docker-compose down -v
docker system prune -a
bash deploy.sh
```

## Hubungi Support

Jika masalah masih berlanjut, kumpulkan informasi berikut:

```bash
# System Info
uname -a
docker --version
docker-compose --version

# Container Status
docker ps -a

# Logs
docker-compose logs > logs.txt

# Network
netstat -tulpn
```

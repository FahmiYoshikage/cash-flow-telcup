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

## 🔧 Manual Fix

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

## 📚 Troubleshooting

Lihat file [TROUBLESHOOTING.md](TROUBLESHOOTING.md) untuk panduan lengkap.

## 🛠️ Useful Commands

```bash
# Lihat logs
docker-compose logs -f

# Restart
docker-compose restart

# Stop
docker-compose down

# Fresh start
docker-compose down -v
docker-compose up -d
```


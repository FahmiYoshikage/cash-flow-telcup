#!/bin/bash
# Quick Fix untuk MongoDB Unhealthy Issue

set -e

echo "🔧 Fixing MongoDB Issue..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

cd /opt/telkom-cup

echo -e "${YELLOW}1. Stopping containers...${NC}"
docker-compose down

echo -e "${YELLOW}2. Removing old MongoDB data (if corrupted)...${NC}"
# Uncomment jika ingin hapus data lama
# docker volume rm telkom-cup_mongodb_data 2>/dev/null || true

echo -e "${YELLOW}3. Starting MongoDB first...${NC}"
docker-compose up -d mongodb

echo -e "${YELLOW}4. Waiting for MongoDB to be ready (30 seconds)...${NC}"
sleep 10

# Check MongoDB health
for i in {1..10}; do
    echo "Checking MongoDB... attempt $i/10"
    if docker exec telkom_mongodb mongosh --quiet --eval "db.adminCommand('ping').ok" &>/dev/null; then
        echo -e "${GREEN}✅ MongoDB is healthy!${NC}"
        break
    fi
    sleep 3
done

echo -e "${YELLOW}5. Starting App container...${NC}"
docker-compose up -d app

echo -e "${YELLOW}6. Waiting for App to start...${NC}"
sleep 10

echo ""
echo -e "${GREEN}✅ Containers Status:${NC}"
docker ps

echo ""
echo -e "${GREEN}🧪 Testing health endpoint...${NC}"
sleep 5
curl -s http://localhost:8766/health || echo -e "${RED}App not ready yet, wait a bit more${NC}"

echo ""
echo -e "${GREEN}📊 View logs with:${NC}"
echo "   docker-compose logs -f"

echo ""
echo -e "${GREEN}✅ Done!${NC}"

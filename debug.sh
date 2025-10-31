#!/bin/bash
# ============================================
# DEBUG TOOL - TELKOM CUP
# Untuk troubleshooting masalah dengan mudah
# ============================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

clear
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     🔍 TELKOM CUP DEBUG TOOL 🔍       ║${NC}"
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo ""

# Change to project directory
cd /opt/telkom-cup 2>/dev/null || cd ~/telkom-cup-transparency 2>/dev/null || echo "Warning: Not in project directory"

# Function to print section header
print_header() {
    echo ""
    echo -e "${MAGENTA}═══════════════════════════════════════${NC}"
    echo -e "${MAGENTA}  $1${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════${NC}"
}

# Function to check status
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ OK${NC}"
    else
        echo -e "${RED}❌ FAILED${NC}"
    fi
}

# 1. SYSTEM INFO
print_header "1. 💻 SYSTEM INFO"
echo -e "${BLUE}OS:${NC} $(uname -s)"
echo -e "${BLUE}Kernel:${NC} $(uname -r)"
echo -e "${BLUE}Docker Version:${NC} $(docker --version 2>/dev/null || echo 'Not installed')"
echo -e "${BLUE}Docker Compose:${NC} $(docker-compose --version 2>/dev/null || echo 'Not installed')"
echo -e "${BLUE}Disk Usage:${NC}"
df -h / | tail -1 | awk '{print "  Used: "$3" / "$2" ("$5")"}'

# 2. CONTAINER STATUS
print_header "2. 📦 CONTAINER STATUS"
echo ""
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "telkom|NAMES"
echo ""

if docker ps | grep -q "telkom_mongodb"; then
    echo -e "${GREEN}✅ MongoDB: Running${NC}"
else
    echo -e "${RED}❌ MongoDB: Not Running${NC}"
fi

if docker ps | grep -q "telkom_app"; then
    echo -e "${GREEN}✅ App: Running${NC}"
else
    echo -e "${RED}❌ App: Not Running${NC}"
fi

# 3. HEALTH CHECKS
print_header "3. 🏥 HEALTH CHECKS"

# MongoDB Health
echo -ne "${BLUE}MongoDB Connection:${NC} "
if docker exec telkom_mongodb mongosh --quiet --eval "db.adminCommand('ping').ok" &>/dev/null; then
    echo -e "${GREEN}✅ Healthy${NC}"
else
    echo -e "${RED}❌ Unhealthy${NC}"
fi

# App Health
echo -ne "${BLUE}App Health Endpoint:${NC} "
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8766/health 2>/dev/null)
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ HTTP $HTTP_CODE${NC}"
    curl -s http://localhost:8766/health | jq '.' 2>/dev/null || curl -s http://localhost:8766/health
else
    echo -e "${RED}❌ HTTP $HTTP_CODE (or not accessible)${NC}"
fi

# 4. PORT USAGE
print_header "4. 🔌 PORT USAGE"
echo -e "${BLUE}Port 8766 (App):${NC}"
netstat -tulpn 2>/dev/null | grep 8766 || echo "  Not listening"
echo ""
echo -e "${BLUE}Port 27017 (MongoDB):${NC}"
netstat -tulpn 2>/dev/null | grep 27017 || docker exec telkom_mongodb ss -tulpn 2>/dev/null | grep 27017 || echo "  Not exposed externally (normal)"

# 5. RECENT LOGS
print_header "5. 📋 RECENT LOGS (Last 20 lines)"

echo ""
echo -e "${YELLOW}=== MongoDB Logs ===${NC}"
docker logs --tail 20 telkom_mongodb 2>/dev/null || echo "Container not found"

echo ""
echo -e "${YELLOW}=== App Logs ===${NC}"
docker logs --tail 20 telkom_app 2>/dev/null || echo "Container not found"

# 6. ENVIRONMENT CHECK
print_header "6. 🔧 ENVIRONMENT CHECK"

echo -ne "${BLUE}docker-compose.yml:${NC} "
if [ -f "docker-compose.yml" ]; then
    echo -e "${GREEN}✅ Found${NC}"
    echo "  Port mapping: $(grep -A1 'ports:' docker-compose.yml | grep 8766 || echo 'Not found')"
else
    echo -e "${RED}❌ Not found${NC}"
fi

echo -ne "${BLUE}server.js:${NC} "
if [ -f "server.js" ]; then
    echo -e "${GREEN}✅ Found${NC}"
else
    echo -e "${RED}❌ Not found${NC}"
fi

echo -ne "${BLUE}public/index.html:${NC} "
if [ -f "public/index.html" ]; then
    SIZE=$(du -h public/index.html | cut -f1)
    if [ "$SIZE" = "4.0K" ] || [ "$(wc -c < public/index.html)" -lt 500 ]; then
        echo -e "${YELLOW}⚠️  Found but seems placeholder ($SIZE)${NC}"
    else
        echo -e "${GREEN}✅ Found ($SIZE)${NC}"
    fi
else
    echo -e "${RED}❌ Not found${NC}"
fi

echo -ne "${BLUE}public/admin.html:${NC} "
if [ -f "public/admin.html" ]; then
    SIZE=$(du -h public/admin.html | cut -f1)
    if [ "$SIZE" = "4.0K" ] || [ "$(wc -c < public/admin.html)" -lt 500 ]; then
        echo -e "${YELLOW}⚠️  Found but seems placeholder ($SIZE)${NC}"
    else
        echo -e "${GREEN}✅ Found ($SIZE)${NC}"
    fi
else
    echo -e "${RED}❌ Not found${NC}"
fi

# 7. DATABASE CHECK
print_header "7. 💾 DATABASE CHECK"

echo -ne "${BLUE}Database Connection:${NC} "
if docker exec telkom_mongodb mongosh telkom_cup_transparency --quiet --eval "db.getName()" &>/dev/null; then
    echo -e "${GREEN}✅ Connected${NC}"
    
    echo -ne "${BLUE}Collections:${NC} "
    COLLECTIONS=$(docker exec telkom_mongodb mongosh telkom_cup_transparency --quiet --eval "db.getCollectionNames()" 2>/dev/null)
    echo "$COLLECTIONS"
    
    echo -ne "${BLUE}Admin Count:${NC} "
    ADMIN_COUNT=$(docker exec telkom_mongodb mongosh telkom_cup_transparency --quiet --eval "db.admins.countDocuments()" 2>/dev/null)
    echo "$ADMIN_COUNT"
    
    echo -ne "${BLUE}Expenses Count:${NC} "
    EXPENSE_COUNT=$(docker exec telkom_mongodb mongosh telkom_cup_transparency --quiet --eval "db.expenses.countDocuments()" 2>/dev/null)
    echo "$EXPENSE_COUNT"
else
    echo -e "${RED}❌ Cannot connect${NC}"
fi

# 8. NETWORK CHECK
print_header "8. 🌐 NETWORK CHECK"

echo -ne "${BLUE}Docker Network:${NC} "
docker network ls | grep telkom_network && echo -e "${GREEN}✅ Exists${NC}" || echo -e "${RED}❌ Not found${NC}"

echo -ne "${BLUE}Internet Connectivity:${NC} "
if ping -c 1 8.8.8.8 &>/dev/null; then
    echo -e "${GREEN}✅ Online${NC}"
else
    echo -e "${RED}❌ Offline${NC}"
fi

# 9. DISK SPACE
print_header "9. 💿 DISK & RESOURCE USAGE"

echo -e "${BLUE}Docker Disk Usage:${NC}"
docker system df 2>/dev/null || echo "  Cannot check"

echo ""
echo -e "${BLUE}Container Resources:${NC}"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" 2>/dev/null | grep -E "telkom|NAME" || echo "  Cannot check"

# 10. COMMON ISSUES
print_header "10. 🔴 COMMON ISSUES DETECTED"

ISSUES_FOUND=0

# Check if app is not running
if ! docker ps | grep -q "telkom_app"; then
    echo -e "${RED}❌ App container is not running${NC}"
    echo "   Fix: cd /opt/telkom-cup && docker-compose up -d app"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# Check if MongoDB is not running
if ! docker ps | grep -q "telkom_mongodb"; then
    echo -e "${RED}❌ MongoDB container is not running${NC}"
    echo "   Fix: cd /opt/telkom-cup && docker-compose up -d mongodb"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# Check if port 8766 is not accessible
if ! curl -s http://localhost:8766/health &>/dev/null; then
    echo -e "${RED}❌ App is not accessible on port 8766${NC}"
    echo "   Fix: Check logs with: docker logs telkom_app"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# Check if public HTML files are placeholder
if [ -f "public/index.html" ] && [ "$(wc -c < public/index.html)" -lt 500 ]; then
    echo -e "${YELLOW}⚠️  HTML files seem to be placeholders${NC}"
    echo "   Fix: Copy actual HTML files to /opt/telkom-cup/public/"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ No common issues detected!${NC}"
fi

# SUMMARY & RECOMMENDATIONS
print_header "11. 📊 SUMMARY & QUICK ACTIONS"

echo ""
echo -e "${CYAN}Quick Action Commands:${NC}"
echo ""
echo -e "${YELLOW}📋 View live logs:${NC}"
echo "   docker-compose logs -f"
echo ""
echo -e "${YELLOW}🔄 Restart services:${NC}"
echo "   docker-compose restart"
echo ""
echo -e "${YELLOW}🛑 Stop all:${NC}"
echo "   docker-compose down"
echo ""
echo -e "${YELLOW}▶️  Start all:${NC}"
echo "   docker-compose up -d"
echo ""
echo -e "${YELLOW}🔧 Fix MongoDB issues:${NC}"
echo "   bash fix-mongodb.sh"
echo ""
echo -e "${YELLOW}🧪 Test endpoints:${NC}"
echo "   curl http://localhost:8766/health"
echo "   curl http://localhost:8766/api/expenses/summary"
echo ""
echo -e "${YELLOW}💾 Database shell:${NC}"
echo "   docker exec -it telkom_mongodb mongosh telkom_cup_transparency"
echo ""
echo -e "${YELLOW}🐚 App shell:${NC}"
echo "   docker exec -it telkom_app sh"
echo ""

echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Debug scan complete!${NC}"
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo ""

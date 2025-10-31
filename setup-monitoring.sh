#!/bin/bash
# ============================================
# MONITORING & LOGGING SETUP
# Setup comprehensive monitoring
# ============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔧 Setting up monitoring and logging..."

cd /opt/telkom-cup 2>/dev/null || cd ~/telkom-cup-transparency 2>/dev/null

# Create logs directory
mkdir -p logs

# Create logging configuration for Docker Compose
cat > docker-compose.override.yml << 'EOF'
version: '3.8'

services:
  mongodb:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
  
  app:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    volumes:
      - ./logs:/app/logs
EOF

# Create a simple monitoring script
cat > monitor.sh << 'EOF'
#!/bin/bash
# Simple monitoring script - runs every minute

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
LOG_FILE="/opt/telkom-cup/logs/monitor.log"

# Check if containers are running
MONGO_STATUS=$(docker ps | grep telkom_mongodb | wc -l)
APP_STATUS=$(docker ps | grep telkom_app | wc -l)

# Check health endpoint
HEALTH_CHECK=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8766/health 2>/dev/null || echo "000")

# Log status
echo "[$TIMESTAMP] MongoDB: $MONGO_STATUS | App: $APP_STATUS | Health: $HEALTH_CHECK" >> "$LOG_FILE"

# Alert if something is down
if [ "$MONGO_STATUS" -eq 0 ]; then
    echo "[$TIMESTAMP] ❌ ALERT: MongoDB is DOWN!" >> "$LOG_FILE"
    # Auto-restart
    cd /opt/telkom-cup && docker-compose up -d mongodb
fi

if [ "$APP_STATUS" -eq 0 ]; then
    echo "[$TIMESTAMP] ❌ ALERT: App is DOWN!" >> "$LOG_FILE"
    # Auto-restart
    cd /opt/telkom-cup && docker-compose up -d app
fi

if [ "$HEALTH_CHECK" != "200" ]; then
    echo "[$TIMESTAMP] ⚠️  WARNING: Health check failed (HTTP $HEALTH_CHECK)" >> "$LOG_FILE"
fi

# Keep only last 1000 lines
tail -1000 "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
EOF

chmod +x monitor.sh

# Create log viewer
cat > view-logs.sh << 'EOF'
#!/bin/bash
# Interactive log viewer

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║       📋 LOG VIEWER - TELKOM CUP      ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Choose log to view:${NC}"
echo ""
echo "  1) App logs (live)"
echo "  2) MongoDB logs (live)"
echo "  3) Both logs (live)"
echo "  4) App logs (last 100 lines)"
echo "  5) MongoDB logs (last 100 lines)"
echo "  6) Monitor log"
echo "  7) Error logs only"
echo "  0) Exit"
echo ""
read -p "Your choice: " choice

cd /opt/telkom-cup 2>/dev/null || cd ~/telkom-cup-transparency 2>/dev/null

case $choice in
    1)
        echo -e "${YELLOW}📱 Streaming App logs... (Ctrl+C to stop)${NC}"
        docker-compose logs -f app
        ;;
    2)
        echo -e "${YELLOW}🗄️  Streaming MongoDB logs... (Ctrl+C to stop)${NC}"
        docker-compose logs -f mongodb
        ;;
    3)
        echo -e "${YELLOW}📋 Streaming all logs... (Ctrl+C to stop)${NC}"
        docker-compose logs -f
        ;;
    4)
        echo -e "${YELLOW}📱 Last 100 App logs:${NC}"
        docker-compose logs --tail 100 app
        ;;
    5)
        echo -e "${YELLOW}🗄️  Last 100 MongoDB logs:${NC}"
        docker-compose logs --tail 100 mongodb
        ;;
    6)
        echo -e "${YELLOW}📊 Monitor log:${NC}"
        if [ -f "logs/monitor.log" ]; then
            tail -50 logs/monitor.log
        else
            echo "No monitor log found"
        fi
        ;;
    7)
        echo -e "${YELLOW}❌ Error logs:${NC}"
        docker-compose logs | grep -i error | tail -50
        ;;
    0)
        echo "Bye!"
        exit 0
        ;;
    *)
        echo "Invalid choice"
        ;;
esac
EOF

chmod +x view-logs.sh

# Create status dashboard
cat > status.sh << 'EOF'
#!/bin/bash
# Quick status dashboard

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║      📊 STATUS - TELKOM CUP           ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

cd /opt/telkom-cup 2>/dev/null || cd ~/telkom-cup-transparency 2>/dev/null

# Container Status
echo -e "${GREEN}📦 CONTAINERS:${NC}"
docker ps --format "  {{.Names}}: {{.Status}}" | grep telkom
echo ""

# Health Check
echo -e "${GREEN}🏥 HEALTH:${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8766/health 2>/dev/null)
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "  App: ${GREEN}✅ Healthy (HTTP $HTTP_CODE)${NC}"
else
    echo -e "  App: ${RED}❌ Unhealthy (HTTP $HTTP_CODE)${NC}"
fi

if docker exec telkom_mongodb mongosh --quiet --eval "db.adminCommand('ping').ok" &>/dev/null; then
    echo -e "  MongoDB: ${GREEN}✅ Connected${NC}"
else
    echo -e "  MongoDB: ${RED}❌ Disconnected${NC}"
fi
echo ""

# Resource Usage
echo -e "${GREEN}💻 RESOURCES:${NC}"
docker stats --no-stream --format "  {{.Name}}: CPU {{.CPUPerc}} | RAM {{.MemUsage}}" | grep telkom
echo ""

# Database Stats
echo -e "${GREEN}💾 DATABASE:${NC}"
ADMIN_COUNT=$(docker exec telkom_mongodb mongosh telkom_cup_transparency --quiet --eval "db.admins.countDocuments()" 2>/dev/null || echo "?")
EXPENSE_COUNT=$(docker exec telkom_mongodb mongosh telkom_cup_transparency --quiet --eval "db.expenses.countDocuments()" 2>/dev/null || echo "?")
echo "  Admins: $ADMIN_COUNT"
echo "  Expenses: $EXPENSE_COUNT"
echo ""

# URLs
echo -e "${GREEN}🔗 ACCESS:${NC}"
echo "  Public: http://localhost:8766"
echo "  Admin:  http://localhost:8766/admin"
echo ""

# Quick Actions
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo "Quick: ${YELLOW}debug.sh${NC} | ${YELLOW}view-logs.sh${NC} | ${YELLOW}monitor.sh${NC}"
echo -e "${CYAN}═══════════════════════════════════════${NC}"
EOF

chmod +x status.sh

# Setup cron for monitoring (optional)
echo ""
echo -e "${YELLOW}📝 Setup automatic monitoring? (will check every minute)${NC}"
read -p "Add to crontab? (y/n): " setup_cron

if [ "$setup_cron" = "y" ]; then
    CRON_CMD="* * * * * /opt/telkom-cup/monitor.sh"
    (crontab -l 2>/dev/null | grep -v "monitor.sh"; echo "$CRON_CMD") | crontab -
    echo -e "${GREEN}✅ Monitoring added to crontab${NC}"
fi

# Apply changes
docker-compose up -d

echo ""
echo -e "${GREEN}✅ Monitoring setup complete!${NC}"
echo ""
echo -e "${GREEN}Available commands:${NC}"
echo -e "  ${YELLOW}./debug.sh${NC}      - Comprehensive debug tool"
echo -e "  ${YELLOW}./status.sh${NC}     - Quick status dashboard"
echo -e "  ${YELLOW}./view-logs.sh${NC}  - Interactive log viewer"
echo -e "  ${YELLOW}./monitor.sh${NC}    - Manual monitoring check"
echo ""

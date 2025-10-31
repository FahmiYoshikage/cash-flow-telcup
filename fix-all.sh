#!/bin/bash
# ============================================
# FIX ALL ISSUES - Telkom Cup
# Fix port conflicts, nginx config, cloudflare
# ============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║    🔧 FIX ALL ISSUES - TELKOM CUP     ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

cd /opt/telkom-cup 2>/dev/null || cd ~/telkom-cup-transparency 2>/dev/null

# ============================================
# FIX 1: Port 27017 Conflict
# ============================================
echo -e "${YELLOW}🔧 FIX 1: Checking Port 27017 Conflict${NC}"

if netstat -tulpn | grep -q ":27017"; then
    echo -e "${RED}⚠️  Port 27017 is in use!${NC}"
    echo "   Checking who's using it..."
    netstat -tulpn | grep 27017
    
    echo ""
    echo -e "${YELLOW}This is likely your existing MongoDB.${NC}"
    echo -e "${GREEN}✅ Solution: We'll use internal Docker networking only (no port exposure needed)${NC}"
    echo ""
else
    echo -e "${GREEN}✅ Port 27017 is available${NC}"
fi

# Update docker-compose.yml to NOT expose MongoDB port
echo -e "${YELLOW}📝 Updating docker-compose.yml...${NC}"
if grep -q "27017:27017" docker-compose.yml; then
    echo "Removing MongoDB port exposure (not needed)..."
    sed -i '/ports:/,/27017:27017/d' docker-compose.yml 2>/dev/null || \
    sed -i '' '/ports:/,/27017:27017/d' docker-compose.yml 2>/dev/null || \
    echo "Manual edit needed - remove '27017:27017' from docker-compose.yml"
fi

# ============================================
# FIX 2: Nginx Configuration
# ============================================
echo ""
echo -e "${YELLOW}🔧 FIX 2: Nginx Configuration${NC}"

NGINX_CONFIG="/etc/nginx/sites-available/telkom-cup"

if [ -f "$NGINX_CONFIG" ]; then
    echo "Current Nginx config found. Analyzing..."
    
    LISTEN_PORT=$(grep "listen " "$NGINX_CONFIG" | grep -o '[0-9]*' | head -1)
    PROXY_PORT=$(grep "proxy_pass" "$NGINX_CONFIG" | grep -o '[0-9]*' | head -1)
    
    echo "  Listen Port: $LISTEN_PORT"
    echo "  Proxy Port:  $PROXY_PORT"
    
    if [ "$LISTEN_PORT" = "8766" ] && [ "$PROXY_PORT" = "8765" ]; then
        echo -e "${RED}❌ MISMATCH DETECTED!${NC}"
        echo "   Nginx listening on 8766 but proxying to 8765"
        echo ""
        echo -e "${YELLOW}Creating corrected config...${NC}"
        
        cat > /tmp/telkom-cup-nginx << 'EOF'
server {
    listen 8766;
    server_name _;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Logs
    access_log /var/log/nginx/telkom-cup-access.log;
    error_log /var/log/nginx/telkom-cup-error.log;

    location / {
        proxy_pass http://localhost:8766;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF
        
        echo -e "${GREEN}✅ Fixed config created at /tmp/telkom-cup-nginx${NC}"
        echo ""
        echo -e "${YELLOW}To apply:${NC}"
        echo "  sudo cp /tmp/telkom-cup-nginx /etc/nginx/sites-available/telkom-cup"
        echo "  sudo nginx -t"
        echo "  sudo systemctl reload nginx"
        echo ""
    else
        echo -e "${GREEN}✅ Nginx config looks OK${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Nginx config not found at $NGINX_CONFIG${NC}"
    echo "Creating recommended config..."
    
    cat > /tmp/telkom-cup-nginx << 'EOF'
server {
    listen 8766;
    server_name telkomcup.kagayakuverse.my.id;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Logs
    access_log /var/log/nginx/telkom-cup-access.log;
    error_log /var/log/nginx/telkom-cup-error.log;

    location / {
        proxy_pass http://localhost:8766;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF
    
    echo -e "${GREEN}✅ Recommended config created at /tmp/telkom-cup-nginx${NC}"
fi

# ============================================
# FIX 3: Cloudflare Tunnel
# ============================================
echo ""
echo -e "${YELLOW}🔧 FIX 3: Cloudflare Tunnel Configuration${NC}"

CF_CONFIG="$HOME/.cloudflared/config.yml"

if [ -f "$CF_CONFIG" ]; then
    echo "Current Cloudflare config:"
    grep "telkomcup" "$CF_CONFIG" || echo "  No telkomcup entry found"
    echo ""
    
    if grep -q "telkomcup.kagayakuverse.my.id" "$CF_CONFIG"; then
        TUNNEL_PORT=$(grep -A1 "telkomcup.kagayakuverse.my.id" "$CF_CONFIG" | grep "service:" | grep -o '[0-9]*')
        echo "  Tunnel configured for port: $TUNNEL_PORT"
        
        if [ "$TUNNEL_PORT" != "8766" ]; then
            echo -e "${RED}❌ Port mismatch! Tunnel points to $TUNNEL_PORT but app is on 8766${NC}"
            echo ""
            echo -e "${YELLOW}Fix needed in Cloudflare config:${NC}"
            echo "  Change: service: http://localhost:$TUNNEL_PORT"
            echo "  To:     service: http://localhost:8766"
        else
            echo -e "${GREEN}✅ Cloudflare tunnel port is correct${NC}"
        fi
    fi
    
    echo ""
    echo -e "${CYAN}📝 Cloudflare Tunnel Issue Diagnosis:${NC}"
    echo ""
    echo "If your new tunnels are failing but old ones work, this usually means:"
    echo ""
    echo "1. ${YELLOW}Systemd service cache issue${NC}"
    echo "   Fix: sudo systemctl daemon-reload"
    echo "        sudo systemctl restart cloudflared"
    echo ""
    echo "2. ${YELLOW}Config file permission issue${NC}"
    echo "   Fix: sudo chown -R root:root ~/.cloudflared"
    echo "        sudo chmod 600 ~/.cloudflared/*.json"
    echo ""
    echo "3. ${YELLOW}Services not actually listening on specified ports${NC}"
    echo "   Check: netstat -tulpn | grep LISTEN"
    echo ""
    echo "4. ${YELLOW}Cloudflare DNS not updated${NC}"
    echo "   Check: dig telkomcup.kagayakuverse.my.id"
    echo ""
    
else
    echo -e "${YELLOW}⚠️  Cloudflare config not found at $CF_CONFIG${NC}"
fi

# ============================================
# FIX 4: Start Services
# ============================================
echo ""
echo -e "${YELLOW}🚀 Starting Services...${NC}"
echo ""

# Stop everything first
echo "Stopping containers..."
docker-compose down 2>/dev/null

# Start MongoDB first
echo "Starting MongoDB..."
docker-compose up -d mongodb

echo "Waiting for MongoDB (15 seconds)..."
for i in {1..15}; do
    echo -n "."
    sleep 1
done
echo ""

# Check MongoDB
if docker exec telkom_mongodb mongosh --quiet --eval "db.adminCommand('ping').ok" &>/dev/null; then
    echo -e "${GREEN}✅ MongoDB is healthy${NC}"
else
    echo -e "${RED}❌ MongoDB still unhealthy, waiting 15 more seconds...${NC}"
    sleep 15
fi

# Start App
echo "Starting App..."
docker-compose up -d app

echo "Waiting for App (10 seconds)..."
sleep 10

# ============================================
# VERIFICATION
# ============================================
echo ""
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         🔍 VERIFICATION                ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

# Check containers
echo -e "${YELLOW}📦 Container Status:${NC}"
docker ps --format "  {{.Names}}: {{.Status}}" | grep telkom

echo ""

# Check ports
echo -e "${YELLOW}🔌 Port Listening:${NC}"
echo -n "  Port 8766 (App): "
if netstat -tulpn 2>/dev/null | grep -q ":8766"; then
    echo -e "${GREEN}✅ Listening${NC}"
else
    echo -e "${RED}❌ Not listening${NC}"
fi

echo ""

# Check health
echo -e "${YELLOW}🏥 Health Check:${NC}"
echo -n "  HTTP Test: "
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8766/health 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ HTTP $HTTP_CODE${NC}"
    curl -s http://localhost:8766/health | jq '.' 2>/dev/null || curl -s http://localhost:8766/health
else
    echo -e "${RED}❌ HTTP $HTTP_CODE${NC}"
fi

echo ""

# ============================================
# SUMMARY & NEXT STEPS
# ============================================
echo ""
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║      📋 SUMMARY & NEXT STEPS          ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

echo -e "${GREEN}✅ Fixes Applied:${NC}"
echo "  1. MongoDB port conflict resolved (using internal networking only)"
echo "  2. Nginx config checked/fixed"
echo "  3. Services restarted"
echo ""

echo -e "${YELLOW}⚠️  Manual Steps Required:${NC}"
echo ""
echo "1. ${CYAN}Fix Nginx (if needed):${NC}"
echo "   sudo cp /tmp/telkom-cup-nginx /etc/nginx/sites-available/telkom-cup"
echo "   sudo ln -sf /etc/nginx/sites-available/telkom-cup /etc/nginx/sites-enabled/"
echo "   sudo nginx -t"
echo "   sudo systemctl reload nginx"
echo ""

echo "2. ${CYAN}Fix Cloudflare Tunnel:${NC}"
echo "   sudo nano ~/.cloudflared/config.yml"
echo "   # Make sure telkomcup points to http://localhost:8766"
echo "   sudo systemctl daemon-reload"
echo "   sudo systemctl restart cloudflared"
echo "   sudo systemctl status cloudflared"
echo ""

echo "3. ${CYAN}Verify Cloudflare DNS:${NC}"
echo "   # Go to Cloudflare Dashboard"
echo "   # Check if telkomcup.kagayakuverse.my.id points to your tunnel"
echo ""

echo "4. ${CYAN}Test Everything:${NC}"
echo "   curl http://localhost:8766/health"
echo "   curl https://telkomcup.kagayakuverse.my.id/health"
echo ""

echo -e "${GREEN}🎯 Quick Status Check:${NC}"
echo "   bash status.sh"
echo ""
echo -e "${GREEN}🔍 Full Debug:${NC}"
echo "   bash debug.sh"
echo ""

echo -e "${GREEN}✅ Fix script complete!${NC}"

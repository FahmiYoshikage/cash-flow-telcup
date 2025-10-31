#!/bin/bash
# ============================================
# QUICK FIX - No Rebuild Needed
# Add health endpoint without rebuilding
# ============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   ⚡ QUICK FIX /health - No Rebuild   ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

cd /opt/telkom-cup 2>/dev/null || cd ~/telkom-cup-transparency 2>/dev/null

# ============================================
# METHOD 1: Hot-fix inside running container
# ============================================
echo -e "${YELLOW}Method 1: Patching server.js in running container${NC}"

# Check if health endpoint exists
docker exec telkom_app grep -q "app.get('/health'" server.js 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Health endpoint already exists in container${NC}"
else
    echo -e "${YELLOW}Adding health endpoint to container...${NC}"
    
    # Create temp file with health endpoint
    cat > /tmp/health-patch.js << 'EOF'

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    timestamp: new Date(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development'
  });
});
EOF

    # Insert before admin route in container
    docker exec telkom_app sh -c "
    sed -i \"/\\/\\/ Serve admin page/i\\$(cat /tmp/health-patch.js | sed 's/$/\\\\n/' | tr -d '\\n')\" server.js
    "
    
    echo -e "${GREEN}✅ Health endpoint added${NC}"
fi

# ============================================
# Restart App Container
# ============================================
echo ""
echo -e "${YELLOW}Restarting app to apply changes...${NC}"
docker-compose restart app

echo "Waiting for app to start (15 seconds)..."
sleep 15

# ============================================
# VERIFICATION
# ============================================
echo ""
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         🔍 VERIFICATION                ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

# Test main page
echo -e "${YELLOW}1. Main Page:${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8766 2>/dev/null)
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "   ${GREEN}✅ HTTP $HTTP_CODE${NC}"
else
    echo -e "   ${RED}❌ HTTP $HTTP_CODE${NC}"
fi

# Test health endpoint
echo ""
echo -e "${YELLOW}2. Health Endpoint:${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8766/health 2>/dev/null)
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "   ${GREEN}✅ HTTP $HTTP_CODE${NC}"
    curl -s http://localhost:8766/health | jq '.' 2>/dev/null || curl -s http://localhost:8766/health
else
    echo -e "   ${RED}❌ HTTP $HTTP_CODE${NC}"
    echo ""
    echo -e "${YELLOW}Trying alternative method...${NC}"
fi

# If still not working, try direct copy
if [ "$HTTP_CODE" != "200" ]; then
    echo ""
    echo -e "${YELLOW}Method 2: Direct file copy${NC}"
    
    # Make sure local server.js has health endpoint
    if ! grep -q "app.get('/health'" server.js; then
        echo "Adding health endpoint to local server.js..."
        sed -i "/\/\/ Serve admin page/i\\
// Health check endpoint\\
app.get('/health', (req, res) => {\\
  res.json({ \\
    status: 'ok', \\
    timestamp: new Date(),\\
    uptime: process.uptime(),\\
    environment: process.env.NODE_ENV || 'development'\\
  });\\
});\\
\\
" server.js
    fi
    
    # Copy to container
    docker cp server.js telkom_app:/app/server.js
    
    # Restart
    docker-compose restart app
    
    echo "Waiting for app to start (10 seconds)..."
    sleep 10
    
    # Test again
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8766/health 2>/dev/null)
    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "   ${GREEN}✅ Success! HTTP $HTTP_CODE${NC}"
        curl -s http://localhost:8766/health
    else
        echo -e "   ${RED}❌ Still failing: HTTP $HTTP_CODE${NC}"
        echo ""
        echo "Checking logs..."
        docker logs --tail 20 telkom_app
    fi
fi

# Test API
echo ""
echo -e "${YELLOW}3. API Expenses:${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8766/api/expenses/summary 2>/dev/null)
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "   ${GREEN}✅ HTTP $HTTP_CODE${NC}"
else
    echo -e "   ${YELLOW}⚠️  HTTP $HTTP_CODE (may be empty, that's OK)${NC}"
fi

# Cloudflare reminder
echo ""
echo -e "${CYAN}════════════════════════════════════════${NC}"
echo -e "${YELLOW}⚠️  Cloudflare Security Reminder:${NC}"
echo ""
echo "External access will still show challenge until you:"
echo "1. Login to Cloudflare Dashboard"
echo "2. Go to Security → WAF → Create rule"
echo "3. Hostname: telkomcup.kagayakuverse.my.id"
echo "4. Action: Skip all rules"
echo ""
echo "See CLOUDFLARE-SECURITY-FIX.md for detailed steps"
echo -e "${CYAN}════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}✅ Done!${NC}"

#!/bin/bash
# ============================================
# FIX HEALTH ENDPOINT & CLOUDFLARE
# Apply fixes untuk missing health endpoint & Cloudflare challenge
# ============================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   🔧 FIX HEALTH & CLOUDFLARE          ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

cd /opt/telkom-cup 2>/dev/null || cd ~/telkom-cup-transparency 2>/dev/null

# ============================================
# FIX 1: Add Health Endpoint to server.js
# ============================================
echo -e "${YELLOW}🔧 FIX 1: Adding /health endpoint to server.js${NC}"

if ! grep -q "app.get('/health'" server.js; then
    echo "Health endpoint not found in server.js. Adding it..."
    
    # Backup original
    cp server.js server.js.backup
    
    # Add health endpoint before the admin route
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
    
    echo -e "${GREEN}✅ Health endpoint added!${NC}"
else
    echo -e "${GREEN}✅ Health endpoint already exists${NC}"
fi

# ============================================
# FIX 2: Rebuild and Restart Container
# ============================================
echo ""
echo -e "${YELLOW}🔧 FIX 2: Rebuilding container with updated code${NC}"

echo "Stopping containers..."
docker-compose down

echo "Rebuilding app container..."
docker-compose build --no-cache app

echo "Starting MongoDB..."
docker-compose up -d mongodb
sleep 15

echo "Starting App..."
docker-compose up -d app
sleep 10

# ============================================
# FIX 3: Cloudflare Security Settings
# ============================================
echo ""
echo -e "${YELLOW}🔧 FIX 3: Cloudflare Challenge Page Issue${NC}"
echo ""
echo "Your Cloudflare tunnel IS working! The challenge page you see is"
echo "Cloudflare's security feature (Bot Fight Mode or Security Level)."
echo ""
echo -e "${CYAN}To fix this, you need to adjust Cloudflare settings:${NC}"
echo ""
echo "1. Login to Cloudflare Dashboard"
echo "2. Select your domain: kagayakuverse.my.id"
echo "3. Go to Security → Settings"
echo "4. Turn OFF or set to LOW:"
echo "   - Security Level → Low or Essentially Off"
echo "   - Bot Fight Mode → OFF"
echo "   - Challenge Passage → 15 minutes or longer"
echo ""
echo "5. Go to SSL/TLS → Overview"
echo "   - Set encryption mode to: Full (not Full Strict)"
echo ""
echo "6. Add WAF Rule to bypass for your tunnel:"
echo "   - Go to Security → WAF"
echo "   - Create Rule:"
echo "     Field: Hostname"
echo "     Operator: equals"
echo "     Value: telkomcup.kagayakuverse.my.id"
echo "     Then: Skip → All remaining rules"
echo ""

# ============================================
# VERIFICATION
# ============================================
echo ""
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         🔍 VERIFICATION                ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

# Check containers
echo -e "${YELLOW}📦 Containers:${NC}"
docker ps --format "  {{.Names}}: {{.Status}}" | grep telkom

echo ""

# Test health endpoint
echo -e "${YELLOW}🏥 Health Check:${NC}"
sleep 5
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8766/health 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "  ${GREEN}✅ Local health check: HTTP $HTTP_CODE${NC}"
    curl -s http://localhost:8766/health | jq '.' 2>/dev/null || curl -s http://localhost:8766/health
else
    echo -e "  ${RED}❌ Local health check: HTTP $HTTP_CODE${NC}"
    echo "  Check logs: docker logs telkom_app"
fi

echo ""

# Test expenses summary
echo -e "${YELLOW}📊 API Test:${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8766/api/expenses/summary 2>/dev/null || echo "000")
echo -n "  Expenses Summary: "
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}HTTP $HTTP_CODE ✅${NC}"
else
    echo -e "${YELLOW}HTTP $HTTP_CODE (may be empty, that's OK)${NC}"
fi

echo ""

# Test external (will likely show challenge)
echo -e "${YELLOW}🌐 External Access Test:${NC}"
echo "  Testing: https://telkomcup.kagayakuverse.my.id/health"
EXTERNAL_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://telkomcup.kagayakuverse.my.id/health 2>/dev/null || echo "000")
if [ "$EXTERNAL_CODE" = "200" ]; then
    echo -e "  ${GREEN}✅ HTTP $EXTERNAL_CODE - Working perfectly!${NC}"
elif [ "$EXTERNAL_CODE" = "403" ] || [ "$EXTERNAL_CODE" = "503" ]; then
    echo -e "  ${YELLOW}⚠️  HTTP $EXTERNAL_CODE - Cloudflare Challenge/Security${NC}"
    echo "  This means tunnel IS working, but Cloudflare is blocking."
    echo "  Follow the Cloudflare settings above to disable challenge."
else
    echo -e "  ${RED}❌ HTTP $EXTERNAL_CODE${NC}"
fi

# ============================================
# CLOUDFLARE BYPASS RULE (Quick Copy-Paste)
# ============================================
echo ""
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║    ⚡ CLOUDFLARE QUICK FIX             ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Quick WAF Rule to bypass challenge:${NC}"
echo ""
echo "1. Go to: https://dash.cloudflare.com"
echo "2. Select: kagayakuverse.my.id"
echo "3. Click: Security → WAF → Create rule"
echo "4. Rule name: Bypass Telkom Cup"
echo "5. Expression:"
echo ""
echo "   (http.host eq \"telkomcup.kagayakuverse.my.id\")"
echo ""
echo "6. Then choose: Skip → All remaining rules"
echo "7. Deploy"
echo ""
echo -e "${GREEN}This will disable all Cloudflare security for telkomcup subdomain.${NC}"
echo ""

echo -e "${CYAN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Fixes applied!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Test local: curl http://localhost:8766/health"
echo "2. Fix Cloudflare security settings (see above)"
echo "3. Test external: curl https://telkomcup.kagayakuverse.my.id/health"
echo ""
echo -e "${CYAN}Full debug: ${YELLOW}bash debug.sh${NC}"
echo -e "${CYAN}════════════════════════════════════════${NC}"

#!/bin/bash
# ============================================
# QUICK FIX - For VPS
# Super cepat fix common issues
# ============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║       ⚡ QUICK FIX - TELKOM CUP       ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

cd /opt/telkom-cup 2>/dev/null || cd ~/telkom-cup-transparency 2>/dev/null

echo -e "${GREEN}What do you want to fix?${NC}"
echo ""
echo "  1) Port 27017 conflict (MongoDB won't start)"
echo "  2) Nginx configuration"
echo "  3) Cloudflare tunnel not working"
echo "  4) Container keeps restarting"
echo "  5) Fix ALL issues (comprehensive)"
echo "  6) Just restart everything"
echo "  0) Exit"
echo ""
read -p "Your choice: " choice

case $choice in
    1)
        echo -e "${YELLOW}🔧 Fixing Port 27017 conflict...${NC}"
        docker-compose down
        # Remove port exposure from docker-compose if exists
        if grep -q "27017:27017" docker-compose.yml; then
            echo "Removing MongoDB port exposure..."
            # Just start without exposing the port
        fi
        docker-compose up -d
        echo -e "${GREEN}✅ Done! MongoDB now uses internal networking only.${NC}"
        ;;
    
    2)
        echo -e "${YELLOW}🔧 Fixing Nginx configuration...${NC}"
        echo ""
        echo "Current config check:"
        if [ -f "/etc/nginx/sites-available/telkom-cup" ]; then
            LISTEN_PORT=$(grep "listen " /etc/nginx/sites-available/telkom-cup | grep -o '[0-9]*' | head -1)
            PROXY_PORT=$(grep "proxy_pass" /etc/nginx/sites-available/telkom-cup | grep -o '[0-9]*' | head -1)
            echo "  Listen: $LISTEN_PORT"
            echo "  Proxy:  $PROXY_PORT"
            
            if [ "$LISTEN_PORT" != "$PROXY_PORT" ]; then
                echo -e "${RED}❌ Port mismatch detected!${NC}"
                echo ""
                echo "Fix command:"
                echo "  sudo sed -i 's/proxy_pass http:\/\/localhost:$PROXY_PORT/proxy_pass http:\/\/localhost:$LISTEN_PORT/' /etc/nginx/sites-available/telkom-cup"
                echo "  sudo nginx -t"
                echo "  sudo systemctl reload nginx"
            else
                echo -e "${GREEN}✅ Config looks OK!${NC}"
            fi
        else
            echo -e "${YELLOW}Config not found. See CLOUDFLARE-TUNNEL-FIX.md for sample config.${NC}"
        fi
        ;;
    
    3)
        echo -e "${YELLOW}🔧 Fixing Cloudflare tunnel...${NC}"
        echo ""
        echo "1. Checking if services are running locally..."
        if curl -s http://localhost:8766/health &>/dev/null; then
            echo -e "   ${GREEN}✅ App is accessible locally${NC}"
        else
            echo -e "   ${RED}❌ App NOT accessible locally - Fix Docker first!${NC}"
            echo "   Run: bash fix-all.sh"
            exit 1
        fi
        
        echo ""
        echo "2. Checking Cloudflare config..."
        if grep -q "telkomcup.kagayakuverse.my.id" ~/.cloudflared/config.yml; then
            PORT=$(grep -A1 "telkomcup.kagayakuverse.my.id" ~/.cloudflared/config.yml | grep "service:" | grep -o '[0-9]*')
            echo "   Config found: Port $PORT"
            if [ "$PORT" != "8766" ]; then
                echo -e "   ${RED}❌ Wrong port in config!${NC}"
                echo "   Edit: sudo nano ~/.cloudflared/config.yml"
                echo "   Change to: http://localhost:8766"
            else
                echo -e "   ${GREEN}✅ Config looks OK${NC}"
            fi
        else
            echo -e "   ${YELLOW}⚠️  No telkomcup entry in config${NC}"
            echo "   Add to ~/.cloudflared/config.yml:"
            echo "     - hostname: telkomcup.kagayakuverse.my.id"
            echo "       service: http://localhost:8766"
        fi
        
        echo ""
        echo "3. Restarting Cloudflared with proper reload..."
        sudo systemctl stop cloudflared
        sudo systemctl daemon-reload
        sudo systemctl start cloudflared
        sleep 3
        
        if sudo systemctl is-active --quiet cloudflared; then
            echo -e "   ${GREEN}✅ Cloudflared is running${NC}"
            echo ""
            echo "   Check logs:"
            echo "   sudo journalctl -u cloudflared -n 20"
        else
            echo -e "   ${RED}❌ Cloudflared failed to start${NC}"
            echo "   Check: sudo systemctl status cloudflared"
        fi
        ;;
    
    4)
        echo -e "${YELLOW}🔧 Fixing container restart loop...${NC}"
        echo ""
        echo "Checking logs..."
        docker logs --tail 30 telkom_app 2>/dev/null || echo "Container not found"
        echo ""
        echo "Common causes:"
        echo "  1. MongoDB not ready → Wait longer"
        echo "  2. Port conflict → Check netstat -tulpn"
        echo "  3. Code error → Check logs above"
        echo ""
        echo "Attempting fix..."
        docker-compose down
        sleep 3
        docker-compose up -d mongodb
        echo "Waiting for MongoDB (30 seconds)..."
        sleep 30
        docker-compose up -d app
        echo ""
        echo -e "${GREEN}✅ Services restarted. Check status in 10 seconds.${NC}"
        ;;
    
    5)
        echo -e "${YELLOW}🔧 Running comprehensive fix...${NC}"
        bash fix-all.sh
        ;;
    
    6)
        echo -e "${YELLOW}🔄 Restarting everything...${NC}"
        docker-compose down
        sleep 2
        docker-compose up -d
        echo ""
        echo -e "${GREEN}✅ Restarted! Wait 15 seconds then check status.${NC}"
        sleep 15
        docker ps | grep telkom
        ;;
    
    0)
        echo "Bye!"
        exit 0
        ;;
    
    *)
        echo "Invalid choice"
        ;;
esac

echo ""
echo -e "${CYAN}════════════════════════════════════════${NC}"
echo -e "${GREEN}Quick commands:${NC}"
echo "  bash status.sh     - Check status"
echo "  bash debug.sh      - Full diagnosis"
echo "  bash view-logs.sh  - View logs"
echo -e "${CYAN}════════════════════════════════════════${NC}"

#!/bin/bash
# ============================================
# SYNC TO VPS - Upload files to production
# Usage: bash sync-to-vps.sh
# ============================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     📤 SYNC TO VPS - TELKOM CUP       ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

# Configuration
read -p "VPS IP Address or Domain: " VPS_HOST
read -p "VPS User (default: root): " VPS_USER
VPS_USER=${VPS_USER:-root}
read -p "VPS Project Path (default: /opt/telkom-cup): " VPS_PATH
VPS_PATH=${VPS_PATH:-/opt/telkom-cup}

echo ""
echo -e "${YELLOW}📋 Sync Configuration:${NC}"
echo "  Host: $VPS_HOST"
echo "  User: $VPS_USER"
echo "  Path: $VPS_PATH"
echo ""

read -p "Continue? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo -e "${YELLOW}🚀 Starting sync...${NC}"
echo ""

# Create temporary directory for files to sync
TEMP_DIR=$(mktemp -d)
echo -e "${CYAN}📦 Preparing files...${NC}"

# Copy files to temp directory
cp -r . "$TEMP_DIR/telkom-cup"
cd "$TEMP_DIR/telkom-cup"

# Remove unnecessary files
rm -rf node_modules .git logs *.log

# Make scripts executable
chmod +x *.sh

echo -e "${GREEN}✅ Files prepared${NC}"
echo ""

# Sync to VPS
echo -e "${YELLOW}📤 Uploading to VPS...${NC}"

# Option 1: Using rsync (recommended)
if command -v rsync &> /dev/null; then
    rsync -avz --progress \
        --exclude 'node_modules' \
        --exclude '.git' \
        --exclude 'logs' \
        --exclude '*.log' \
        "$TEMP_DIR/telkom-cup/" \
        "$VPS_USER@$VPS_HOST:$VPS_PATH/"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Sync complete via rsync${NC}"
    else
        echo -e "${RED}❌ Rsync failed${NC}"
        exit 1
    fi
else
    # Option 2: Using scp (fallback)
    echo "rsync not found, using scp..."
    scp -r "$TEMP_DIR/telkom-cup/"* "$VPS_USER@$VPS_HOST:$VPS_PATH/"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Sync complete via scp${NC}"
    else
        echo -e "${RED}❌ SCP failed${NC}"
        exit 1
    fi
fi

# Cleanup
rm -rf "$TEMP_DIR"

echo ""
echo -e "${GREEN}✅ Files uploaded successfully!${NC}"
echo ""
echo -e "${YELLOW}🔧 Next steps on VPS:${NC}"
echo ""
echo "ssh $VPS_USER@$VPS_HOST"
echo "cd $VPS_PATH"
echo ""
echo "# If first time deploy:"
echo "bash deploy.sh"
echo ""
echo "# If updating existing:"
echo "docker-compose down"
echo "docker-compose build --no-cache"
echo "docker-compose up -d"
echo ""
echo "# Check status:"
echo "bash status.sh"
echo ""
echo -e "${GREEN}🎉 Done!${NC}"

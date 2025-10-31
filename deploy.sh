#!/bin/bash
# ============================================
# SCRIPT AUTO DEPLOY - TELKOM CUP
# Save as: deploy.sh
# Run: chmod +x deploy.sh && ./deploy.sh
# ============================================

set -e

echo "🚀 Starting Telkom Cup Deployment..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}❌ Please run as root: sudo ./deploy.sh${NC}"
    exit 1
fi

# Install Docker if not exists
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}📦 Installing Docker...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    systemctl enable docker
    systemctl start docker
fi

# Install Docker Compose if not exists
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}📦 Installing Docker Compose...${NC}"
    curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Create project directory
PROJECT_DIR="/opt/telkom-cup"
echo -e "${YELLOW}📁 Creating project directory at ${PROJECT_DIR}${NC}"
mkdir -p ${PROJECT_DIR}/{config,models,middleware,routes,scripts,public}
cd ${PROJECT_DIR}

# Create package.json
echo -e "${YELLOW}📝 Creating package.json...${NC}"
cat > package.json << 'EOF'
{
  "name": "telkom-cup-transparency",
  "version": "1.0.0",
  "description": "Transparansi Dana Telkom Cup TRI",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "create-admin": "node scripts/createAdmin.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mongoose": "^8.0.0",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.0.2",
    "dotenv": "^16.3.1",
    "cookie-parser": "^1.4.6",
    "cors": "^2.8.5"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF

# Create Dockerfile
echo -e "${YELLOW}📝 Creating Dockerfile...${NC}"
cat > Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY . .

RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

USER nodejs

EXPOSE 3000

CMD ["node", "server.js"]
EOF

# Create .dockerignore
cat > .dockerignore << 'EOF'
node_modules
npm-debug.log
.env
.git
.gitignore
README.md
logs
*.log
EOF

# Create docker-compose.yml
echo -e "${YELLOW}📝 Creating docker-compose.yml...${NC}"
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  mongodb:
    image: mongo:7.0
    container_name: telkom_mongodb
    restart: unless-stopped
    environment:
      MONGO_INITDB_DATABASE: telkom_cup_transparency
    volumes:
      - mongodb_data:/data/db
    networks:
      - telkom_network
    healthcheck:
      test: ["CMD", "mongosh", "--quiet", "--eval", "db.adminCommand('ping').ok"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 40s

  app:
    build: .
    container_name: telkom_app
    restart: unless-stopped
    environment:
      - PORT=3000
      - MONGODB_URI=mongodb://mongodb:27017/telkom_cup_transparency
      - JWT_SECRET=telkom_cup_super_secret_key_change_in_production_2024
      - NODE_ENV=production
    ports:
      - "8766:3000"
    depends_on:
      mongodb:
        condition: service_healthy
    networks:
      - telkom_network
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000/api/expenses/summary"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  mongodb_data:
    driver: local

networks:
  telkom_network:
    driver: bridge
EOF

# Create server.js
echo -e "${YELLOW}📝 Creating server.js...${NC}"
cat > server.js << 'EOF'
require('dotenv').config();
const express = require('express');
const cookieParser = require('cookie-parser');
const cors = require('cors');
const connectDB = require('./config/db');

const app = express();
const PORT = process.env.PORT || 3000;

// Connect to MongoDB
connectDB();

// Middleware
app.use(cors({
  origin: true,
  credentials: true
}));
app.use(express.json());
app.use(cookieParser());
app.use(express.static('public'));

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/expenses', require('./routes/expense'));

// Serve admin page
app.get('/admin', (req, res) => {
  res.sendFile(__dirname + '/public/admin.html');
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date() });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📊 Public: http://localhost:${PORT}`);
  console.log(`🔐 Admin: http://localhost:${PORT}/admin`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  process.exit(0);
});
EOF

# Create config/db.js
cat > config/db.js << 'EOF'
const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    const options = {
      maxPoolSize: 10,
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
    };
    
    await mongoose.connect(process.env.MONGODB_URI, options);
    console.log('✅ MongoDB Connected');
  } catch (error) {
    console.error('❌ MongoDB Connection Error:', error.message);
    setTimeout(connectDB, 5000); // Retry after 5 seconds
  }
};

mongoose.connection.on('disconnected', () => {
  console.log('⚠️  MongoDB disconnected. Attempting to reconnect...');
});

mongoose.connection.on('error', (err) => {
  console.error('❌ MongoDB error:', err);
});

module.exports = connectDB;
EOF

# Create models/Admin.js
cat > models/Admin.js << 'EOF'
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const adminSchema = new mongoose.Schema({
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  password: {
    type: String,
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

adminSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

adminSchema.methods.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

module.exports = mongoose.model('Admin', adminSchema);
EOF

# Create models/Expense.js
cat > models/Expense.js << 'EOF'
const mongoose = require('mongoose');

const expenseSchema = new mongoose.Schema({
  date: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true,
    trim: true
  },
  category: {
    type: String,
    required: true,
    enum: ['Transport', 'Konsumsi', 'Perlengkapan', 'Administrasi', 'Lainnya']
  },
  amount: {
    type: Number,
    required: true,
    min: 0
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Expense', expenseSchema);
EOF

# Create middleware/auth.js
cat > middleware/auth.js << 'EOF'
const jwt = require('jsonwebtoken');

const auth = (req, res, next) => {
  try {
    const token = req.cookies.token || req.headers.authorization?.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({ message: 'Authentication required' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.userId = decoded.userId;
    next();
  } catch (error) {
    res.status(401).json({ message: 'Invalid or expired token' });
  }
};

module.exports = auth;
EOF

# Create routes/auth.js
cat > routes/auth.js << 'EOF'
const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const Admin = require('../models/Admin');

router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    const admin = await Admin.findOne({ username });
    if (!admin) {
      return res.status(401).json({ message: 'Username atau password salah' });
    }

    const isMatch = await admin.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Username atau password salah' });
    }

    const token = jwt.sign(
      { userId: admin._id },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.cookie('token', token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      maxAge: 24 * 60 * 60 * 1000
    });

    res.json({ message: 'Login berhasil', token });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

router.post('/logout', (req, res) => {
  res.clearCookie('token');
  res.json({ message: 'Logout berhasil' });
});

router.get('/check', async (req, res) => {
  try {
    const token = req.cookies.token;
    if (!token) {
      return res.status(401).json({ authenticated: false });
    }

    jwt.verify(token, process.env.JWT_SECRET);
    res.json({ authenticated: true });
  } catch (error) {
    res.status(401).json({ authenticated: false });
  }
});

module.exports = router;
EOF

# Create routes/expense.js
cat > routes/expense.js << 'EOF'
const express = require('express');
const router = express.Router();
const Expense = require('../models/Expense');
const auth = require('../middleware/auth');

router.get('/', async (req, res) => {
  try {
    const expenses = await Expense.find().sort({ createdAt: -1 });
    res.json(expenses);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

router.post('/', auth, async (req, res) => {
  try {
    const { date, description, category, amount } = req.body;
    
    const expense = new Expense({
      date,
      description,
      category,
      amount
    });

    await expense.save();
    res.status(201).json(expense);
  } catch (error) {
    res.status(400).json({ message: 'Error adding expense', error: error.message });
  }
});

router.delete('/:id', auth, async (req, res) => {
  try {
    const expense = await Expense.findByIdAndDelete(req.params.id);
    if (!expense) {
      return res.status(404).json({ message: 'Expense not found' });
    }
    res.json({ message: 'Expense deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

router.get('/summary', async (req, res) => {
  try {
    const expenses = await Expense.find();
    const totalSpent = expenses.reduce((sum, exp) => sum + exp.amount, 0);
    const totalBudget = 150000;
    const remaining = totalBudget - totalSpent;

    res.json({
      totalBudget,
      totalSpent,
      remaining
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;
EOF

# Create scripts/createAdmin.js
cat > scripts/createAdmin.js << 'EOF'
require('dotenv').config();
const mongoose = require('mongoose');
const Admin = require('../models/Admin');

const createAdmin = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    
    // Check if admin exists
    const existingAdmin = await Admin.findOne({ username: 'admin' });
    if (existingAdmin) {
      console.log('⚠️  Admin already exists!');
      process.exit(0);
    }
    
    const admin = new Admin({
      username: 'admin',
      password: 'telkomcup2024'
    });
    
    await admin.save();
    console.log('✅ Admin created successfully');
    console.log('Username: admin');
    console.log('Password: telkomcup2024');
    console.log('⚠️  IMPORTANT: Change password after first login!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
};

createAdmin();
EOF

echo -e "${YELLOW}📝 Creating frontend files...${NC}"

# Download frontend files from the artifacts
# For now, create placeholder notice
cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Setup Required</title>
</head>
<body>
    <h1>⚠️ Setup Required</h1>
    <p>Please copy index.html and admin.html from the artifacts to /opt/telkom-cup/public/</p>
    <p>Then restart: cd /opt/telkom-cup && docker-compose restart app</p>
</body>
</html>
EOF

cp public/index.html public/admin.html

# Create .env
cat > .env << 'EOF'
PORT=3000
MONGODB_URI=mongodb://mongodb:27017/telkom_cup_transparency
JWT_SECRET=telkom_cup_super_secret_key_change_in_production_2024
NODE_ENV=production
EOF

echo -e "${GREEN}✅ All files created!${NC}"
echo ""
echo -e "${YELLOW}📦 Building and starting containers...${NC}"

# Build and start
docker-compose down 2>/dev/null || true
docker-compose build --no-cache
docker-compose up -d

echo ""
echo -e "${YELLOW}⏳ Waiting for services to be ready...${NC}"
sleep 15

# Check if MongoDB is ready
echo -e "${YELLOW}🔍 Checking MongoDB status...${NC}"
for i in {1..10}; do
    if docker exec telkom_mongodb mongosh --quiet --eval "db.adminCommand('ping').ok" &>/dev/null; then
        echo -e "${GREEN}✅ MongoDB is ready!${NC}"
        break
    fi
    echo "Waiting for MongoDB... attempt $i/10"
    sleep 3
done

# Create admin
echo -e "${YELLOW}👤 Creating admin user...${NC}"
docker-compose exec -T app node scripts/createAdmin.js

echo ""
echo -e "${GREEN}✅ DEPLOYMENT COMPLETE!${NC}"
echo ""
echo -e "${GREEN}📊 Application is running on:${NC}"
echo -e "   Public: http://localhost:8766"
echo -e "   Admin:  http://localhost:8766/admin"
echo ""
echo -e "${GREEN}🔐 Admin Credentials:${NC}"
echo -e "   Username: admin"
echo -e "   Password: telkomcup2024"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT: Change admin password after first login!${NC}"
echo ""
echo -e "${GREEN}🔧 Useful Commands:${NC}"
echo -e "   View logs:       cd /opt/telkom-cup && docker-compose logs -f"
echo -e "   Restart:         cd /opt/telkom-cup && docker-compose restart"
echo -e "   Stop:            cd /opt/telkom-cup && docker-compose down"
echo -e "   Start:           cd /opt/telkom-cup && docker-compose up -d"
echo ""
echo -e "${GREEN}📝 Next Steps:${NC}"
echo "1. Copy index.html and admin.html from artifacts to /opt/telkom-cup/public/"
echo "2. Restart app: cd /opt/telkom-cup && docker-compose restart app"
echo "3. Update Cloudflare config to point to localhost:8766"
echo "4. Test: curl http://localhost:8766/health"
echo ""
echo -e "${GREEN}🎉 Happy deploying!${NC}"

require('dotenv').config();
const mongoose = require('mongoose');
const Admin = require('./models/Admin');

const createAdmin = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    
    const admin = new Admin({
      username: 'admin',
      password: 'telkomcup2024' // Ganti dengan password yang aman!
    });
    
    await admin.save();
    console.log('✅ Admin created successfully');
    console.log('Username: admin');
    console.log('Password: telkomcup2024');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
};

createAdmin();

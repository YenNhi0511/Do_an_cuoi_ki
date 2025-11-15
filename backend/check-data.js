// check-data.js - Script kiểm tra dữ liệu trong MongoDB
import mongoose from 'mongoose';
import dotenv from 'dotenv';

dotenv.config();

async function checkData() {
  try {
    console.log('🔌 Đang kết nối MongoDB...');
    await mongoose.connect(process.env.MONGO_URI);
    console.log('✅ Kết nối thành công!\n');

    // Lấy tất cả collections
    const collections = await mongoose.connection.db.listCollections().toArray();
    console.log('📦 Collections trong database QLLamViec:');
    collections.forEach(col => console.log(`   - ${col.name}`));
    
    // Đếm documents trong mỗi collection
    console.log('\n📊 Số lượng documents:');
    for (const col of collections) {
      const count = await mongoose.connection.db.collection(col.name).countDocuments();
      console.log(`   ${col.name}: ${count} documents`);
    }
    
    // Lấy users
    const users = await mongoose.connection.db.collection('users').find().toArray();
    console.log('\n👥 Users:');
    users.forEach(user => {
      console.log(`   - ${user.name} (${user.email}) - Role: ${user.role}`);
    });
    
    // Lấy tasks
    const tasks = await mongoose.connection.db.collection('tasks').find().toArray();
    console.log('\n📋 Tasks:');
    tasks.forEach(task => {
      console.log(`   - ${task.title}`);
      console.log(`     Priority: ${task.priority}, Status: ${task.status}`);
      console.log(`     StartTime: ${task.startTime || 'N/A'}, EndTime: ${task.endTime || 'N/A'}`);
      console.log(`     Color: ${task.color}, IsAllDay: ${task.isAllDay}`);
    });
    
    await mongoose.connection.close();
    console.log('\n✅ Hoàn tất kiểm tra!');
    
  } catch (error) {
    console.error('❌ Lỗi:', error.message);
    process.exit(1);
  }
}

checkData();

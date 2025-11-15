// test-api.js - Script test API
// Node 18+ có native fetch, không cần import

const BASE_URL = 'http://localhost:5000/api';
let authToken = '';

// Test 1: Đăng ký user mới
async function testRegister() {
  console.log('\n🧪 TEST 1: Đăng ký user mới');
  try {
    const response = await fetch(`${BASE_URL}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name: 'Test User',
        email: `test${Date.now()}@example.com`,
        password: 'test123456'
      })
    });
    
    const data = await response.json();
    console.log('📥 Response:', response.status, data);
    
    if (data.token) {
      authToken = data.token;
      console.log('✅ Đăng ký thành công! Token:', authToken.substring(0, 20) + '...');
      return true;
    } else {
      console.log('❌ Đăng ký thất bại:', data.message);
      return false;
    }
  } catch (error) {
    console.error('❌ Lỗi:', error.message);
    return false;
  }
}

// Test 2: Tạo task mới
async function testCreateTask() {
  console.log('\n🧪 TEST 2: Tạo task mới');
  try {
    const response = await fetch(`${BASE_URL}/tasks`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${authToken}`
      },
      body: JSON.stringify({
        title: 'Task test ' + Date.now(),
        description: 'Đây là task test từ script',
        category: 'Test',
        priority: 'Cao',
        deadline: new Date(Date.now() + 86400000).toISOString(),
        status: 'not started',
        startTime: '09:00',
        endTime: '10:00',
        isAllDay: false,
        color: '#FF5733'
      })
    });
    
    const data = await response.json();
    console.log('📥 Response:', response.status);
    console.log('📝 Task created:', {
      id: data._id,
      title: data.title,
      priority: data.priority,
      startTime: data.startTime,
      endTime: data.endTime
    });
    
    if (response.status === 201) {
      console.log('✅ Tạo task thành công!');
      return true;
    } else {
      console.log('❌ Tạo task thất bại:', data.message);
      return false;
    }
  } catch (error) {
    console.error('❌ Lỗi:', error.message);
    return false;
  }
}

// Test 3: Lấy danh sách tasks
async function testGetTasks() {
  console.log('\n🧪 TEST 3: Lấy danh sách tasks');
  try {
    const response = await fetch(`${BASE_URL}/tasks`, {
      headers: {
        'Authorization': `Bearer ${authToken}`
      }
    });
    
    const data = await response.json();
    console.log('📥 Response:', response.status);
    console.log('📋 Số lượng tasks:', data.length);
    
    if (data.length > 0) {
      console.log('📝 Task đầu tiên:', {
        title: data[0].title,
        priority: data[0].priority,
        status: data[0].status
      });
      console.log('✅ Lấy danh sách thành công!');
      return true;
    } else {
      console.log('⚠️ Chưa có task nào');
      return false;
    }
  } catch (error) {
    console.error('❌ Lỗi:', error.message);
    return false;
  }
}

// Chạy tất cả tests
async function runTests() {
  console.log('🚀 BẮT ĐẦU TEST API');
  console.log('=' .repeat(50));
  
  const registerOk = await testRegister();
  if (!registerOk) {
    console.log('\n❌ DỪNG: Đăng ký thất bại');
    return;
  }
  
  await new Promise(resolve => setTimeout(resolve, 1000)); // Đợi 1s
  
  const createOk = await testCreateTask();
  if (!createOk) {
    console.log('\n❌ CẢNH BÁO: Không tạo được task');
  }
  
  await new Promise(resolve => setTimeout(resolve, 1000));
  
  const getOk = await testGetTasks();
  
  console.log('\n' + '='.repeat(50));
  console.log('🏁 KẾT QUẢ TỔNG QUAN:');
  console.log(`   Đăng ký: ${registerOk ? '✅' : '❌'}`);
  console.log(`   Tạo task: ${createOk ? '✅' : '❌'}`);
  console.log(`   Lấy tasks: ${getOk ? '✅' : '❌'}`);
  console.log('=' .repeat(50));
}

runTests();

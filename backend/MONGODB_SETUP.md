# 🍃 HƯỚNG DẪN CÀI ĐẶT VÀ CẤU HÌNH MONGODB

## Có 2 cách sử dụng MongoDB:

1. **MongoDB Local** - Cài trên máy tính
2. **MongoDB Atlas** - Cloud (miễn phí)

---

## 🖥️ CÁCH 1: MongoDB Local

### Windows:

#### Bước 1: Download MongoDB

- Truy cập: https://www.mongodb.com/try/download/community
- Chọn phiên bản Windows
- Download và cài đặt (Next → Next → Finish)

#### Bước 2: Thêm vào PATH (nếu chưa tự động)

```cmd
setx PATH "%PATH%;C:\Program Files\MongoDB\Server\7.0\bin"
```

#### Bước 3: Tạo thư mục data

```cmd
mkdir C:\data\db
```

#### Bước 4: Khởi động MongoDB

```cmd
mongod
```

**Hoặc chạy như service (khuyến nghị):**

```cmd
net start MongoDB
```

#### Bước 5: Kiểm tra

Mở terminal mới:

```cmd
mongosh
```

Nếu thấy MongoDB shell → Thành công!

---

### macOS:

#### Bước 1: Cài đặt với Homebrew

```bash
brew tap mongodb/brew
brew install mongodb-community
```

#### Bước 2: Khởi động MongoDB

```bash
brew services start mongodb-community
```

#### Bước 3: Kiểm tra

```bash
mongosh
```

---

### Linux (Ubuntu/Debian):

#### Bước 1: Import GPG key

```bash
curl -fsSL https://pgp.mongodb.com/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
```

#### Bước 2: Thêm repository

```bash
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
```

#### Bước 3: Cài đặt

```bash
sudo apt-get update
sudo apt-get install -y mongodb-org
```

#### Bước 4: Khởi động

```bash
sudo systemctl start mongod
sudo systemctl enable mongod
```

#### Bước 5: Kiểm tra

```bash
mongosh
```

---

## ☁️ CÁCH 2: MongoDB Atlas (Cloud - Khuyến nghị cho người mới)

### Bước 1: Tạo tài khoản

- Truy cập: https://www.mongodb.com/cloud/atlas/register
- Đăng ký miễn phí (có thể dùng Google)

### Bước 2: Tạo Cluster

1. Chọn "Build a Database"
2. Chọn **FREE** (Shared)
3. Chọn Provider: **AWS** hoặc **Google Cloud**
4. Chọn Region gần bạn nhất (vd: Singapore)
5. Cluster Name: `Cluster0` (hoặc tùy thích)
6. Nhấn **Create**

### Bước 3: Cấu hình Network Access

1. Vào **Network Access** (menu bên trái)
2. Nhấn **Add IP Address**
3. Chọn **Allow Access from Anywhere** (0.0.0.0/0)
4. Nhấn **Confirm**

⚠️ **Lưu ý:** Trong production nên giới hạn IP cụ thể

### Bước 4: Tạo Database User

1. Vào **Database Access**
2. Nhấn **Add New Database User**
3. Chọn **Password** authentication
4. Username: `admin` (hoặc tùy thích)
5. Password: Tạo password mạnh (nhớ lưu lại!)
6. Database User Privileges: **Read and write to any database**
7. Nhấn **Add User**

### Bước 5: Lấy Connection String

1. Quay lại **Database** → **Connect**
2. Chọn **Drivers**
3. Copy connection string:

```
mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
```

### Bước 6: Cấu hình trong Backend

Mở file `.env` và thay thế:

```env
MONGO_URI=mongodb+srv://admin:your_password@cluster0.xxxxx.mongodb.net/task_manager_db?retryWrites=true&w=majority
```

**Lưu ý:**

- Thay `<username>` bằng username bạn tạo
- Thay `<password>` bằng password thật
- Thay `cluster0.xxxxx` bằng cluster URL của bạn
- Thêm `/task_manager_db` để chỉ định database name

### Bước 7: Test Connection

```bash
cd backend
npm start
```

Nếu thấy "✅ MongoDB Connected" → Thành công!

---

## 🧪 Kiểm tra MongoDB

### 1. Với MongoDB Local:

```bash
# Kết nối
mongosh

# Show databases
show dbs

# Use database
use task_manager_db

# Show collections
show collections

# Query data
db.users.find()
db.tasks.find()
```

### 2. Với MongoDB Atlas:

Sử dụng **MongoDB Compass** (GUI tool):

1. Download: https://www.mongodb.com/try/download/compass
2. Paste connection string
3. Xem data trực quan

---

## 📊 MongoDB Commands Hữu ích

### Quản lý Database:

```javascript
// Show tất cả databases
show dbs

// Chuyển sang database
use task_manager_db

// Xóa database hiện tại
db.dropDatabase()
```

### Quản lý Collections:

```javascript
// Show collections
show collections

// Đếm documents
db.users.countDocuments()
db.tasks.countDocuments()

// Xem documents
db.users.find().pretty()
db.tasks.find().limit(5)

// Xóa collection
db.tasks.drop()
```

### Query Examples:

```javascript
// Tìm user theo email
db.users.findOne({ email: "test@example.com" });

// Tìm tasks của user
db.tasks.find({ creator: ObjectId("user_id_here") });

// Tìm tasks hoàn thành
db.tasks.find({ status: "completed" });

// Update task
db.tasks.updateOne(
  { _id: ObjectId("task_id") },
  { $set: { status: "completed" } }
);

// Delete task
db.tasks.deleteOne({ _id: ObjectId("task_id") });
```

---

## 🔒 Security Best Practices

### Với MongoDB Local:

```bash
# Tạo admin user
use admin
db.createUser({
  user: "admin",
  pwd: "strong_password",
  roles: ["root"]
})

# Enable authentication trong mongod.conf
security:
  authorization: enabled
```

### Với MongoDB Atlas:

- ✅ Sử dụng strong password
- ✅ Giới hạn IP whitelist
- ✅ Enable encryption at rest
- ✅ Regular backups (tự động)
- ✅ Monitor performance

---

## 🐛 Troubleshooting

### Lỗi: "Connection refused"

**Giải pháp:**

- MongoDB service chưa chạy: `mongod` (Local) hoặc check Atlas
- Sai PORT: Default là 27017
- Firewall blocking

### Lỗi: "Authentication failed"

**Giải pháp:**

- Sai username/password
- Check MONGO_URI trong .env
- Với Atlas: Check Database User permissions

### Lỗi: "Network timeout"

**Giải pháp:**

- Check internet connection
- Với Atlas: Check IP Whitelist
- Với Local: Check mongod đang chạy

### Lỗi: "Database does not exist"

**Giải pháp:**

- MongoDB tự tạo database khi có data
- Chạy backend, tạo user/task đầu tiên
- Database sẽ xuất hiện

---

## 📚 Tài liệu tham khảo

- MongoDB Docs: https://docs.mongodb.com/
- MongoDB University (Free courses): https://university.mongodb.com/
- MongoDB Atlas Docs: https://docs.atlas.mongodb.com/
- Mongoose Docs: https://mongoosejs.com/docs/

---

## ✅ Checklist Setup

### MongoDB Local:

- [ ] MongoDB đã cài đặt
- [ ] mongod service đang chạy
- [ ] Có thể kết nối bằng mongosh
- [ ] .env đã cấu hình đúng `mongodb://localhost:27017/task_manager_db`

### MongoDB Atlas:

- [ ] Đã tạo tài khoản
- [ ] Cluster đã tạo và running
- [ ] IP Whitelist đã cấu hình (0.0.0.0/0)
- [ ] Database User đã tạo
- [ ] Connection string đã copy và cấu hình trong .env
- [ ] Backend connect thành công

---

_Hướng dẫn MongoDB cho Task Manager App_
_Version: 1.0.0_
_Last Updated: November 12, 2025_

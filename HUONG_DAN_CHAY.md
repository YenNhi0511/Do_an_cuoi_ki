# 🚀 HƯỚNG DẪN CHẠY ỨNG DỤNG

## 📋 Yêu cầu hệ thống

### Backend:

- Node.js (v14 trở lên)
- MongoDB (local hoặc cloud)
- npm hoặc yarn

### Frontend:

- Flutter SDK (3.0 trở lên)
- Android Studio / VS Code
- Android Emulator hoặc thiết bị thật

---

## 🔧 BƯỚC 1: Cài đặt Backend

### 1.1. Di chuyển vào thư mục backend:

```bash
cd backend
```

### 1.2. Cài đặt dependencies:

```bash
npm install
```

### 1.3. Cấu hình MongoDB:

Tạo file `.env` trong thư mục `backend`:

```env
PORT=5000
MONGO_URI=mongodb://localhost:27017/task_manager
JWT_SECRET=your_secret_key_here
EMAIL_USER=your_email@gmail.com
EMAIL_PASS=your_email_password
```

**Lưu ý:**

- Nếu dùng MongoDB Atlas, thay `MONGO_URI` bằng connection string của bạn
- Email service chỉ cần nếu muốn gửi thông báo qua email

### 1.4. Chạy server:

```bash
npm start
```

hoặc với nodemon (auto-reload):

```bash
npm run dev
```

Server sẽ chạy tại: **http://localhost:5000**

Kiểm tra: Mở browser và truy cập http://localhost:5000 - bạn sẽ thấy "API đang chạy... OK"

---

## 📱 BƯỚC 2: Cài đặt Flutter App

### 2.1. Kiểm tra Flutter:

```bash
flutter doctor
```

Đảm bảo không có lỗi nghiêm trọng.

### 2.2. Di chuyển về thư mục gốc:

```bash
cd ..
```

### 2.3. Cài đặt dependencies:

```bash
flutter pub get
```

### 2.4. Cấu hình API URL:

**Quan trọng:** Kiểm tra file `lib/services/api_service.dart`:

```dart
static const String baseUrl = "http://10.0.2.2:5000/api"; // Android Emulator
```

- **Android Emulator:** Dùng `10.0.2.2`
- **iOS Simulator:** Dùng `localhost`
- **Thiết bị thật:** Dùng IP máy tính (vd: `http://192.168.1.100:5000/api`)

### 2.5. Chạy ứng dụng:

**Android Emulator:**

```bash
flutter run
```

**Chọn device cụ thể:**

```bash
flutter devices
flutter run -d <device_id>
```

**Build APK:**

```bash
flutter build apk --release
```

---

## 🧪 BƯỚC 3: Test ứng dụng

### 3.1. Đăng ký tài khoản:

1. Mở app
2. Nhấn "Đăng ký" (nếu chưa có tài khoản)
3. Nhập thông tin: username, email, password
4. Đăng ký thành công → Tự động đăng nhập

### 3.2. Tạo công việc đầu tiên:

1. Nhấn nút ➕ (FAB) ở góc dưới phải
2. Nhập:
   - Tiêu đề
   - Mô tả
   - Danh mục
   - Độ ưu tiên
   - Deadline
3. Nhấn "Lưu"

### 3.3. Test các chức năng mới (Phase 1):

#### ✅ Xóa công việc:

- Click vào icon 🗑️ trên TaskCard
- Xác nhận xóa

#### ✅ Tìm kiếm & Lọc:

- Nhấn icon 🔍 trên HomeScreen
- Thử tìm kiếm theo từ khóa
- Thử lọc theo Status, Priority, Category

#### ✅ Chi tiết công việc:

- Click vào bất kỳ TaskCard nào
- Xem chi tiết
- Thử thêm bình luận

#### ✅ Dashboard:

- Chuyển sang tab "Dashboard"
- Xem thống kê và biểu đồ

### 3.4. Test nhóm:

1. Chuyển sang tab "Nhóm"
2. Tạo nhóm mới
3. Thêm thành viên (cần email của user khác)
4. Gán công việc cho nhóm

---

## 🐛 XỬ LÝ LỖI THƯỜNG GẶP

### Lỗi 1: "Connection refused"

**Nguyên nhân:** Backend chưa chạy hoặc sai URL

**Giải pháp:**

- Kiểm tra backend đang chạy: `npm start`
- Kiểm tra URL trong `api_service.dart`
- Với Android Emulator, phải dùng `10.0.2.2`

### Lỗi 2: "MongoDB connection failed"

**Nguyên nhân:** MongoDB chưa chạy hoặc sai connection string

**Giải pháp:**

- Nếu dùng MongoDB local: `mongod` để start
- Kiểm tra `MONGO_URI` trong file `.env`
- Với MongoDB Atlas, check network access và whitelist IP

### Lỗi 3: "JWT token invalid"

**Nguyên nhân:** Token hết hạn hoặc không đúng

**Giải pháp:**

- Đăng xuất và đăng nhập lại
- Xóa data app (trong settings) và đăng ký lại

### Lỗi 4: Packages not found

**Nguyên nhân:** Dependencies chưa cài

**Giải pháp:**

```bash
flutter clean
flutter pub get
```

### Lỗi 5: Build failed

**Nguyên nhân:** Gradle/Kotlin version

**Giải pháp:**

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

---

## 📊 CẤU TRÚC DATABASE

### Users Collection:

```javascript
{
  _id: ObjectId,
  username: String,
  email: String,
  password: String (hashed),
  createdAt: Date
}
```

### Tasks Collection:

```javascript
{
  _id: ObjectId,
  title: String,
  description: String,
  category: String,
  priority: String,
  status: String,
  deadline: Date,
  groupId: ObjectId (optional),
  creatorId: ObjectId,
  assignedUsers: [ObjectId],
  createdAt: Date
}
```

### Groups Collection:

```javascript
{
  _id: ObjectId,
  name: String,
  members: [ObjectId],
  createdAt: Date
}
```

### Comments Collection:

```javascript
{
  _id: ObjectId,
  taskId: ObjectId,
  user: ObjectId,
  content: String,
  createdAt: Date
}
```

---

## 🔐 API Endpoints

### Auth:

- POST `/api/auth/register` - Đăng ký
- POST `/api/auth/login` - Đăng nhập

### Tasks:

- GET `/api/tasks` - Lấy danh sách task
- POST `/api/tasks` - Tạo task mới
- PUT `/api/tasks/:id` - Cập nhật task
- DELETE `/api/tasks/:id` - Xóa task
- GET `/api/tasks/:id` - Lấy chi tiết task

### Groups:

- GET `/api/groups` - Lấy danh sách nhóm
- POST `/api/groups` - Tạo nhóm mới
- POST `/api/groups/addMember` - Thêm thành viên

### Comments:

- GET `/api/comments/task/:taskId` - Lấy comments của task
- POST `/api/comments` - Thêm comment mới

### Reports:

- GET `/api/reports` - Lấy báo cáo thống kê

### Export:

- GET `/api/exports/pdf` - Export PDF
- GET `/api/exports/excel` - Export Excel

---

## 📱 Thông tin Version

- **Flutter:** 3.0+
- **Dart:** 3.0+
- **Node.js:** 14+
- **MongoDB:** 4.4+

---

## 👥 Liên hệ & Hỗ trợ

Nếu gặp vấn đề, hãy:

1. Kiểm tra console logs (cả backend và frontend)
2. Đọc lại hướng dẫn
3. Check file BAO_CAO_TIEN_DO.md
4. Check file PHASE_1_COMPLETED.md

---

## ✅ Checklist Setup

- [ ] MongoDB đang chạy
- [ ] Backend server đang chạy (port 5000)
- [ ] Flutter dependencies đã cài (`flutter pub get`)
- [ ] API URL đã cấu hình đúng
- [ ] Emulator/Device đã kết nối
- [ ] App đã build và chạy thành công
- [ ] Đã tạo tài khoản test
- [ ] Đã test tạo/xóa/sửa task
- [ ] Đã test Dashboard và Search

---

_Hướng dẫn được cập nhật: 12/11/2025_
_Phiên bản: 1.0 - Phase 1_

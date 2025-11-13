# 🚀 BACKEND API - TASK MANAGER

Backend API cho ứng dụng quản lý công việc cá nhân/nhóm

## 🛠 Tech Stack

- **Node.js** & **Express.js** - Framework backend
- **MongoDB** & **Mongoose** - Database
- **JWT** - Authentication
- **Bcrypt** - Password hashing
- **Nodemailer** - Email service
- **Multer** - File upload
- **ExcelJS** & **PDFKit** - Export reports

---

## 📦 Installation

### 1. Cài đặt dependencies:

```bash
npm install
```

### 2. Cấu hình môi trường:

Tạo file `.env` từ `.env.example`:

```bash
cp .env.example .env
```

Sau đó chỉnh sửa file `.env` với thông tin của bạn:

```env
PORT=5000
MONGO_URI=mongodb://localhost:27017/task_manager_db
JWT_SECRET=your_secret_key_here
```

### 3. Khởi động MongoDB:

**MongoDB Local:**

```bash
mongod
```

**MongoDB Atlas:**

- Đã có sẵn, chỉ cần cấu hình MONGO_URI

### 4. Chạy server:

**Development mode (với nodemon):**

```bash
npm run dev
```

**Production mode:**

```bash
npm start
```

Server sẽ chạy tại: `http://localhost:5000`

---

## 📚 API Endpoints

### 🔐 Authentication

#### Đăng ký

```http
POST /api/auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123"
}
```

#### Đăng nhập

```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:**

```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "_id": "...",
    "name": "John Doe",
    "email": "john@example.com"
  }
}
```

#### Lấy Profile

```http
GET /api/auth/profile
Authorization: Bearer <token>
```

---

### 📝 Tasks

**Tất cả endpoints cần Authentication (Bearer Token)**

#### Lấy danh sách tasks

```http
GET /api/tasks
Authorization: Bearer <token>
```

#### Tạo task mới

```http
POST /api/tasks
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Hoàn thành báo cáo",
  "description": "Báo cáo tháng 11",
  "category": "Công việc",
  "priority": "Cao",
  "deadline": "2025-11-20",
  "status": "not started"
}
```

#### Lấy task theo ID

```http
GET /api/tasks/:id
Authorization: Bearer <token>
```

#### Cập nhật task

```http
PUT /api/tasks/:id
Authorization: Bearer <token>
Content-Type: application/json

{
  "status": "in progress",
  "priority": "Khẩn cấp"
}
```

#### Xóa task

```http
DELETE /api/tasks/:id
Authorization: Bearer <token>
```

#### Thống kê tasks

```http
GET /api/tasks/stats
Authorization: Bearer <token>
```

**Response:**

```json
{
  "total": 10,
  "completed": 3,
  "inProgress": 4,
  "paused": 1,
  "notStarted": 2
}
```

---

### 👥 Groups

#### Lấy danh sách nhóm

```http
GET /api/groups
Authorization: Bearer <token>
```

#### Tạo nhóm mới

```http
POST /api/groups
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Team Development"
}
```

#### Thêm thành viên

```http
POST /api/groups/addMember
Authorization: Bearer <token>
Content-Type: application/json

{
  "groupId": "group_id_here",
  "email": "member@example.com"
}
```

---

### 💬 Comments

#### Lấy comments của task

```http
GET /api/comments/task/:taskId
Authorization: Bearer <token>
```

#### Thêm comment

```http
POST /api/comments
Authorization: Bearer <token>
Content-Type: application/json

{
  "taskId": "task_id_here",
  "content": "Đây là comment của tôi"
}
```

---

### 📊 Reports

#### Lấy báo cáo

```http
GET /api/reports
Authorization: Bearer <token>
```

---

### 📄 Export

#### Export PDF

```http
GET /api/exports/pdf
Authorization: Bearer <token>
```

#### Export Excel

```http
GET /api/exports/excel
Authorization: Bearer <token>
```

---

## 📂 Cấu trúc thư mục

```
backend/
├── config/
│   └── db.js              # MongoDB connection
├── controllers/
│   ├── authController.js  # Auth logic
│   ├── taskController.js  # Task CRUD
│   ├── groupController.js # Group management
│   ├── commentController.js
│   ├── reportController.js
│   └── exportController.js
├── middleware/
│   ├── auth.js           # JWT verification
│   └── upload.js         # File upload config
├── models/
│   ├── User.js           # User schema
│   ├── Task.js           # Task schema
│   ├── Group.js          # Group schema
│   └── Comment.js        # Comment schema
├── routes/
│   ├── authRoutes.js
│   ├── taskRoutes.js
│   ├── groupRoutes.js
│   ├── commentRoutes.js
│   ├── reportRoutes.js
│   └── exportRoutes.js
├── utils/
│   ├── emailService.js   # Email sending
│   └── scheduler.js      # Cron jobs
├── uploads/              # Uploaded files
├── .env.example          # Environment template
├── .gitignore
├── package.json
└── server.js             # Entry point
```

---

## 🔒 Security

- Passwords được hash với **bcrypt**
- API được bảo vệ bằng **JWT tokens**
- CORS được cấu hình
- Environment variables cho sensitive data
- Input validation
- Error handling middleware

---

## 🐛 Testing

### Test với curl:

**Đăng ký:**

```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@test.com","password":"123456"}'
```

**Đăng nhập:**

```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"123456"}'
```

**Lấy tasks:**

```bash
curl http://localhost:5000/api/tasks \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Test với Postman:

1. Import collection từ `postman/` (nếu có)
2. Set environment variable `token` sau khi login
3. Test tất cả endpoints

---

## 📝 Models Schema

### User

```javascript
{
  name: String,
  email: String (unique),
  password: String (hashed),
  role: String (admin/leader/member),
  group: ObjectId (ref: Group),
  createdAt: Date
}
```

### Task

```javascript
{
  title: String,
  description: String,
  category: String,
  priority: String (Thấp/Trung bình/Cao/Khẩn cấp),
  deadline: Date,
  status: String (not started/in progress/completed/paused),
  creator: ObjectId (ref: User),
  group: ObjectId (ref: Group),
  assignedUsers: [ObjectId],
  createdAt: Date,
  updatedAt: Date
}
```

### Group

```javascript
{
  name: String,
  members: [ObjectId (ref: User)],
  createdAt: Date
}
```

### Comment

```javascript
{
  task: ObjectId (ref: Task),
  user: ObjectId (ref: User),
  content: String,
  createdAt: Date
}
```

---

## 🚀 Deployment

### Heroku:

```bash
heroku create your-app-name
git push heroku main
heroku config:set MONGO_URI=your_mongodb_atlas_uri
heroku config:set JWT_SECRET=your_secret
```

### Railway/Render:

- Connect GitHub repo
- Set environment variables
- Deploy automatically

### VPS (Ubuntu):

```bash
# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Clone và setup
git clone your-repo
cd backend
npm install
npm install -g pm2
pm2 start server.js --name task-api
pm2 startup
pm2 save
```

---

## 📞 Support

Nếu gặp vấn đề:

1. Check MongoDB đang chạy
2. Check `.env` configuration
3. Check console logs
4. Check network/firewall

---

## 📄 License

MIT License

---

_Created with ❤️ for Task Manager App_
_Version: 1.0.0_
_Last Updated: November 12, 2025_

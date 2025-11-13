# 📱 Task Manager App - Ứng dụng Quản lý Công việc

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-14+-339933?logo=node.js)](https://nodejs.org)
[![MongoDB](https://img.shields.io/badge/MongoDB-4.4+-47A248?logo=mongodb)](https://www.mongodb.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Ứng dụng quản lý công việc cá nhân và nhóm, được xây dựng với **Flutter**, **Node.js**, và **MongoDB**.

![App Screenshots](https://via.placeholder.com/800x400?text=Task+Manager+App+Screenshots)

---

## ✨ Tính năng chính

### 📋 Quản lý Công việc Cá nhân

- ✅ Tạo, chỉnh sửa, xóa công việc
- ✅ Phân loại theo danh mục
- ✅ 4 mức độ ưu tiên (Thấp, Trung bình, Cao, Khẩn cấp)
- ✅ 4 trạng thái (Chưa bắt đầu, Đang làm, Hoàn thành, Tạm dừng)
- ✅ **Tìm kiếm & lọc** công việc theo nhiều tiêu chí
- ✅ Deadline tracking

### 👥 Quản lý Nhóm

- ✅ Tạo và quản lý nhóm
- ✅ Thêm thành viên
- ✅ Phân công công việc
- ✅ **Comment và thảo luận** về công việc

### 📊 Dashboard & Báo cáo

- ✅ **Dashboard trực quan** với biểu đồ
- ✅ Thống kê theo trạng thái
- ✅ Phân bố độ ưu tiên
- ✅ Tỷ lệ hoàn thành

### 📅 Quản lý Thời gian

- ✅ Lịch công việc (Calendar view)
- ✅ Hiển thị công việc theo ngày
- ✅ Cảnh báo deadline

### 🎨 Giao diện & UX

- ✅ Responsive design
- ✅ Dark mode
- ✅ Màn hình chi tiết công việc
- ✅ Navigation bar với 6 tabs

---

## 🚀 Quick Start

### Yêu cầu hệ thống

- **Flutter SDK** 3.0+
- **Node.js** 14+
- **MongoDB** (Local hoặc Atlas)
- **Android Studio** / **VS Code**

### Cài đặt Backend

```bash
# Di chuyển vào thư mục backend
cd backend

# Cài đặt dependencies
npm install

# Tạo file .env từ template
cp .env.example .env

# Chỉnh sửa .env với MongoDB URI của bạn
# MONGO_URI=mongodb://localhost:27017/task_manager_db

# Chạy server
npm run dev
```

### Cài đặt Flutter App

```bash
# Cài đặt dependencies
flutter pub get

# Chạy app
flutter run
```

**📖 Hướng dẫn chi tiết:** Xem [HUONG_DAN_CHAY.md](HUONG_DAN_CHAY.md)

---

## 📁 Cấu trúc dự án

```
do_an_cuoi_ki/
├── lib/                        # Flutter app
│   ├── main.dart              # Entry point
│   ├── models/                # Data models
│   ├── screens/               # UI screens
│   ├── services/              # API services
│   ├── widgets/               # Reusable widgets
│   └── providers/             # State management
│
├── backend/                    # Node.js API
│   ├── config/                # Database config
│   ├── controllers/           # Business logic
│   ├── models/                # MongoDB schemas
│   ├── routes/                # API routes
│   ├── middleware/            # Auth, etc.
│   └── utils/                 # Helpers
│
├── assets/                     # Images, fonts
├── pubspec.yaml               # Flutter dependencies
└── README.md                  # This file
```

---

## 🛠 Tech Stack

### Frontend

- **Flutter** - Cross-platform mobile framework
- **Provider** - State management
- **HTTP** - API communication
- **FL Chart** - Data visualization
- **Table Calendar** - Calendar widget

### Backend

- **Node.js** + **Express** - REST API
- **MongoDB** + **Mongoose** - Database
- **JWT** - Authentication
- **Bcrypt** - Password encryption

---

## 📸 Screenshots

| Home Screen                                            | Dashboard                                                        | Task Detail                                                |
| ------------------------------------------------------ | ---------------------------------------------------------------- | ---------------------------------------------------------- |
| ![Home](https://via.placeholder.com/200x400?text=Home) | ![Dashboard](https://via.placeholder.com/200x400?text=Dashboard) | ![Detail](https://via.placeholder.com/200x400?text=Detail) |

| Search & Filter                                            | Calendar                                                       | Groups                                                     |
| ---------------------------------------------------------- | -------------------------------------------------------------- | ---------------------------------------------------------- |
| ![Search](https://via.placeholder.com/200x400?text=Search) | ![Calendar](https://via.placeholder.com/200x400?text=Calendar) | ![Groups](https://via.placeholder.com/200x400?text=Groups) |

---

## 📚 Tài liệu

- 📖 [Hướng dẫn chạy ứng dụng](HUONG_DAN_CHAY.md)
- 📊 [Báo cáo tiến độ](BAO_CAO_TIEN_DO.md)
- ✅ [Phase 1 Completed](PHASE_1_COMPLETED.md)
- 🎉 [Dự án hoàn thành](PROJECT_COMPLETE.md)
- 🔧 [Backend Documentation](backend/README.md)
- 🍃 [MongoDB Setup](backend/MONGODB_SETUP.md)

---

## 🧪 Testing

### Test Backend API

**Windows PowerShell:**

```powershell
cd backend
.\test-api.ps1
```

**Linux/Mac:**

```bash
cd backend
chmod +x test-api.sh
./test-api.sh
```

### Test Flutter App

1. Chạy app với `flutter run`
2. Đăng ký tài khoản mới
3. Thử các tính năng:
   - Tạo/sửa/xóa công việc
   - Tìm kiếm và lọc
   - Xem chi tiết và comment
   - Dashboard và calendar

---

## 🔐 API Endpoints

### Authentication

- `POST /api/auth/register` - Đăng ký
- `POST /api/auth/login` - Đăng nhập
- `GET /api/auth/profile` - Lấy profile

### Tasks

- `GET /api/tasks` - Lấy danh sách
- `POST /api/tasks` - Tạo mới
- `GET /api/tasks/:id` - Chi tiết
- `PUT /api/tasks/:id` - Cập nhật
- `DELETE /api/tasks/:id` - Xóa
- `GET /api/tasks/stats` - Thống kê

### Groups & Comments

- `GET /api/groups` - Danh sách nhóm
- `POST /api/groups` - Tạo nhóm
- `GET /api/comments/task/:taskId` - Lấy comments
- `POST /api/comments` - Thêm comment

**📖 Full API Documentation:** [backend/README.md](backend/README.md)

---

## 🎯 Mức độ hoàn thành

| Feature          | Progress   |
| ---------------- | ---------- |
| Task Management  | ✅ 90%     |
| Group Management | ✅ 70%     |
| Time Management  | ✅ 80%     |
| Reports & Stats  | ✅ 75%     |
| User Management  | ✅ 95%     |
| UI/UX            | ✅ 80%     |
| **Overall**      | **✅ 85%** |

---

## 🔜 Roadmap

### Phase 2 (Upcoming)

- [ ] Tags/Labels system
- [ ] Export PDF/Excel
- [ ] Profile management UI
- [ ] File attachments

### Phase 3

- [ ] Advanced notifications
- [ ] Recurring tasks
- [ ] Time tracking
- [ ] Better animations

### Phase 4

- [ ] Team analytics
- [ ] Performance metrics
- [ ] Data backup/restore
- [ ] Multi-language support

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Authors

- **Your Name** - _Initial work_

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- MongoDB for the database
- Node.js & Express for the backend
- All open-source contributors

---

## 📞 Support

Nếu bạn gặp vấn đề:

1. Check [HUONG_DAN_CHAY.md](HUONG_DAN_CHAY.md)
2. Check [backend/README.md](backend/README.md)
3. Check [backend/MONGODB_SETUP.md](backend/MONGODB_SETUP.md)
4. Open an issue on GitHub

---

## ⭐ Show your support

Give a ⭐️ if you like this project!

---

**Built with ❤️ using Flutter + Node.js + MongoDB**

_Last Updated: November 12, 2025_

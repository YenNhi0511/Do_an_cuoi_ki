# 📱 Ứng Dụng Quản Lý Công Việc Cá Nhân & Nhóm

## 🎯 Tổng Quan

Ứng dụng quản lý công việc toàn diện với đầy đủ tính năng cho cá nhân và nhóm, được xây dựng bằng Flutter và Node.js.

## ✨ Tính Năng Chính

### 1. 📅 Quản Lý Công Việc

- ✅ **Tạo/Sửa/Xóa công việc** với đầy đủ thông tin
- ⏰ **Đặt thời gian cụ thể**: Giờ bắt đầu, giờ kết thúc hoặc cả ngày
- 🔄 **Lặp lại công việc**: Hàng ngày, tuần, tháng, năm
- 🔔 **Nhắc nhở đa dạng**: 5 phút, 15 phút, 1 giờ, 1 ngày trước...
- 🎨 **Màu sắc tùy chỉnh**: 6 màu mặc định + chọn màu tùy ý
- 📎 **Đính kèm file**: Upload và quản lý tài liệu
- 🏷️ **Tags/Labels**: Phân loại công việc dễ dàng
- 📍 **Địa điểm**: Thêm location cho task
- 🔗 **URL liên quan**: Link tài liệu, meeting...

### 2. 📆 Lịch Công Việc

#### Chế độ xem Tháng

- Hiển thị toàn bộ tháng với TableCalendar
- Đánh dấu các ngày có công việc
- Gradient màu cho ngày hiện tại và ngày được chọn
- Click vào ngày để xem chi tiết tasks

#### Chế độ Tuần

- **Week Selector**: Chọn nhanh các ngày trong tuần
- **Timeline chi tiết**: 24 giờ với grid rõ ràng
- **Task cards**: Hiển thị theo thời gian thực tế (startTime - endTime)
- **Màu sắc task**: Theo màu đã chọn
- Navigation trước/sau tuần dễ dàng

#### Chế độ Ngày (7-Day Grid)

- **Grid 7 ngày**: Xem overview cả tuần
- **Timeline 24h**: Mỗi ngày có timeline riêng
- **Tasks positioning**: Đặt đúng vị trí theo giờ
- **Scroll ngang**: Xem nhiều ngày cùng lúc
- **Highlight hôm nay**: Nổi bật ngày hiện tại

#### Chế độ Danh sách

- Xem tất cả tasks dạng list
- Sắp xếp theo deadline
- Badge priority với màu task
- Tags display
- Scroll dễ dàng

### 3. 👥 Quản Lý Nhóm

- **Tạo nhóm**: Đặt tên, mô tả, avatar
- **Mời thành viên**: Thêm user vào nhóm
- **Phân quyền**:
  - 👑 Admin: Toàn quyền quản lý
  - 📝 Editor: Tạo/sửa tasks
  - 👀 Viewer: Chỉ xem
- **Công việc nhóm**: Gán task cho nhiều người
- **Timeline nhóm**: Xem lịch làm việc chung

### 4. 💬 Comments & Chat

- **Comment trên task**: Thảo luận chi tiết
- **@mention**: Tag thành viên
- **File sharing**: Chia sẻ file trong comment
- **Real-time**: Cập nhật tức thời
- **Notification**: Thông báo khi có comment mới

### 5. 📊 Thống Kê & Báo Cáo

- **Dashboard tổng quan**:
  - Tổng số tasks
  - Tasks hoàn thành/đang làm/chưa bắt đầu
  - Tỷ lệ hoàn thành
- **Biểu đồ**:
  - Pie chart theo priority
  - Bar chart theo category
  - Line chart theo thời gian
- **Export báo cáo**: PDF, Excel
- **Lọc theo**:
  - Thời gian (tuần, tháng, năm)
  - Nhóm, thành viên
  - Priority, status

### 6. 🔔 Thông Báo

- **Push notification**: Nhắc nhở đúng giờ
- **In-app notification**: Danh sách thông báo
- **Email notification**: Gửi mail cho tasks quan trọng
- **Badges**: Hiển thị số thông báo chưa đọc
- **Cài đặt**: Bật/tắt từng loại thông báo

### 7. 👤 Quản Lý Tài Khoản

- **Profile**: Avatar, tên, email, bio
- **Cài đặt**:
  - Ngôn ngữ (VN/EN)
  - Theme (Light/Dark/Auto)
  - Định dạng ngày tháng
  - Timezone
  - Hiển thị số tuần
  - Chế độ xem mặc định
- **Bảo mật**: Đổi mật khẩu, 2FA
- **Privacy**: Quản lý quyền riêng tư

### 8. 🔍 Tìm Kiếm & Lọc

- **Search**: Tìm task theo tên, mô tả
- **Filter**:
  - Status: not started, in progress, completed, paused
  - Priority: Thấp, Trung bình, Cao, Khẩn cấp
  - Category: Work, Personal, Study...
  - Date range: Từ ngày - đến ngày
  - Assigned to: Người được giao
  - Tags: Theo nhãn
- **Sort**: Sắp xếp nhiều tiêu chí

### 9. 📤 Export & Import

- **Export**:
  - PDF: In báo cáo đẹp
  - Excel: Phân tích dữ liệu
  - CSV: Backup data
  - iCal: Sync với calendar khác
- **Import**:
  - CSV: Import hàng loạt tasks
  - iCal: Sync từ calendar khác

### 10. 🎯 Templates

- **Mẫu công việc**: Tạo template cho tasks thường xuyên
- **Quick create**: Tạo nhanh từ template
- **Share template**: Chia sẻ trong nhóm
- **Library**: Thư viện templates

## 🏗️ Kiến Trúc

### Frontend (Flutter)

```
lib/
├── main.dart                 # Entry point
├── models/                   # Data models
│   ├── task.dart            # Task model với đầy đủ fields
│   ├── user.dart
│   ├── group.dart
│   └── comment.dart
├── screens/                  # UI screens
│   ├── calendar_screen.dart # 4 chế độ xem lịch
│   ├── task_form.dart       # Form tạo/sửa task
│   ├── dashboard_screen.dart
│   ├── group_screen.dart
│   └── ...
├── services/                 # Business logic
│   ├── api_service.dart     # API calls
│   ├── auth_service.dart    # Authentication
│   ├── notification_service.dart
│   └── repeat_task_service.dart
├── providers/               # State management
│   ├── task_provider.dart
│   ├── auth_provider.dart
│   └── theme_provider.dart
└── widgets/                 # Reusable widgets
    ├── app_colors.dart
    ├── task_card.dart
    └── ...
```

### Backend (Node.js + Express)

```
backend/
├── server.js               # Server entry
├── config/
│   └── db.js              # MongoDB connection
├── models/                # Mongoose models
│   ├── Task.js           # Task schema với fields mới
│   ├── User.js
│   ├── Group.js
│   └── Comment.js
├── controllers/           # Business logic
│   ├── taskController.js
│   ├── groupController.js
│   └── ...
├── routes/               # API routes
│   ├── taskRoutes.js
│   ├── groupRoutes.js
│   └── ...
├── middleware/
│   ├── auth.js          # JWT verification
│   └── upload.js        # File upload
└── utils/
    ├── emailService.js  # Send emails
    └── scheduler.js     # Cron jobs
```

## 📋 Task Model Fields

```dart
class Task {
  String? id;
  String title;              // Tiêu đề
  String description;        // Mô tả
  String category;           // Danh mục
  String priority;           // Độ ưu tiên
  String status;             // Trạng thái
  String? deadline;          // Hạn chót (date)
  String? startTime;         // Giờ bắt đầu (HH:mm)
  String? endTime;           // Giờ kết thúc (HH:mm)
  bool isAllDay;             // Cả ngày
  String? repeatType;        // Loại lặp: none, daily, weekly, monthly, yearly
  List<String>? reminders;   // Danh sách nhắc nhở
  String? color;             // Màu task (#RRGGBB)
  String? location;          // Địa điểm
  String? url;               // URL liên quan
  String? groupId;           // ID nhóm
  String? creatorId;         // ID người tạo
  List<String>? assignedUsers; // IDs người được giao
  List<String>? tags;        // Tags/labels
  List<String>? attachments; // File paths
}
```

## 🚀 Hướng Dẫn Sử Dụng

### 1. Tạo Task Mới

1. Nhấn nút ➕ (FloatingActionButton)
2. Điền thông tin:
   - **Tiêu đề**: Tên công việc
   - **Chi tiết**: Mô tả (optional)
   - **Cả ngày**: Bật nếu task không có giờ cụ thể
   - **Ngày & Giờ**: Chọn deadline, start/end time
   - **Nhắc nhở**: Thêm reminders (có thể nhiều)
   - **Lặp lại**: Chọn repeat type
   - **Màu sắc**: Pick color
   - **Location/URL**: Thêm nếu cần
3. Nhấn ✅ để lưu

### 2. Xem Lịch

#### Tuần:

- Chọn tab "Tuần"
- Dùng selector trên cùng để chọn ngày
- Scroll timeline để xem tasks theo giờ
- Click task để xem chi tiết/sửa

#### Ngày (7-Day Grid):

- Chọn tab "Ngày"
- Xem overview 7 ngày
- Scroll ngang để xem thêm
- Click task để open

### 3. Quản Lý Nhóm

1. Vào tab "Nhóm"
2. Tạo nhóm mới:
   - Tên nhóm
   - Mô tả
   - Avatar (optional)
3. Mời thành viên:
   - Nhập email/username
   - Chọn role: Admin/Editor/Viewer
4. Giao công việc:
   - Tạo task trong nhóm
   - Chọn "Assigned to"
   - Pick members

### 4. Xem Thống Kê

1. Vào "Dashboard"
2. Xem overview:
   - Total tasks
   - Completion rate
   - Charts
3. Filter theo:
   - Time range
   - Group
   - Member
4. Export báo cáo nếu cần

## 🔧 Cài Đặt

### Frontend

```bash
cd do_an_cuoi_ki
flutter pub get
flutter run
```

### Backend

```bash
cd backend
npm install
npm start
```

### Database

- MongoDB Atlas hoặc local MongoDB
- Update connection string trong `backend/config/db.js`

## 📱 Yêu Cầu Hệ Thống

- Flutter SDK: ≥3.0.0
- Node.js: ≥14.0.0
- MongoDB: ≥4.4.0
- Android: ≥5.0 (API 21)
- iOS: ≥11.0

## 🎨 Màu Sắc Chủ Đạo

```dart
Primary: #1E40AF (Deep Blue)
Accent: #14B8A6 (Teal)
Success: #10B981 (Green)
Warning: #F59E0B (Amber)
Error: #EF4444 (Red)
Background: #F8FAFC (Light Gray)
```

## 📝 API Endpoints

### Tasks

- `GET /api/tasks` - Lấy all tasks
- `POST /api/tasks` - Tạo task mới
- `PUT /api/tasks/:id` - Update task
- `DELETE /api/tasks/:id` - Xóa task
- `GET /api/tasks/:id` - Lấy chi tiết task

### Groups

- `GET /api/groups` - Lấy groups của user
- `POST /api/groups` - Tạo group mới
- `PUT /api/groups/:id` - Update group
- `DELETE /api/groups/:id` - Xóa group
- `POST /api/groups/:id/members` - Thêm member

### Comments

- `GET /api/tasks/:taskId/comments` - Lấy comments
- `POST /api/tasks/:taskId/comments` - Thêm comment
- `DELETE /api/comments/:id` - Xóa comment

### Reports

- `GET /api/reports/dashboard` - Dashboard stats
- `GET /api/reports/export` - Export data

## 🐛 Debug & Testing

- Enable debug mode trong settings
- Check logs: `flutter logs` hoặc `npm run dev`
- Test API: Postman collection included

## 📄 License

MIT License - Free to use

## 👨‍💻 Developer

Developed with ❤️ by Team

## 📞 Support

- Email: support@example.com
- GitHub Issues: [repository]/issues
- Documentation: [wiki link]

---

**⚡ App được xây dựng với kiến trúc hiện đại, scalable và maintainable!**

// server.js (Hoàn chỉnh)

import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import path from "path"; 
import connectDB from "./config/db.js";

// Import routes
import authRoutes from "./routes/authRoutes.js";
import groupRoutes from "./routes/groupRoutes.js";
import taskRoutes from "./routes/taskRoutes.js";
import commentRoutes from "./routes/commentRoutes.js";
import reportRoutes from "./routes/reportRoutes.js";
import exportRoutes from "./routes/exportRoutes.js";

import { scheduleReminders } from "./utils/scheduler.js";

// Cấu hình dotenv
dotenv.config();

const app = express();

// --- Các Middleware chính ---
app.use(cors());      
app.use(express.json()); 

// Cấu hình phục vụ file tĩnh (cho thư mục 'uploads')
const __dirname = path.resolve();
app.use("/uploads", express.static(path.join(__dirname, "/uploads")));

// --- Các Routes API ---
app.use("/api/auth", authRoutes);
app.use("/api/groups", groupRoutes);
app.use("/api/tasks", taskRoutes);
app.use("/api/comments", commentRoutes);
app.use("/api/reports", reportRoutes);
app.use("/api/exports", exportRoutes);

// --- Route kiểm tra "Sức khỏe" API (Health Check) ---
app.get("/", (req, res) => {
  res.send("API đang chạy... OK");
});

// --- Middleware Xử lý lỗi (Phải đặt SAU KHI khai báo routes) ---

// 1. Bắt lỗi 404 (Không tìm thấy Route)
app.use((req, res, next) => {
  const error = new Error(`Không tìm thấy - ${req.originalUrl}`);
  res.status(404);
  next(error); 
});

// 2. Bắt tất cả các lỗi khác (500 Server Error)
app.use((err, req, res, next) => {
  const statusCode = res.statusCode === 200 ? 500 : res.statusCode;
  res.status(statusCode);
  res.json({
    message: err.message,
    stack: process.env.NODE_ENV === "production" ? null : err.stack,
  });
});

// --- Khởi động Server ---
const PORT = process.env.PORT || 5001; 

const startServer = async () => {
  try {
    // 1. Kết nối DB
    await connectDB();
    console.log("Database đã kết nối thành công");

    // 2. Chạy các tác vụ nền (nếu cần)
    scheduleReminders();

    // 3. Khởi động Server Express
    // --- SỬA LỖI Ở ĐÂY ---
    // Thêm '0.0.0.0' để chấp nhận kết nối từ máy ảo
    app.listen(PORT, '0.0.0.0', () =>
      console.log(`🚀 Server đang chạy ở http://localhost:${PORT} (và trên 0.0.0.0)`)
    );
  } catch (error) {
    console.error(`Lỗi khởi động server: ${error.message}`);
    process.exit(1); 
  }
};

// Gọi hàm để bắt đầu
startServer();
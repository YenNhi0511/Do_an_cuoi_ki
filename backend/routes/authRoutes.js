// backend/routes/authRoutes.js
import express from "express";
import jwt from "jsonwebtoken";
// 'bcrypt' không cần ở đây nếu 'User.create' và 'user.matchPassword' đã xử lý
import User from "../models/User.js";
import authMiddleware from "../middleware/auth.js";

const router = express.Router();

// Hàm generateToken (Rất tốt, giữ nguyên)
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRE || "7d",
  });
};

// Đăng ký
router.post("/register", async (req, res) => {
  try {
    const { name, email, password } = req.body;
    
    // --- SỬA LỖI LOGIC: Thêm chuẩn hóa email ---
    if (!email) {
      return res.status(400).json({ message: "Email là bắt buộc" });
    }
    const trimmedEmail = email.trim();
    const searchEmail = new RegExp('^' + trimmedEmail + '$', 'i');
    // ---

    const userExists = await User.findOne({ email: searchEmail });
    console.log('🔍 Check user exists:', userExists ? 'YES' : 'NO');
    
    if (userExists)
      return res.status(400).json({ message: "Email đã được sử dụng" });

    console.log('➡️ Creating user:', { name, email: trimmedEmail });
    
    // User model (trong User.js) sẽ tự động hash mật khẩu
    const user = await User.create({ name, email: trimmedEmail, password }); 
    
    console.log('✅ User created successfully:', user._id);
    
    const token = generateToken(user._id);
    
    // Trả về token và user (không cần populate)
    res.status(201).json({ token, user }); 
  } catch (err) {
    console.error("Lỗi đăng ký:", err);
    res.status(500).json({ message: "Lỗi máy chủ khi đăng ký" });
  }
});

// Đăng nhập
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    // --- SỬA LỖI LOGIC: Thêm chuẩn hóa email ---
    if (!email) {
      return res.status(400).json({ message: "Email là bắt buộc" });
    }
    const trimmedEmail = email.trim();
    const searchEmail = new RegExp('^' + trimmedEmail + '$', 'i');
    // ---

    // --- SỬA LỖI "TREO": ĐÃ XÓA .populate() ---
    // Chỉ cần tìm user, không cần thông tin group ở bước này
    const user = await User.findOne({ email: searchEmail });
    // ---

    if (!user) return res.status(404).json({ message: "Không tìm thấy tài khoản" });
    
    const isMatch = await user.matchPassword(password);
    if (!isMatch) return res.status(400).json({ message: "Sai mật khẩu" });

    const token = generateToken(user._id);

    // Trả về token và user (không cần populate)
    // AuthService (Flutter) sẽ gọi /me ngay sau đây để lấy user đầy đủ
    res.json({ token, user });
  } catch (err) {
    console.error("Lỗi đăng nhập:", err);
    res.status(500).json({ message: "Lỗi máy chủ khi đăng nhập" });
  }
});

// Lấy thông tin user hiện tại (Giữ nguyên, file này đã đúng)
// authMiddleware sẽ chạy, và nó sẽ populate user
router.get("/me", authMiddleware, async (req, res) => {
  try {
    res.json(req.user); // req.user này đã được populate từ middleware
  } catch (err) {
    console.error("Lỗi lấy thông tin người dùng:", err);
    res.status(500).json({ message: "Không thể lấy thông tin người dùng" });
  }
});

export default router;
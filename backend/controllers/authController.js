import jwt from "jsonwebtoken";
import User from "../models/User.js";

export const registerUser = async (req, res) => {
  try {
    const { name, email, password, role } = req.body;
    
    // --- SỬA LỖI ĐĂNG NHẬP 1 (Giống bên dưới) ---
    // Luôn dọn dẹp email trước khi tìm kiếm/tạo mới
    if (!email) {
      return res.status(400).json({ message: "Email là bắt buộc" });
    }
    const trimmedEmail = email.trim().toLowerCase(); // <-- Chuẩn hóa email
    // ---

    const exist = await User.findOne({ email: trimmedEmail });
    if (exist) return res.status(400).json({ message: "Email đã tồn tại" });

    // Mongoose 'pre-save' hook trong User.js sẽ tự động hash mật khẩu
    const user = await User.create({ name, email: trimmedEmail, password, role });

    // --- SỬA LỖI ĐIỀU HƯỚNG 2 ---
    // Sau khi đăng ký thành công, tạo token và tự động đăng nhập luôn
    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, {
      expiresIn: "7d",
    });

    // Trả về token + user, giống hệt hàm login
    res.status(201).json({ token, user });
    // ---
  } catch (err) {
    res.status(400).json({ message: "Lỗi đăng ký", error: err.message });
  }
};

export const loginUser = async (req, res) => {
  try { // <-- SỬA LỖI 3: Thêm try...catch
    const { email, password } = req.body;

    // --- SỬA LỖI ĐĂNG NHẬP 1 (Quan trọng nhất) ---
    // Kiểm tra và dọn dẹp dữ liệu đầu vào
    if (!email || !password) {
      return res.status(400).json({ message: "Vui lòng nhập email và mật khẩu" });
    }
    
    const trimmedEmail = email.trim(); // 1. Loại bỏ khoảng trắng

    // 2. Tìm kiếm không phân biệt chữ hoa/thường
    const user = await User.findOne({ 
      email: new RegExp('^' + trimmedEmail + '$', 'i') 
    });
    // ---

    if (!user) {
      return res.status(401).json({ message: "Sai email hoặc mật khẩu" });
    }

    // Hàm 'matchPassword' (trong User.js) sẽ so sánh mật khẩu
    const match = await user.matchPassword(password);
    if (!match) {
      return res.status(401).json({ message: "Sai email hoặc mật khẩu" });
    }

    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, {
      expiresIn: "7d",
    });
    
    // Trả về { token, user } là chính xác
    res.json({ token, user });

  } catch (err) { // <-- SỬA LỖI 3: Bắt lỗi server
    res.status(500).json({ message: "Lỗi server", error: err.message });
  }
};

export const getProfile = async (req, res) => {
  try { // <-- SỬA LỖI 3: Thêm try...catch
    // req.user được gán từ middleware 'auth.js'
    const user = await User.findById(req.user._id).select("-password");
    res.json(user);
  } catch (err) {
    res.status(500).json({ message: "Lỗi lấy thông tin", error: err.message });
  }
};
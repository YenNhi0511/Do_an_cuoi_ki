import express from "express";
import auth from "../middleware/auth.js";
import {
  createGroup,
  getGroups,
  addMember
} from "../controllers/groupController.js";

const router = express.Router();

// ✅ Tạo nhóm mới
router.post("/", auth, createGroup);

// ✅ Lấy danh sách nhóm của người dùng
router.get("/", auth, getGroups);

// ✅ Thêm thành viên vào nhóm
router.post("/addMember", auth, addMember);

export default router;

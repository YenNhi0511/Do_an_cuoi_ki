// backend/routes/taskRoutes.js
import express from "express";
import {
  createTask,
  getTasks,
  getTaskById,
  updateTask,
  deleteTask,
  getStats,
} from "../controllers/taskController.js";
import auth from "../middleware/auth.js";

const router = express.Router();

// 📌 Routes chính
router.route("/")
  .get(auth, getTasks)       // GET tất cả tasks
  .post(auth, createTask);   // POST tạo task mới

router.route("/:id")
  .get(auth, getTaskById)    // GET task theo ID
  .put(auth, updateTask)     // PUT cập nhật task
  .delete(auth, deleteTask); // DELETE xóa task

// 📊 Route thống kê
router.get("/stats", auth, getStats);

export default router;

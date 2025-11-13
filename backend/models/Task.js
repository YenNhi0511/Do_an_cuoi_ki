// backend/models/Task.js
import mongoose from "mongoose";

const taskSchema = new mongoose.Schema(
  {
    // 🏷 Tiêu đề công việc
    title: {
      type: String,
      required: [true, "Tên công việc không được để trống"],
      trim: true,
    },

    // 📝 Mô tả chi tiết
    description: {
      type: String,
      default: "",
      trim: true,
    },

    // 📁 Danh mục / loại công việc
    category: {
      type: String,
      default: "Chung",
      trim: true,
    },

    // ⚡ Mức độ ưu tiên
    priority: {
      type: String,
      enum: ["Thấp", "Trung bình", "Cao", "Khẩn cấp"],
      default: "Trung bình",
    },

    // ⏰ Hạn chót
    deadline: {
      type: Date,
    },

    // 📊 Trạng thái công việc
    status: {
      type: String,
      enum: ["not started", "in progress", "completed", "paused"],
      default: "not started",
    },

    // 👤 Người tạo công việc
    creator: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    // 👥 Nhóm mà công việc thuộc về
    group: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Group",
      default: null,
    },

    // 👨‍💻 Danh sách người được giao công việc (có thể nhiều người)
    assignedUsers: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
      },
    ],

    // 🏷️ Tags/Labels cho công việc
    tags: [
      {
        type: String,
        trim: true,
      },
    ],
  },
  {
    timestamps: true, // tự thêm createdAt & updatedAt
  }
);

// 🧠 Index tối ưu tìm kiếm nhanh trong nhóm
taskSchema.index({ group: 1, creator: 1 });

const Task = mongoose.model("Task", taskSchema);
export default Task;

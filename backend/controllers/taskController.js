import Task from "../models/Task.js";

// 🟢 Tạo công việc mới
export const createTask = async (req, res) => {
  try {
    const { title, description, category, priority, deadline, status, groupId, assignedUsers } = req.body;

    const newTask = new Task({
      title,
      description: description || "",
      category: category || "Chung",
      priority: priority || "Trung bình",
      deadline: deadline || null,
      status: status || "not started",
      creator: req.user._id,
      group: groupId || null,
      assignedUsers: assignedUsers || [req.user._id],
    });

    const savedTask = await newTask.save();
    
    // Populate để trả về đầy đủ thông tin
    const populatedTask = await Task.findById(savedTask._id)
      .populate("creator", "name email")
      .populate("assignedUsers", "name email")
      .populate("group", "name");

    res.status(201).json(populatedTask);
  } catch (error) {
    console.error("❌ Lỗi tạo công việc:", error.message);
    res.status(500).json({ message: error.message });
  }
};

// 🟢 Lấy danh sách công việc
export const getTasks = async (req, res) => {
  try {
    const userId = req.user._id;
    const userGroup = req.user.group || null;

    // Lấy tasks mà user tạo HOẶC được assign HOẶC thuộc nhóm của user
    const tasks = await Task.find({
      $or: [
        { creator: userId },
        { assignedUsers: userId },
        { group: userGroup, group: { $ne: null } },
      ],
    })
      .populate("creator", "name email")
      .populate("assignedUsers", "name email")
      .populate("group", "name")
      .sort({ createdAt: -1 }); // Mới nhất trước

    res.json(tasks);
  } catch (error) {
    console.error("❌ Lỗi lấy danh sách:", error.message);
    res.status(500).json({ message: error.message });
  }
};

// 🟢 Lấy task theo ID
export const getTaskById = async (req, res) => {
  try {
    const task = await Task.findById(req.params.id)
      .populate("creator", "name email")
      .populate("assignedUsers", "name email")
      .populate("group", "name");

    if (!task) {
      return res.status(404).json({ message: "Không tìm thấy công việc" });
    }

    res.json(task);
  } catch (error) {
    console.error("❌ Lỗi lấy chi tiết:", error.message);
    res.status(500).json({ message: error.message });
  }
};

// 🟢 Cập nhật công việc
export const updateTask = async (req, res) => {
  try {
    const { title, description, category, priority, deadline, status, groupId, assignedUsers } = req.body;

    const task = await Task.findById(req.params.id);

    if (!task) {
      return res.status(404).json({ message: "Không tìm thấy công việc" });
    }

    // Kiểm tra quyền (chỉ creator hoặc assigned users mới được sửa)
    const isCreator = task.creator.toString() === req.user._id.toString();
    const isAssigned = task.assignedUsers.some(
      (userId) => userId.toString() === req.user._id.toString()
    );

    if (!isCreator && !isAssigned) {
      return res.status(403).json({ message: "Bạn không có quyền chỉnh sửa công việc này" });
    }

    // Update fields
    if (title) task.title = title;
    if (description !== undefined) task.description = description;
    if (category) task.category = category;
    if (priority) task.priority = priority;
    if (deadline !== undefined) task.deadline = deadline;
    if (status) task.status = status;
    if (groupId !== undefined) task.group = groupId;
    if (assignedUsers) task.assignedUsers = assignedUsers;

    const updatedTask = await task.save();

    // Populate để trả về đầy đủ
    const populatedTask = await Task.findById(updatedTask._id)
      .populate("creator", "name email")
      .populate("assignedUsers", "name email")
      .populate("group", "name");

    res.json(populatedTask);
  } catch (error) {
    console.error("❌ Lỗi cập nhật:", error.message);
    res.status(500).json({ message: error.message });
  }
};

// 🟢 Xóa công việc
export const deleteTask = async (req, res) => {
  try {
    const task = await Task.findById(req.params.id);

    if (!task) {
      return res.status(404).json({ message: "Không tìm thấy công việc" });
    }

    // Chỉ creator mới được xóa
    if (task.creator.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: "Chỉ người tạo mới có thể xóa công việc này" });
    }

    await Task.findByIdAndDelete(req.params.id);
    res.json({ message: "Xóa công việc thành công" });
  } catch (error) {
    console.error("❌ Lỗi xóa:", error.message);
    res.status(500).json({ message: error.message });
  }
};

// 🟢 Thống kê công việc
export const getStats = async (req, res) => {
  try {
    const userId = req.user._id;

    const completed = await Task.countDocuments({
      $or: [{ creator: userId }, { assignedUsers: userId }],
      status: "completed",
    });

    const inProgress = await Task.countDocuments({
      $or: [{ creator: userId }, { assignedUsers: userId }],
      status: "in progress",
    });

    const paused = await Task.countDocuments({
      $or: [{ creator: userId }, { assignedUsers: userId }],
      status: "paused",
    });

    const notStarted = await Task.countDocuments({
      $or: [{ creator: userId }, { assignedUsers: userId }],
      status: "not started",
    });

    const total = completed + inProgress + paused + notStarted;

    res.json({
      total,
      completed,
      inProgress,
      paused,
      notStarted,
      // Alias cho Flutter app (backward compatible)
      done: completed,
      doing: inProgress,
    });
  } catch (error) {
    console.error("❌ Lỗi thống kê:", error.message);
    res.status(500).json({ message: error.message });
  }
};

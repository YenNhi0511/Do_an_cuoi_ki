import Task from "../models/Task.js";

export const getReport = async (req, res) => {
  try {
    const all = await Task.find({ createdBy: req.user._id });
    const total = all.length;
    const done = all.filter(t => t.status === "Hoàn thành").length;
    const doing = all.filter(t => t.status === "Đang làm").length;
    const pending = all.filter(t => t.status === "Chưa bắt đầu").length;
    const paused = all.filter(t => t.status === "Tạm dừng").length;

    const categoryStats = {};
    for (const t of all) {
      if (!categoryStats[t.category]) categoryStats[t.category] = 0;
      categoryStats[t.category]++;
    }

    res.json({
      total,
      done,
      doing,
      pending,
      paused,
      completionRate: total ? ((done / total) * 100).toFixed(1) + "%" : "0%",
      categoryStats,
    });
  } catch (err) {
    res.status(500).json({ message: "Lỗi thống kê", error: err.message });
  }
};

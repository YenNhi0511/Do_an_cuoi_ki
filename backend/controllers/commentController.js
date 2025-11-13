import Comment from "../models/Comment.js";

export const addComment = async (req, res) => {
  try {
    const comment = await Comment.create({
      task: req.body.taskId,
      user: req.user._id,
      content: req.body.content,
    });
    res.json(comment);
  } catch (err) {
    res.status(400).json({ message: "Lỗi thêm bình luận", error: err.message });
  }
};

export const getComments = async (req, res) => {
  const comments = await Comment.find({ task: req.params.taskId }).populate("user", "name email");
  res.json(comments);
};

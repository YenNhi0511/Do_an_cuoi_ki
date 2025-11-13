import Group from "../models/Group.js";
import User from "../models/User.js";

export const createGroup = async (req, res) => {
  try {
    const { name } = req.body;
    const newGroup = await Group.create({
      name,
      leader: req.user.id,
      members: [req.user.id],
    });
    res.status(201).json(newGroup);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

export const getGroups = async (req, res) => {
  try {
    const groups = await Group.find({
      members: { $in: [req.user.id] },
    }).populate("members", "name email");
    res.status(200).json(groups);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

export const addMember = async (req, res) => {
  try {
    const { groupId, email } = req.body;
    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ message: "User không tồn tại" });

    const group = await Group.findById(groupId);
    if (!group) return res.status(404).json({ message: "Nhóm không tồn tại" });

    if (group.members.includes(user._id))
      return res.status(400).json({ message: "Đã có trong nhóm" });

    group.members.push(user._id);
    await group.save();
    res.status(200).json({ message: "Thêm thành viên thành công", group });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

import express from "express";
import { addComment, getComments } from "../controllers/commentController.js";
import auth from "../middleware/auth.js";

const router = express.Router();

router.post("/", auth, addComment);
router.get("/:taskId", auth, getComments);

export default router;

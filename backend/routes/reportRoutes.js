import express from "express";
import { getReport } from "../controllers/reportController.js";
import auth from "../middleware/auth.js";

const router = express.Router();

router.get("/", auth, getReport);

export default router;

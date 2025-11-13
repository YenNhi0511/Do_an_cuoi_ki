import express from "express";
import { exportExcel, exportPDF } from "../controllers/exportController.js";
import auth from "../middleware/auth.js";

const router = express.Router();
router.get("/excel", auth, exportExcel);
router.get("/pdf", auth, exportPDF);

export default router;

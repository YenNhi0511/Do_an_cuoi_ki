import ExcelJS from "exceljs";
import PDFDocument from "pdfkit";
import Task from "../models/Task.js";
import fs from "fs";
import path from "path";

export const exportExcel = async (req, res) => {
  try {
    const tasks = await Task.find({ createdBy: req.user._id });
    const workbook = new ExcelJS.Workbook();
    const sheet = workbook.addWorksheet("Tasks");

    sheet.columns = [
      { header: "Tiêu đề", key: "title", width: 30 },
      { header: "Mô tả", key: "description", width: 40 },
      { header: "Độ ưu tiên", key: "priority", width: 15 },
      { header: "Trạng thái", key: "status", width: 20 },
      { header: "Thời hạn", key: "deadline", width: 25 },
      { header: "Danh mục", key: "category", width: 20 },
    ];

    tasks.forEach((t) => sheet.addRow(t));

    const filePath = path.join("uploads", `report_${Date.now()}.xlsx`);
    await workbook.xlsx.writeFile(filePath);
    res.download(filePath);
  } catch (err) {
    res.status(500).json({ message: "Lỗi xuất Excel", error: err.message });
  }
};

export const exportPDF = async (req, res) => {
  try {
    const tasks = await Task.find({ createdBy: req.user._id });
    const filePath = path.join("uploads", `report_${Date.now()}.pdf`);
    const doc = new PDFDocument({ margin: 30 });
    doc.pipe(fs.createWriteStream(filePath));

    doc.fontSize(20).text("BÁO CÁO CÔNG VIỆC", { align: "center" });
    doc.moveDown();

    tasks.forEach((t, i) => {
      doc.fontSize(12).text(`${i + 1}. ${t.title}`);
      doc.text(`   Mô tả: ${t.description || "Không có"}`);
      doc.text(`   Ưu tiên: ${t.priority} | Trạng thái: ${t.status}`);
      doc.text(`   Deadline: ${t.deadline ? new Date(t.deadline).toLocaleString() : "Chưa có"}`);
      doc.moveDown(0.5);
    });

    doc.end();
    res.download(filePath);
  } catch (err) {
    res.status(500).json({ message: "Lỗi xuất PDF", error: err.message });
  }
};

import nodemailer from "nodemailer";

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER, // đặt trong .env
    pass: process.env.EMAIL_PASS,
  },
});

export const sendEmail = async (to, subject, text) => {
  try {
    await transporter.sendMail({ from: "Work Manager", to, subject, text });
  } catch (err) {
    console.error("Lỗi gửi email:", err.message);
  }
};

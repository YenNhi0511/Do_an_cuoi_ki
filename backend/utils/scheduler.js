import cron from "node-cron";
import Task from "../models/Task.js";
import { sendEmail } from "./emailService.js";

export const scheduleReminders = () => {
  cron.schedule("0 * * * *", async () => {
    const tasks = await Task.find({
      reminder: { $lte: new Date(Date.now() + 60 * 60 * 1000) }, // trong 1h tới
    }).populate("assignedTo", "email name");

    for (const t of tasks) {
      if (t.assignedTo?.email) {
        await sendEmail(
          t.assignedTo.email,
          `⏰ Nhắc nhở công việc: ${t.title}`,
          `Công việc "${t.title}" sẽ đến hạn vào ${t.deadline?.toLocaleString()}.`
        );
      }
    }
  });
};

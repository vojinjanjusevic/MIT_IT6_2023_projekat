import { Router } from "express";
import { protect } from "../middleware/authMiddleware.js";
import {
  deleteAllNotifications,
  deleteNotification,
  getMyNotifications,
  markNotificationRead,
} from "../controllers/notificationController.js";

const router = Router();

router.get("/", protect, getMyNotifications);
router.delete("/", protect, deleteAllNotifications);
router.post("/:id/read", protect, markNotificationRead);
router.delete("/:id", protect, deleteNotification);

export default router;

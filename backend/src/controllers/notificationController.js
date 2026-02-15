import mongoose from "mongoose";
import Notification from "../models/Notification.js";
import asyncHandler from "../utils/asyncHandler.js";

export const getMyNotifications = asyncHandler(async (req, res) => {
  const notifications = await Notification.find({ user: req.user._id })
    .populate("actor", "name email role")
    .populate("car", "title priceEur city")
    .sort({ createdAt: -1 })
    .limit(50);

  res.json({ count: notifications.length, notifications });
});

export const markNotificationRead = asyncHandler(async (req, res) => {
  const { id } = req.params;
  if (!mongoose.isValidObjectId(id)) {
    res.status(400);
    throw new Error("Invalid notification id");
  }

  const notification = await Notification.findById(id);
  if (!notification) {
    res.status(404);
    throw new Error("Notification not found");
  }

  if (notification.user.toString() !== req.user._id.toString()) {
    res.status(403);
    throw new Error("Not allowed to update this notification");
  }

  notification.read = true;
  await notification.save();

  const populated = await Notification.findById(notification._id)
    .populate("actor", "name email role")
    .populate("car", "title priceEur city");

  res.json({ notification: populated });
});

export const deleteNotification = asyncHandler(async (req, res) => {
  const { id } = req.params;
  if (!mongoose.isValidObjectId(id)) {
    res.status(400);
    throw new Error("Invalid notification id");
  }

  const notification = await Notification.findById(id);
  if (!notification) {
    res.status(404);
    throw new Error("Notification not found");
  }

  if (notification.user.toString() !== req.user._id.toString()) {
    res.status(403);
    throw new Error("Not allowed to delete this notification");
  }

  await notification.deleteOne();
  res.json({ message: "Notification deleted" });
});

export const deleteAllNotifications = asyncHandler(async (req, res) => {
  const result = await Notification.deleteMany({ user: req.user._id });
  res.json({ message: "All notifications deleted", deletedCount: result.deletedCount });
});

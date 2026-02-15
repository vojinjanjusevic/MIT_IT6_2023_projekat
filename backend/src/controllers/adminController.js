import mongoose from "mongoose";
import User from "../models/User.js";
import Car from "../models/Car.js";
import asyncHandler from "../utils/asyncHandler.js";

const sanitizeUser = (user) => ({
  id: user._id,
  name: user.name,
  email: user.email,
  role: user.role,
  createdAt: user.createdAt,
  updatedAt: user.updatedAt,
});

export const getUsers = asyncHandler(async (req, res) => {
  const users = await User.find().select("-password").sort({ createdAt: -1 });
  res.json({ count: users.length, users: users.map(sanitizeUser) });
});

export const deleteUser = asyncHandler(async (req, res) => {
  const { id } = req.params;

  if (!mongoose.isValidObjectId(id)) {
    res.status(400);
    throw new Error("Invalid user id");
  }

  if (req.user._id.toString() === id) {
    res.status(409);
    throw new Error("Admin cannot delete own account");
  }

  const user = await User.findById(id);
  if (!user) {
    res.status(404);
    throw new Error("User not found");
  }

  const deletedCarsResult = await Car.deleteMany({ owner: user._id });
  await Car.updateMany(
    { reservedBy: user._id },
    {
      $set: {
        reserved: false,
        reservedBy: null,
        reservedAt: null,
        reservationStatus: "none",
        reservationRequestedAt: null,
        reservationNote: {
          message: "",
          contactPhone: "",
          preferredTime: "",
        },
      },
    }
  );

  await user.deleteOne();

  res.json({
    message: "User deleted",
    deletedUser: sanitizeUser(user),
    deletedListingsCount: deletedCarsResult.deletedCount ?? 0,
  });
});

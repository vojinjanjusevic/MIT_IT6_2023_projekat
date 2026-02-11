import { Router } from "express";
import {
  createCar,
  deleteCar,
  getCarById,
  getCars,
  getMyCars,
  updateCar,
} from "../controllers/carController.js";
import { protect } from "../middleware/authMiddleware.js";

const router = Router();

router.get("/", getCars);
router.get("/my", protect, getMyCars);
router.get("/:id", getCarById);
router.post("/", protect, createCar);
router.put("/:id", protect, updateCar);
router.delete("/:id", protect, deleteCar);

export default router;

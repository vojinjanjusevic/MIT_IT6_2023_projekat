import { Router } from "express";
import authRoutes from "./authRoutes.js";
import carRoutes from "./carRoutes.js";
import adminRoutes from "./adminRoutes.js";
import notificationRoutes from "./notificationRoutes.js";

const router = Router();

router.get("/health", (req, res) => {
  res.json({ ok: true, service: "cardealer-backend" });
});

router.use("/auth", authRoutes);
router.use("/cars", carRoutes);
router.use("/admin", adminRoutes);
router.use("/notifications", notificationRoutes);

export default router;

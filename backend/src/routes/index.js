import { Router } from "express";
import authRoutes from "./authRoutes.js";
import carRoutes from "./carRoutes.js";

const router = Router();

router.get("/health", (req, res) => {
  res.json({ ok: true, service: "cardealer-backend" });
});

router.use("/auth", authRoutes);
router.use("/cars", carRoutes);

export default router;

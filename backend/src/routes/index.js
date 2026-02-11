import { Router } from "express";
import authRoutes from "./authRoutes.js";

const router = Router();

router.get("/health", (req, res) => {
  res.json({ ok: true, service: "cardealer-backend" });
});

router.use("/auth", authRoutes);

export default router;

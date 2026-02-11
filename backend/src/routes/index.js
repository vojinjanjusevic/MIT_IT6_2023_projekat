import { Router } from "express";

const router = Router();

router.get("/health", (req, res) => {
  res.json({ ok: true, service: "cardealer-backend" });
});

export default router;

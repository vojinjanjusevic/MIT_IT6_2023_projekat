import { Router } from "express";
import { deleteUser, getUsers } from "../controllers/adminController.js";
import { adminOnly, protect } from "../middleware/authMiddleware.js";

const router = Router();

router.use(protect, adminOnly);

router.get("/users", getUsers);
router.delete("/users/:id", deleteUser);

export default router;

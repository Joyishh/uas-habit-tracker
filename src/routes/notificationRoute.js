import express from "express";
import { registerDeviceToken } from "../controller/notificationController.js";
import verifyToken from "../middlewares/authMiddlewares.js";

const router = express.Router();

router.post("/register-fcm-token", verifyToken, registerDeviceToken);

export default router;

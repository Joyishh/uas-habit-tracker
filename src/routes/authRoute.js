import express from 'express';
import { registerUser, loginUser, logoutUser } from '../controller/authController.js';
import verifyToken from '../middlewares/authMiddlewares.js';

const router = express.Router();

router.post('/register', registerUser);
router.post('/login', loginUser);
router.post('/logout', verifyToken, logoutUser);

export default router;
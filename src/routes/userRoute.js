import express from 'express';
import { getAllUser, getUserById } from '../controller/userController.js';

const router = express.Router();

router.get('/', getAllUser);
router.get('/:id', getUserById);

export default router;
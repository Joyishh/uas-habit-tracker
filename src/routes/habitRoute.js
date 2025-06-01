import express from 'express';
import { getAllHabit, getHabitById, createHabit, updateHabit, deleteHabit, habitCheckIn, getHabitEntries, getMontlyHabitEntries } from '../controller/habitController.js';
import verifyToken from '../middlewares/authMiddlewares.js';

const router = express.Router();

router.get('/', verifyToken, getAllHabit);
router.get('/entries', verifyToken, getMontlyHabitEntries);
router.get('/:id', verifyToken, getHabitById);
router.post('/', verifyToken, createHabit);
router.put('/:id', verifyToken, updateHabit);
router.delete('/:id', verifyToken, deleteHabit);
router.post('/:id/check-in', verifyToken, habitCheckIn);
router.get('/:id/entries' , verifyToken, getHabitEntries);


export default router;
import express from 'express';
import { monthOverview, dayDetails } from '../controller/calendarController.js';
import verifyToken from '../middlewares/authMiddlewares.js';

const router = express.Router();

router.get('/month-overview', verifyToken, monthOverview);
router.get('/day-details', verifyToken, dayDetails);

export default router;

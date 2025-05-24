import express from 'express';
import { getCompletionRates, getPieChartStats } from '../controller/statisticsController.js';
import verifyToken from '../middlewares/authMiddlewares.js';

const router = express.Router();

router.get('/pie-chart-rates', verifyToken, getPieChartStats);
router.get('/completion-rates', verifyToken, getCompletionRates);

export default router;

import { Router } from 'express';
import { createFeedback, getFeedback } from '../controllers/feedback.controller.js';
import { protect } from '../middlewares/auth.js';

const router = Router();

router.post('/feedback', protect, createFeedback);
router.get('/feedback', protect, getFeedback);

export default router;

import { Router } from 'express';
import { getMe } from '../controllers/user.controller.js';
import { protect } from '../middlewares/auth.js';

const router = Router();

router.get('/users/me', protect, getMe);

export default router;

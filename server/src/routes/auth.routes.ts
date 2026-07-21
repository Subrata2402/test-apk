import { Router } from 'express';
import { googleLogin, logout } from '../controllers/auth.controller.js';
import { protect } from '../middlewares/auth.js';

const router = Router();

router.post('/auth/google', googleLogin);
router.post('/auth/logout', protect, logout);

export default router;

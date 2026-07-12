import { Router } from 'express';
import { googleLogin, logout } from '../controllers/auth.controller.js';

const router = Router();

router.post('/auth/google', googleLogin);
router.post('/auth/logout', logout);

export default router;

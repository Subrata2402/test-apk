import { Router } from 'express';
import { getMe, configureDrive } from '../controllers/user.controller.js';
import { protect } from '../middlewares/auth.js';

const router = Router();

router.get('/users/me', protect, getMe);
router.post('/users/configure-drive', protect, configureDrive);

export default router;

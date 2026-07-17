import { Router } from 'express';
import {
  generateDeviceCode,
  authorizeDeviceCode,
  pollDeviceToken,
} from '../controllers/device-auth.controller.js';
import { protect } from '../middlewares/auth.js';

const router = Router();

router.post('/code', generateDeviceCode);
router.post('/authorize', protect, authorizeDeviceCode);
router.post('/token', pollDeviceToken);

export default router;

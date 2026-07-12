import { Router } from 'express';
import multer from 'multer';
import {
  createApp,
  getApps,
  uploadApk,
  downloadApk,
  deleteRelease,
  inviteMember,
  removeMember,
  getInvitations,
  acceptInvitation,
  rejectInvitation,
} from '../controllers/app.controller.js';
import { protect } from '../middlewares/auth.js';

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 150 * 1024 * 1024, // 150MB limit
  },
});

const router = Router();

router.post('/apps', protect, createApp);
router.get('/apps', protect, getApps);
router.get('/apps/invitations', protect, getInvitations);
router.post('/apps/:appId/invitations/accept', protect, acceptInvitation);
router.post('/apps/:appId/invitations/reject', protect, rejectInvitation);
router.post('/apps/:appId/members', protect, inviteMember);
router.delete('/apps/:appId/members/:email', protect, removeMember);
router.post('/apps/:appId/releases', protect, upload.single('file'), uploadApk);
router.get('/apps/:appId/releases/:buildNumber/download', protect, downloadApk);
router.delete('/apps/:appId/releases/:buildNumber', protect, deleteRelease);

export default router;

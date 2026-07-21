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
  getReleases,
  getMembers,
} from '../controllers/app.controller.js';
import { protect } from '../middlewares/auth.js';

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 200 * 1024 * 1024, // 200MB limit
  },
});

const router = Router();

router.post('/apps', protect, createApp);
router.get('/apps', protect, getApps);
router.get('/apps/invitations', protect, getInvitations);
router.post('/apps/:appId/invitations/accept', protect, acceptInvitation);
router.post('/apps/:appId/invitations/reject', protect, rejectInvitation);
router.get('/apps/:appId/members', protect, getMembers);
router.post('/apps/:appId/members', protect, inviteMember);
router.delete('/apps/:appId/members/:email', protect, removeMember);
router.get('/apps/:appId/releases', protect, getReleases);
router.post('/apps/:appId/releases', protect, upload.single('file'), uploadApk);
router.get('/apps/:appId/releases/:buildNumber/download', protect, downloadApk);
router.delete('/apps/:appId/releases/:buildNumber', protect, deleteRelease);

export default router;

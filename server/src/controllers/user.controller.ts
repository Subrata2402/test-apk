import { Request, Response, NextFunction } from 'express';
import { google } from 'googleapis';
import { env } from '../config/env.js';
import { User } from '../models/user.model.js';
import { createFolderInDrive } from '../services/google-drive.service.js';

export const getMe = (req: Request, res: Response, next: NextFunction): void => {
  if (!req.user) {
    res.status(401).json({
      status: 'fail',
      message: 'User not authenticated',
    });
    return;
  }

  res.status(200).json({
    status: 'success',
    data: {
      user: {
        id: req.user._id,
        email: req.user.email,
        name: req.user.name,
        picture: req.user.picture,
        role: req.user.role,
        isDriveConfigured: !!req.user.googleRefreshToken,
      },
    },
  });
};

export const configureDrive = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { code } = req.body;

    if (!code) {
      res.status(400).json({
        status: 'fail',
        message: 'Authorization code is required',
      });
      return;
    }

    if (!req.user) {
      res.status(401).json({
        status: 'fail',
        message: 'User not authenticated',
      });
      return;
    }

    // Exchange code for tokens
    const oauth2Client = new google.auth.OAuth2(
      env.GOOGLE_CLIENT_ID,
      env.GOOGLE_CLIENT_SECRET,
      'postmessage' // Must match the redirect URI used by the frontend popup
    );

    const { tokens } = await oauth2Client.getToken(code);
    const refreshToken = tokens.refresh_token;

    if (!refreshToken) {
      res.status(400).json({
        status: 'fail',
        message: 'Failed to obtain refresh token. Please ensure you grant offline access and consent.',
      });
      return;
    }

    // Create a folder in the user's Google Drive
    const folderId = await createFolderInDrive('TestAPK_Releases', refreshToken);

    // Save credentials to user document
    const user = await User.findById(req.user._id);
    if (!user) {
      res.status(404).json({
        status: 'fail',
        message: 'User not found',
      });
      return;
    }

    user.googleRefreshToken = refreshToken;
    user.googleDriveFolderId = folderId;
    await user.save();

    res.status(200).json({
      status: 'success',
      message: 'Google Drive configured successfully',
      data: {
        isDriveConfigured: true,
      },
    });
  } catch (error) {
    next(error);
  }
};

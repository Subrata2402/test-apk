import { Request, Response, NextFunction } from 'express';
import crypto from 'crypto';
import jwt from 'jsonwebtoken';
import { DeviceCode } from '../models/device-code.model.js';
import { User } from '../models/user.model.js';
import { env } from '../config/env.js';

const generateUserCode = (): string => {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let code = '';
  for (let i = 0; i < 8; i++) {
    if (i === 4) code += '-';
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return code;
};

export const generateDeviceCode = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const deviceCode = crypto.randomUUID();
    const userCode = generateUserCode();
    const urlToken = crypto.randomUUID(); // separate short-lived URL access token
    const expiresIn = 300; // 5 minutes
    const expiresAt = new Date(Date.now() + expiresIn * 1000);

    await DeviceCode.create({
      deviceCode,
      userCode,
      urlToken,
      expiresAt,
    });

    // Use request origin or default to localhost
    const origin = req.headers.origin || 'http://localhost:5173';
    // The urlToken gates access to the /device page; user code is typed manually
    const verificationUri = `${origin}/device?token=${urlToken}`;

    res.status(200).json({
      status: 'success',
      data: {
        deviceCode,
        userCode,
        verificationUri,
        expiresIn,
      },
    });
  } catch (error) {
    next(error);
  }
};

// Validates the URL token embedded in the verification link.
// No auth required — this is a public page-access check.
export const checkUrlToken = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { token } = req.query;

    if (!token || typeof token !== 'string') {
      res.status(400).json({ status: 'fail', code: 'missing', message: 'Token is required' });
      return;
    }

    const doc = await DeviceCode.findOne({ urlToken: token });

    if (!doc) {
      // Token never existed or already cleaned up
      res.status(404).json({ status: 'fail', code: 'not_found', message: 'Invalid or already used token' });
      return;
    }

    if (doc.expiresAt < new Date()) {
      res.status(410).json({ status: 'fail', code: 'expired', message: 'This authorization link has expired' });
      return;
    }

    if (doc.isAuthorized) {
      // Already authorized — treat as used
      res.status(410).json({ status: 'fail', code: 'used', message: 'This link has already been used' });
      return;
    }

    res.status(200).json({ status: 'success', code: 'valid' });
  } catch (error) {
    next(error);
  }
};



export const authorizeDeviceCode = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { userCode } = req.body;

    if (!userCode) {
      res.status(400).json({
        status: 'fail',
        message: 'User code is required',
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

    // Normalize user code (uppercase, trim, ensure hyphen)
    let normalizedCode = userCode.trim().toUpperCase();
    if (normalizedCode.length === 8 && !normalizedCode.includes('-')) {
      normalizedCode = `${normalizedCode.slice(0, 4)}-${normalizedCode.slice(4)}`;
    }

    const deviceCodeDoc = await DeviceCode.findOne({
      userCode: normalizedCode,
    });

    if (!deviceCodeDoc) {
      res.status(404).json({
        status: 'fail',
        code: 'invalid_code',
        message: 'Invalid authorization code. Please check the code and try again.',
      });
      return;
    }

    if (deviceCodeDoc.expiresAt < new Date()) {
      res.status(410).json({
        status: 'fail',
        code: 'expired_code',
        message: 'This authorization code has expired. Please generate a new one.',
      });
      return;
    }

    deviceCodeDoc.userId = req.user._id as any;
    deviceCodeDoc.isAuthorized = true;
    await deviceCodeDoc.save();

    res.status(200).json({
      status: 'success',
      message: 'Device successfully authorized',
    });
  } catch (error) {
    next(error);
  }
};

export const pollDeviceToken = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { deviceCode } = req.body;

    if (!deviceCode) {
      res.status(400).json({
        status: 'fail',
        message: 'Device code is required',
      });
      return;
    }

    const deviceCodeDoc = await DeviceCode.findOne({
      deviceCode,
    });

    if (!deviceCodeDoc || deviceCodeDoc.expiresAt < new Date()) {
      res.status(400).json({
        error: 'expired_token',
        message: 'The device code has expired. Please request a new one.',
      });
      return;
    }

    if (!deviceCodeDoc.isAuthorized) {
      res.status(400).json({
        error: 'authorization_pending',
        message: 'The user has not yet authorized the device.',
      });
      return;
    }

    // Generate token
    const token = jwt.sign({ id: deviceCodeDoc.userId }, env.JWT_SECRET, {
      expiresIn: env.JWT_EXPIRES_IN as any,
    });

    const user = await User.findById(deviceCodeDoc.userId);
    if (!user) {
      res.status(404).json({
        status: 'fail',
        message: 'User not found',
      });
      return;
    }

    // Delete the device code so it cannot be reused
    await DeviceCode.deleteOne({ _id: deviceCodeDoc._id });

    res.status(200).json({
      status: 'success',
      token,
      data: {
        user: {
          name: user.name,
          email: user.email,
          role: user.role,
          isDriveConfigured: !!(user.googleRefreshToken && user.googleDriveFolderId),
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

import { Request, Response, NextFunction } from 'express';
import { App } from '../models/app.model.js';
import { User } from '../models/user.model.js';
import { Release } from '../models/release.model.js';

const populateMemberNames = async (apps: any[]): Promise<any[]> => {
  const emails = apps.flatMap(app => app.members.map((m: any) => m.email.toLowerCase()));
  const users = await User.find({ email: { $in: emails } });
  const userMap = new Map(users.map(u => [u.email.toLowerCase(), u.name]));

  return apps.map(app => {
    const appObj = app.toObject ? app.toObject() : app;
    appObj.members = appObj.members.map((m: any) => ({
      ...m,
      name: userMap.get(m.email.toLowerCase()) || m.email.split('@')[0],
    }));
    return appObj;
  });
};

const getOwnerCredentials = async (app: any) => {
  const ownerMember = app.members.find((m: any) => m.role === 'Owner');
  if (ownerMember) {
    const ownerUser = await User.findOne({ email: ownerMember.email.toLowerCase() });
    if (ownerUser && ownerUser.googleRefreshToken && ownerUser.googleDriveFolderId) {
      return {
        refreshToken: ownerUser.googleRefreshToken,
        folderId: ownerUser.googleDriveFolderId,
      };
    }
  }
  return undefined;
};

export const createApp = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { name, packageName, description } = req.body;

    if (!name || !packageName || !description) {
      res.status(400).json({
        status: 'fail',
        message: 'Application name, package name, and description are required',
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

    // Check if package name already exists
    const existingApp = await App.findOne({ packageName });
    if (existingApp) {
      res.status(400).json({
        status: 'fail',
        message: 'An application with this package name already exists',
      });
      return;
    }

    const newApp = await App.create({
      name,
      packageName,
      description,
      members: [
        {
          email: req.user.email,
          role: 'Owner',
          status: 'Accepted',
        },
      ],
    });

    await newApp.populate('releases');

    res.status(201).json({
      status: 'success',
      data: {
        app: (await populateMemberNames([newApp]))[0],
      },
    });
  } catch (error) {
    next(error);
  }
};

export const getApps = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    if (!req.user) {
      res.status(401).json({
        status: 'fail',
        message: 'User not authenticated',
      });
      return;
    }

    // Get apps where the user is a member and has accepted the invitation
    const apps = await App.find(
      {
        members: {
          $elemMatch: {
            email: req.user.email,
            status: 'Accepted',
          },
        },
      },
      { members: 0 }
    ).populate({
      path: 'releases',
      options: { limit: 1, sort: { buildNumber: -1 } },
    }).populate('releasesCount');

    res.status(200).json({
      status: 'success',
      results: apps.length,
      data: {
        apps,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const uploadApk = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { appId } = req.params;
    const { releaseNotes } = req.body;

    if (!req.file) {
      res.status(400).json({
        status: 'fail',
        message: 'Please upload an APK file',
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

    const app = await App.findById(appId);
    if (!app) {
      res.status(404).json({
        status: 'fail',
        message: 'Application not found',
      });
      return;
    }

    // Verify role (Owner or Developer only)
    const member = app.members.find(m => m.email.toLowerCase() === req.user!.email.toLowerCase());
    if (!member || (member.role !== 'Owner' && member.role !== 'Developer')) {
      res.status(403).json({
        status: 'fail',
        message: 'Only Owners and Developers are allowed to upload APKs',
      });
      return;
    }

    // Parse APK
    let parsed;
    try {
      const { parseApk } = await import('../services/apk.service.js');
      parsed = await parseApk(req.file.buffer);
    } catch (err) {
      res.status(400).json({
        status: 'fail',
        message: 'Failed to parse APK file. Make sure it is a valid Android package.',
      });
      return;
    }

    // Verify package name matches
    if (parsed.packageName !== app.packageName) {
      res.status(400).json({
        status: 'fail',
        message: `Package name mismatch. Expected: ${app.packageName}, Found: ${parsed.packageName}`,
      });
      return;
    }

    // Check if build number already exists
    const buildExists = await Release.findOne({ appId: app._id, buildNumber: parsed.versionCode });
    if (buildExists) {
      res.status(400).json({
        status: 'fail',
        message: `A release with build number #${parsed.versionCode} already exists`,
      });
      return;
    }

    // Check if build number is greater than the latest build number
    const latestRelease = await Release.findOne({ appId: app._id }).sort({ buildNumber: -1 });
    if (latestRelease) {
      if (parsed.versionCode <= latestRelease.buildNumber) {
        res.status(400).json({
          status: 'fail',
          message: `Build number #${parsed.versionCode} cannot be used because the latest published build number is #${latestRelease.buildNumber}. Please increment the build number and try again.`,
        });
        return;
      }
    }

    // Upload to Google Drive
    let driveFileId;
    try {
      const credentials = await getOwnerCredentials(app);
      if (!credentials) {
        res.status(400).json({
          status: 'fail',
          message: 'Google Drive is not configured for the owner of this application.',
        });
        return;
      }
      const { uploadFileToDrive } = await import('../services/google-drive.service.js');
      const fileName = `${app.name.replace(/\s+/g, '_')}_v${parsed.versionName}_b${parsed.versionCode}.apk`;
      driveFileId = await uploadFileToDrive(fileName, req.file.buffer, req.file.mimetype, credentials);
    } catch (err: any) {
      const errMsg = err.message || String(err);
      if (errMsg.includes('invalid_grant')) {
        res.status(400).json({
          status: 'fail',
          message: 'Google Drive access has been revoked or is invalid. Please re-configure Google Drive in your application settings.',
        });
      } else {
        res.status(500).json({
          status: 'error',
          message: `Failed to upload APK to Google Drive: ${errMsg}`,
        });
      }
      return;
    }

    // Check if this is the first release
    const releaseCount = await Release.countDocuments({ appId: app._id });
    const isFirstRelease = releaseCount === 0;

    // Save release to DB
    const newRelease = await Release.create({
      appId: app._id,
      version: parsed.versionName,
      buildNumber: parsed.versionCode,
      releaseNotes: releaseNotes || 'No release notes provided',
      date: new Date().toISOString(),
      size: `${(req.file.size / (1024 * 1024)).toFixed(1)} MB`,
      apkUrl: driveFileId,
      appName: parsed.appName,
      minSdkVersion: parsed.minSdkVersion,
      targetSdkVersion: parsed.targetSdkVersion,
      sha256: parsed.sha256,
      permissions: parsed.permissions,
      appIcon: parsed.appIcon,
      uploadedByEmail: req.user.email,
      uploadedByName: req.user.name,
    });

    if (isFirstRelease && parsed.appIcon) {
      app.icon = parsed.appIcon;
      await app.save();
    }

    await app.populate('releases');

    // Send push notification to other accepted members
    try {
      const otherMembersEmails = app.members
        .filter(m => m.status === 'Accepted' && m.email.toLowerCase() !== req.user!.email.toLowerCase())
        .map(m => m.email.toLowerCase());

      if (otherMembersEmails.length > 0) {
        const users = await User.find({ email: { $in: otherMembersEmails } });
        const tokens = users.flatMap(u => u.fcmTokens || []);
        if (tokens.length > 0) {
          const { sendPushNotificationToMultiple } = await import('../services/notification.service.js');
          await sendPushNotificationToMultiple(tokens, {
            title: `New Release for ${app.name}`,
            body: `Version ${newRelease.version} (Build #${newRelease.buildNumber}) is now available.`,
            data: {
              appId: app._id.toString(),
              buildNumber: newRelease.buildNumber.toString(),
              type: 'new_release',
            },
          });
        }
      }
    } catch (err) {
      console.error('Failed to send new release push notifications:', err);
    }

    res.status(201).json({
      status: 'success',
      data: {
        release: newRelease,
        app: (await populateMemberNames([app]))[0],
      },
    });
  } catch (error) {
    next(error);
  }
};

export const downloadApk = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { appId, buildNumber } = req.params;

    if (!req.user) {
      res.status(401).json({
        status: 'fail',
        message: 'User not authenticated',
      });
      return;
    }

    const app = await App.findById(appId);
    if (!app) {
      res.status(404).json({
        status: 'fail',
        message: 'Application not found',
      });
      return;
    }

    // Verify role (Owner, Developer, or Tester)
    const isMember = app.members.some(m => m.email.toLowerCase() === req.user!.email.toLowerCase());
    if (!isMember) {
      res.status(403).json({
        status: 'fail',
        message: 'You are not a member of this application',
      });
      return;
    }

    // Find release
    const release = await Release.findOne({ appId: app._id, buildNumber: parseInt(buildNumber as string) });
    if (!release) {
      res.status(404).json({
        status: 'fail',
        message: 'Release not found',
      });
      return;
    }

    // Get file stream from Google Drive
    const { getFileStreamFromDrive } = await import('../services/google-drive.service.js');
    
    let fileData;
    try {
      const credentials = await getOwnerCredentials(app);
      if (!credentials) {
        res.status(400).json({
          status: 'fail',
          message: 'Google Drive is not configured for the owner of this application.',
        });
        return;
      }
      fileData = await getFileStreamFromDrive(release.apkUrl, credentials);
    } catch (err: any) {
      if (err.code === 404 || err.status === 404 || (err.message && err.message.includes('File not found'))) {
        res.status(404).json({
          status: 'fail',
          message: 'The APK file was not found on Google Drive. It may have been deleted.',
        });
        return;
      }
      throw err;
    }

    const { stream, contentLength } = fileData;

    res.setHeader('Content-Type', 'application/vnd.android.package-archive');
    res.setHeader(
      'Content-Disposition',
      `attachment; filename="${app.name.replace(/\s+/g, '_')}_v${release.version}.apk"`
    );
    if (contentLength) {
      res.setHeader('Content-Length', contentLength);
    }

    stream.pipe(res);
  } catch (error) {
    next(error);
  }
};

export const deleteRelease = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { appId, buildNumber } = req.params;

    if (!req.user) {
      res.status(401).json({
        status: 'fail',
        message: 'User not authenticated',
      });
      return;
    }

    const app = await App.findById(appId);
    if (!app) {
      res.status(404).json({
        status: 'fail',
        message: 'Application not found',
      });
      return;
    }

    // Verify role (Owner or Developer only)
    const member = app.members.find(m => m.email.toLowerCase() === req.user!.email.toLowerCase());
    if (!member || (member.role !== 'Owner' && member.role !== 'Developer')) {
      res.status(403).json({
        status: 'fail',
        message: 'Only Owners and Developers are allowed to delete releases',
      });
      return;
    }

    // Find release
    const release = await Release.findOne({ appId: app._id, buildNumber: parseInt(buildNumber as string) });
    if (!release) {
      res.status(404).json({
        status: 'fail',
        message: 'Release not found',
      });
      return;
    }

    // Delete file from Google Drive
    try {
      const credentials = await getOwnerCredentials(app);
      if (!credentials) {
        res.status(400).json({
          status: 'fail',
          message: 'Google Drive is not configured for the owner of this application.',
        });
        return;
      }
      const { deleteFileFromDrive } = await import('../services/google-drive.service.js');
      await deleteFileFromDrive(release.apkUrl, credentials);
    } catch (err: any) {
      console.error(`Failed to delete file from Google Drive: ${err.message || err}`);
    }

    // Remove release from DB
    await Release.deleteOne({ _id: release._id });
    await app.populate('releases');

    res.status(200).json({
      status: 'success',
      data: {
        app: (await populateMemberNames([app]))[0],
      },
    });
  } catch (error) {
    next(error);
  }
};

export const inviteMember = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { appId } = req.params;
    const { email, role } = req.body;

    if (!email || !role) {
      res.status(400).json({
        status: 'fail',
        message: 'Email and role are required',
      });
      return;
    }

    const app = await App.findById(appId);
    if (!app) {
      res.status(404).json({
        status: 'fail',
        message: 'Application not found',
      });
      return;
    }

    // Check if requester is Owner or Developer
    const requester = app.members.find(m => m.email.toLowerCase() === req.user!.email.toLowerCase());
    if (!requester || (requester.role !== 'Owner' && requester.role !== 'Developer')) {
      res.status(403).json({
        status: 'fail',
        message: 'Only Owners and Developers can invite members',
      });
      return;
    }

    // Check if invited user is the requester
    if (email.toLowerCase() === req.user!.email.toLowerCase()) {
      res.status(400).json({
        status: 'fail',
        message: 'You cannot invite yourself',
      });
      return;
    }

    // Check if invited user is registered
    const invitedUser = await User.findOne({ email: email.toLowerCase() });
    if (!invitedUser) {
      res.status(400).json({
        status: 'fail',
        message: 'User is not registered. Only registered users can be invited.',
      });
      return;
    }

    // Check if already a member
    const existingMember = app.members.find(m => m.email.toLowerCase() === email.toLowerCase());
    if (existingMember) {
      res.status(400).json({
        status: 'fail',
        message: 'User is already a member or has a pending invitation',
      });
      return;
    }

    app.members.push({
      email,
      role,
      status: 'Pending',
    });

    await app.save();
    await app.populate('releases');

    // Send push notification to the invited user
    try {
      const invitedUser = await User.findOne({ email: email.toLowerCase() });
      if (invitedUser && invitedUser.fcmTokens && invitedUser.fcmTokens.length > 0) {
        const { sendPushNotificationToMultiple } = await import('../services/notification.service.js');
        await sendPushNotificationToMultiple(invitedUser.fcmTokens, {
          title: `Invitation to join ${app.name}`,
          body: `You have been invited to join ${app.name} as a ${role}.`,
          data: {
            appId: app._id.toString(),
            type: 'invitation',
          },
        });
      }
    } catch (err) {
      console.error('Failed to send invitation push notification:', err);
    }

    res.status(200).json({
      status: 'success',
      data: {
        app: (await populateMemberNames([app]))[0],
      },
    });
  } catch (error) {
    next(error);
  }
};

export const removeMember = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { appId, email } = req.params;

    const app = await App.findById(appId);
    if (!app) {
      res.status(404).json({
        status: 'fail',
        message: 'Application not found',
      });
      return;
    }

    // Check if requester is Owner or Developer
    const requester = app.members.find(m => m.email.toLowerCase() === req.user!.email.toLowerCase());
    if (!requester || (requester.role !== 'Owner' && requester.role !== 'Developer')) {
      res.status(403).json({
        status: 'fail',
        message: 'Only Owners and Developers can remove members',
      });
      return;
    }

    const emailStr = email as string;

    // Cannot remove the owner
    const memberToRemove = app.members.find(m => m.email.toLowerCase() === emailStr.toLowerCase());
    if (memberToRemove && memberToRemove.role === 'Owner') {
      res.status(400).json({
        status: 'fail',
        message: 'Cannot remove the application owner',
      });
      return;
    }

    app.members = app.members.filter(m => m.email.toLowerCase() !== emailStr.toLowerCase());
    await app.save();
    await app.populate('releases');

    res.status(200).json({
      status: 'success',
      data: {
        app: (await populateMemberNames([app]))[0],
      },
    });
  } catch (error) {
    next(error);
  }
};

export const getInvitations = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    if (!req.user) {
      res.status(401).json({
        status: 'fail',
        message: 'User not authenticated',
      });
      return;
    }

    const apps = await App.find(
      {
        members: {
          $elemMatch: {
            email: req.user.email,
            status: 'Pending',
          },
        },
      },
      { members: 0 }
    ).populate({
      path: 'releases',
      options: { limit: 1, sort: { buildNumber: -1 } },
    }).populate('releasesCount');

    res.status(200).json({
      status: 'success',
      results: apps.length,
      data: {
        apps,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const acceptInvitation = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { appId } = req.params;

    const app = await App.findById(appId);
    if (!app) {
      res.status(404).json({
        status: 'fail',
        message: 'Application not found',
      });
      return;
    }

    const member = app.members.find(m => m.email.toLowerCase() === req.user!.email.toLowerCase());
    if (!member) {
      res.status(404).json({
        status: 'fail',
        message: 'Invitation not found',
      });
      return;
    }

    member.status = 'Accepted';
    await app.save();
    await app.populate('releases');

    res.status(200).json({
      status: 'success',
      data: {
        app: (await populateMemberNames([app]))[0],
      },
    });
  } catch (error) {
    next(error);
  }
};

export const rejectInvitation = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { appId } = req.params;

    const app = await App.findById(appId);
    if (!app) {
      res.status(404).json({
        status: 'fail',
        message: 'Application not found',
      });
      return;
    }

    app.members = app.members.filter(m => m.email.toLowerCase() !== req.user!.email.toLowerCase());
    await app.save();
    await app.populate('releases');

    res.status(200).json({
      status: 'success',
      message: 'Invitation rejected successfully',
    });
  } catch (error) {
    next(error);
  }
};

export const getReleases = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { appId } = req.params;

    if (!req.user) {
      res.status(401).json({
        status: 'fail',
        message: 'User not authenticated',
      });
      return;
    }

    const app = await App.findById(appId);
    if (!app) {
      res.status(404).json({
        status: 'fail',
        message: 'Application not found',
      });
      return;
    }

    // Verify role (Owner, Developer, or Tester)
    const isMember = app.members.some(m => m.email.toLowerCase() === req.user!.email.toLowerCase());
    if (!isMember) {
      res.status(403).json({
        status: 'fail',
        message: 'You are not a member of this application',
      });
      return;
    }

    const releases = await Release.find({ appId }).sort({ buildNumber: -1 });

    res.status(200).json({
      status: 'success',
      results: releases.length,
      data: {
        releases,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const getMembers = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { appId } = req.params;

    if (!req.user) {
      res.status(401).json({
        status: 'fail',
        message: 'User not authenticated',
      });
      return;
    }

    const app = await App.findById(appId);
    if (!app) {
      res.status(404).json({
        status: 'fail',
        message: 'Application not found',
      });
      return;
    }

    // Verify role (Owner, Developer, or Tester)
    const isMember = app.members.some(m => m.email.toLowerCase() === req.user!.email.toLowerCase());
    if (!isMember) {
      res.status(403).json({
        status: 'fail',
        message: 'You are not a member of this application',
      });
      return;
    }

    const populatedApps = await populateMemberNames([app]);
    const members = populatedApps[0].members;

    res.status(200).json({
      status: 'success',
      results: members.length,
      data: {
        members,
      },
    });
  } catch (error) {
    next(error);
  }
};

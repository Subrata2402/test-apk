import { User } from '../models/user.model.js';
import { logger } from '../config/logger.js';

export const migrateEncryption = async (): Promise<void> => {
  try {
    const users = await User.find({
      $or: [
        { googleRefreshToken: { $exists: true, $ne: '' } },
        { googleDriveFolderId: { $exists: true, $ne: '' } }
      ]
    });

    let migratedCount = 0;

    for (const user of users) {
      let needsMigration = false;

      // Bypass Mongoose getters to check the raw value stored in DB
      const rawUser = user.toObject({ getters: false });

      const isEncrypted = (val?: string): boolean => {
        if (!val) return true;
        const parts = val.split(':');
        return parts.length === 2 && parts[0].length === 32 && /^[0-9a-fA-F]+$/.test(parts[0]);
      };

      if (rawUser.googleRefreshToken && !isEncrypted(rawUser.googleRefreshToken)) {
        // Assigning triggers the setter (encrypt) using the value returned by the getter (decrypt/as-is)
        user.googleRefreshToken = user.googleRefreshToken;
        needsMigration = true;
      }

      if (rawUser.googleDriveFolderId && !isEncrypted(rawUser.googleDriveFolderId)) {
        user.googleDriveFolderId = user.googleDriveFolderId;
        needsMigration = true;
      }

      if (needsMigration) {
        await user.save();
        migratedCount++;
      }
    }

    if (migratedCount > 0) {
      logger.info(`🔐 Successfully migrated ${migratedCount} users to encrypted Google Drive credentials.`);
    }
  } catch (error) {
    logger.error('❌ Failed to migrate encryption:', error);
  }
};

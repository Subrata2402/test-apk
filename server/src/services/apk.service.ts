import AppInfoParser from 'app-info-parser';
import crypto from 'crypto';
import { promises as fs } from 'fs';
import path from 'path';
import os from 'os';

export interface IApkMetadata {
  packageName: string;
  versionName: string;
  versionCode: number;
  appName: string;
  minSdkVersion: string;
  targetSdkVersion: string;
  sha256: string;
  permissions: string[];
  appIcon: string;
}

export const parseApk = async (fileBuffer: Buffer): Promise<IApkMetadata> => {
  // Calculate SHA-256 hash
  const sha256 = crypto.createHash('sha256').update(fileBuffer).digest('hex').toUpperCase();
  const sha256Formatted = sha256.match(/.{1,2}/g)?.join(':') || sha256;

  const tempPath = path.join(os.tmpdir(), `temp-${Date.now()}-${Math.random().toString(36).substring(7)}.apk`);

  try {
    await fs.writeFile(tempPath, fileBuffer);

    const parser = new AppInfoParser(tempPath);
    const result = await parser.parse();

    // Extract permissions
    const permissions = result.usesPermission
      ? result.usesPermission.map((p: any) => p.name.split('.').pop())
      : [];

    let appName = result.application?.label || 'Unknown App';
    if (Array.isArray(appName)) {
      appName = appName[0] || 'Unknown App';
    }

    return {
      packageName: result.package,
      versionName: result.versionName,
      versionCode: result.versionCode,
      appName,
      minSdkVersion: result.usesSdk?.minSdkVersion?.toString() || 'Unknown',
      targetSdkVersion: result.usesSdk?.targetSdkVersion?.toString() || 'Unknown',
      sha256: sha256Formatted,
      permissions,
      appIcon: result.icon || '',
    };
  } finally {
    await fs.unlink(tempPath).catch(() => { });
  }
};

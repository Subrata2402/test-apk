import { google } from 'googleapis';
import { Readable } from 'stream';
import { env } from '../config/env.js';

export interface DriveCredentials {
  refreshToken: string;
  folderId: string;
}

const getDriveClient = (credentials: DriveCredentials) => {
  if (!credentials || !credentials.refreshToken) {
    throw new Error('Google Drive credentials are not configured.');
  }
  const oauth2Client = new google.auth.OAuth2(
    env.GOOGLE_CLIENT_ID,
    env.GOOGLE_CLIENT_SECRET
  );
  oauth2Client.setCredentials({
    refresh_token: credentials.refreshToken,
  });
  return google.drive({ version: 'v3', auth: oauth2Client });
};

export const createFolderInDrive = async (
  folderName: string,
  refreshToken: string
): Promise<string> => {
  const oauth2Client = new google.auth.OAuth2(
    env.GOOGLE_CLIENT_ID,
    env.GOOGLE_CLIENT_SECRET
  );
  oauth2Client.setCredentials({ refresh_token: refreshToken });
  const drive = google.drive({ version: 'v3', auth: oauth2Client });

  const fileMetadata = {
    name: folderName,
    mimeType: 'application/vnd.google-apps.folder',
  };

  const response = await drive.files.create({
    requestBody: fileMetadata,
    fields: 'id',
  });

  if (!response.data.id) {
    throw new Error('Failed to create folder in Google Drive');
  }

  return response.data.id;
};

export const uploadFileToDrive = async (
  fileName: string,
  fileBuffer: Buffer,
  mimeType: string,
  credentials: DriveCredentials
): Promise<string> => {
  if (!credentials || !credentials.refreshToken || !credentials.folderId) {
    throw new Error('Google Drive credentials are not configured.');
  }

  const driveClient = getDriveClient(credentials);

  const fileMetadata = {
    name: fileName,
    parents: [credentials.folderId],
  };

  const media = {
    mimeType,
    body: Readable.from(fileBuffer),
  };

  const response = await driveClient.files.create({
    requestBody: fileMetadata,
    media: media,
    fields: 'id',
  });

  if (!response.data.id) {
    throw new Error('Failed to upload file to Google Drive: No ID returned');
  }

  return response.data.id;
};

export const getFileStreamFromDrive = async (
  fileId: string,
  credentials: DriveCredentials
): Promise<{ stream: Readable; contentLength?: string }> => {
  if (!credentials || !credentials.refreshToken) {
    throw new Error('Google Drive credentials are not configured.');
  }

  const driveClient = getDriveClient(credentials);

  const response = await driveClient.files.get(
    {
      fileId,
      alt: 'media',
    },
    { responseType: 'stream' }
  );

  return {
    stream: response.data as Readable,
    contentLength: response.headers['content-length'] as string | undefined,
  };
};

export const deleteFileFromDrive = async (
  fileId: string,
  credentials: DriveCredentials
): Promise<void> => {
  if (!credentials || !credentials.refreshToken) {
    throw new Error('Google Drive credentials are not configured.');
  }

  const driveClient = getDriveClient(credentials);

  await driveClient.files.delete({
    fileId,
  });
};

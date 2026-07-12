import { google } from 'googleapis';
import { Readable } from 'stream';
import { env } from '../config/env.js';

const oauth2Client = new google.auth.OAuth2(
  env.GOOGLE_CLIENT_ID,
  env.GOOGLE_CLIENT_SECRET
);

if (env.GOOGLE_DRIVE_REFRESH_TOKEN) {
  oauth2Client.setCredentials({
    refresh_token: env.GOOGLE_DRIVE_REFRESH_TOKEN,
  });
}

const drive = google.drive({ version: 'v3', auth: oauth2Client });

export const uploadFileToDrive = async (
  fileName: string,
  fileBuffer: Buffer,
  mimeType: string
): Promise<string> => {
  if (!env.GOOGLE_DRIVE_REFRESH_TOKEN) {
    throw new Error('GOOGLE_DRIVE_REFRESH_TOKEN is not configured in environment variables. Please run get-refresh-token script first.');
  }

  const fileMetadata = {
    name: fileName,
    parents: [env.GOOGLE_DRIVE_FOLDER_ID],
  };

  const media = {
    mimeType,
    body: Readable.from(fileBuffer),
  };

  const response = await drive.files.create({
    requestBody: fileMetadata,
    media: media,
    fields: 'id',
  });

  if (!response.data.id) {
    throw new Error('Failed to upload file to Google Drive: No ID returned');
  }

  return response.data.id;
};

export const getFileStreamFromDrive = async (fileId: string): Promise<{ stream: Readable; contentLength?: string }> => {
  if (!env.GOOGLE_DRIVE_REFRESH_TOKEN) {
    throw new Error('GOOGLE_DRIVE_REFRESH_TOKEN is not configured in environment variables. Please run get-refresh-token script first.');
  }

  const response = await drive.files.get(
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

export const deleteFileFromDrive = async (fileId: string): Promise<void> => {
  if (!env.GOOGLE_DRIVE_REFRESH_TOKEN) {
    throw new Error('GOOGLE_DRIVE_REFRESH_TOKEN is not configured in environment variables. Please run get-refresh-token script first.');
  }

  await drive.files.delete({
    fileId,
  });
};

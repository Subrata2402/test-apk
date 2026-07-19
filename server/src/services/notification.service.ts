import { GoogleAuth } from 'google-auth-library';
import { env } from '../config/env.js';
import fs from 'fs';
import path from 'path';

let auth: GoogleAuth | null = null;
let projectId: string | null = null;

const initAuth = () => {
  if (auth) return;

  try {
    const keyPath = path.resolve(env.FIREBASE_SERVICE_ACCOUNT_PATH);
    if (!fs.existsSync(keyPath)) {
      console.warn(`⚠️ Firebase service account file not found at ${keyPath}. Push notifications will be disabled.`);
      return;
    }

    const serviceAccount = JSON.parse(fs.readFileSync(keyPath, 'utf8'));
    projectId = serviceAccount.project_id;

    auth = new GoogleAuth({
      keyFile: keyPath,
      scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
    });
    console.log('✅ Firebase Cloud Messaging initialized successfully.');
  } catch (error) {
    console.error('❌ Failed to initialize Firebase Cloud Messaging:', error);
  }
};

export interface NotificationPayload {
  title: string;
  body: string;
  data?: Record<string, string>;
}

export const sendPushNotification = async (
  fcmToken: string,
  payload: NotificationPayload
): Promise<boolean> => {
  initAuth();

  if (!auth || !projectId) {
    console.warn('⚠️ FCM not initialized. Skipping notification.');
    return false;
  }

  try {
    const client = await auth.getClient();
    const url = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

    const response = await client.request({
      url,
      method: 'POST',
      data: {
        message: {
          token: fcmToken,
          notification: {
            title: payload.title,
            body: payload.body,
          },
          data: payload.data,
        },
      },
    });

    return response.status === 200;
  } catch (error: any) {
    console.error(`❌ Failed to send push notification to token ${fcmToken}:`, error.message || error);
    return false;
  }
};

export const sendPushNotificationToMultiple = async (
  fcmTokens: string[],
  payload: NotificationPayload
): Promise<void> => {
  if (!fcmTokens || fcmTokens.length === 0) return;

  // Send notifications in parallel
  await Promise.all(
    fcmTokens.map(token => sendPushNotification(token, payload))
  );
};

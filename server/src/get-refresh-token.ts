import { google } from 'googleapis';
import http from 'http';
import url from 'url';
import { env } from './config/env.js';

const clientID = env.GOOGLE_CLIENT_ID;
const clientSecret = process.env.GOOGLE_CLIENT_SECRET;

if (!clientSecret) {
  console.error('❌ GOOGLE_CLIENT_SECRET is not set in your .env file.');
  console.log('Please add GOOGLE_CLIENT_SECRET to your server/.env file first.');
  process.exit(1);
}

const PORT = 8085;
const REDIRECT_URI = `http://localhost:${PORT}/oauth2callback`;

const oauth2Client = new google.auth.OAuth2(
  clientID,
  clientSecret,
  REDIRECT_URI
);

const scopes = [
  'https://www.googleapis.com/auth/drive'
];

const authUrl = oauth2Client.generateAuthUrl({
  access_type: 'offline',
  scope: scopes,
  prompt: 'consent'
});

const server = http.createServer(async (req, res) => {
  try {
    if (req.url?.startsWith('/oauth2callback')) {
      const query = url.parse(req.url, true).query;
      const code = query.code as string;

      if (!code) {
        res.end('Authorization code not found.');
        return;
      }

      res.end('Authorization successful! You can close this tab and return to the terminal.');

      console.log('Exchanging code for tokens...');
      const { tokens } = await oauth2Client.getToken(code);
      console.log('\n🎉 Success! Add these to your server/.env file:\n');
      console.log(`GOOGLE_CLIENT_SECRET=${clientSecret}`);
      console.log(`GOOGLE_DRIVE_REFRESH_TOKEN=${tokens.refresh_token}`);
      console.log('\n');

      server.close();
      process.exit(0);
    }
  } catch (err) {
    console.error('Error exchanging code:', err);
    res.end('Error exchanging code.');
    server.close();
    process.exit(1);
  }
});

server.listen(PORT, () => {
  console.log('\n=== Google Drive OAuth2 Authorization ===\n');
  console.log('1. Open this URL in your browser:\n');
  console.log(authUrl);
  console.log('\n2. Authorize the app and you will be redirected.');
  console.log('Waiting for authorization...\n');
});

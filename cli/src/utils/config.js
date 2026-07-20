import fs from 'fs';
import path from 'path';
import os from 'os';

export const CONFIG_FILE = path.join(os.homedir(), '.testapk-cli.json');
export const DEFAULT_API_URL = 'https://testapkapi.clipboux.online/api/v1';

export const getApiUrl = () => {
  return process.env.TESTAPK_API_URL || DEFAULT_API_URL;
};

export const saveToken = (token) => {
  fs.writeFileSync(CONFIG_FILE, JSON.stringify({ token }, null, 2));
};

export const getToken = () => {
  if (fs.existsSync(CONFIG_FILE)) {
    try {
      const config = JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf8'));
      return config.token;
    } catch (e) {
      return null;
    }
  }
  return null;
};

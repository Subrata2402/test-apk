import axios from 'axios';
import chalk from 'chalk';
import { getToken, getApiUrl } from './config.js';

export const getClient = () => {
  const token = getToken();
  if (!token) {
    console.error(chalk.red('Error: You are not logged in. Please run `testapk login` first.'));
    process.exit(1);
  }
  return axios.create({
    baseURL: getApiUrl(),
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });
};

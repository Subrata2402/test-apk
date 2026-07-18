#!/usr/bin/env node

import { program } from 'commander';
import axios from 'axios';
import fs from 'fs';
import path from 'path';
import os from 'os';
import FormData from 'form-data';
import chalk from 'chalk';
import { exec } from 'child_process';

const CONFIG_FILE = path.join(os.homedir(), '.testapk-cli.json');
const DEFAULT_API_URL = 'https://testapkapi.clipboux.online/api/v1';
// const DEFAULT_API_URL = 'http://localhost:3000/api/v1';

const openBrowser = (url) => {
  const start = {
    win32: 'start',
    darwin: 'open',
    linux: 'xdg-open'
  }[process.platform] || 'xdg-open';
  
  exec(`${start} "${url}"`, (error) => {
    if (error) {
      // Silently ignore
    }
  });
};

const getApiUrl = () => {
  return process.env.TESTAPK_API_URL || DEFAULT_API_URL;
};

const saveToken = (token) => {
  fs.writeFileSync(CONFIG_FILE, JSON.stringify({ token }, null, 2));
};

const getToken = () => {
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

const getClient = () => {
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

program
  .name('testapk')
  .description('CLI tool for TestAPK Release Manager')
  .version('1.0.0');

program
  .command('login')
  .description('Log in to TestAPK using Device Authorization Flow')
  .option('-f, --force', 'Force re-authentication even if already logged in')
  .action(async (options) => {
    const apiUrl = getApiUrl();
    const token = getToken();

    if (token && !options.force) {
      try {
        const response = await axios.get(`${apiUrl}/users/me`, {
          headers: { Authorization: `Bearer ${token}` }
        });
        if (response.data.status === 'success') {
          const user = response.data.data.user;
          console.log(chalk.green(`You are already logged in as ${chalk.bold(user.name)} (${user.email}).`));
          console.log(chalk.gray('To log in as a different user, run `testapk login --force` or `node index.js login --force`.'));
          process.exit(0);
        }
      } catch (error) {
        // Token is invalid or expired, proceed with login flow
      }
    }

    console.log(chalk.blue('Initiating login flow...'));

    try {
      const response = await axios.post(`${apiUrl}/auth/device/code`);
      const { deviceCode, userCode, verificationUri, expiresIn } = response.data.data;

      console.log('\n----------------------------------------');
      console.log(chalk.yellow('Please visit the following URL in your browser:'));
      console.log(chalk.bold.cyan(verificationUri));
      console.log('\nAnd enter the following authorization code:');
      console.log(chalk.bold.green(userCode));
      console.log('----------------------------------------\n');

      // Automatically open the browser
      openBrowser(verificationUri);

      console.log(chalk.gray('Waiting for authorization...'));

      const pollInterval = 5000; // 5 seconds
      const maxAttempts = Math.floor((expiresIn * 1000) / pollInterval);
      let attempts = 0;

      const poll = setInterval(async () => {
        attempts++;
        if (attempts > maxAttempts) {
          clearInterval(poll);
          console.log(chalk.red('\nLogin session expired. Please run `testapk login` again.'));
          process.exit(1);
        }

        try {
          const tokenResponse = await axios.post(`${apiUrl}/auth/device/token`, { deviceCode });
          if (tokenResponse.data.status === 'success') {
            clearInterval(poll);
            saveToken(tokenResponse.data.token);
            console.log(chalk.green(`\nSuccessfully logged in as ${chalk.bold(tokenResponse.data.data.user.name)}!`));
            process.exit(0);
          }
        } catch (error) {
          const errData = error.response?.data;
          if (errData?.error === 'authorization_pending') {
            // Keep polling silently
            process.stdout.write('.');
          } else {
            clearInterval(poll);
            console.log(chalk.red(`\nLogin failed: ${errData?.message || error.message}`));
            process.exit(1);
          }
        }
      }, pollInterval);

    } catch (error) {
      console.error(chalk.red('Failed to initiate login flow:'), error.response?.data?.message || error.message || error);
      if (error.stack) {
        console.error(chalk.gray(error.stack));
      }
      process.exit(1);
    }
  });

program
  .command('list-apps')
  .description('List all applications')
  .action(async () => {
    const client = getClient();
    try {
      const response = await client.get('/apps');
      const apps = response.data.data.apps;

      if (apps.length === 0) {
        console.log(chalk.yellow('No applications found.'));
        return;
      }

      console.log(chalk.bold('\nYour Applications:'));
      console.log('----------------------------------------------------------------------');
      apps.forEach((app) => {
        console.log(`${chalk.bold.cyan(app.name)} (${chalk.gray(app.packageName)})`);
        console.log(`ID: ${chalk.yellow(app._id || app.id)}`);
        console.log(`Releases: ${app.releases.length}`);
        console.log('----------------------------------------------------------------------');
      });
    } catch (error) {
      console.error(chalk.red('Failed to list apps:'), error.response?.data?.message || error.message);
    }
  });

// program
//   .command('create-app')
//   .description('Create a new application')
//   .requiredOption('-n, --name <name>', 'Application Name')
//   .requiredOption('-p, --package <packageName>', 'Package Name (e.g., com.example.app)')
//   .option('-d, --desc <description>', 'Description', 'Created via CLI')
//   .action(async (options) => {
//     const client = getClient();
//     try {
//       const response = await client.post('/apps', {
//         name: options.name,
//         packageName: options.package,
//         description: options.desc,
//       });

//       console.log(chalk.green('✅ Application created successfully!'));
//       console.log(`App ID: ${chalk.yellow(response.data.data.app._id || response.data.data.app.id)}`);
//     } catch (error) {
//       console.error(chalk.red('Failed to create app:'), error.response?.data?.message || error.message);
//     }
//   });

program
  .command('upload')
  .description('Upload a new APK release')
  .requiredOption('-a, --app-id <appId>', 'Application ID')
  .requiredOption('-f, --file <filePath>', 'Path to the APK file')
  .option('-n, --notes <notes>', 'Release notes', 'Uploaded via CLI')
  .action(async (options) => {
    const client = getClient();

    if (!fs.existsSync(options.file)) {
      console.error(chalk.red(`Error: File not found at ${options.file}`));
      process.exit(1);
    }

    console.log(chalk.blue('🚀 Uploading APK to TestAPK...'));

    const form = new FormData();
    form.append('file', fs.createReadStream(options.file));
    form.append('releaseNotes', options.notes);

    form.getLength(async (err, length) => {
      if (err) {
        try {
          const response = await client.post(`/apps/${options.appId}/releases`, form, {
            headers: {
              ...form.getHeaders(),
            },
            maxContentLength: Infinity,
            maxBodyLength: Infinity,
          });

          const release = response.data.data.release;
          console.log(chalk.green('✅ Release uploaded successfully!'));
          console.log(`Version: ${chalk.bold(release.version)} (Build #${chalk.bold(release.buildNumber)})`);
        } catch (error) {
          console.error(chalk.red('Upload failed:'), error.response?.data?.message || error.message);
        }
        return;
      }

      let isDriveSpinnerStarted = false;
      let spinnerInterval;

      const startDriveSpinner = () => {
        if (isDriveSpinnerStarted) return;
        isDriveSpinnerStarted = true;

        const spinnerFrames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
        let frameIndex = 0;
        process.stdout.write('\n');
        spinnerInterval = setInterval(() => {
          process.stdout.clearLine(0);
          process.stdout.cursorTo(0);
          process.stdout.write(`${chalk.cyan(spinnerFrames[frameIndex])} ☁️ Sending to Google Drive...`);
          frameIndex = (frameIndex + 1) % spinnerFrames.length;
        }, 80);
      };

      const stopDriveSpinner = () => {
        if (spinnerInterval) {
          clearInterval(spinnerInterval);
          process.stdout.clearLine(0);
          process.stdout.cursorTo(0);
        }
      };

      try {
        const response = await client.post(`/apps/${options.appId}/releases`, form, {
          headers: {
            ...form.getHeaders(),
            'Content-Length': length,
          },
          maxContentLength: Infinity,
          maxBodyLength: Infinity,
          onUploadProgress: (progressEvent) => {
            const total = progressEvent.total || length;
            const current = progressEvent.loaded;
            const percentage = Math.floor((current / total) * 100);

            const size = 30;
            const dots = Math.floor((percentage / 100) * size);
            const left = size - dots;

            const bar = '='.repeat(dots) + '-'.repeat(left);

            process.stdout.clearLine(0);
            process.stdout.cursorTo(0);
            process.stdout.write(`🚀 Uploading: [${bar}] ${percentage}% (${(current / 1024 / 1024).toFixed(2)}MB / ${(total / 1024 / 1024).toFixed(2)}MB)`);

            if (current >= total) {
              startDriveSpinner();
            }
          }
        });

        stopDriveSpinner();
        const release = response.data.data.release;
        console.log(chalk.green('✅ Release uploaded successfully!'));
        console.log(`Version: ${chalk.bold(release.version)} (Build #${chalk.bold(release.buildNumber)})`);
      } catch (error) {
        stopDriveSpinner();
        console.error(chalk.red('\nUpload failed:'), error.response?.data?.message || error.message);
      }
    });
  });

program
  .command('list-releases')
  .description('List all releases for an application')
  .requiredOption('-a, --app-id <appId>', 'Application ID')
  .action(async (options) => {
    const client = getClient();
    try {
      const response = await client.get(`/apps`);
      const apps = response.data.data.apps;
      const app = apps.find(a => (a._id || a.id) === options.appId);

      if (!app) {
        console.error(chalk.red('Error: Application not found.'));
        return;
      }

      if (app.releases.length === 0) {
        console.log(chalk.yellow('No releases found for this application.'));
        return;
      }

      console.log(chalk.bold(`\nReleases for ${app.name}:`));
      console.log('----------------------------------------------------------------------');
      app.releases.forEach((release) => {
        console.log(`Version: ${chalk.bold.cyan(release.version)} (Build #${chalk.bold.yellow(release.buildNumber)})`);
        console.log(`Date: ${release.date} | Size: ${release.size}`);
        console.log(`Notes: ${chalk.gray(release.releaseNotes)}`);
        console.log('----------------------------------------------------------------------');
      });
    } catch (error) {
      console.error(chalk.red('Failed to list releases:'), error.response?.data?.message || error.message);
    }
  });

program.parse(process.argv);

import fs from 'fs';
import path from 'path';
import http from 'http';
import https from 'https';
import FormData from 'form-data';
import chalk from 'chalk';
import { getClient } from '../utils/api.js';
import { getApiUrl, getToken } from '../utils/config.js';
import { Spinner } from '../utils/spinner.js';
import { ProgressStream } from '../utils/progress-stream.js';

export const registerUploadCommand = (program) => {
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

      const fileStats = fs.statSync(options.file);
      const fileSize = fileStats.size;

      const driveSpinner = new Spinner('☁️ Sending to Google Drive...');

      const fileStream = fs.createReadStream(options.file);
      const progressStream = new ProgressStream(fileSize, (uploaded, total) => {
        const percentage = Math.min(Math.floor((uploaded / total) * 100), 100);

        const size = 30;
        const dots = Math.floor((percentage / 100) * size);
        const left = size - dots;

        const bar = '='.repeat(dots) + '-'.repeat(left);

        process.stdout.clearLine(0);
        process.stdout.cursorTo(0);
        process.stdout.write(`🚀 Uploading: [${bar}] ${percentage}% (${(uploaded / 1024 / 1024).toFixed(2)}MB / ${(total / 1024 / 1024).toFixed(2)}MB)`);

        if (uploaded >= total) {
          process.stdout.write('\n');
          driveSpinner.start();
        }
      });

      fileStream.pipe(progressStream);

      const form = new FormData();
      form.append('file', progressStream, {
        filename: path.basename(options.file),
        knownLength: fileSize,
      });
      form.append('releaseNotes', options.notes);

      const token = getToken();
      const apiUrl = new URL(getApiUrl());
      const requestPath = `${apiUrl.pathname}/apps/${options.appId}/releases`;

      const headers = {
        ...form.getHeaders(),
        'Authorization': `Bearer ${token}`
      };

      form.getLength((err, length) => {
        if (!err && length) {
          headers['Content-Length'] = length;
        }

        const reqOptions = {
          protocol: apiUrl.protocol,
          hostname: apiUrl.hostname,
          port: apiUrl.port || (apiUrl.protocol === 'https:' ? 443 : 80),
          path: requestPath,
          method: 'POST',
          headers: headers
        };

        const httpModule = apiUrl.protocol === 'https:' ? https : http;
        const req = httpModule.request(reqOptions, (res) => {
          let responseBody = '';
          res.on('data', (chunk) => {
            responseBody += chunk;
          });
          res.on('end', () => {
            driveSpinner.stop();
            try {
              const parsedData = JSON.parse(responseBody);
              if (res.statusCode === 201 && parsedData.status === 'success') {
                const release = parsedData.data.release;
                console.log(chalk.green('\n✅ Release uploaded successfully!'));
                console.log(`Version: ${chalk.bold(release.version)} (Build #${chalk.bold(release.buildNumber)})`);
              } else {
                console.error(chalk.red(`\nUpload failed: ${parsedData.message || 'Unknown error'}`));
              }
            } catch (e) {
              console.error(chalk.red(`\nUpload failed: Status ${res.statusCode}. ${responseBody || 'Invalid JSON response'}`));
            }
          });
        });

        req.on('error', (error) => {
          driveSpinner.stop();
          console.error(chalk.red('\nUpload failed:'), error.message);
        });

        form.pipe(req);
      });
    });
};

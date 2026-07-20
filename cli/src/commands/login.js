import axios from 'axios';
import chalk from 'chalk';
import { getApiUrl, getToken, saveToken } from '../utils/config.js';
import { openBrowser } from '../utils/browser.js';
import { Spinner } from '../utils/spinner.js';

export const registerLoginCommand = (program) => {
  program
    .command('login')
    .description('Log in to TestAPK using Device Authorization Flow')
    .option('-f, --force', 'Force re-authentication even if already logged in')
    .action(async (options) => {
      const apiUrl = getApiUrl();
      const token = getToken();

      if (token && !options.force) {
        const checkSpinner = new Spinner('Checking login status...');
        checkSpinner.start();
        try {
          const response = await axios.get(`${apiUrl}/users/me`, {
            headers: { Authorization: `Bearer ${token}` }
          });
          if (response.data.status === 'success') {
            const user = response.data.data.user;
            checkSpinner.stop(true, chalk.green(`You are already logged in as ${chalk.bold(user.name)} (${user.email}).`));
            console.log(chalk.gray('To log in as a different user, run `testapk login --force` or `node index.js login --force`.'));
            process.exit(0);
          }
        } catch (error) {
          checkSpinner.stop(false);
          // Token is invalid or expired, proceed with login flow
        }
      }

      const initSpinner = new Spinner('Initiating login flow...');
      initSpinner.start();

      try {
        const response = await axios.post(`${apiUrl}/auth/device/code`);
        const { deviceCode, userCode, verificationUri, expiresIn } = response.data.data;
        initSpinner.stop(true);

        console.log('\n----------------------------------------');
        console.log(chalk.yellow('Please visit the following URL in your browser:'));
        console.log(chalk.bold.cyan(verificationUri));
        console.log('\nAnd enter the following authorization code:');
        console.log(chalk.bold.green(userCode));
        console.log('----------------------------------------\n');

        // Automatically open the browser
        openBrowser(verificationUri);

        const authSpinner = new Spinner('Waiting for authorization...');
        authSpinner.start();

        const pollInterval = 5000; // 5 seconds
        const maxAttempts = Math.floor((expiresIn * 1000) / pollInterval);
        let attempts = 0;

        const poll = setInterval(async () => {
          attempts++;
          if (attempts > maxAttempts) {
            clearInterval(poll);
            authSpinner.stop(false, chalk.red('\nLogin session expired. Please run `testapk login` again.'));
            process.exit(1);
          }

          try {
            const tokenResponse = await axios.post(`${apiUrl}/auth/device/token`, { deviceCode });
            if (tokenResponse.data.status === 'success') {
              clearInterval(poll);
              saveToken(tokenResponse.data.token);
              authSpinner.stop(true, chalk.green(`\nSuccessfully logged in as ${chalk.bold(tokenResponse.data.data.user.name)}!`));
              process.exit(0);
            }
          } catch (error) {
            const errData = error.response?.data;
            if (errData?.error === 'authorization_pending') {
              // Keep polling silently, spinner keeps spinning
            } else {
              clearInterval(poll);
              authSpinner.stop(false, chalk.red(`\nLogin failed: ${errData?.message || error.message}`));
              process.exit(1);
            }
          }
        }, pollInterval);

      } catch (error) {
        initSpinner.stop(false);
        console.error(chalk.red('Failed to initiate login flow:'), error.response?.data?.message || error.message || error);
        if (error.stack) {
          console.error(chalk.gray(error.stack));
        }
        process.exit(1);
      }
    });
};

import chalk from 'chalk';
import { getClient } from '../utils/api.js';
import { Spinner } from '../utils/spinner.js';

export const registerListAppsCommand = (program) => {
  program
    .command('list-apps')
    .description('List all applications')
    .action(async () => {
      const client = getClient();
      const spinner = new Spinner('Fetching applications...');
      spinner.start();
      try {
        const response = await client.get('/apps');
        const apps = response.data.data.apps;
        spinner.stop(true);

        if (apps.length === 0) {
          console.log(chalk.yellow('No applications found.'));
          return;
        }

        console.log(chalk.bold('\nYour Applications:'));
        console.log('----------------------------------------------------------------------');
        apps.forEach((app) => {
          console.log(`${chalk.bold.cyan(app.name)} (${chalk.gray(app.packageName)})`);
          console.log(`ID: ${chalk.yellow(app._id || app.id)}`);
          console.log(`Releases: ${app.releasesCount ?? app.releases.length}`);
          console.log('----------------------------------------------------------------------');
        });
      } catch (error) {
        spinner.stop(false);
        console.error(chalk.red('Failed to list apps:'), error.response?.data?.message || error.message);
      }
    });
};

import chalk from 'chalk';
import { getClient } from '../utils/api.js';
import { Spinner } from '../utils/spinner.js';

export const registerListReleasesCommand = (program) => {
  program
    .command('list-releases')
    .description('List all releases for an application')
    .requiredOption('-a, --app-id <appId>', 'Application ID')
    .action(async (options) => {
      const client = getClient();
      const spinner = new Spinner('Fetching releases...');
      spinner.start();
      try {
        const appResponse = await client.get('/apps');
        const apps = appResponse.data.data.apps;
        const app = apps.find(a => (a._id || a.id) === options.appId);

        if (!app) {
          spinner.stop(false);
          console.error(chalk.red('Error: Application not found.'));
          return;
        }

        const releasesResponse = await client.get(`/apps/${options.appId}/releases`);
        const releases = releasesResponse.data.data.releases;
        spinner.stop(true);

        if (releases.length === 0) {
          console.log(chalk.yellow('No releases found for this application.'));
          return;
        }

        console.log(chalk.bold(`\nReleases for ${app.name}:`));
        console.log('----------------------------------------------------------------------');
        releases.forEach((release) => {
          console.log(`Version: ${chalk.bold.cyan(release.version)} (Build #${chalk.bold.yellow(release.buildNumber)})`);
          console.log(`Date: ${release.date} | Size: ${release.size}`);
          console.log(`Notes: ${chalk.gray(release.releaseNotes)}`);
          console.log('----------------------------------------------------------------------');
        });
      } catch (error) {
        spinner.stop(false);
        console.error(chalk.red('Failed to list releases:'), error.response?.data?.message || error.message);
      }
    });
};

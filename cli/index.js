#!/usr/bin/env node

import { program } from 'commander';
import { registerLoginCommand } from './src/commands/login.js';
import { registerListAppsCommand } from './src/commands/list-apps.js';
import { registerUploadCommand } from './src/commands/upload.js';
import { registerListReleasesCommand } from './src/commands/list-releases.js';

program
  .name('testapk')
  .description('CLI tool for TestAPK Release Manager')
  .version('1.0.0');

// Register commands
registerLoginCommand(program);
registerListAppsCommand(program);
registerUploadCommand(program);
registerListReleasesCommand(program);

program.parse(process.argv);

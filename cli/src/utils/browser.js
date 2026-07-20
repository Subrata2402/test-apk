import { exec } from 'child_process';

export const openBrowser = (url) => {
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

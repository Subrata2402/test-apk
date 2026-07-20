import chalk from 'chalk';

export class Spinner {
  constructor(message) {
    this.message = message;
    this.frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
    this.interval = null;
    this.frameIndex = 0;
    this.isTTY = !!process.stdout.isTTY;
  }

  start() {
    if (this.interval) return;
    if (!this.isTTY) {
      console.log(`${chalk.blue('i')} ${this.message}`);
      return;
    }
    this.interval = setInterval(() => {
      process.stdout.clearLine(0);
      process.stdout.cursorTo(0);
      process.stdout.write(`${chalk.cyan(this.frames[this.frameIndex])} ${this.message}`);
      this.frameIndex = (this.frameIndex + 1) % this.frames.length;
    }, 80);
  }

  stop(success = true, finalMessage = null) {
    if (!this.isTTY) {
      if (finalMessage) {
        console.log(finalMessage);
      }
      return;
    }
    if (this.interval) {
      clearInterval(this.interval);
      this.interval = null;
      process.stdout.clearLine(0);
      process.stdout.cursorTo(0);
      if (finalMessage) {
        console.log(finalMessage);
      }
    }
  }

  updateMessage(newMessage) {
    this.message = newMessage;
    if (!this.isTTY) {
      console.log(`${chalk.blue('i')} ${this.message}`);
    }
  }
}

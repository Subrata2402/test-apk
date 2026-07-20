import { Transform } from 'stream';

export class ProgressStream extends Transform {
  constructor(totalSize, onProgress) {
    super();
    this.totalSize = totalSize;
    this.uploadedBytes = 0;
    this.onProgress = onProgress;
  }

  _transform(chunk, encoding, callback) {
    this.uploadedBytes += chunk.length;
    this.onProgress(this.uploadedBytes, this.totalSize);
    this.push(chunk);
    callback();
  }
}

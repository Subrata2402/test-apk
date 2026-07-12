declare module 'app-info-parser' {
  export default class AppInfoParser {
    constructor(file: string | Buffer);
    parse(): Promise<any>;
  }
}

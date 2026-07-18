# TestAPK CLI

A command-line interface tool for managing applications and releases on the TestAPK Release Manager platform.

## Installation

Install the CLI tool globally using npm:

```bash
npm install -g testapk
```


---

## Commands

### 1. Log In
Authenticates the CLI with the TestAPK server using the secure Device Authorization Flow.
```bash
testapk login
```
* **Options**:
  - `-f, --force`: Force re-authentication even if already logged in.
* **Flow**:
  - The CLI will automatically open your default browser to the authorization page.
  - Enter the 8-character code displayed in the terminal.
  - Once authorized, the CLI will save the credentials to `~/.testapk-cli.json` and complete the login.

### 2. List Applications
Lists all applications associated with your account.
```bash
testapk list-apps
```

<!-- ### 3. Create Application
Creates a new application.
```bash
testapk create-app --name "My App" --package "com.example.app" --desc "My awesome app description"
```
* **Options**:
  - `-n, --name <name>`: (Required) Application Name.
  - `-p, --package <packageName>`: (Required) Package Name (e.g., `com.example.app`).
  - `-d, --desc <description>`: (Optional) Description. -->

### 3. Upload APK Release
Uploads a new APK release to an application.
```bash
testapk upload --app-id <app-id> --file /path/to/app-release.apk --notes "Release notes here"
```
* **Options**:
  - `-a, --app-id <appId>`: (Required) Application ID.
  - `-f, --file <filePath>`: (Required) Path to the APK file.
  - `-n, --notes <notes>`: (Optional) Release notes.

### 4. List Releases
Lists all releases for a specific application.
```bash
testapk list-releases --app-id <app-id>
```
* **Options**:
  - `-a, --app-id <appId>`: (Required) Application ID.

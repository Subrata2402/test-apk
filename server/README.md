# TestAPK Server

The backend API server for the TestAPK Release Manager platform. It manages user authentication, application metadata, tester invitations, and handles secure APK storage and delivery via Google Drive.

## Tech Stack

- **Runtime**: Node.js
- **Language**: TypeScript
- **Framework**: Express.js
- **Database**: MongoDB (Mongoose ODM)
- **Storage**: Google Drive API
- **Security**: Helmet, Express Rate Limit, CORS, JSON Web Tokens (JWT)
- **Validation**: Zod

---

## Prerequisites

- Node.js (v18 or higher)
- MongoDB (local instance or MongoDB Atlas connection string)
- A Google Cloud Project with:
  - **Google Drive API** enabled
  - **OAuth 2.0 Credentials** (Client ID and Client Secret)

---

## Environment Variables

Create a `.env` file in the root of the `server` directory. You can use `.env.example` as a template:

```env
PORT=3000
NODE_ENV=development
CORS_ORIGIN=http://localhost:5173
MONGODB_URI=mongodb://localhost:27017/testapk
JWT_SECRET=your_jwt_secret_here
JWT_EXPIRES_IN=7d

# Google OAuth Credentials
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret

# Google Drive Configuration (Optional initially, can be configured via Web UI)
GOOGLE_DRIVE_FOLDER_ID=your_google_drive_folder_id
GOOGLE_DRIVE_REFRESH_TOKEN=your_google_drive_refresh_token
```

---

## Installation & Setup

1. **Install dependencies**:
   ```bash
   npm install
   ```

2. **Run in Development Mode** (with hot-reloading via `tsx`):
   ```bash
   npm run dev
   ```

3. **Build for Production**:
   ```bash
   npm run build
   ```

4. **Start Production Server**:
   ```bash
   npm run start
   ```

5. **Lint and Format**:
   ```bash
   npm run lint
   npm run format
   ```

---

## API Endpoints

### Health Check
- `GET /api/v1/health` - Check server and database status.

### Authentication
- `POST /api/v1/auth/google` - Authenticate user using Google OAuth ID token.
- `POST /api/v1/auth/logout` - Invalidate current session.

### Device Authorization Flow (CLI Login)
- `POST /api/v1/auth/device/code` - Request a device code and user verification URL.
- `POST /api/v1/auth/device/token` - Poll for user authorization status and retrieve JWT.

### User Profile
- `GET /api/v1/users/me` - Get authenticated user's profile and configuration status.
- `PATCH /api/v1/users/drive-token` - Update Google Drive refresh token.

### Applications
- `GET /api/v1/apps` - List all applications the user owns or is invited to.
- `POST /api/v1/apps` - Create a new application.
- `GET /api/v1/apps/:appId` - Get details of a specific application.
- `POST /api/v1/apps/:appId/invite` - Invite a tester by email.
- `POST /api/v1/apps/:appId/invite/respond` - Accept or decline an invitation.

### Releases
- `POST /api/v1/apps/:appId/releases` - Upload a new APK release (multipart/form-data). Parses APK metadata (version, package name, permissions) automatically.
- `GET /api/v1/apps/:appId/releases` - List all releases for an application.
- `GET /api/v1/apps/:appId/releases/:releaseId/download` - Download the APK file from Google Drive.

# TestAPK Web Application

The web portal for the TestAPK Release Manager platform. It allows developers to create applications, configure Google Drive storage, invite testers, and view release history. It also hosts the Device Authorization Flow page for CLI authentication.

## Tech Stack

- **Framework**: React (v19)
- **Build Tool**: Vite
- **Styling**: Vanilla CSS (with a modern glassmorphic design system)
- **Icons**: Lucide React
- **Authentication**: Google OAuth (`@react-oauth/google`)
- **Linter**: Oxlint

---

## Prerequisites

- Node.js (v18 or higher)
- A running instance of the [TestAPK Server](../server)

---

## Environment Variables

Create a `.env` file in the root of the `webapp` directory. You can use `.env.example` as a template:

```env
VITE_API_URL=http://localhost:3000/api/v1
VITE_GOOGLE_CLIENT_ID=your_google_client_id_here
```

> [!IMPORTANT]
> The `VITE_GOOGLE_CLIENT_ID` must match the client ID configured in the backend server and Google Cloud Console.

---

## Installation & Setup

1. **Install dependencies**:
   ```bash
   npm install
   ```

2. **Run in Development Mode**:
   ```bash
   npm run dev
   ```
   The application will be available at `http://localhost:5173`.

3. **Build for Production**:
   ```bash
   npm run build
   ```

4. **Preview Production Build**:
   ```bash
   npm run preview
   ```

5. **Lint**:
   ```bash
   npm run lint
   ```

---

## Key Features

- **Google OAuth Login**: Secure login for developers and testers.
- **Developer Dashboard**:
  - Create and manage applications.
  - Connect Google Drive to use as the APK storage backend.
  - Invite testers by email.
  - View application details, member lists, and release history.
- **Device Authorization**: A dedicated `/device` route that handles CLI login requests using the RFC 8628 Device Authorization Flow.

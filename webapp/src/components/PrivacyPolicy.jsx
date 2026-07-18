import React from 'react';
import * as Icons from 'lucide-react';
import './PrivacyPolicy.css';

export default function PrivacyPolicy({ onBackToHome }) {
  return (
    <div className="policy-container flex-center">
      <div className="policy-card glass-panel animate-fade-in">
        <div className="policy-header">
          <button className="btn-back flex-center" onClick={onBackToHome} aria-label="Go back">
            <Icons.ArrowLeft size={20} />
          </button>
          <h2>Privacy Policy</h2>
          <p className="last-updated">Last Updated: July 18, 2026</p>
        </div>

        <div className="policy-content">
          <section>
            <h3>1. Introduction</h3>
            <p>
              Welcome to TestAPK. We respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our web dashboard, mobile application, and command line interface (CLI).
            </p>
          </section>

          <section>
            <h3>2. Information We Collect</h3>
            <p>
              We collect information that you provide directly to us when using our services:
            </p>
            <ul>
              <li><strong>Account Information:</strong> When you sign in using Google OAuth, we receive your name, email address, and profile picture.</li>
              <li><strong>Google Drive Integration:</strong> To enable APK storage and management, our application requests permission to access your Google Drive. We only access, create, and modify files that are created by or uploaded through the TestAPK application (using the <code>drive.file</code> scope). We do not access or read any other files in your Google Drive.</li>
              <li><strong>Application Metadata:</strong> We collect metadata about the APK files you upload (such as package name, version code, version name, and release notes) to display them in your dashboard and mobile app.</li>
            </ul>
          </section>

          <section>
            <h3>3. How We Use Your Information</h3>
            <p>
              We use the collected information for the following purposes:
            </p>
            <ul>
              <li>To authenticate your identity and manage your account.</li>
              <li>To facilitate the upload, storage, and retrieval of APK files directly to/from your own Google Drive storage.</li>
              <li>To display application release history and details on your dashboard and mobile client.</li>
              <li>To support the CLI tool's authentication and upload flows.</li>
            </ul>
          </section>

          <section>
            <h3>4. Data Sharing and Disclosure</h3>
            <p>
              <strong>We do not sell, trade, or share your personal data or Google Drive files with third parties.</strong> All APK files are stored directly in your own Google Drive account. The TestAPK server only stores metadata (such as file IDs, version numbers, and release notes) to coordinate downloads and installations.
            </p>
          </section>

          <section>
            <h3>5. Data Security</h3>
            <p>
              We implement industry-standard security measures to protect your account metadata and authentication tokens. Your Google OAuth tokens are transmitted securely and stored using encryption.
            </p>
          </section>

          <section>
            <h3>6. Your Rights and Choices</h3>
            <p>
              You have full control over your data:
            </p>
            <ul>
              <li>You can disconnect your Google Drive integration at any time through the dashboard settings.</li>
              <li>You can revoke TestAPK's access to your Google Account entirely by visiting the <a href="https://myaccount.google.com/permissions" target="_blank" rel="noopener noreferrer">Google Account Permissions</a> page.</li>
              <li>You can request the deletion of your TestAPK account and associated metadata by contacting us.</li>
            </ul>
          </section>

          <section>
            <h3>7. Contact Us</h3>
            <p>
              If you have any questions or concerns about this Privacy Policy, please contact us at:
            </p>
            <p className="contact-email">
              <Icons.Mail size={16} style={{ marginRight: '8px', verticalAlign: 'middle' }} />
              <a href="mailto:subrata3250das@gmail.com">subrata3250das@gmail.com</a>
            </p>
          </section>
        </div>
      </div>
    </div>
  );
}

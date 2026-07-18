import React from 'react';
import * as Icons from 'lucide-react';
import './TermsOfService.css';

export default function TermsOfService({ onBackToHome }) {
  return (
    <div className="terms-container flex-center">
      <div className="terms-card glass-panel animate-fade-in">
        <div className="terms-header">
          <button className="btn-back flex-center" onClick={onBackToHome} aria-label="Go back">
            <Icons.ArrowLeft size={20} />
          </button>
          <h2>Terms of Service</h2>
          <p className="last-updated">Last Updated: July 18, 2026</p>
        </div>

        <div className="terms-content">
          <section>
            <h3>1. Agreement to Terms</h3>
            <p>
              By accessing or using TestAPK, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our services.
            </p>
          </section>

          <section>
            <h3>2. Description of Service</h3>
            <p>
              TestAPK provides a platform for developers to host, distribute, and manage Android application packages (APKs). The service includes a web dashboard, a mobile client for testing/installation, and a command line interface (CLI) for automated uploads.
            </p>
          </section>

          <section>
            <h3>3. User Accounts and Security</h3>
            <p>
              To use certain features of the service, you must sign in using Google OAuth. You are responsible for maintaining the security of your account credentials and for all activities that occur under your account. You must notify us immediately of any unauthorized use of your account.
            </p>
          </section>

          <section>
            <h3>4. Google Drive Integration</h3>
            <p>
              Our service integrates with Google Drive to store your uploaded APK files. By linking your Google Drive account, you grant TestAPK permission to create, read, and delete files within the specific folder created by the application. You retain full ownership and control of all files stored in your Google Drive.
            </p>
          </section>

          <section>
            <h3>5. Acceptable Use</h3>
            <p>
              You agree not to use the service to:
            </p>
            <ul>
              <li>Upload or distribute malicious software, viruses, or any code designed to damage or disrupt devices.</li>
              <li>Infringe upon the intellectual property rights of others.</li>
              <li>Violate any applicable local, state, national, or international laws.</li>
              <li>Attempt to gain unauthorized access to the service or its related systems.</li>
            </ul>
          </section>

          <section>
            <h3>6. Limitation of Liability</h3>
            <p>
              To the maximum extent permitted by law, TestAPK and its developers shall not be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits or revenues, whether incurred directly or indirectly, or any loss of data, use, goodwill, or other intangible losses, resulting from your use of the service.
            </p>
          </section>

          <section>
            <h3>7. Changes to Terms</h3>
            <p>
              We reserve the right to modify or replace these Terms of Service at any time. We will notify you of any changes by posting the new terms on this page. Your continued use of the service after any changes constitutes acceptance of the new terms.
            </p>
          </section>

          <section>
            <h3>8. Contact Us</h3>
            <p>
              If you have any questions about these Terms of Service, please contact us at:
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

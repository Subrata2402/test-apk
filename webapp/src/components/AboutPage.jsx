import React, { useState } from 'react';
import * as Icons from 'lucide-react';
import './AboutPage.css';

const GithubIcon = (props) => (
  <svg
    viewBox="0 0 24 24"
    width="24"
    height="24"
    stroke="currentColor"
    strokeWidth="2"
    fill="none"
    strokeLinecap="round"
    strokeLinejoin="round"
    {...props}
  >
    <path d="M15 22v-4a4.8 4.8 0 0 0-1-3.5c3 0 6-2 6-5.5.08-1.25-.27-2.48-1-3.5.28-1.15.28-2.35 0-3.5 0 0-1 0-3 1.5-2.64-.5-5.36-.5-8 0C6 2 5 2 5 2c-.3 1.15-.3 2.35 0 3.5A5.403 5.403 0 0 0 4 9c0 3.5 3 5.5 6 5.5-.39.49-.68 1.05-.85 1.65-.17.6-.22 1.23-.15 1.85v4" />
    <path d="M9 18c-4.51 2-5-2-7-2" />
  </svg>
);

export default function AboutPage({ showAlert }) {
  const [activeTab, setActiveTab] = useState('info'); // 'info' | 'contact'

  // Contact Form State
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [subject, setSubject] = useState('');
  const [message, setMessage] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleContactSubmit = async (e) => {
    e.preventDefault();
    if (!name || !email || !subject || !message) {
      showAlert('Please fill in all fields.', 'Error', 'error');
      return;
    }

    setIsSubmitting(true);
    try {
      // Simulate API call
      await new Promise((resolve) => setTimeout(resolve, 1500));
      showAlert('Your message has been sent successfully! We will get back to you soon.', 'Success', 'success');
      setName('');
      setEmail('');
      setSubject('');
      setMessage('');
    } catch (err) {
      console.error('Failed to send message:', err);
      showAlert('Failed to send message. Please try again later.', 'Error', 'error');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="about-page-container animate-fade-in">
      <header className="about-header glass-card">
        <div className="about-header-main">
          <div className="about-logo-wrapper flex-center">
            <Icons.Cpu size={36} className="about-logo-icon" />
          </div>
          <div className="about-header-info">
            <h2>About TestAPK</h2>
            <p className="text-secondary">A modern, secure, and self-hosted APK release management platform.</p>
          </div>
        </div>
      </header>

      {/* Tabs Navigation */}
      <div className="tabs-header">
        <button
          className={`tab-btn ${activeTab === 'info' ? 'active' : ''}`}
          onClick={() => setActiveTab('info')}
        >
          <Icons.Info size={16} /> Platform Info
        </button>
        <button
          className={`tab-btn ${activeTab === 'contact' ? 'active' : ''}`}
          onClick={() => setActiveTab('contact')}
        >
          <Icons.Mail size={16} /> Contact Support
        </button>
      </div>

      {activeTab === 'info' ? (
        <div className="about-content-grid">
          {/* Webapp Card */}
          <div className="about-card glass-card">
            <div className="about-card-header">
              <div className="about-card-icon-wrapper webapp-color flex-center">
                <Icons.Globe size={24} />
              </div>
              <h3>Web Dashboard</h3>
            </div>
            <p className="about-card-desc">
              The central management console for your application releases, team members, and storage configurations.
            </p>
            <ul className="about-features-list">
              <li>
                <Icons.Check size={16} className="feature-check" />
                <span><strong>Google Drive Storage:</strong> Connects directly to your personal Google Drive for secure APK storage.</span>
              </li>
              <li>
                <Icons.Check size={16} className="feature-check" />
                <span><strong>Team Management:</strong> Invite developers to publish releases and testers to download builds.</span>
              </li>
              <li>
                <Icons.Check size={16} className="feature-check" />
                <span><strong>Release History:</strong> Track version codes, build numbers, SHA-256 hashes, and permissions.</span>
              </li>
            </ul>
          </div>

          {/* Flutter App Card */}
          <div className="about-card glass-card">
            <div className="about-card-header">
              <div className="about-card-icon-wrapper flutter-color flex-center">
                <Icons.Smartphone size={24} />
              </div>
              <h3>Flutter Client</h3>
            </div>
            <p className="about-card-desc">
              The mobile application designed for testers and developers to easily install and test new releases.
            </p>
            <ul className="about-features-list">
              <li>
                <Icons.Check size={16} className="feature-check" />
                <span><strong>Glassmorphic UI:</strong> A premium, modern, and responsive iOS-inspired design.</span>
              </li>
              <li>
                <Icons.Check size={16} className="feature-check" />
                <span><strong>One-Tap Install:</strong> Download and automatically install APKs directly from the app.</span>
              </li>
              <li>
                <Icons.Check size={16} className="feature-check" />
                <span><strong>Version Detection:</strong> Automatically compares installed versions with the latest release.</span>
              </li>
            </ul>
            <a
              href="https://github.com/Subrata2402/test-apk/releases/download/v1.0.0%2B2/testapk_v1.0.0+2.apk"
              download="testapk.apk"
              className="btn btn-primary btn-sm flex-center gap-2 mt-4"
              style={{ textDecoration: 'none', width: 'fit-content' }}
            >
              <Icons.Download size={14} />
              <span>Download APK</span>
            </a>
          </div>

          {/* CLI Tool Card */}
          <div className="about-card glass-card">
            <div className="about-card-header">
              <div className="about-card-icon-wrapper cli-color flex-center">
                <Icons.Terminal size={24} />
              </div>
              <h3>CLI Tool</h3>
            </div>
            <p className="about-card-desc">
              A powerful command-line interface for automating release uploads directly from your CI/CD pipelines.
            </p>
            <ul className="about-features-list">
              <li>
                <Icons.Check size={16} className="feature-check" />
                <span><strong>Device Auth Flow:</strong> Securely log in using the standard OAuth Device Authorization Flow.</span>
              </li>
              <li>
                <Icons.Check size={16} className="feature-check" />
                <span><strong>Real-Time Progress:</strong> Visual progress bar and percentage indicator during uploads.</span>
              </li>
              <li>
                <Icons.Check size={16} className="feature-check" />
                <span><strong>Drive Upload Status:</strong> Real-time feedback while the server transfers the APK to Google Drive.</span>
              </li>
            </ul>
          </div>
        </div>
      ) : (
        <div className="contact-tab-content animate-fade-in">
          <div className="contact-grid">
            {/* Contact Form */}
            <div className="contact-form-container glass-card">
              <h3>Send us a Message</h3>
              <p className="contact-desc">Have questions, feedback, or need help? Fill out the form below and we will get back to you.</p>
              
              <form onSubmit={handleContactSubmit} className="contact-form">
                <div className="form-row">
                  <div className="form-group">
                    <label className="form-label">Your Name</label>
                    <input
                      type="text"
                      className="form-input"
                      placeholder="John Doe"
                      value={name}
                      onChange={(e) => setName(e.target.value)}
                      required
                    />
                  </div>
                  <div className="form-group">
                    <label className="form-label">Email Address</label>
                    <input
                      type="email"
                      className="form-input"
                      placeholder="john@company.com"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      required
                    />
                  </div>
                </div>

                <div className="form-group">
                  <label className="form-label">Subject</label>
                  <input
                    type="text"
                    className="form-input"
                    placeholder="How can we help you?"
                    value={subject}
                    onChange={(e) => setSubject(e.target.value)}
                    required
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">Message</label>
                  <textarea
                    className="form-textarea"
                    placeholder="Write your message here..."
                    value={message}
                    onChange={(e) => setMessage(e.target.value)}
                    required
                    rows={5}
                  />
                </div>

                <button type="submit" className="btn btn-primary flex-center gap-2" disabled={isSubmitting}>
                  {isSubmitting ? (
                    <>
                      <div className="spinner spinner-sm"></div>
                      <span>Sending Message...</span>
                    </>
                  ) : (
                    <>
                      <Icons.Send size={16} />
                      <span>Send Message</span>
                    </>
                  )}
                </button>
              </form>
            </div>

            {/* Support Info */}
            <div className="support-info-container glass-card">
              <h3>Support Channels</h3>
              <p className="contact-desc">You can also reach out to us directly through any of the following channels:</p>

              <div className="support-channels-list">
                <div className="support-channel-item">
                  <div className="channel-icon-wrapper flex-center">
                    <Icons.Mail size={20} />
                  </div>
                  <div className="channel-details">
                    <span className="channel-label">Email Support</span>
                    <a href="mailto:support@testapk.com" className="channel-value">support@testapk.com</a>
                  </div>
                </div>

                <div className="support-channel-item">
                  <div className="channel-icon-wrapper flex-center">
                    <GithubIcon size={20} />
                  </div>
                  <div className="channel-details">
                    <span className="channel-label">GitHub Issues</span>
                    <a href="https://github.com/testapk/issues" target="_blank" rel="noopener noreferrer" className="channel-value">github.com/testapk/issues</a>
                  </div>
                </div>

                <div className="support-channel-item">
                  <div className="channel-icon-wrapper flex-center">
                    <Icons.MessageSquare size={20} />
                  </div>
                  <div className="channel-details">
                    <span className="channel-label">Discord Community</span>
                    <a href="https://discord.gg/testapk" target="_blank" rel="noopener noreferrer" className="channel-value">discord.gg/testapk</a>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      <footer className="about-footer glass-card text-center">
        <p>TestAPK Release Manager &copy; 2026. Built with React, Node.js, and Flutter.</p>
      </footer>
    </div>
  );
}

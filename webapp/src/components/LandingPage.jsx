import React, { useState } from 'react';
import * as Icons from 'lucide-react';
import logoImg from '../assets/logo.jpg';
import './LandingPage.css';

export default function LandingPage({ onLoginClick }) {
  const [activeTab, setActiveTab] = useState('details'); // 'details' | 'releases'

  const appDetails = {
    name: 'TestAPK',
    packageName: 'com.testapk.app',
    description: 'The official TestAPK companion mobile app for testers. Install this app on your Android device to browse, download, and install beta releases of all your registered applications directly from your phone.',
    downloads: '1.2K',
    rating: '4.9',
    activeUsers: '850+',
    category: 'Developer Tools',
    minSdk: 'Android 8.0 (API 26)',
    releases: [
      {
        version: '1.0.0',
        buildNumber: 1,
        releaseNotes: 'Initial release of the TestAPK companion app. Features Google Sign-In, real-time application list, release history, and direct APK download & installation flow with progress feedback.',
        date: '2026-07-13',
        size: '17.8 MB',
      }
    ]
  };

  const latestRelease = appDetails.releases[0];

  return (
    <div className="landing-container container">
      {/* Hero Section */}
      <div className="hero-section glass-card">
        <div className="hero-content">
          <div className="app-meta-header">
            <div className="app-icon-wrapper" style={{ overflow: 'hidden', padding: 0 }}>
              <img src={logoImg} alt="TestAPK Logo" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
            </div>
            <div className="app-title-area">
              <h1>{appDetails.name}</h1>
              <span className="package-name">{appDetails.packageName}</span>
            </div>
          </div>

          <p className="app-description">{appDetails.description}</p>

          <div className="hero-actions">
            <a
              href="https://github.com/Subrata2402/test-apk/releases/download/v1.0.0%2B1/testapk_v1.0.0+1.apk"
              download="testapk.apk"
              className="btn btn-primary btn-lg flex-center gap-2"
              style={{ textDecoration: 'none' }}
            >
              <Icons.Download size={20} />
              <span>Download TestAPK</span>
            </a>
            <button className="btn btn-secondary btn-lg flex-center gap-2" onClick={onLoginClick}>
              <Icons.LogIn size={20} />
              <span>Developer Portal</span>
            </button>
          </div>
        </div>

        <div className="hero-stats">
          <div className="stat-card">
            <Icons.Download size={20} className="stat-icon cyan" />
            <span className="stat-value">{appDetails.downloads}</span>
            <span className="stat-label">Downloads</span>
          </div>
          <div className="stat-card">
            <Icons.Star size={20} className="stat-icon yellow" />
            <span className="stat-value">{appDetails.rating}</span>
            <span className="stat-label">Rating</span>
          </div>
          <div className="stat-card">
            <Icons.Users size={20} className="stat-icon purple" />
            <span className="stat-value">{appDetails.activeUsers}</span>
            <span className="stat-label">Active Testers</span>
          </div>
        </div>
      </div>

      {/* Main Grid */}
      <div className="landing-grid">
        {/* Left Column: Tabs Content */}
        <div className="glass-card">
          <div className="tabs-header">
            <button
              className={`tab-btn ${activeTab === 'details' ? 'active' : ''}`}
              onClick={() => setActiveTab('details')}
            >
              <Icons.Info size={16} />
              <span>Details & Specs</span>
            </button>
            <button
              className={`tab-btn ${activeTab === 'releases' ? 'active' : ''}`}
              onClick={() => setActiveTab('releases')}
            >
              <Icons.History size={16} />
              <span>Release History</span>
            </button>
          </div>

          <div className="tab-content">
            {activeTab === 'details' ? (
              <div className="details-tab">
                <div>
                  <h3>About {appDetails.name}</h3>
                  <p className="text-secondary mt-2" style={{ lineHeight: '1.6' }}>
                    TestAPK is a premium APK release management platform. The companion mobile app allows testers to get instant notifications of new builds, view release notes, and install updates with a single tap.
                  </p>
                </div>

                <div>
                  <h3>App Icon</h3>
                  <div className="screenshots-grid">
                    <div
                      className="screenshot-card flex-center"
                      style={{ background: 'rgba(255, 255, 255, 0.02)', overflow: 'hidden', padding: '20px' }}
                    >
                      <img src={logoImg} alt="TestAPK Logo Large" style={{ width: '100%', height: '100%', objectFit: 'contain', borderRadius: '24px' }} />
                    </div>
                  </div>
                </div>

                <div className="app-info-specs">
                  <h3>Technical Specifications</h3>
                  <div className="specs-grid">
                    <div className="spec-item">
                      <span className="spec-label">Package Name</span>
                      <span className="spec-value">{appDetails.packageName}</span>
                    </div>
                    <div className="spec-item">
                      <span className="spec-label">Latest Version</span>
                      <span className="spec-value">v{latestRelease.version}</span>
                    </div>
                    <div className="spec-item">
                      <span className="spec-label">Category</span>
                      <span className="spec-value">{appDetails.category}</span>
                    </div>
                    <div className="spec-item">
                      <span className="spec-label">Min SDK Version</span>
                      <span className="spec-value">{appDetails.minSdk}</span>
                    </div>
                  </div>
                </div>
              </div>
            ) : (
              <div className="releases-tab">
                <h3>All Releases</h3>
                <div className="releases-timeline">
                  {appDetails.releases.map((release, index) => (
                    <div key={index} className="release-timeline-item">
                      <div className="release-timeline-badge" />
                      <div className="release-timeline-content glass-card">
                        <div className="release-header">
                          <div className="release-title-info">
                            <h4>Version {release.version}</h4>
                            <span className="badge badge-secondary">Build {release.buildNumber}</span>
                          </div>
                          <span className="release-date">
                            {new Date(release.date).toLocaleDateString(undefined, {
                              year: 'numeric',
                              month: 'short',
                              day: 'numeric',
                            })}
                          </span>
                        </div>

                        <div className="release-notes">
                          <h5>What's New:</h5>
                          <p>{release.releaseNotes}</p>
                        </div>

                        <div className="release-footer" style={{ flexWrap: 'wrap', gap: '12px' }}>
                          <span className="release-size">
                            <Icons.FileText size={14} />
                            <span>{release.size}</span>
                          </span>
                          <a
                            href="https://github.com/Subrata2402/test-apk/releases/download/v1.0.0%2B1/testapk_v1.0.0+1.apk"
                            download="testapk.apk"
                            className="btn btn-primary btn-sm flex-center gap-1"
                            style={{ textDecoration: 'none' }}
                          >
                            <Icons.Download size={12} />
                            <span>Download APK</span>
                          </a>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Right Column: Sidebar Widgets */}
        <div className="landing-sidebar">
          {/* Security Verification Widget */}
          <div className="sidebar-widget glass-card">
            <h3>Security Verification</h3>
            <div className="security-item">
              <Icons.ShieldCheck size={24} className="text-success" style={{ marginTop: '2px' }} />
              <div>
                <span className="security-title">SHA-256 Verified</span>
                <p className="security-desc mt-1">All APKs are automatically scanned and verified using SHA-256 checksums to ensure they haven't been tampered with.</p>
              </div>
            </div>
            <div className="security-item">
              <Icons.Lock size={24} className="text-cyan" style={{ marginTop: '2px' }} />
              <div>
                <span className="security-title">Secure Delivery</span>
                <p className="security-desc mt-1">APKs are stored securely in Google Drive and delivered via encrypted HTTPS connections.</p>
              </div>
            </div>
          </div>

          {/* Developer Info Widget */}
          <div className="sidebar-widget glass-card">
            <h3>Developer Info</h3>
            <div className="dev-info-item">
              <Icons.Globe size={16} />
              <span>Website: <a href="#" onClick={(e) => e.preventDefault()}>testapk.clipboux.online</a></span>
            </div>
            <div className="dev-info-item">
              <Icons.Mail size={16} />
              <span>Support: <a href="mailto:support@clipboux.online">support@clipboux.online</a></span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

import React, { useState } from 'react';
import * as Icons from 'lucide-react';
import './LandingPage.css';

export default function LandingPage({ app, onLoginClick, showAlert }) {
  const [activeTab, setActiveTab] = useState('details'); // 'details' | 'releases'

  if (!app) {
    return (
      <div className="flex-center" style={{ minHeight: '80vh', flexDirection: 'column', gap: '20px' }}>
        <Icons.AlertCircle size={48} color="var(--accent-primary)" />
        <h2>No Application Selected</h2>
        <p>Please select an application or sign in to manage your apps.</p>
        <button className="btn btn-primary" onClick={onLoginClick}>
          <Icons.LogIn size={18} /> Sign In with Google
        </button>
      </div>
    );
  }

  const latestRelease = app.releases && app.releases.length > 0 ? app.releases[0] : null;

  const handleDownload = (release) => {
    if (!release || !release.downloadUrl) {
      showAlert('Download URL not available for this release', 'Error', 'error');
      return;
    }
    window.open(release.downloadUrl, '_blank');
  };

  return (
    <div className="landing-container container">
      {/* Hero Section */}
      <div className="hero-section glass-card">
        <div className="hero-content">
          <div className="app-meta-header">
            <div className="app-icon-wrapper">
              <Icons.Smartphone size={48} className="app-icon-svg" />
            </div>
            <div className="app-title-area">
              <h1>{app.name}</h1>
              <span className="package-name">{app.packageName}</span>
            </div>
          </div>

          <p className="app-description">{app.description}</p>

          <div className="hero-actions">
            {latestRelease ? (
              <button
                className="btn btn-primary btn-lg flex-center gap-2"
                onClick={() => handleDownload(latestRelease)}
              >
                <Icons.Download size={20} />
                <span>Download Latest APK (v{latestRelease.version})</span>
              </button>
            ) : (
              <button className="btn btn-secondary btn-lg" disabled>
                No Releases Available
              </button>
            )}
            <button className="btn btn-secondary btn-lg flex-center gap-2" onClick={onLoginClick}>
              <Icons.LogIn size={20} />
              <span>Developer Portal</span>
            </button>
          </div>
        </div>

        <div className="hero-stats">
          <div className="stat-card">
            <Icons.Download size={20} className="stat-icon cyan" />
            <span className="stat-value">{app.downloads || '0'}</span>
            <span className="stat-label">Downloads</span>
          </div>
          <div className="stat-card">
            <Icons.Star size={20} className="stat-icon yellow" />
            <span className="stat-value">{app.rating || '0.0'}</span>
            <span className="stat-label">Rating</span>
          </div>
          <div className="stat-card">
            <Icons.Users size={20} className="stat-icon purple" />
            <span className="stat-value">{app.activeUsers || '0'}</span>
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
                  <h3>About {app.name}</h3>
                  <p className="text-secondary mt-2" style={{ lineHeight: '1.6' }}>
                    {app.description || 'No description provided by the developer.'}
                  </p>
                </div>

                <div>
                  <h3>Screenshots</h3>
                  <div className="screenshots-grid">
                    {app.screenshots && app.screenshots.length > 0 ? (
                      app.screenshots.map((screenshot, index) => (
                        <div
                          key={index}
                          className="screenshot-card"
                          style={{
                            background: screenshot.startsWith('linear-gradient')
                              ? screenshot
                              : `url(${screenshot}) center/cover no-repeat`,
                          }}
                        >
                          <div className="screenshot-overlay">
                            <Icons.Eye size={20} />
                            <span>View Screenshot</span>
                          </div>
                        </div>
                      ))
                    ) : (
                      <div
                        className="screenshot-card flex-center"
                        style={{ background: 'linear-gradient(135deg, #1e1b4b 0%, #311042 100%)' }}
                      >
                        <Icons.Image size={24} color="var(--text-muted)" />
                      </div>
                    )}
                  </div>
                </div>

                <div className="app-info-specs">
                  <h3>Technical Specifications</h3>
                  <div className="specs-grid">
                    <div className="spec-item">
                      <span className="spec-label">Package Name</span>
                      <span className="spec-value">{app.packageName}</span>
                    </div>
                    <div className="spec-item">
                      <span className="spec-label">Latest Version</span>
                      <span className="spec-value">{latestRelease ? `v${latestRelease.version}` : 'N/A'}</span>
                    </div>
                    <div className="spec-item">
                      <span className="spec-label">Category</span>
                      <span className="spec-value">{app.category || 'Android App'}</span>
                    </div>
                    <div className="spec-item">
                      <span className="spec-label">Min SDK Version</span>
                      <span className="spec-value">{latestRelease?.minSdk || 'Android 8.0 (API 26)'}</span>
                    </div>
                  </div>
                </div>
              </div>
            ) : (
              <div className="releases-tab">
                <h3>All Releases</h3>
                {app.releases && app.releases.length > 0 ? (
                  <div className="releases-timeline">
                    {app.releases.map((release) => (
                      <div key={release._id || release.id} className="release-timeline-item">
                        <div className="release-timeline-badge" />
                        <div className="release-timeline-content glass-card">
                          <div className="release-header">
                            <div className="release-title-info">
                              <h4>Version {release.version}</h4>
                              {release.versionCode && (
                                <span className="badge badge-secondary">Build {release.versionCode}</span>
                              )}
                            </div>
                            <span className="release-date">
                              {release.date ? (
                                isNaN(Date.parse(release.date))
                                  ? release.date
                                  : new Date(release.date).toLocaleDateString(undefined, {
                                    year: 'numeric',
                                    month: 'short',
                                    day: 'numeric',
                                  })
                              ) : 'N/A'}
                            </span>
                          </div>

                          <div className="release-notes">
                            <h5>What's New:</h5>
                            <p>{release.releaseNotes || 'No release notes provided.'}</p>
                          </div>

                          <div className="release-footer">
                            <span className="release-size">
                              <Icons.FileText size={14} />
                              <span>{release.size || 'Unknown size'}</span>
                            </span>
                            <button
                              className="btn btn-primary btn-sm flex-center gap-1"
                              onClick={() => handleDownload(release)}
                            >
                              <Icons.Download size={12} />
                              <span>Download APK</span>
                            </button>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="flex-center" style={{ padding: '40px 0', flexDirection: 'column', gap: '12px' }}>
                    <Icons.History size={32} color="var(--text-muted)" />
                    <p className="text-secondary">No release history available.</p>
                  </div>
                )}
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
              <span>Website: <a href="#" onClick={(e) => e.preventDefault()}>aeroplayer.com</a></span>
            </div>
            <div className="dev-info-item">
              <Icons.Mail size={16} />
              <span>Support: <a href="mailto:support@aeroplayer.com">support@aeroplayer.com</a></span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

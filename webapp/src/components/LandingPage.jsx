import React, { useState } from 'react';
import * as Icons from 'lucide-react';

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

  // Helper to render dynamic Lucide icons
  const getIconComponent = (iconName) => {
    const Icon = Icons[iconName];
    return Icon ? Icon : Icons.HelpCircle;
  };

  const IconComponent = getIconComponent(app.icon);
  const latestRelease = app.releases && app.releases.length > 0 ? app.releases[0] : null;

  return (
    <div className="landing-container animate-fade-in">
      {/* Hero Section */}
      <section className="hero-section glass-card">
        <div className="hero-content">
          <div className="app-meta-header">
            <div className="app-icon-wrapper">
              <IconComponent size={48} className="app-icon-svg" />
            </div>
            <div className="app-title-area">
              <h1>{app.name}</h1>
              <code className="package-name">{app.packageName}</code>
            </div>
          </div>

          <p className="app-description">{app.description}</p>

          <div className="hero-actions">
            <button className="btn btn-primary btn-lg" onClick={() => showAlert(`Downloading APK for ${app.name} v${latestRelease?.version || '1.0.0'}...`, 'Download Started', 'success')}>
              <Icons.Download size={20} /> Download Latest APK
            </button>
            <button className="btn btn-secondary" onClick={onLoginClick}>
              <Icons.LogIn size={18} /> Sign In with Google
            </button>
          </div>
        </div>

        <div className="hero-stats">
          <div className="stat-card">
            <Icons.DownloadCloud size={24} className="stat-icon cyan" />
            <div className="stat-value">{app.downloads}</div>
            <div className="stat-label">Downloads</div>
          </div>
          <div className="stat-card">
            <Icons.Star size={24} className="stat-icon yellow" />
            <div className="stat-value">{app.rating} / 5.0</div>
            <div className="stat-label">Rating</div>
          </div>
          <div className="stat-card">
            <Icons.Users size={24} className="stat-icon purple" />
            <div className="stat-value">{app.activeUsers}</div>
            <div className="stat-label">Active Users</div>
          </div>
        </div>
      </section>

      {/* Main Content Area */}
      <div className="landing-grid">
        {/* Left Column: Screenshots & Details */}
        <div className="landing-main">
          <div className="tabs-header">
            <button
              className={`tab-btn ${activeTab === 'details' ? 'active' : ''}`}
              onClick={() => setActiveTab('details')}
            >
              <Icons.Info size={16} /> App Details
            </button>
            <button
              className={`tab-btn ${activeTab === 'releases' ? 'active' : ''}`}
              onClick={() => setActiveTab('releases')}
            >
              <Icons.History size={16} /> Release History ({app.releases?.length || 0})
            </button>
          </div>

          <div className="tab-content glass-card">
            {activeTab === 'details' ? (
              <div className="details-tab animate-fade-in">
                <h3>Screenshots</h3>
                <div className="screenshots-grid">
                  {app.screenshots.map((bg, idx) => (
                    <div
                      key={idx}
                      className="screenshot-card"
                      style={{ background: bg }}
                    >
                      <div className="screenshot-overlay">
                        <Icons.Eye size={24} />
                        <span>Screenshot {idx + 1}</span>
                      </div>
                    </div>
                  ))}
                </div>

                <div className="app-info-specs">
                  <h3>Technical Specifications</h3>
                  <div className="specs-grid">
                    <div className="spec-item">
                      <span className="spec-label">Latest Version</span>
                      <span className="spec-value">{latestRelease?.version || 'N/A'}</span>
                    </div>
                    <div className="spec-item">
                      <span className="spec-label">Build Number</span>
                      <span className="spec-value">#{latestRelease?.buildNumber || 'N/A'}</span>
                    </div>
                    <div className="spec-item">
                      <span className="spec-label">File Size</span>
                      <span className="spec-value">{latestRelease?.size || 'N/A'}</span>
                    </div>
                    <div className="spec-item">
                      <span className="spec-label">Last Updated</span>
                      <span className="spec-value">{latestRelease?.date || 'N/A'}</span>
                    </div>
                  </div>
                </div>
              </div>
            ) : (
              <div className="releases-tab animate-fade-in">
                <h3>All Releases</h3>
                <div className="releases-timeline">
                  {app.releases && app.releases.map((release, idx) => (
                    <div key={idx} className="release-timeline-item">
                      <div className="release-timeline-badge">
                        <Icons.GitCommit size={16} />
                      </div>
                      <div className="release-timeline-content glass-card">
                        <div className="release-header">
                          <div className="release-title-info">
                            <h4>Version {release.version}</h4>
                            <span className="badge badge-secondary">Build #{release.buildNumber}</span>
                          </div>
                          <span className="release-date">{release.date}</span>
                        </div>
                        <p className="release-notes">{release.releaseNotes}</p>
                        <div className="release-footer">
                          <span className="release-size"><Icons.File size={14} /> {release.size}</span>
                          <button className="btn btn-secondary btn-sm" onClick={() => showAlert(`Downloading APK v${release.version}...`, 'Download Started', 'success')}>
                            <Icons.Download size={14} /> Download APK
                          </button>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Right Column: Sidebar info */}
        <div className="landing-sidebar">
          <div className="glass-card sidebar-widget">
            <h3>Security Verified</h3>
            <div className="security-item">
              <Icons.ShieldCheck size={20} className="text-success" />
              <div>
                <div className="security-title">Play Protect Certified</div>
                <div className="security-desc">Scanned and verified safe from malware.</div>
              </div>
            </div>
            <div className="security-item">
              <Icons.Lock size={20} className="text-cyan" />
              <div>
                <div className="security-title">Secure Connection</div>
                <div className="security-desc">All downloads are served over encrypted HTTPS.</div>
              </div>
            </div>
          </div>

          <div className="glass-card sidebar-widget">
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

      {/* CSS Styles specific to Landing Page */}
      <style>{`
        .landing-container {
          display: flex;
          flex-direction: column;
          gap: 32px;
          padding: 40px 0;
        }

        .hero-section {
          display: grid;
          grid-template-columns: 2fr 1fr;
          gap: 40px;
          padding: 48px;
          align-items: center;
          position: relative;
          overflow: hidden;
        }

        @media (max-width: 768px) {
          .hero-section {
            grid-template-columns: 1fr;
            padding: 24px;
            gap: 24px;
          }
        }

        .hero-content {
          display: flex;
          flex-direction: column;
          gap: 24px;
          text-align: left;
        }

        .app-meta-header {
          display: flex;
          align-items: center;
          gap: 24px;
        }

        .app-icon-wrapper {
          width: 96px;
          height: 96px;
          border-radius: 24px;
          background: linear-gradient(135deg, var(--accent-primary) 0%, var(--accent-secondary) 100%);
          display: flex;
          align-items: center;
          justify-content: center;
          box-shadow: 0 8px 32px 0 rgba(139, 92, 246, 0.3);
        }

        .app-icon-svg {
          color: #ffffff;
        }

        .app-title-area {
          display: flex;
          flex-direction: column;
          align-items: flex-start;
          gap: 6px;
        }

        .app-title-area h1 {
          font-size: 2.5rem;
          line-height: 1.1;
        }

        .package-name {
          font-size: 0.85rem;
          color: var(--text-secondary);
          background: rgba(255, 255, 255, 0.05);
          padding: 2px 8px;
          border-radius: 4px;
        }

        .app-description {
          font-size: 1.1rem;
          color: var(--text-secondary);
        }

        .hero-actions {
          display: flex;
          gap: 16px;
          flex-wrap: wrap;
        }

        .btn-lg {
          padding: 14px 28px;
          font-size: 1.05rem;
          border-radius: 12px;
        }

        .hero-stats {
          display: flex;
          flex-direction: column;
          gap: 16px;
        }

        @media (max-width: 768px) {
          .hero-stats {
            flex-direction: row;
            justify-content: space-between;
          }
        }

        .stat-card {
          background: rgba(255, 255, 255, 0.02);
          border: 1px solid var(--border-color);
          border-radius: 12px;
          padding: 20px;
          text-align: center;
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 6px;
        }

        @media (max-width: 768px) {
          .stat-card {
            flex: 1;
            padding: 12px;
          }
        }

        .stat-icon {
          margin-bottom: 4px;
        }

        .stat-icon.cyan { color: var(--accent-secondary); }
        .stat-icon.yellow { color: var(--accent-warning); }
        .stat-icon.purple { color: var(--accent-primary); }

        .stat-value {
          font-size: 1.5rem;
          font-weight: 800;
          color: #ffffff;
        }

        .stat-label {
          font-size: 0.8rem;
          color: var(--text-muted);
          text-transform: uppercase;
          letter-spacing: 0.05em;
        }

        /* Landing Grid */
        .landing-grid {
          display: grid;
          grid-template-columns: 2.5fr 1fr;
          gap: 32px;
          text-align: left;
        }

        @media (max-width: 992px) {
          .landing-grid {
            grid-template-columns: 1fr;
          }
        }

        .tabs-header {
          display: flex;
          gap: 8px;
          margin-bottom: 16px;
          border-bottom: 1px solid var(--border-color);
          padding-bottom: 8px;
        }

        .tab-btn {
          background: transparent;
          border: none;
          color: var(--text-secondary);
          padding: 10px 16px;
          font-size: 0.95rem;
          font-weight: 600;
          cursor: pointer;
          display: flex;
          align-items: center;
          gap: 8px;
          border-radius: 8px;
          transition: var(--transition-smooth);
        }

        .tab-btn:hover {
          color: #ffffff;
          background: rgba(255, 255, 255, 0.03);
        }

        .tab-btn.active {
          color: var(--accent-primary);
          background: var(--accent-primary-glow);
        }

        .tab-content {
          padding: 32px;
        }

        @media (max-width: 768px) {
          .tab-content {
            padding: 20px;
          }
        }

        .details-tab, .releases-tab {
          display: flex;
          flex-direction: column;
          gap: 24px;
        }

        .screenshots-grid {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
          gap: 16px;
          margin-top: 8px;
        }

        .screenshot-card {
          aspect-ratio: 9/16;
          border-radius: 12px;
          position: relative;
          overflow: hidden;
          cursor: pointer;
          border: 1px solid var(--border-color);
          box-shadow: 0 4px 12px rgba(0,0,0,0.2);
          transition: var(--transition-smooth);
        }

        .screenshot-card:hover {
          transform: scale(1.03);
          border-color: var(--accent-primary);
        }

        .screenshot-overlay {
          position: absolute;
          inset: 0;
          background: rgba(0, 0, 0, 0.6);
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          gap: 8px;
          opacity: 0;
          transition: var(--transition-smooth);
        }

        .screenshot-card:hover .screenshot-overlay {
          opacity: 1;
        }

        .screenshot-overlay span {
          font-size: 0.85rem;
          font-weight: 600;
        }

        .app-info-specs {
          display: flex;
          flex-direction: column;
          gap: 16px;
          margin-top: 16px;
        }

        .specs-grid {
          display: grid;
          grid-template-columns: repeat(2, 1fr);
          gap: 16px;
        }

        @media (max-width: 576px) {
          .specs-grid {
            grid-template-columns: 1fr;
          }
        }

        .spec-item {
          background: rgba(255, 255, 255, 0.01);
          border: 1px solid var(--border-color);
          padding: 16px;
          border-radius: 10px;
          display: flex;
          flex-direction: column;
          gap: 4px;
        }

        .spec-label {
          font-size: 0.8rem;
          color: var(--text-muted);
          text-transform: uppercase;
        }

        .spec-value {
          font-size: 1.1rem;
          font-weight: 600;
          color: #ffffff;
        }

        /* Releases Timeline */
        .releases-timeline {
          display: flex;
          flex-direction: column;
          gap: 20px;
          position: relative;
          padding-left: 24px;
        }

        .releases-timeline::before {
          content: '';
          position: absolute;
          left: 7px;
          top: 8px;
          bottom: 8px;
          width: 2px;
          background: var(--border-color);
        }

        .release-timeline-item {
          position: relative;
        }

        .release-timeline-badge {
          position: absolute;
          left: -24px;
          top: 16px;
          width: 16px;
          height: 16px;
          border-radius: 50%;
          background: var(--bg-dark);
          border: 2px solid var(--accent-primary);
          display: flex;
          align-items: center;
          justify-content: center;
          color: var(--accent-primary);
        }

        .release-timeline-content {
          padding: 20px;
        }

        .release-header {
          display: flex;
          justify-content: space-between;
          align-items: flex-start;
          margin-bottom: 12px;
          flex-wrap: wrap;
          gap: 8px;
        }

        .release-title-info {
          display: flex;
          align-items: center;
          gap: 12px;
        }

        .release-date {
          font-size: 0.85rem;
          color: var(--text-muted);
        }

        .release-notes {
          font-size: 0.95rem;
          color: var(--text-secondary);
          margin-bottom: 16px;
          white-space: pre-line;
        }

        .release-footer {
          display: flex;
          justify-content: space-between;
          align-items: center;
          border-top: 1px solid var(--border-color);
          padding-top: 12px;
        }

        .release-size {
          font-size: 0.85rem;
          color: var(--text-muted);
          display: flex;
          align-items: center;
          gap: 4px;
        }

        .btn-sm {
          padding: 6px 12px;
          font-size: 0.8rem;
          border-radius: 6px;
        }

        /* Sidebar Widgets */
        .landing-sidebar {
          display: flex;
          flex-direction: column;
          gap: 24px;
        }

        .sidebar-widget {
          padding: 24px;
          display: flex;
          flex-direction: column;
          gap: 16px;
        }

        .security-item {
          display: flex;
          gap: 16px;
          align-items: flex-start;
        }

        .security-title {
          font-weight: 600;
          font-size: 0.95rem;
          color: #ffffff;
        }

        .security-desc {
          font-size: 0.85rem;
          color: var(--text-secondary);
        }

        .text-success { color: var(--accent-success); }
        .text-cyan { color: var(--accent-secondary); }

        .dev-info-item {
          display: flex;
          align-items: center;
          gap: 12px;
          font-size: 0.9rem;
          color: var(--text-secondary);
        }

        .dev-info-item a {
          color: var(--accent-primary);
          text-decoration: none;
        }

        .dev-info-item a:hover {
          text-decoration: underline;
        }
      `}</style>
    </div>
  );
}

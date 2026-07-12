import React, { useState } from 'react';
import * as Icons from 'lucide-react';
import AppDetails from './AppDetails';

export default function Dashboard({ user, apps, selectedAppId, onSelectApp, onCreateApp, onLogout, onOpenCreateModal, showAlert, showConfirm }) {
  const selectedApp = apps.find(app => (app._id === selectedAppId || app.id === selectedAppId));

  return (
    <div className="dashboard-container animate-fade-in">
      {/* Sidebar */}
      <aside className="dashboard-sidebar glass-card">
        <div className="sidebar-header">
          <div className="logo-area">
            <Icons.Cpu size={24} className="logo-icon" />
            <span className="logo-text">APK Manager</span>
          </div>
          <button className="btn btn-primary btn-sm" onClick={onOpenCreateModal} title="Create New App" style={{ width: '100%' }}>
            <Icons.Plus size={16} /> Create App
          </button>
        </div>

        <div className="sidebar-nav">
          <div className="nav-section-title">My Applications</div>
          <div className="apps-list">
            {apps.length === 0 ? (
              <div style={{ padding: '20px 8px', textAlign: 'center', fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                No applications yet.
              </div>
            ) : (
              apps.map((app) => {
                const AppIcon = Icons[app.icon] || Icons.HelpCircle;
                const appId = app._id || app.id;
                const isSelected = appId === selectedAppId;
                return (
                  <button
                    key={appId}
                    className={`app-nav-item ${isSelected ? 'active' : ''}`}
                    onClick={() => onSelectApp(appId)}
                  >
                    <div className="app-nav-icon-wrapper">
                      <AppIcon size={16} />
                    </div>
                    <div className="app-nav-info">
                      <span className="app-nav-name">{app.name}</span>
                      <span className="app-nav-package">{app.packageName}</span>
                    </div>
                  </button>
                );
              })
            )}
          </div>
        </div>

        <div className="sidebar-footer">
          <div className="user-profile-widget">
            <div className="user-avatar">{user.avatar}</div>
            <div className="user-info">
              <div className="user-name">{user.name}</div>
              <div className="user-email">{user.email}</div>
            </div>
            <button className="logout-btn" onClick={onLogout} title="Sign Out">
              <Icons.LogOut size={18} />
            </button>
          </div>
        </div>
      </aside>

      {/* Main Content Area */}
      <main className="dashboard-main">
        {selectedApp ? (
          <AppDetails
            app={selectedApp}
            user={user}
            onUpdateApp={(updatedApp) => {
              onCreateApp(updatedApp, true); // true indicates update
            }}
            showAlert={showAlert}
            showConfirm={showConfirm}
          />
        ) : apps.length === 0 ? (
          <div className="welcome-screen glass-card flex-center">
            <Icons.Cpu size={48} className="welcome-icon" />
            <h2>Create your first application</h2>
            <p>You don't have any applications registered yet. Create an application to start uploading releases and inviting collaborators.</p>
            <div className="welcome-actions">
              <button className="btn btn-primary" onClick={onOpenCreateModal}>
                <Icons.Plus size={18} /> Create Application
              </button>
            </div>
          </div>
        ) : (
          <div className="welcome-screen glass-card flex-center">
            <Icons.Sparkles size={48} className="welcome-icon" />
            <h2>Welcome back, {user.name.split(' ')[0]}!</h2>
            <p>Select an application from the sidebar to view details, invite developers, or upload new releases.</p>
            <div className="welcome-actions">
              <button className="btn btn-primary" onClick={onOpenCreateModal}>
                <Icons.Plus size={18} /> Create New Application
              </button>
            </div>

            <div className="quick-access-section">
              <h3>Quick Access</h3>
              <div className="quick-apps-grid">
                {apps.map((app) => {
                  const AppIcon = Icons[app.icon] || Icons.HelpCircle;
                  const appId = app._id || app.id;
                  return (
                    <button
                      key={appId}
                      className="quick-app-card glass-card"
                      onClick={() => onSelectApp(appId)}
                    >
                      <AppIcon size={24} className="quick-app-icon" />
                      <h4>{app.name}</h4>
                      <code>{app.packageName}</code>
                    </button>
                  );
                })}
              </div>
            </div>
          </div>
        )}
      </main>



      <style>{`
        .dashboard-container {
          display: grid;
          grid-template-columns: 280px 1fr;
          min-height: 100vh;
          background: rgba(0, 0, 0, 0.2);
        }

        @media (max-width: 768px) {
          .dashboard-container {
            grid-template-columns: 1fr;
          }
          .dashboard-sidebar {
            display: none; /* In a real app we'd have a hamburger menu, let's keep it simple or implement a toggle later */
          }
        }

        .dashboard-sidebar {
          border-radius: 0;
          border-top: none;
          border-bottom: none;
          border-left: none;
          display: flex;
          flex-direction: column;
          height: calc(100vh - 64px);
          position: sticky;
          top: 64px;
          z-index: 10;
        }

        .sidebar-header {
          padding: 24px;
          border-bottom: 1px solid var(--border-color);
          display: flex;
          flex-direction: column;
          align-items: stretch;
          gap: 16px;
        }

        .logo-area {
          display: flex;
          align-items: center;
          gap: 10px;
        }

        .logo-icon {
          color: var(--accent-primary);
        }

        .logo-text {
          font-weight: 700;
          font-size: 1.1rem;
          letter-spacing: -0.01em;
        }

        .sidebar-nav {
          flex: 1;
          padding: 24px 16px;
          overflow-y: auto;
          display: flex;
          flex-direction: column;
          gap: 16px;
        }

        .nav-section-title {
          font-size: 0.75rem;
          font-weight: 700;
          color: var(--text-muted);
          text-transform: uppercase;
          letter-spacing: 0.05em;
          padding-left: 8px;
        }

        .apps-list {
          display: flex;
          flex-direction: column;
          gap: 6px;
        }

        .app-nav-item {
          display: flex;
          align-items: center;
          gap: 12px;
          padding: 10px 12px;
          border-radius: 10px;
          background: transparent;
          border: 1px solid transparent;
          color: var(--text-secondary);
          cursor: pointer;
          text-align: left;
          width: 100%;
          transition: var(--transition-smooth);
        }

        .app-nav-item:hover {
          background: rgba(255, 255, 255, 0.02);
          color: #ffffff;
        }

        .app-nav-item.active {
          background: var(--accent-primary-glow);
          border-color: rgba(139, 92, 246, 0.2);
          color: #ffffff;
        }

        .app-nav-icon-wrapper {
          width: 32px;
          height: 32px;
          border-radius: 8px;
          background: rgba(255, 255, 255, 0.05);
          display: flex;
          align-items: center;
          justify-content: center;
          color: var(--text-secondary);
          transition: var(--transition-smooth);
        }

        .app-nav-item.active .app-nav-icon-wrapper {
          background: var(--accent-primary);
          color: #ffffff;
        }

        .app-nav-info {
          display: flex;
          flex-direction: column;
          overflow: hidden;
        }

        .app-nav-name {
          font-weight: 600;
          font-size: 0.9rem;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }

        .app-nav-package {
          font-size: 0.75rem;
          color: var(--text-muted);
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }

        .sidebar-footer {
          padding: 20px;
          border-top: 1px solid var(--border-color);
        }

        .user-profile-widget {
          display: flex;
          align-items: center;
          gap: 12px;
          position: relative;
        }

        .user-avatar {
          width: 36px;
          height: 36px;
          border-radius: 50%;
          background: var(--accent-secondary);
          color: #ffffff;
          font-weight: 700;
          font-size: 0.85rem;
          display: flex;
          align-items: center;
          justify-content: center;
        }

        .user-info {
          display: flex;
          flex-direction: column;
          flex: 1;
          overflow: hidden;
          text-align: left;
        }

        .user-name {
          font-weight: 600;
          font-size: 0.85rem;
          color: #ffffff;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }

        .user-email {
          font-size: 0.75rem;
          color: var(--text-muted);
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }

        .logout-btn {
          background: transparent;
          border: none;
          color: var(--text-muted);
          cursor: pointer;
          padding: 6px;
          border-radius: 6px;
          display: flex;
          align-items: center;
          justify-content: center;
          transition: var(--transition-smooth);
        }

        .logout-btn:hover {
          background: rgba(239, 68, 68, 0.1);
          color: var(--accent-danger);
        }

        /* Main Area */
        .dashboard-main {
          padding: 40px;
          overflow-y: auto;
          height: calc(100vh - 64px);
        }

        @media (max-width: 768px) {
          .dashboard-main {
            padding: 20px;
            height: auto;
          }
        }

        .welcome-screen {
          height: 100%;
          min-height: 500px;
          flex-direction: column;
          gap: 20px;
          padding: 48px;
          text-align: center;
        }

        .welcome-icon {
          color: var(--accent-primary);
          animation: float 3s ease-in-out infinite;
        }

        @keyframes float {
          0%, 100% { transform: translateY(0); }
          50% { transform: translateY(-10px); }
        }

        .welcome-screen h2 {
          font-size: 2rem;
        }

        .welcome-screen p {
          max-width: 500px;
        }

        .quick-access-section {
          margin-top: 40px;
          width: 100%;
          max-width: 600px;
          display: flex;
          flex-direction: column;
          gap: 16px;
          text-align: left;
        }

        .quick-access-section h3 {
          font-size: 1.1rem;
          color: var(--text-secondary);
        }

        .quick-apps-grid {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
          gap: 16px;
        }

        .quick-app-card {
          padding: 20px;
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 10px;
          cursor: pointer;
          text-align: center;
          background: rgba(255, 255, 255, 0.01);
        }

        .quick-app-card:hover {
          transform: translateY(-2px);
          border-color: var(--accent-primary);
        }

        .quick-app-icon {
          color: var(--accent-primary);
        }

        .quick-app-card h4 {
          font-size: 0.95rem;
          margin: 0;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
          width: 100%;
        }

        .quick-app-card code {
          font-size: 0.75rem;
          color: var(--text-muted);
        }


      `}</style>
    </div>
  );
}

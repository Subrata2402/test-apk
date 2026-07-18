import React, { useState } from 'react';
import * as Icons from 'lucide-react';
import AppDetails from '../components/dashboard/AppDetails';
import AboutPage from './AboutPage';
import './Dashboard.css';

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
          <button className="btn btn-primary flex-center gap-2" onClick={onOpenCreateModal}>
            <Icons.Plus size={16} />
            <span>Create App</span>
          </button>
        </div>

        <nav className="sidebar-nav">
          <div className="nav-section">
            <span className="nav-section-title">Applications</span>
            <div className="apps-list mt-3">
              {apps.map((app) => {
                const isSelected = app._id === selectedAppId || app.id === selectedAppId;
                return (
                  <button
                    key={app._id || app.id}
                    className={`app-nav-item ${isSelected ? 'active' : ''}`}
                    onClick={() => onSelectApp(app._id || app.id)}
                  >
                    <div className="app-nav-icon-wrapper">
                      <Icons.Smartphone size={18} />
                    </div>
                    <div className="app-nav-info">
                      <span className="app-nav-name">{app.name}</span>
                      <span className="app-nav-package">{app.packageName}</span>
                    </div>
                  </button>
                );
              })}
            </div>
          </div>

          <div className="nav-section" style={{ marginTop: 'auto', paddingTop: '16px', borderTop: '1px solid rgba(255, 255, 255, 0.08)' }}>
            <button
              className={`app-nav-item ${selectedAppId === 'about' ? 'active' : ''}`}
              onClick={() => onSelectApp('about')}
            >
              <div className="app-nav-icon-wrapper" style={{ background: 'rgba(99, 102, 241, 0.1)', color: '#6366f1' }}>
                <Icons.Info size={18} />
              </div>
              <div className="app-nav-info">
                <span className="app-nav-name">About TestAPK</span>
                <span className="app-nav-package">System Info & Docs</span>
              </div>
            </button>
          </div>
        </nav>

        <div className="sidebar-footer">
          <div className="user-profile-widget">
            <div className="user-avatar">
              {user.avatar || (user.name ? user.name.substring(0, 2).toUpperCase() : 'US')}
            </div>
            <div className="user-info">
              <span className="user-name" style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                <span>{user.name}</span>
                {user.isDriveConfigured ? (
                  <Icons.Cloud size={14} style={{ color: 'var(--accent-success)' }} title="Google Drive Connected" />
                ) : (
                  <Icons.CloudOff size={14} style={{ color: 'var(--accent-warning)' }} title="Google Drive Not Connected" />
                )}
              </span>
              <span className="user-email">{user.email}</span>
            </div>
            <button 
              className="logout-btn" 
              onClick={() => {
                const token = localStorage.getItem('token');
                if (token) {
                  navigator.clipboard.writeText(token);
                  showAlert('API Token copied to clipboard!', 'Success', 'success');
                }
              }} 
              title="Copy API Token"
              style={{ marginRight: '4px' }}
            >
              <Icons.Key size={18} />
            </button>
            <button
              className="logout-btn"
              onClick={() => {
                showConfirm(
                  'Are you sure you want to log out?',
                  onLogout,
                  'Logout'
                );
              }}
              title="Logout"
            >
              <Icons.LogOut size={18} />
            </button>
          </div>
        </div>
      </aside>

      {/* Main Content Area */}
      <main className="dashboard-main">
        {selectedAppId === 'about' ? (
          <AboutPage showAlert={showAlert} />
        ) : selectedApp ? (
          <AppDetails
            app={selectedApp}
            user={user}
            onUpdateApp={(updatedApp) => onCreateApp(updatedApp, true)}
            showAlert={showAlert}
            showConfirm={showConfirm}
          />
        ) : (
          <div className="welcome-screen flex-center">
            <Icons.Cpu size={64} className="welcome-icon" />
            <h2>Welcome to APK Manager</h2>
            <p className="text-secondary">Select an application from the sidebar or create a new one to manage releases, collaborators, and downloads.</p>

            <div className="quick-access-section">
              <h3>Quick Access</h3>
              <div className="quick-apps-grid">
                {apps.map((app) => {
                  return (
                    <button
                      key={app._id || app.id}
                      className="quick-app-card glass-card"
                      onClick={() => onSelectApp(app._id || app.id)}
                    >
                      <Icons.Smartphone size={24} className="quick-app-icon" />
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
    </div>
  );
}

import React, { useState } from 'react';
import * as Icons from 'lucide-react';
import { initialApps } from './mockData';
import LandingPage from './components/LandingPage';
import Dashboard from './components/Dashboard';
import GoogleLoginModal from './components/GoogleLoginModal';
import CreateAppModal from './components/CreateAppModal';
import CustomDropdown from './components/CustomDropdown';

export default function App() {
  const [user, setUser] = useState(null); // { name, email, avatar }
  const [apps, setApps] = useState(initialApps);
  const [selectedAppId, setSelectedAppId] = useState(initialApps[0]?.id || null);
  const [currentView, setCurrentView] = useState('landing'); // 'landing' | 'dashboard'
  const [isLoginModalOpen, setIsLoginModalOpen] = useState(false);
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);

  const fetchApps = async (token) => {
    try {
      const response = await fetch(`${import.meta.env.VITE_API_URL}/apps`, {
        headers: {
          'Authorization': `Bearer ${token}`,
        },
      });
      const data = await response.json();
      if (response.ok && data.status === 'success') {
        setApps(data.data.apps);
        if (data.data.apps.length > 0) {
          setSelectedAppId(data.data.apps[0]._id || data.data.apps[0].id);
        } else {
          setSelectedAppId(null);
        }
      }
    } catch (err) {
      console.error('Failed to fetch apps:', err);
    }
  };

  React.useEffect(() => {
    const checkLoggedIn = async () => {
      const token = localStorage.getItem('token');
      if (!token) return;

      try {
        const response = await fetch(`${import.meta.env.VITE_API_URL}/users/me`, {
          headers: {
            'Authorization': `Bearer ${token}`,
          },
        });

        const data = await response.json();

        if (response.ok && data.status === 'success') {
          setUser({
            name: data.data.user.name,
            email: data.data.user.email,
            avatar: data.data.user.name.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase(),
            picture: data.data.user.picture,
            role: data.data.user.role,
          });
          setCurrentView('dashboard');
          fetchApps(token);
        } else {
          localStorage.removeItem('token');
        }
      } catch (err) {
        console.error('Auto-login failed:', err);
        localStorage.removeItem('token');
      }
    };

    checkLoggedIn();
  }, []);

  const handleLoginSuccess = (userData) => {
    setUser(userData);
    setCurrentView('dashboard');
    const token = localStorage.getItem('token');
    if (token) {
      fetchApps(token);
    }
  };

  const handleLogout = async () => {
    const token = localStorage.getItem('token');
    if (token) {
      try {
        await fetch(`${import.meta.env.VITE_API_URL}/auth/logout`, {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${token}`,
          },
        });
      } catch (err) {
        console.error('Logout API call failed:', err);
      }
    }
    localStorage.removeItem('token');
    setUser(null);
    setApps(initialApps);
    setSelectedAppId(initialApps[0]?.id || null);
    setCurrentView('landing');
  };

  const [alertConfig, setAlertConfig] = useState(null); // { title, message, type: 'error' | 'success' | 'info' }
  const [confirmConfig, setConfirmConfig] = useState(null); // { title, message, onConfirm }

  const showAlert = (message, title = 'Notification', type = 'info') => {
    setAlertConfig({ title, message, type });
  };

  const showConfirm = (message, onConfirm, title = 'Are you sure?') => {
    setConfirmConfig({ title, message, onConfirm });
  };

  const handleCreateApp = async (newAppOrUpdatedApp, isUpdate = false) => {
    if (isUpdate) {
      setApps(apps.map(a => (a._id === newAppOrUpdatedApp._id || a.id === newAppOrUpdatedApp.id) ? newAppOrUpdatedApp : a));
    } else {
      const token = localStorage.getItem('token');
      if (!token) return;

      try {
        const response = await fetch(`${import.meta.env.VITE_API_URL}/apps`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`,
          },
          body: JSON.stringify({
            name: newAppOrUpdatedApp.name,
            packageName: newAppOrUpdatedApp.packageName,
            description: newAppOrUpdatedApp.description,
          }),
        });

        const data = await response.json();
        if (response.ok && data.status === 'success') {
          const createdApp = data.data.app;
          setApps([...apps, createdApp]);
          setSelectedAppId(createdApp._id);
        } else {
          showAlert(data.message || 'Failed to create application', 'Error', 'error');
        }
      } catch (err) {
        console.error('Failed to create app:', err);
        showAlert('Failed to create application', 'Error', 'error');
      }
    }
  };

  const selectedApp = apps.find(app => (app._id === selectedAppId || app.id === selectedAppId));

  return (
    <div className="app-layout">
      {/* Global Navigation Bar */}
      <header className="global-navbar glass-card">
        <div className="container nav-container">
          <div className="nav-logo" onClick={() => setCurrentView('landing')} style={{ cursor: 'pointer' }}>
            <Icons.Cpu size={24} className="logo-icon" />
            <span className="logo-text">APK Release Manager</span>
          </div>

          {currentView === 'landing' && apps.length > 0 && (
            <div className="nav-app-selector" style={{ minWidth: '180px' }}>
              <span className="selector-label">Viewing:</span>
              <CustomDropdown
                options={apps.map(app => ({ value: app.id, label: app.name, icon: app.icon }))}
                value={selectedAppId}
                onChange={setSelectedAppId}
              />
            </div>
          )}

          <div className="nav-actions">
            {user ? (
              <>
                {currentView === 'landing' ? (
                  <button className="btn btn-primary" onClick={() => setCurrentView('dashboard')}>
                    <Icons.LayoutDashboard size={16} /> Go to Dashboard
                  </button>
                ) : (
                  <button className="btn btn-secondary" onClick={() => setCurrentView('landing')}>
                    <Icons.Globe size={16} /> View Public Page
                  </button>
                )}
                <div className="user-nav-profile" title={user.email}>
                  <div className="user-nav-avatar">{user.avatar}</div>
                  <span className="user-nav-name">{user.name.split(' ')[0]}</span>
                </div>
              </>
            ) : (
              <button className="btn btn-primary" onClick={() => setIsLoginModalOpen(true)}>
                <Icons.LogIn size={16} /> Sign In
              </button>
            )}
          </div>
        </div>
      </header>

      {/* Main Content */}
      <div className="container main-content-container">
        {currentView === 'landing' ? (
          <LandingPage
            app={selectedApp}
            onLoginClick={() => setIsLoginModalOpen(true)}
            showAlert={showAlert}
          />
        ) : (
          <Dashboard
            user={user}
            apps={apps}
            selectedAppId={selectedAppId}
            onSelectApp={setSelectedAppId}
            onCreateApp={handleCreateApp}
            onLogout={handleLogout}
            onOpenCreateModal={() => setIsCreateModalOpen(true)}
            showAlert={showAlert}
            showConfirm={showConfirm}
          />
        )}
      </div>

      {/* Google Login Modal */}
      <GoogleLoginModal
        isOpen={isLoginModalOpen}
        onClose={() => setIsLoginModalOpen(false)}
        onLoginSuccess={handleLoginSuccess}
      />

      {/* Create App Modal */}
      <CreateAppModal
        isOpen={isCreateModalOpen}
        onClose={() => setIsCreateModalOpen(false)}
        onCreateApp={handleCreateApp}
        user={user}
        showAlert={showAlert}
      />

      {/* Global Alert Modal */}
      {alertConfig && (
        <div className="modal-overlay" onClick={() => setAlertConfig(null)}>
          <div
            className="modal-content glass-card animate-fade-in"
            style={{ maxWidth: '400px', textAlign: 'center' }}
            onClick={(e) => e.stopPropagation()}
          >
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '16px' }}>
              {alertConfig.type === 'error' ? (
                <div
                  style={{
                    width: '48px',
                    height: '48px',
                    borderRadius: '50%',
                    background: 'rgba(239, 68, 68, 0.1)',
                    color: 'var(--accent-danger)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  <Icons.AlertTriangle size={24} />
                </div>
              ) : alertConfig.type === 'success' ? (
                <div
                  style={{
                    width: '48px',
                    height: '48px',
                    borderRadius: '50%',
                    background: 'rgba(16, 185, 129, 0.1)',
                    color: 'var(--accent-success)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  <Icons.CheckCircle size={24} />
                </div>
              ) : (
                <div
                  style={{
                    width: '48px',
                    height: '48px',
                    borderRadius: '50%',
                    background: 'rgba(139, 92, 246, 0.1)',
                    color: 'var(--accent-primary)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  <Icons.Info size={24} />
                </div>
              )}
              <h3 style={{ fontSize: '1.25rem' }}>{alertConfig.title}</h3>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.95rem' }}>{alertConfig.message}</p>
              <button className="btn btn-primary" style={{ width: '100%', marginTop: '8px' }} onClick={() => setAlertConfig(null)}>
                OK
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Global Confirmation Modal */}
      {confirmConfig && (
        <div className="modal-overlay" onClick={() => setConfirmConfig(null)}>
          <div
            className="modal-content glass-card animate-fade-in"
            style={{ maxWidth: '400px', textAlign: 'center' }}
            onClick={(e) => e.stopPropagation()}
          >
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '16px' }}>
              <div
                style={{
                  width: '48px',
                  height: '48px',
                  borderRadius: '50%',
                  background: 'rgba(245, 158, 11, 0.1)',
                  color: 'var(--accent-warning)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                <Icons.HelpCircle size={24} />
              </div>
              <h3 style={{ fontSize: '1.25rem' }}>{confirmConfig.title}</h3>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.95rem' }}>{confirmConfig.message}</p>
              <div style={{ display: 'flex', gap: '12px', width: '100%', marginTop: '8px' }}>
                <button className="btn btn-secondary" style={{ flex: 1 }} onClick={() => setConfirmConfig(null)}>
                  Cancel
                </button>
                <button
                  className="btn btn-primary"
                  style={{ flex: 1 }}
                  onClick={() => {
                    confirmConfig.onConfirm();
                    setConfirmConfig(null);
                  }}
                >
                  Confirm
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      <style>{`
        .app-layout {
          min-height: 100vh;
          display: flex;
          flex-direction: column;
        }

        .global-navbar {
          position: sticky;
          top: 0;
          z-index: 100;
          border-radius: 0;
          border-top: none;
          border-left: none;
          border-right: none;
          background: rgba(8, 7, 16, 0.8);
          padding: 12px 0;
          height: 64px;
          display: flex;
          align-items: center;
        }

        .nav-container {
          display: flex;
          justify-content: space-between;
          align-items: center;
          gap: 20px;
        }

        .nav-logo {
          display: flex;
          align-items: center;
          gap: 10px;
        }

        .nav-logo .logo-icon {
          color: var(--accent-primary);
        }

        .nav-logo .logo-text {
          font-weight: 800;
          font-size: 1.2rem;
          letter-spacing: -0.02em;
          background: linear-gradient(135deg, #ffffff 0%, var(--text-secondary) 100%);
          -webkit-background-clip: text;
          -webkit-text-fill-color: transparent;
        }

        .nav-app-selector {
          display: flex;
          align-items: center;
          gap: 8px;
        }

        .selector-label {
          font-size: 0.85rem;
          color: var(--text-muted);
          font-weight: 600;
        }

        .nav-select {
          padding: 6px 12px;
          font-size: 0.85rem;
          background: rgba(255, 255, 255, 0.03);
          border-color: var(--border-color);
          border-radius: 8px;
          color: #ffffff;
          cursor: pointer;
        }

        .nav-actions {
          display: flex;
          align-items: center;
          gap: 16px;
        }

        .user-nav-profile {
          display: flex;
          align-items: center;
          gap: 8px;
          background: rgba(255, 255, 255, 0.03);
          border: 1px solid var(--border-color);
          padding: 4px 12px 4px 4px;
          border-radius: 20px;
        }

        .user-nav-avatar {
          width: 28px;
          height: 28px;
          border-radius: 50%;
          background: var(--accent-secondary);
          color: #ffffff;
          font-weight: 700;
          font-size: 0.75rem;
          display: flex;
          align-items: center;
          justify-content: center;
        }

        .user-nav-name {
          font-size: 0.85rem;
          font-weight: 600;
          color: #ffffff;
        }

        .main-content-container {
          flex: 1;
          display: flex;
          flex-direction: column;
        }
      `}</style>
    </div>
  );
}

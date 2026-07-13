import React, { useState } from 'react';
import * as Icons from 'lucide-react';
import { initialApps } from './mockData';
import LandingPage from './components/LandingPage';
import Dashboard from './components/Dashboard';
import GoogleLoginModal from './components/GoogleLoginModal';
import CreateAppModal from './components/CreateAppModal';
import CustomDropdown from './components/CustomDropdown';
import './App.css';

export default function App() {
  const [user, setUser] = useState(null); // { name, email, avatar }
  const [apps, setApps] = useState(initialApps);
  const [selectedAppId, setSelectedAppId] = useState(initialApps[0]?.id || null);
  const [currentView, setCurrentView] = useState('landing'); // 'landing' | 'dashboard'
  const [isLoginModalOpen, setIsLoginModalOpen] = useState(false);
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);
  const [isAuthChecking, setIsAuthChecking] = useState(!!localStorage.getItem('token'));

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
      if (!token) {
        setIsAuthChecking(false);
        return;
      }

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
          await fetchApps(token);
          setCurrentView('dashboard');
        } else {
          localStorage.removeItem('token');
        }
      } catch (err) {
        console.error('Auto-login failed:', err);
        localStorage.removeItem('token');
      } finally {
        setIsAuthChecking(false);
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
      setApps(apps.map(a => {
        const isMatch = newAppOrUpdatedApp._id
          ? a._id === newAppOrUpdatedApp._id
          : (newAppOrUpdatedApp.id && a.id === newAppOrUpdatedApp.id);
        return isMatch ? newAppOrUpdatedApp : a;
      }));
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

  if (isAuthChecking) {
    return (
      <div className="auth-loading-screen">
        <div className="spinner"></div>
        <p>Loading your workspace...</p>
      </div>
    );
  }

  const selectedApp = apps.find(app => (app._id === selectedAppId || app.id === selectedAppId));

  return (
    <div className="app-layout">
      {/* Global Navigation Bar */}
      <header className="global-navbar glass-card">
        <div className="container nav-container">
          <div className="nav-logo" onClick={() => setCurrentView(user ? 'dashboard' : 'landing')} style={{ cursor: 'pointer' }}>
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
    </div>
  );
}

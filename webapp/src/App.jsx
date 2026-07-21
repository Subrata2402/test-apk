import React, { useState } from 'react';
import * as Icons from 'lucide-react';
import { useNavigate, useLocation } from 'react-router-dom';
import { initialApps } from './mockData';
import GoogleLoginModal from './components/modals/GoogleLoginModal';
import CreateAppModal from './components/modals/CreateAppModal';
import ContactSupportModal from './components/modals/ContactSupportModal';
import Navbar from './components/layout/Navbar';
import AlertModal from './components/common/AlertModal';
import ConfirmModal from './components/common/ConfirmModal';
import AppRoutes from './routes/AppRoutes';
import './App.css';

export default function App() {
  const navigate = useNavigate();
  const location = useLocation();
  const [user, setUser] = useState(null); // { name, email, avatar }
  const [apps, setApps] = useState(initialApps);
  const [selectedAppId, setSelectedAppId] = useState(initialApps[0]?.id || null);
  const [isLoginModalOpen, setIsLoginModalOpen] = useState(false);
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);
  const [isContactModalOpen, setIsContactModalOpen] = useState(false);
  const [isAuthChecking, setIsAuthChecking] = useState(!!localStorage.getItem('token'));
  const [isLoadingApps, setIsLoadingApps] = useState(false);
  const [isLoggingOut, setIsLoggingOut] = useState(false);

  const fetchApps = async (token) => {
    setIsLoadingApps(true);
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
    } finally {
      setIsLoadingApps(false);
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
            isDriveConfigured: data.data.user.isDriveConfigured,
          });
          await fetchApps(token);
          
          if (window.location.pathname === '/device') {
            const urlParams = new URLSearchParams(window.location.search);
            if (!urlParams.has('token')) {
              navigate('/', { replace: true });
            }
          }
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

  React.useEffect(() => {
    window.scrollTo(0, 0);
  }, [location.pathname]);

  const handleLoginSuccess = async (userData) => {
    // Set user and navigate immediately to prevent landing page flicker
    setUser(userData);
    navigate('/dashboard');

    const token = localStorage.getItem('token');
    if (token) {
      // Fetch apps (which sets isLoadingApps to true, showing the loading screen)
      fetchApps(token);
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
            isDriveConfigured: data.data.user.isDriveConfigured,
          });
        }
      } catch (err) {
        console.error('Failed to fetch user details after login:', err);
      }
    }
  };

  const handleLogout = async () => {
    setIsLoggingOut(true);
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
    setIsLoggingOut(false);
    navigate('/');
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
      return true;
    } else {
      const token = localStorage.getItem('token');
      if (!token) return false;

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
          return true;
        } else {
          showAlert(data.message || 'Failed to create application', 'Error', 'error');
          return false;
        }
      } catch (err) {
        console.error('Failed to create app:', err);
        showAlert('Failed to create application', 'Error', 'error');
        return false;
      }
    }
  };

  if (isAuthChecking || isLoadingApps) {
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
      <Navbar user={user} onLoginClick={() => setIsLoginModalOpen(true)} />

      {/* Main Content */}
      <div className="container main-content-container">
        <AppRoutes
          user={user}
          apps={apps}
          selectedAppId={selectedAppId}
          setSelectedAppId={setSelectedAppId}
          handleCreateApp={handleCreateApp}
          handleLogout={handleLogout}
          setIsLoginModalOpen={setIsLoginModalOpen}
          setIsCreateModalOpen={setIsCreateModalOpen}
          showAlert={showAlert}
          showConfirm={showConfirm}
          setUser={setUser}
          onContactClick={() => setIsContactModalOpen(true)}
        />
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
        onDriveConfigured={() => setUser(prev => ({ ...prev, isDriveConfigured: true }))}
      />

      {/* Contact Support Modal */}
      <ContactSupportModal
        isOpen={isContactModalOpen}
        onClose={() => setIsContactModalOpen(false)}
      />

      <AlertModal config={alertConfig} onClose={() => setAlertConfig(null)} />
      <ConfirmModal config={confirmConfig} onClose={() => setConfirmConfig(null)} />

      {isLoggingOut && (
        <div className="modal-overlay flex-center" style={{ zIndex: 9999, background: 'rgba(0, 0, 0, 0.7)', backdropFilter: 'blur(10px)' }}>
          <div className="google-loading-state" style={{ color: '#ffffff' }}>
            <div className="spinner"></div>
            <p style={{ marginTop: '16px', fontSize: '1.1rem', fontWeight: '500' }}>Logging out...</p>
            <span className="loading-subtext" style={{ color: 'rgba(255, 255, 255, 0.5)' }}>Cleaning up session data</span>
          </div>
        </div>
      )}
    </div>
  );
}

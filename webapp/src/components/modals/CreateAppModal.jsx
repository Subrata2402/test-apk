import React, { useState } from 'react';
import * as Icons from 'lucide-react';
import { useGoogleLogin } from '@react-oauth/google';
import './CreateAppModal.css';

export default function CreateAppModal({ isOpen, onClose, onCreateApp, user, showAlert, onDriveConfigured }) {
  const [appName, setAppName] = useState('');
  const [packageName, setPackageName] = useState('');
  const [description, setDescription] = useState('');
  const [isConfiguring, setIsConfiguring] = useState(false);

  const login = useGoogleLogin({
    onSuccess: async (codeResponse) => {
      setIsConfiguring(true);
      try {
        const token = localStorage.getItem('token');
        const response = await fetch(`${import.meta.env.VITE_API_URL}/users/configure-drive`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`,
          },
          body: JSON.stringify({ code: codeResponse.code }),
        });

        const data = await response.json();
        if (response.ok && data.status === 'success') {
          showAlert('Google Drive configured successfully!', 'Success', 'success');
          onDriveConfigured();
        } else {
          showAlert(data.message || 'Failed to configure Google Drive', 'Error', 'error');
        }
      } catch (err) {
        console.error('Failed to configure drive:', err);
        showAlert('Failed to configure Google Drive', 'Error', 'error');
      } finally {
        setIsConfiguring(false);
      }
    },
    flow: 'auth-code',
    scope: 'https://www.googleapis.com/auth/drive.file',
  });

  const [isCreating, setIsCreating] = useState(false);

  if (!isOpen) return null;

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!appName || !packageName || !description) {
      showAlert('Please fill in all fields', 'Warning', 'warning');
      return;
    }
    setIsCreating(true);
    const success = await onCreateApp({ name: appName, packageName, description });
    setIsCreating(false);
    if (success) {
      setAppName('');
      setPackageName('');
      setDescription('');
      onClose();
    }
  };

  const isDriveConfigured = user?.isDriveConfigured;

  return (
    <div className="modal-overlay">
      <div className="modal-container glass-panel animate-fade-in">
        <button className="modal-close" onClick={onClose} disabled={isConfiguring || isCreating}>
          <Icons.X size={20} />
        </button>

        {!isDriveConfigured ? (
          <div className="drive-config-container">
            <div className="modal-header">
              <h2>Configure Google Drive</h2>
              <p>Connect your Google Drive to store application releases securely.</p>
            </div>

            <div className="drive-config-body flex-center">
              {isConfiguring ? (
                <div className="google-loading-state">
                  <div className="spinner"></div>
                  <p>Configuring Google Drive...</p>
                  <span className="loading-subtext">Creating folder and setting up credentials</span>
                </div>
              ) : (
                <div className="drive-config-prompt">
                  <div className="drive-icon-wrapper flex-center">
                    <Icons.CloudLightning size={48} className="drive-icon" />
                  </div>
                  <h3>Storage Configuration Required</h3>
                  <p>
                    To create applications, you must first connect your Google Drive. 
                    We will create a secure folder named <code>TestAPK_Releases</code> to store your APK files.
                  </p>
                  <button className="btn btn-primary google-drive-btn flex-center gap-2" onClick={() => login()}>
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
                      <path d="M19.35 10.04C18.67 6.59 15.64 4 12 4 9.11 4 6.6 5.64 5.35 8.04 2.34 8.36 0 10.91 0 14c0 3.31 2.69 6 6 6h13c2.76 0 5-2.24 5-5 0-2.64-2.05-4.78-4.65-4.96zM19 18H6c-2.21 0-4-1.79-4-4 0-2.05 1.53-3.76 3.56-3.97l1.07-.11.5-.95C8.08 7.14 9.94 6 12 6c2.62 0 4.88 1.86 5.39 4.43l.3 1.5 1.53.11c1.56.1 2.78 1.41 2.78 2.96 0 1.65-1.35 3-3 3z"/>
                    </svg>
                    <span>Connect Google Drive</span>
                  </button>
                </div>
              )}
            </div>
          </div>
        ) : (
          <>
            <div className="modal-header">
              <h2>Create Application</h2>
              <p>Register a new application to start managing its releases.</p>
            </div>

            <form onSubmit={handleSubmit} className="create-app-form">
              <div className="form-group">
                <label htmlFor="appName" className="form-label">
                  Application Name
                </label>
                <input
                  type="text"
                  id="appName"
                  className="form-input"
                  placeholder="e.g., My Awesome App"
                  value={appName}
                  onChange={(e) => setAppName(e.target.value)}
                  required
                  disabled={isCreating}
                />
              </div>

              <div className="form-group">
                <label htmlFor="packageName" className="form-label">
                  Package Name (Application ID)
                </label>
                <input
                  type="text"
                  id="packageName"
                  className="form-input"
                  placeholder="e.g., com.example.myapp"
                  value={packageName}
                  onChange={(e) => setPackageName(e.target.value)}
                  required
                  disabled={isCreating}
                />
              </div>

              <div className="form-group">
                <label htmlFor="description" className="form-label">
                  Description
                </label>
                <textarea
                  id="description"
                  className="form-input"
                  placeholder="Briefly describe what this application does..."
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  rows="3"
                  required
                  disabled={isCreating}
                />
              </div>

              <div className="modal-actions">
                <button type="button" className="btn btn-secondary" onClick={onClose} disabled={isCreating}>
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary" disabled={isCreating}>
                  {isCreating ? (
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px', justifyContent: 'center' }}>
                      <div className="spinner" style={{ width: '16px', height: '16px', borderWidth: '2px' }}></div>
                      <span>Creating...</span>
                    </div>
                  ) : (
                    'Create Application'
                  )}
                </button>
              </div>
            </form>
          </>
        )}
      </div>
    </div>
  );
}

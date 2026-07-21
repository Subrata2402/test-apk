import React, { useState } from 'react';
import * as Icons from 'lucide-react';
import './CreateAppModal.css';

export default function CreateAppModal({ isOpen, onClose, onCreateApp, user, showAlert, onOpenDriveModal }) {
  const [appName, setAppName] = useState('');
  const [packageName, setPackageName] = useState('');
  const [description, setDescription] = useState('');
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
        <button className="modal-close" onClick={onClose} disabled={isCreating}>
          <Icons.X size={20} />
        </button>

        {!isDriveConfigured ? (
          <div className="drive-config-container">
            <div className="modal-header">
              <h2>Storage Configuration Required</h2>
              <p>To create applications, you must first connect your Google Drive.</p>
            </div>

            <div className="drive-config-body flex-center" style={{ padding: '24px 0', textAlign: 'center' }}>
              <div className="drive-config-prompt" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '16px' }}>
                <div className="drive-icon-wrapper flex-center" style={{ width: '80px', height: '80px', borderRadius: '50%', background: 'rgba(139, 92, 246, 0.1)', color: 'var(--accent-primary)', marginBottom: '8px' }}>
                  <Icons.CloudLightning size={48} className="drive-icon" />
                </div>
                <p style={{ color: 'var(--text-secondary)', fontSize: '0.95rem', lineHeight: '1.5', maxWidth: '360px', margin: 0 }}>
                  We will create a secure folder named <code>TestAPK_Releases</code> in your Google Drive to store your APK files.
                </p>
                <button 
                  className="btn btn-primary flex-center gap-2" 
                  style={{ width: '100%', maxWidth: '280px', height: '46px', fontWeight: '600' }}
                  onClick={() => {
                    onOpenDriveModal();
                    onClose();
                  }}
                >
                  <Icons.Settings size={18} />
                  <span>Configure Google Drive</span>
                </button>
              </div>
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

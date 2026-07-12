import React, { useState } from 'react';
import * as Icons from 'lucide-react';

export default function CreateAppModal({ isOpen, onClose, onCreateApp, user, showAlert }) {
  const [appName, setAppName] = useState('');
  const [packageName, setPackageName] = useState('');
  const [description, setDescription] = useState('');

  if (!isOpen) return null;

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!appName || !packageName || !description) {
      showAlert('Please fill in all fields', 'Warning', 'warning');
      return;
    }

    const newApp = {
      name: appName,
      packageName,
      description,
      category: 'Android App',
      icon: 'Android',
      downloads: '0',
      rating: '0.0',
      activeUsers: '0',
      screenshots: [
        'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        'linear-gradient(135deg, #2af598 0%, #009efd 100%)'
      ],
      releases: [],
      members: [
        { email: user.email, role: 'Owner' }
      ]
    };

    onCreateApp(newApp);
    onClose();

    // Reset form
    setAppName('');
    setPackageName('');
    setDescription('');
  };

  return (
    <div className="modal-overlay flex-center">
      <div className="modal-container glass-card animate-fade-in" style={{ maxWidth: '500px' }}>
        <button className="modal-close" onClick={onClose}>
          <Icons.X size={20} />
        </button>

        <div className="modal-header">
          <h2>Create New Application</h2>
          <p>Register your application to start uploading releases and inviting collaborators.</p>
        </div>

        <form onSubmit={handleSubmit} className="create-app-form">
          <div className="form-group">
            <label className="form-label">Application Name</label>
            <input
              type="text"
              className="form-input"
              placeholder="e.g., AeroPlayer Pro"
              value={appName}
              onChange={(e) => setAppName(e.target.value)}
              required
            />
          </div>

          <div className="form-group">
            <label className="form-label">Package Name (Unique ID)</label>
            <input
              type="text"
              className="form-input"
              placeholder="e.g., com.aero.player.pro"
              value={packageName}
              onChange={(e) => setPackageName(e.target.value)}
              required
            />
          </div>

          <div className="form-group">
            <label className="form-label">Description</label>
            <textarea
              className="form-textarea"
              placeholder="Describe what your application does..."
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              required
            />
          </div>

          <div className="modal-actions">
            <button type="button" className="btn btn-secondary" onClick={onClose}>
              Cancel
            </button>
            <button type="submit" className="btn btn-primary">
              Create Application
            </button>
          </div>
        </form>
      </div>

      <style>{`
        .modal-overlay {
          position: fixed;
          inset: 0;
          background: rgba(0, 0, 0, 0.7);
          backdrop-filter: blur(8px);
          z-index: 1000;
          display: flex;
          align-items: center;
          justify-content: center;
        }

        .modal-container {
          width: 100%;
          max-width: 500px;
          padding: 32px;
          position: relative;
          display: flex;
          flex-direction: column;
          gap: 24px;
          border-radius: 20px;
          background: rgba(15, 15, 25, 0.85);
        }

        .modal-close {
          position: absolute;
          top: 16px;
          right: 16px;
          background: transparent;
          border: none;
          color: var(--text-secondary);
          cursor: pointer;
          padding: 4px;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          transition: var(--transition-smooth);
        }

        .modal-close:hover {
          background: rgba(255, 255, 255, 0.05);
          color: #ffffff;
        }

        .modal-header {
          text-align: left;
          margin-bottom: 8px;
        }

        .modal-header h2 {
          font-size: 1.5rem;
          margin-bottom: 6px;
        }

        .modal-header p {
          font-size: 0.9rem;
          color: var(--text-secondary);
        }

        .create-app-form {
          display: flex;
          flex-direction: column;
          gap: 20px;
        }

        .form-row {
          display: flex;
          gap: 16px;
        }

        @media (max-width: 576px) {
          .form-row {
            flex-direction: column;
            gap: 20px;
          }
        }

        .modal-actions {
          display: flex;
          justify-content: flex-end;
          gap: 12px;
          border-top: 1px solid var(--border-color);
          padding-top: 20px;
          margin-top: 10px;
        }
      `}</style>
    </div>
  );
}

import React, { useState } from 'react';
import * as Icons from 'lucide-react';
import './CreateAppModal.css';

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
    onCreateApp({ name: appName, packageName, description });
    setAppName('');
    setPackageName('');
    setDescription('');
    onClose();
  };

  return (
    <div className="modal-overlay">
      <div className="modal-container glass-panel animate-fade-in">
        <button className="modal-close" onClick={onClose}>
          <Icons.X size={20} />
        </button>

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
    </div>
  );
}

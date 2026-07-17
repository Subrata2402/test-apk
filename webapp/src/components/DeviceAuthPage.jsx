import React, { useState } from 'react';
import * as Icons from 'lucide-react';
import './DeviceAuthPage.css';

export default function DeviceAuthPage({ user, onLoginClick, showAlert, onGoToDashboard }) {
  const [userCode, setUserCode] = useState('');
  const [isAuthorizing, setIsAuthorizing] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!userCode) return;

    setIsAuthorizing(true);
    try {
      const token = localStorage.getItem('token');
      const response = await fetch(`${import.meta.env.VITE_API_URL}/auth/device/authorize`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
        },
        body: JSON.stringify({ userCode }),
      });

      const data = await response.json();
      if (response.ok && data.status === 'success') {
        setIsSuccess(true);
        showAlert('Device authorized successfully!', 'Success', 'success');
        setTimeout(() => {
          window.history.pushState({}, '', '/');
          onGoToDashboard();
        }, 3000);
      } else {
        showAlert(data.message || 'Failed to authorize device', 'Error', 'error');
      }
    } catch (err) {
      console.error('Failed to authorize device:', err);
      showAlert('Failed to authorize device', 'Error', 'error');
    } finally {
      setIsAuthorizing(false);
    }
  };

  return (
    <div className="device-auth-container flex-center">
      <div className="device-auth-card glass-panel animate-fade-in">
        <div className="device-auth-header">
          <div className="device-icon-wrapper flex-center">
            <Icons.Terminal size={40} className="terminal-icon" />
          </div>
          <h2>Authorize Device</h2>
          <p>Link your command line interface to your TestAPK account.</p>
        </div>

        {!user ? (
          <div className="device-auth-body text-center">
            <p className="auth-prompt-text">
              You must be signed in to authorize a new device.
            </p>
            <button className="btn btn-primary flex-center gap-2" onClick={onLoginClick} style={{ margin: '0 auto' }}>
              <Icons.LogIn size={18} />
              <span>Sign In to Continue</span>
            </button>
          </div>
        ) : isSuccess ? (
          <div className="device-auth-body text-center success-state">
            <div className="success-icon-wrapper flex-center">
              <Icons.CheckCircle size={48} className="success-icon" />
            </div>
            <h3>Device Authorized!</h3>
            <p>
              Your terminal has been successfully linked. You can now close this tab or return to your dashboard.
            </p>
            <button
              className="btn btn-secondary w-100"
              onClick={() => {
                window.history.pushState({}, '', '/');
                onGoToDashboard();
              }}
              style={{ marginTop: '12px' }}
            >
              Go to Dashboard
            </button>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="device-auth-form">
            <div className="form-group">
              <label htmlFor="userCode" className="form-label">
                Enter User Code
              </label>
              <input
                type="text"
                id="userCode"
                className="form-input code-input"
                placeholder="ABCD-EFGH"
                value={userCode}
                onChange={(e) => setUserCode(e.target.value)}
                maxLength={9}
                required
                autoFocus
              />
              <span className="form-help">
                Enter the 8-character code displayed in your terminal.
              </span>
            </div>

            <button
              type="submit"
              className="btn btn-primary w-100 flex-center gap-2"
              disabled={isAuthorizing || !userCode}
            >
              {isAuthorizing ? (
                <>
                  <div className="spinner spinner-sm"></div>
                  <span>Authorizing...</span>
                </>
              ) : (
                <>
                  <Icons.Key size={18} />
                  <span>Authorize Device</span>
                </>
              )}
            </button>
          </form>
        )}
      </div>
    </div>
  );
}

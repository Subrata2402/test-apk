import React, { useState, useEffect } from 'react';
import * as Icons from 'lucide-react';
import './DeviceAuthPage.css';

// States: 'checking' | 'form' | 'expired' | 'success'

export default function DeviceAuthPage({ user, onLoginClick, showAlert, onGoToDashboard }) {
  const [pageState, setPageState] = useState('checking');
  const [userCode, setUserCode] = useState('');
  const [isAuthorizing, setIsAuthorizing] = useState(false);

  const urlParams = new URLSearchParams(window.location.search);
  const token = urlParams.get('token');

  useEffect(() => {
    const validateToken = async () => {
      if (!token) {
        setPageState('expired');
        return;
      }
      try {
        const response = await fetch(`${import.meta.env.VITE_API_URL}/auth/device/check-url?token=${token}`);
        const data = await response.json();
        if (response.ok && data.status === 'success') {
          setPageState('form');
        } else {
          setPageState('expired');
        }
      } catch (err) {
        console.error('Failed to validate token:', err);
        setPageState('expired');
      }
    };
    validateToken();
  }, [token]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!userCode) return;

    setIsAuthorizing(true);
    try {
      const authToken = localStorage.getItem('token');
      const response = await fetch(`${import.meta.env.VITE_API_URL}/auth/device/authorize`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${authToken}`,
        },
        body: JSON.stringify({ userCode }),
      });

      const data = await response.json();
      if (response.ok && data.status === 'success') {
        setPageState('success');
        setTimeout(() => {
          window.history.pushState({}, '', '/');
          onGoToDashboard();
        }, 3000);
      } else if (response.status === 410 || data.code === 'expired_code') {
        // Code expired — show expired state
        setPageState('expired');
      } else {
        // Invalid code (typo) or other error — show alert and stay on form
        showAlert(data.message || 'Failed to authorize device', 'Error', 'error');
      }
    } catch (err) {
      console.error('Failed to authorize device:', err);
      showAlert('Failed to authorize device', 'Error', 'error');
    } finally {
      setIsAuthorizing(false);
    }
  };

  if (pageState === 'checking') {
    return (
      <div className="device-auth-container flex-center">
        <div className="device-auth-card glass-panel animate-fade-in">
          <div className="device-auth-body text-center">
            <div className="spinner" style={{ margin: '0 auto' }}></div>
            <p style={{ marginTop: '16px', opacity: 0.7 }}>Validating authorization link...</p>
          </div>
        </div>
      </div>
    );
  }

  if (pageState === 'expired') {
    return (
      <div className="device-auth-container flex-center">
        <div className="device-auth-card glass-panel animate-fade-in">
          <div className="device-auth-header">
            <div className="device-icon-wrapper expired-icon-bg flex-center">
              <Icons.Clock size={40} className="expired-icon" />
            </div>
            <h2>Link Expired or Invalid</h2>
            <p>This authorization link has expired or is invalid. Please run the login command again to get a new link.</p>
          </div>
          <div className="device-auth-body text-center expired-state">
            <div className="expired-code-hint">
              <code className="code-snippet">testapk login</code>
            </div>
            {user && (
              <button
                className="btn btn-primary w-100"
                onClick={() => {
                  window.history.pushState({}, '', '/');
                  onGoToDashboard();
                }}
              >
                Go to Dashboard
              </button>
            )}
          </div>
        </div>
      </div>
    );
  }

  if (pageState === 'success') {
    return (
      <div className="device-auth-container flex-center">
        <div className="device-auth-card glass-panel animate-fade-in">
          <div className="device-auth-header">
            <div className="success-icon-wrapper flex-center">
              <Icons.CheckCircle size={48} className="success-icon" />
            </div>
            <h2>Device Authorized!</h2>
            <p>Your terminal has been successfully linked. You can now close this tab or return to your dashboard.</p>
          </div>
          <div className="device-auth-body text-center success-state">
            <button
              className="btn btn-secondary w-100"
              onClick={() => {
                window.history.pushState({}, '', '/');
                onGoToDashboard();
              }}
            >
              Go to Dashboard
            </button>
          </div>
        </div>
      </div>
    );
  }

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

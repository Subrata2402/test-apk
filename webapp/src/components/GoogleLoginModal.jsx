import React, { useState } from 'react';
import * as Icons from 'lucide-react';
import { GoogleLogin } from '@react-oauth/google';

export default function GoogleLoginModal({ isOpen, onClose, onLoginSuccess }) {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);

  if (!isOpen) return null;

  const handleGoogleSuccess = async (credentialResponse) => {
    setIsLoading(true);
    setError(null);

    try {
      const response = await fetch(`${import.meta.env.VITE_API_URL}/auth/google`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          idToken: credentialResponse.credential,
        }),
      });

      const data = await response.json();

      if (!response.ok || data.status !== 'success') {
        throw new Error(data.message || 'Authentication failed');
      }

      // Save token to localStorage
      localStorage.setItem('token', data.token);

      // Call success callback
      onLoginSuccess({
        name: data.data.user.name,
        email: data.data.user.email,
        avatar: data.data.user.name.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase(),
        picture: data.data.user.picture,
        role: data.data.user.role,
      });
      onClose();
    } catch (err) {
      setError(err.message || 'Failed to authenticate with server');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="modal-overlay flex-center">
      <div className="modal-container glass-card animate-fade-in">
        <button className="modal-close" onClick={onClose} disabled={isLoading}>
          <Icons.X size={20} />
        </button>

        <div className="google-login-header">
          {/* Google G Logo SVG */}
          <svg className="google-logo" viewBox="0 0 24 24" width="24" height="24">
            <path
              fill="#4285F4"
              d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
            />
            <path
              fill="#34A853"
              d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
            />
            <path
              fill="#FBBC05"
              d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"
            />
            <path
              fill="#EA4335"
              d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"
            />
          </svg>
          <h2>Sign in with Google</h2>
          <p>to continue to APK Release Manager</p>
        </div>

        {error && (
          <div className="error-message" style={{ color: '#ef4444', fontSize: '0.85rem', textAlign: 'center', background: 'rgba(239, 68, 68, 0.1)', padding: '8px 12px', borderRadius: '8px', border: '1px solid rgba(239, 68, 68, 0.2)' }}>
            {error}
          </div>
        )}

        <div className="google-login-button-container" style={{ display: 'flex', justifyContent: 'center', padding: '20px 0' }}>
          {isLoading ? (
            <div className="google-loading-state">
              <div className="spinner"></div>
              <p>Signing you in...</p>
            </div>
          ) : (
            <GoogleLogin
              onSuccess={handleGoogleSuccess}
              onError={() => setError('Google Sign-In failed. Please try again.')}
              theme="filled_dark"
              shape="pill"
              size="large"
            />
          )}
        </div>

        <div className="google-login-footer">
          <p>To continue, Google will share your name, email address, language preference, and profile picture with APK Release Manager.</p>
        </div>
      </div>

      <style>{`
        .modal-overlay {
          position: fixed;
          inset: 0;
          background: rgba(0, 0, 0, 0.7);
          backdrop-filter: blur(8px);
          z-index: 1000;
        }

        .modal-container {
          width: 100%;
          max-width: 420px;
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

        .google-login-header {
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 8px;
          text-align: center;
        }

        .google-logo {
          margin-bottom: 8px;
        }

        .google-login-header h2 {
          font-size: 1.5rem;
          font-weight: 600;
        }

        .google-login-header p {
          font-size: 0.9rem;
          color: var(--text-secondary);
        }

        .google-accounts-list {
          display: flex;
          flex-direction: column;
          gap: 10px;
        }

        .google-account-item {
          display: flex;
          align-items: center;
          gap: 16px;
          padding: 12px 16px;
          background: rgba(255, 255, 255, 0.02);
          border: 1px solid var(--border-color);
          border-radius: 12px;
          cursor: pointer;
          text-align: left;
          width: 100%;
          transition: var(--transition-smooth);
        }

        .google-account-item:hover {
          background: rgba(255, 255, 255, 0.06);
          border-color: var(--border-color-hover);
          transform: translateY(-1px);
        }

        .google-avatar {
          width: 40px;
          height: 40px;
          border-radius: 50%;
          background: var(--accent-primary);
          color: #ffffff;
          font-weight: 700;
          font-size: 0.95rem;
          display: flex;
          align-items: center;
          justify-content: center;
        }

        .google-account-info {
          display: flex;
          flex-direction: column;
          flex: 1;
        }

        .google-account-name {
          font-weight: 600;
          font-size: 0.95rem;
          color: #ffffff;
        }

        .google-account-email {
          font-size: 0.8rem;
          color: var(--text-secondary);
        }

        .chevron-icon {
          color: var(--text-muted);
          transition: var(--transition-smooth);
        }

        .google-account-item:hover .chevron-icon {
          color: #ffffff;
          transform: translateX(2px);
        }

        .google-account-item.use-another {
          background: transparent;
          border-style: dashed;
        }

        .google-account-item.use-another .google-avatar {
          background: rgba(255, 255, 255, 0.05);
          color: var(--text-secondary);
        }

        .google-loading-state {
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          padding: 40px 0;
          gap: 16px;
          text-align: center;
        }

        .spinner {
          width: 40px;
          height: 40px;
          border: 3px solid rgba(139, 92, 246, 0.1);
          border-top-color: var(--accent-primary);
          border-radius: 50%;
          animation: spin 1s linear infinite;
        }

        @keyframes spin {
          to { transform: rotate(360deg); }
        }

        .loading-subtext {
          font-size: 0.8rem;
          color: var(--text-muted);
        }

        .google-login-footer {
          border-top: 1px solid var(--border-color);
          padding-top: 16px;
        }

        .google-login-footer p {
          font-size: 0.75rem;
          color: var(--text-muted);
          line-height: 1.4;
          text-align: left;
        }
      `}</style>
    </div>
  );
}

import React, { useState } from 'react';
import * as Icons from 'lucide-react';
import { GoogleLogin } from '@react-oauth/google';
import googleIcon from '../../assets/google-icon-logo.svg';
import './GoogleLoginModal.css';

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

      onLoginSuccess({
        name: data.data.user.name,
        email: data.data.user.email,
        avatar: data.data.user.name.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase(),
        picture: data.data.user.picture,
        role: data.data.user.role,
        isDriveConfigured: data.data.user.isDriveConfigured,
      });
      onClose();
    } catch (err) {
      console.error('Google Auth Error:', err);
      setError(err.message || 'Failed to authenticate with Google');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="modal-overlay flex-center">
      <div className="modal-container glass-card animate-fade-in" style={{ maxWidth: '420px' }}>
        <button className="modal-close" onClick={onClose}>
          <Icons.X size={20} />
        </button>

        <div className="google-login-header">
          <div className="google-logo">
            <img src={googleIcon} alt="google-icon" height={40} width={40} />
          </div>
          <h2>Sign in to TestAPK</h2>
          <p>Use your Google account to access beta releases</p>
        </div>

        {error && (
          <div className="error-banner" style={{ margin: '0 0 16px 0' }}>
            <Icons.AlertCircle size={16} />
            <span>{error}</span>
          </div>
        )}

        <div className="google-login-body flex-center" style={{ minHeight: '80px' }}>
          {isLoading ? (
            <div className="google-loading-state">
              <div className="spinner"></div>
              <p>Authenticating...</p>
              <span className="loading-subtext">This may take a few seconds</span>
            </div>
          ) : (
            <GoogleLogin
              onSuccess={handleGoogleSuccess}
              onError={() => setError('Google Sign-In was cancelled or failed')}
              useOneTap
              theme="filled_blue"
              size="large"
            />
          )}
        </div>

        <div className="google-login-footer">
          <p>To continue, Google will share your name, email address, language preference, and profile picture with TestAPK.</p>
        </div>
      </div>
    </div>
  );
}

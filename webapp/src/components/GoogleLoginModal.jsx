import React, { useState } from 'react';
import * as Icons from 'lucide-react';
import { GoogleLogin } from '@react-oauth/google';
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
            <svg width="40" height="40" viewBox="0 0 24 24">
              <path
                fill="#4285F4"
                d="M23.745 12.27c0-.7-.06-1.4-.19-2.07H12v3.92h6.69c-.29 1.5-.14 3.01-1.3 4l3.01 2.33c1.76-1.61 2.76-4.01 2.76-6.93z"
              />
              <path
                fill="#34A853"
                d="M12 24c3.24 0 5.97-1.09 7.96-2.93l-3.01-2.33c-.83.57-1.9.91-3.15.91-2.43 0-4.5-1.64-5.24-3.86H5.43v2.4C7.42 20.09 10.51 24 12 24z"
              />
              <path
                fill="#FBBC05"
                d="M6.76 15.79c-.19-.57-.3-1.19-.3-1.79s.11-1.22.3-1.79V9.81H5.43c-.63 1.25-.99 2.66-.99 4.19s.36 2.94.99 4.19l1.33-2.4z"
              />
              <path
                fill="#EA4335"
                d="M12 4.75c1.77 0 3.35.61 4.6 1.8l3.42-3.42C17.95 1.19 15.24 0 12 0 10.51 0 7.42 3.91 5.43 7.41l1.33 2.4c.74-2.22 2.81-3.86 5.24-3.86z"
              />
            </svg>
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
          <p>To continue, Google will share your name, email address, language preference, and profile picture with APK Release Manager.</p>
        </div>
      </div>
    </div>
  );
}

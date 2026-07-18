import React from 'react';
import * as Icons from 'lucide-react';

export default function AlertModal({ config, onClose }) {
  if (!config) return null;

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div
        className="modal-content glass-card animate-fade-in"
        style={{ maxWidth: '400px', textAlign: 'center' }}
        onClick={(e) => e.stopPropagation()}
      >
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '16px' }}>
          {config.type === 'error' ? (
            <div
              style={{
                width: '48px',
                height: '48px',
                borderRadius: '50%',
                background: 'rgba(239, 68, 68, 0.1)',
                color: 'var(--accent-danger)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <Icons.AlertTriangle size={24} />
            </div>
          ) : config.type === 'success' ? (
            <div
              style={{
                width: '48px',
                height: '48px',
                borderRadius: '50%',
                background: 'rgba(16, 185, 129, 0.1)',
                color: 'var(--accent-success)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <Icons.CheckCircle size={24} />
            </div>
          ) : (
            <div
              style={{
                width: '48px',
                height: '48px',
                borderRadius: '50%',
                background: 'rgba(139, 92, 246, 0.1)',
                color: 'var(--accent-primary)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <Icons.Info size={24} />
            </div>
          )}
          <h3 style={{ fontSize: '1.25rem' }}>{config.title}</h3>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.95rem' }}>{config.message}</p>
          <button className="btn btn-primary" style={{ width: '100%', marginTop: '8px' }} onClick={onClose}>
            OK
          </button>
        </div>
      </div>
    </div>
  );
}

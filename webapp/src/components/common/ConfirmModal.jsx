import React from 'react';
import * as Icons from 'lucide-react';

export default function ConfirmModal({ config, onClose }) {
  if (!config) return null;

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div
        className="modal-content glass-card animate-fade-in"
        style={{ maxWidth: '400px', textAlign: 'center' }}
        onClick={(e) => e.stopPropagation()}
      >
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '16px' }}>
          <div
            style={{
              width: '48px',
              height: '48px',
              borderRadius: '50%',
              background: 'rgba(245, 158, 11, 0.1)',
              color: 'var(--accent-warning)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <Icons.HelpCircle size={24} />
          </div>
          <h3 style={{ fontSize: '1.25rem' }}>{config.title}</h3>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.95rem' }}>{config.message}</p>
          <div style={{ display: 'flex', gap: '12px', width: '100%', marginTop: '8px' }}>
            <button className="btn btn-secondary" style={{ flex: 1 }} onClick={onClose}>
              Cancel
            </button>
            <button
              className="btn btn-primary"
              style={{ flex: 1 }}
              onClick={() => {
                config.onConfirm();
                onClose();
              }}
            >
              Confirm
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

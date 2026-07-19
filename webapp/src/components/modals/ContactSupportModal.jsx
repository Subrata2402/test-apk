import React, { useState } from 'react';
import * as Icons from 'lucide-react';
import './ContactSupportModal.css';

export default function ContactSupportModal({ isOpen, onClose }) {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [subject, setSubject] = useState('');
  const [message, setMessage] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSubmitted, setIsSubmitted] = useState(false);

  if (!isOpen) return null;

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!name || !email || !subject || !message) {
      return;
    }
    setIsSubmitting(true);
    
    // Simulate API call
    await new Promise((resolve) => setTimeout(resolve, 1500));
    
    setIsSubmitting(false);
    setIsSubmitted(true);
    setName('');
    setEmail('');
    setSubject('');
    setMessage('');
  };

  return (
    <div className="modal-overlay flex-center" onClick={onClose}>
      <div className="modal-container glass-card animate-fade-in" style={{ maxWidth: '500px' }} onClick={(e) => e.stopPropagation()}>
        <button className="modal-close" onClick={onClose}>
          <Icons.X size={20} />
        </button>

        {isSubmitted ? (
          <div className="success-state flex-center" style={{ padding: '20px 0' }}>
            <div className="success-icon-wrapper flex-center" style={{ marginBottom: '16px' }}>
              <Icons.CheckCircle size={48} className="success-icon" />
            </div>
            <h2>Message Sent!</h2>
            <p style={{ textAlign: 'center', marginTop: '8px', color: 'var(--text-muted)' }}>
              Thank you for contacting support. We have received your message and will get back to you as soon as possible.
            </p>
            <button className="btn btn-primary mt-4" onClick={() => setIsSubmitted(false)}>
              Send Another Message
            </button>
          </div>
        ) : (
          <>
            <div className="contact-header" style={{ textAlign: 'center', marginBottom: '24px' }}>
              <div className="contact-icon-wrapper flex-center" style={{ margin: '0 auto 12px auto', width: '56px', height: '56px', borderRadius: '50%', background: 'rgba(6, 182, 212, 0.1)', border: '1px solid rgba(6, 182, 212, 0.2)' }}>
                <Icons.Mail size={28} className="contact-icon" style={{ color: '#06b6d4' }} />
              </div>
              <h2 style={{ fontSize: '1.5rem', fontWeight: 700 }}>Contact Support</h2>
              <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem', marginTop: '4px' }}>
                Have questions or need help with TestAPK? Send us a message.
              </p>
            </div>

            <form onSubmit={handleSubmit} className="contact-form">
              <div className="form-group">
                <label htmlFor="name" className="form-label">
                  Your Name
                </label>
                <input
                  type="text"
                  id="name"
                  className="form-input"
                  placeholder="e.g., John Doe"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  required
                  disabled={isSubmitting}
                />
              </div>

              <div className="form-group">
                <label htmlFor="email" className="form-label">
                  Email Address
                </label>
                <input
                  type="email"
                  id="email"
                  className="form-input"
                  placeholder="e.g., john@example.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                  disabled={isSubmitting}
                />
              </div>

              <div className="form-group">
                <label htmlFor="subject" className="form-label">
                  Subject
                </label>
                <input
                  type="text"
                  id="subject"
                  className="form-input"
                  placeholder="How can we help you?"
                  value={subject}
                  onChange={(e) => setSubject(e.target.value)}
                  required
                  disabled={isSubmitting}
                />
              </div>

              <div className="form-group">
                <label htmlFor="message" className="form-label">
                  Message
                </label>
                <textarea
                  id="message"
                  className="form-input"
                  placeholder="Describe your issue or question in detail..."
                  value={message}
                  onChange={(e) => setMessage(e.target.value)}
                  rows="4"
                  required
                  disabled={isSubmitting}
                  style={{ resize: 'none' }}
                />
              </div>

              <button type="submit" className="btn btn-primary submit-btn" disabled={isSubmitting} style={{ width: '100%', marginTop: '8px' }}>
                {isSubmitting ? (
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px', justifyContent: 'center' }}>
                    <div className="spinner" style={{ width: '16px', height: '16px', borderWidth: '2px' }}></div>
                    <span>Sending...</span>
                  </div>
                ) : (
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px', justifyContent: 'center' }}>
                    <Icons.Send size={16} />
                    <span>Send Message</span>
                  </div>
                )}
              </button>
            </form>
          </>
        )}
      </div>
    </div>
  );
}

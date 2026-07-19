import React, { useState } from 'react';
import * as Icons from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import './ContactSupport.css';

export default function ContactSupport() {
  const navigate = useNavigate();
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [subject, setSubject] = useState('');
  const [message, setMessage] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSubmitted, setIsSubmitted] = useState(false);

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
    <div className="contact-container container flex-center">
      <div className="contact-card glass-card animate-fade-in">
        <button className="back-btn flex-center gap-2" onClick={() => navigate('/')}>
          <Icons.ArrowLeft size={16} />
          <span>Back to Home</span>
        </button>

        {isSubmitted ? (
          <div className="success-state flex-center">
            <div className="success-icon-wrapper flex-center">
              <Icons.CheckCircle size={48} className="success-icon" />
            </div>
            <h2>Message Sent!</h2>
            <p>
              Thank you for contacting support. We have received your message and will get back to you at <strong>{email || 'your email'}</strong> as soon as possible.
            </p>
            <button className="btn btn-primary mt-4" onClick={() => setIsSubmitted(false)}>
              Send Another Message
            </button>
          </div>
        ) : (
          <>
            <div className="contact-header">
              <div className="contact-icon-wrapper flex-center">
                <Icons.Mail size={32} className="contact-icon" />
              </div>
              <h2>Contact Support</h2>
              <p>Have questions or need help with TestAPK? Send us a message.</p>
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
                  rows="5"
                  required
                  disabled={isSubmitting}
                />
              </div>

              <button type="submit" className="btn btn-primary submit-btn" disabled={isSubmitting}>
                {isSubmitting ? (
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px', justifyContent: 'center' }}>
                    <div className="spinner" style={{ width: '16px', height: '16px', borderWidth: '2px' }}></div>
                    <span>Sending...</span>
                  </div>
                ) : (
                  <>
                    <Icons.Send size={16} />
                    <span>Send Message</span>
                  </>
                )}
              </button>
            </form>
          </>
        )}
      </div>
    </div>
  );
}

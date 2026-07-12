import React, { useState, useRef } from 'react';
import * as Icons from 'lucide-react';
import CustomDropdown from './CustomDropdown';

export default function AppDetails({ app, user, onUpdateApp, showAlert, showConfirm }) {
  const [activeTab, setActiveTab] = useState('releases'); // 'releases' | 'collaborators'
  const [inviteEmail, setInviteEmail] = useState('');
  const [inviteRole, setInviteRole] = useState('Tester');

  const isMock = !app._id;
  const currentUserMember = app.members.find(m => m.email.toLowerCase() === user.email.toLowerCase());
  const canUpload = !isMock && currentUserMember && (currentUserMember.role === 'Owner' || currentUserMember.role === 'Developer');

  // APK Upload States
  const [isDragging, setIsDragging] = useState(false);
  const [uploadFile, setUploadFile] = useState(null);
  const [uploadProgress, setUploadProgress] = useState(0);
  const [isUploading, setIsUploading] = useState(false);
  const [uploadPhase, setUploadPhase] = useState('uploading'); // 'uploading' | 'processing'
  const [showReleaseForm, setShowReleaseForm] = useState(false);

  // Release Form States
  const [version, setVersion] = useState('');
  const [buildNumber, setBuildNumber] = useState('');
  const [releaseNotes, setReleaseNotes] = useState('');

  const [selectedRelease, setSelectedRelease] = useState(null);
  const [isDeleting, setIsDeleting] = useState(false);

  const fileInputRef = useRef(null);

  // Helper to render dynamic Lucide icons
  const IconComponent = Icons[app.icon] || Icons.HelpCircle;

  // Drag and Drop Handlers
  const handleDragOver = (e) => {
    e.preventDefault();
    setIsDragging(true);
  };

  const handleDragLeave = () => {
    setIsDragging(false);
  };

  const handleDrop = (e) => {
    e.preventDefault();
    setIsDragging(false);
    const files = e.dataTransfer.files;
    if (files.length > 0) {
      validateAndProcessFile(files[0]);
    }
  };

  const handleFileSelect = (e) => {
    const files = e.target.files;
    if (files.length > 0) {
      validateAndProcessFile(files[0]);
    }
  };

  const validateAndProcessFile = (file) => {
    if (!file.name.endsWith('.apk')) {
      alert('Please upload only APK files.');
      return;
    }
    setUploadFile(file);
    setShowReleaseForm(true);
  };

  const handleReleaseSubmit = async (e) => {
    e.preventDefault();
    if (!releaseNotes || !uploadFile) {
      alert('Please fill in all release details.');
      return;
    }

    const token = localStorage.getItem('token');
    if (!token) return;

    setIsUploading(true);
    setUploadPhase('uploading');
    setUploadProgress(0);

    const formData = new FormData();
    formData.append('file', uploadFile);
    formData.append('releaseNotes', releaseNotes);

    try {
      const xhr = new XMLHttpRequest();
      xhr.open('POST', `${import.meta.env.VITE_API_URL}/apps/${app._id || app.id}/releases`);
      xhr.setRequestHeader('Authorization', `Bearer ${token}`);

      xhr.upload.onprogress = (event) => {
        if (event.lengthComputable) {
          const percentComplete = Math.round((event.loaded / event.total) * 100);
          setUploadProgress(percentComplete);
          if (percentComplete === 100) {
            // File sent to server; now server is uploading to Google Drive
            setUploadPhase('processing');
          }
        }
      };

      xhr.onload = async () => {
        setIsUploading(false);
        if (xhr.status === 201) {
          const responseData = JSON.parse(xhr.responseText);
          onUpdateApp(responseData.data.app);
          setUploadFile(null);
          setShowReleaseForm(false);
          setReleaseNotes('');
        } else {
          let errorMsg = 'Upload failed';
          try {
            const errorData = JSON.parse(xhr.responseText);
            errorMsg = errorData.message || errorMsg;
          } catch (_) { }
          alert(errorMsg);
        }
      };

      xhr.onerror = () => {
        setIsUploading(false);
        alert('An error occurred during the upload.');
      };

      xhr.send(formData);
    } catch (err) {
      console.error('Upload failed:', err);
      setIsUploading(false);
      alert('Upload failed');
    }
  };

  const handleDownload = async (buildNumber, version) => {
    const token = localStorage.getItem('token');
    if (!token) return;

    try {
      const response = await fetch(`${import.meta.env.VITE_API_URL}/apps/${app._id || app.id}/releases/${buildNumber}/download`, {
        headers: {
          'Authorization': `Bearer ${token}`,
        },
      });

      if (!response.ok) {
        const data = await response.json();
        alert(data.message || 'Failed to download APK');
        return;
      }

      const blob = await response.blob();
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `${app.name.replace(/\s+/g, '_')}_v${version}.apk`;
      document.body.appendChild(a);
      a.click();
      a.remove();
      window.URL.revokeObjectURL(url);
    } catch (err) {
      console.error('Download failed:', err);
      alert('Failed to download APK');
    }
  };

  const handleInviteSubmit = async (e) => {
    e.preventDefault();
    if (!inviteEmail) return;

    // Check if already invited
    if (app.members.some(m => m.email.toLowerCase() === inviteEmail.toLowerCase())) {
      showAlert('This user is already a member of this application.', 'Error', 'error');
      return;
    }

    const token = localStorage.getItem('token');
    if (!token) return;

    try {
      const response = await fetch(`${import.meta.env.VITE_API_URL}/apps/${app._id || app.id}/members`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
        },
        body: JSON.stringify({
          email: inviteEmail,
          role: inviteRole,
        }),
      });

      const data = await response.json();
      if (response.ok && data.status === 'success') {
        onUpdateApp(data.data.app);
        setInviteEmail('');
        showAlert('Invitation sent successfully.', 'Success', 'success');
      } else {
        showAlert(data.message || 'Failed to send invitation', 'Error', 'error');
      }
    } catch (err) {
      console.error('Failed to send invitation:', err);
      showAlert('Failed to send invitation', 'Error', 'error');
    }
  };

  const handleRemoveMember = (emailToRemove) => {
    if (emailToRemove === user.email) {
      showAlert('You cannot remove yourself as the owner.', 'Error', 'error');
      return;
    }

    showConfirm(
      `Are you sure you want to remove ${emailToRemove}?`,
      async () => {
        const token = localStorage.getItem('token');
        if (!token) return;

        try {
          const response = await fetch(`${import.meta.env.VITE_API_URL}/apps/${app._id || app.id}/members/${emailToRemove}`, {
            method: 'DELETE',
            headers: {
              'Authorization': `Bearer ${token}`,
            },
          });

          const data = await response.json();
          if (response.ok && data.status === 'success') {
            onUpdateApp(data.data.app);
            showAlert('Member removed successfully.', 'Success', 'success');
          } else {
            showAlert(data.message || 'Failed to remove member', 'Error', 'error');
          }
        } catch (err) {
          console.error('Failed to remove member:', err);
          showAlert('Failed to remove member', 'Error', 'error');
        }
      },
      'Remove Member'
    );
  };

  const handleDeleteRelease = (buildNumberToDelete) => {
    showConfirm(
      'Are you sure you want to delete this release? This action cannot be undone.',
      async () => {
        const token = localStorage.getItem('token');
        if (!token) return;

        setIsDeleting(true);
        try {
          const response = await fetch(`${import.meta.env.VITE_API_URL}/apps/${app._id || app.id}/releases/${buildNumberToDelete}`, {
            method: 'DELETE',
            headers: {
              'Authorization': `Bearer ${token}`,
            },
          });

          const data = await response.json();
          if (response.ok && data.status === 'success') {
            onUpdateApp(data.data.app);
            showAlert('Release deleted successfully.', 'Success', 'success');
          } else {
            showAlert(data.message || 'Failed to delete release', 'Error', 'error');
          }
        } catch (err) {
          console.error('Failed to delete release:', err);
          showAlert('Failed to delete release', 'Error', 'error');
        } finally {
          setIsDeleting(false);
        }
      },
      'Delete Release'
    );
  };

  return (
    <div className="app-details-container animate-fade-in">
      {/* App Header */}
      <header className="app-details-header glass-card">
        <div className="app-header-main">
          <div className="app-icon-wrapper-sm">
            <IconComponent size={32} />
          </div>
          <div className="app-header-info">
            <div className="app-header-title-row">
              <h2>{app.name}</h2>
            </div>
            <code>{app.packageName}</code>
          </div>
        </div>
        <div className="app-header-actions">
          {/* We can trigger a view switch back to the landing page for this app */}
          <button className="btn btn-secondary" onClick={() => window.location.reload()}>
            <Icons.ExternalLink size={16} /> View Public Page
          </button>
        </div>
      </header>

      {/* Tabs Navigation */}
      <div className="tabs-header">
        <button
          className={`tab-btn ${activeTab === 'releases' ? 'active' : ''}`}
          onClick={() => setActiveTab('releases')}
        >
          <Icons.Layers size={16} /> Releases & Uploads
        </button>
        <button
          className={`tab-btn ${activeTab === 'collaborators' ? 'active' : ''}`}
          onClick={() => setActiveTab('collaborators')}
        >
          <Icons.Users size={16} /> Collaborators & Testers ({app.members.length})
        </button>
      </div>

      {/* Tab Content */}
      <div className="tab-content-wrapper">
        {isMock && (
          <div className="demo-warning-banner" style={{
            background: 'rgba(245, 158, 11, 0.1)',
            border: '1px solid rgba(245, 158, 11, 0.2)',
            color: '#f59e0b',
            padding: '12px 16px',
            borderRadius: '8px',
            marginBottom: '16px',
            fontSize: '0.9rem',
            display: 'flex',
            alignItems: 'center',
            gap: '8px'
          }}>
            <Icons.AlertTriangle size={16} />
            <span><strong>Demo Mode:</strong> This is a demo application. To invite collaborators or upload releases, please create a new application first.</span>
          </div>
        )}
        {activeTab === 'releases' ? (
          <div className="releases-tab-content">
            {/* Upload Area */}
            {canUpload && !showReleaseForm && !isUploading && (
              <div
                className={`upload-zone glass-card ${isDragging ? 'dragging' : ''}`}
                onDragOver={handleDragOver}
                onDragLeave={handleDragLeave}
                onDrop={handleDrop}
                onClick={() => fileInputRef.current.click()}
              >
                <input
                  type="file"
                  ref={fileInputRef}
                  onChange={handleFileSelect}
                  accept=".apk"
                  style={{ display: 'none' }}
                />
                <div className="upload-prompt">
                  <Icons.UploadCloud size={48} className="upload-icon" />
                  <h3>Drag & Drop APK file here</h3>
                  <p>or click to browse your files</p>
                  <span className="upload-limits">Maximum file size: 150MB (.apk only)</span>
                </div>
              </div>
            )}

            {/* Upload Progress */}
            {isUploading && (
              <div className="upload-zone glass-card uploading">
                <div className="upload-progress-container">
                  <div className="spinner"></div>
                  {uploadPhase === 'uploading' ? (
                    <>
                      <h3>Uploading {uploadFile?.name}…</h3>
                      <div className="progress-bar-bg">
                        <div className="progress-bar-fill" style={{ width: `${uploadProgress}%` }}></div>
                      </div>
                      <span>{uploadProgress}% — Sending to server</span>
                    </>
                  ) : (
                    <>
                      <h3>Saving to Google Drive…</h3>
                      <div className="progress-bar-bg">
                        <div className="progress-bar-fill progress-bar-pulse"></div>
                      </div>
                      <span>Processing — please wait, this may take a moment</span>
                    </>
                  )}
                </div>
              </div>
            )}

            {/* Release Details Form (Shown after file is selected) */}
            {showReleaseForm && !isUploading && (
              <div className="release-form-container glass-card animate-fade-in">
                <div className="release-form-header">
                  <Icons.FileCheck size={24} className="text-success" />
                  <div>
                    <h3>Configure Release Details</h3>
                    <p>Selected file: <strong>{uploadFile?.name}</strong></p>
                  </div>
                </div>

                <form onSubmit={handleReleaseSubmit} className="release-form">
                  <div className="form-group">
                    <label className="form-label">Release Notes</label>
                    <textarea
                      className="form-textarea"
                      placeholder="What's new in this release? Bug fixes, new features..."
                      value={releaseNotes}
                      onChange={(e) => setReleaseNotes(e.target.value)}
                      required
                    />
                  </div>

                  <div className="form-actions">
                    <button type="button" className="btn btn-secondary" onClick={() => { setUploadFile(null); setShowReleaseForm(false); setReleaseNotes(''); }}>
                      Cancel
                    </button>
                    <button type="submit" className="btn btn-primary">
                      Publish Release
                    </button>
                  </div>
                </form>
              </div>
            )}

            {/* Releases List */}
            <div className="releases-list-section">
              <h3>Release History</h3>
              {app.releases.length === 0 ? (
                <div className="empty-state glass-card flex-center">
                  <Icons.Layers size={32} className="empty-icon" />
                  <p>
                    {canUpload
                      ? 'No releases uploaded yet. Upload your first APK above.'
                      : 'No releases uploaded yet.'}
                  </p>
                </div>
              ) : (
                <div className="dashboard-releases-grid">
                  {app.releases.map((release) => (
                    <div
                      key={release.buildNumber}
                      className="dashboard-release-card glass-card"
                      onClick={() => setSelectedRelease(release)}
                    >
                      <div className="release-card-header">
                        <div className="release-card-header-main">
                          {release.appIcon ? (
                            <img src={release.appIcon} alt={release.appName || app.name} className="release-card-icon" />
                          ) : (
                            <div className="release-card-icon-fallback">
                              <Icons.Smartphone size={24} />
                            </div>
                          )}
                          <div className="release-card-title-info">
                            <h4>{release.appName || app.name}</h4>
                            <span className="badge badge-secondary">Build #{release.buildNumber}</span>
                          </div>
                        </div>
                        <span className="release-card-date">{release.date}</span>
                      </div>
                      <p className="release-card-notes">{release.releaseNotes}</p>
                      <div className="release-card-footer">
                        <span className="release-card-size">
                          <Icons.File size={14} /> {release.size} | v{release.version}
                        </span>
                        <div className="release-card-actions" onClick={(e) => e.stopPropagation()}>
                          {canUpload && (
                            <button
                              className="btn btn-danger btn-sm btn-icon-only"
                              onClick={() => handleDeleteRelease(release.buildNumber)}
                              title="Delete Release"
                            >
                              <Icons.Trash2 size={14} />
                            </button>
                          )}
                          <button
                            className="btn btn-secondary btn-sm"
                            onClick={() => handleDownload(release.buildNumber, release.version)}
                          >
                            <Icons.Download size={14} /> Download
                          </button>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        ) : (
          <div className="collaborators-tab-content animate-fade-in">
            {/* Invite Form */}
            {!isMock ? (
              <div className="invite-form-container glass-card">
                <h3>Invite Collaborator</h3>
                <p className="invite-desc">Invite developers to upload releases or testers to download and test builds.</p>

                <form onSubmit={handleInviteSubmit} className="invite-form">
                  <div className="form-group" style={{ flex: 2 }}>
                    <label className="form-label">Email Address</label>
                    <div className="input-with-icon">
                      <Icons.Mail size={16} className="input-icon" />
                      <input
                        type="email"
                        className="form-input"
                        placeholder="developer@company.com"
                        value={inviteEmail}
                        onChange={(e) => setInviteEmail(e.target.value)}
                        required
                        style={{ paddingLeft: '40px' }}
                      />
                    </div>
                  </div>

                  <div className="form-group" style={{ flex: 1 }}>
                    <label className="form-label">Role</label>
                    <CustomDropdown
                      options={['Developer', 'Tester']}
                      value={inviteRole}
                      onChange={setInviteRole}
                    />
                  </div>

                  <button type="submit" className="btn btn-primary invite-btn">
                    <Icons.UserPlus size={16} /> Send Invitation
                  </button>
                </form>
              </div>
            ) : (
              <div className="glass-card" style={{ padding: '24px', textAlign: 'center', color: 'rgba(255, 255, 255, 0.4)', marginBottom: '24px', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '8px' }}>
                <Icons.Lock size={24} style={{ color: 'rgba(255, 255, 255, 0.2)' }} />
                <p style={{ margin: 0 }}>Invitation is disabled for demo applications.</p>
              </div>
            )}

            {/* Collaborators List */}
            <div className="collaborators-list-section">
              <h3>Team Members</h3>
              <div className="collaborators-list glass-card">
                {app.members.map((member, idx) => (
                  <div key={idx} className="collaborator-item">
                    <div className="collaborator-info-main">
                      <div className="collaborator-avatar">
                        {member.email.substring(0, 2).toUpperCase()}
                      </div>
                      <div className="collaborator-details">
                        <span className="collaborator-email">{member.email}</span>
                        <span className="collaborator-role-badge">
                          <span className={`badge ${member.role === 'Owner' ? 'badge-primary' : member.role === 'Developer' ? 'badge-secondary' : 'badge-success'}`}>
                            {member.role}
                          </span>
                          {member.status === 'Pending' && (
                            <span className="badge badge-warning" style={{ marginLeft: '8px' }}>
                              Pending
                            </span>
                          )}
                        </span>
                      </div>
                    </div>
                    {member.role !== 'Owner' && (
                      <button className="btn btn-danger btn-sm btn-icon-only" onClick={() => handleRemoveMember(member.email)} title="Remove Member">
                        <Icons.UserMinus size={14} />
                      </button>
                    )}
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}
      </div>

      <style>{`
        .app-details-container {
          display: flex;
          flex-direction: column;
          gap: 24px;
          text-align: left;
        }

        .app-details-header {
          padding: 24px;
          display: flex;
          justify-content: space-between;
          align-items: center;
          flex-wrap: wrap;
          gap: 16px;
        }

        .app-header-main {
          display: flex;
          align-items: center;
          gap: 16px;
        }

        .app-icon-wrapper-sm {
          width: 56px;
          height: 56px;
          border-radius: 12px;
          background: linear-gradient(135deg, var(--accent-primary) 0%, var(--accent-secondary) 100%);
          display: flex;
          align-items: center;
          justify-content: center;
          color: #ffffff;
        }

        .app-header-info {
          display: flex;
          flex-direction: column;
          gap: 4px;
        }

        .app-header-title-row {
          display: flex;
          align-items: center;
          gap: 12px;
        }

        .app-header-info code {
          font-size: 0.8rem;
          color: var(--text-secondary);
        }

        .tab-content-wrapper {
          margin-top: 8px;
        }

        /* Upload Zone */
        .upload-zone {
          border: 2px dashed var(--border-color);
          border-radius: 16px;
          padding: 48px;
          text-align: center;
          cursor: pointer;
          transition: var(--transition-smooth);
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          background: rgba(255, 255, 255, 0.01);
        }

        .upload-zone:hover, .upload-zone.dragging {
          border-color: var(--accent-primary);
          background: rgba(139, 92, 246, 0.03);
        }

        .upload-prompt {
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 12px;
        }

        .upload-icon {
          color: var(--text-muted);
          transition: var(--transition-smooth);
        }

        .upload-zone:hover .upload-icon {
          color: var(--accent-primary);
          transform: translateY(-4px);
        }

        .upload-limits {
          font-size: 0.75rem;
          color: var(--text-muted);
        }

        .upload-progress-container {
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 16px;
          width: 100%;
          max-width: 300px;
        }

        .progress-bar-bg {
          width: 100%;
          height: 6px;
          background: rgba(255, 255, 255, 0.05);
          border-radius: 3px;
          overflow: hidden;
        }

        .progress-bar-fill {
          height: 100%;
          background: var(--accent-primary);
          border-radius: 3px;
          transition: width 0.2s ease;
        }

        @keyframes pulse-sweep {
          0%   { transform: translateX(-100%); }
          100% { transform: translateX(400%); }
        }

        .progress-bar-pulse {
          width: 30% !important;
          background: linear-gradient(90deg, transparent, var(--accent-primary), var(--accent-secondary, #a78bfa), transparent);
          animation: pulse-sweep 1.4s ease-in-out infinite;
        }

        /* Release Form */
        .release-form-container {
          padding: 28px;
          display: flex;
          flex-direction: column;
          gap: 20px;
        }

        .release-form-header {
          display: flex;
          gap: 16px;
          align-items: center;
          border-bottom: 1px solid var(--border-color);
          padding-bottom: 16px;
        }

        .release-form {
          display: flex;
          flex-direction: column;
          gap: 20px;
        }

        /* Releases List */
        .releases-list-section {
          margin-top: 32px;
          display: flex;
          flex-direction: column;
          gap: 16px;
        }

        .dashboard-releases-grid {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
          gap: 20px;
        }

        .dashboard-release-card {
          padding: 20px;
          display: flex;
          flex-direction: column;
          gap: 12px;
        }

        .release-card-header {
          display: flex;
          justify-content: space-between;
          align-items: flex-start;
        }

        .release-card-date {
          font-size: 0.8rem;
          color: var(--text-muted);
        }

        .release-card-notes {
          font-size: 0.9rem;
          color: var(--text-secondary);
          flex: 1;
          white-space: pre-line;
        }

        .release-card-footer {
          display: flex;
          justify-content: space-between;
          align-items: center;
          border-top: 1px solid var(--border-color);
          padding-top: 12px;
          margin-top: 8px;
        }

        .release-card-size {
          font-size: 0.8rem;
          color: var(--text-muted);
          display: flex;
          align-items: center;
          gap: 4px;
        }

        .release-card-actions {
          display: flex;
          gap: 8px;
        }

        .btn-icon-only {
          padding: 8px;
          border-radius: 8px;
        }

        /* Collaborators Tab */
        .collaborators-tab-content {
          display: flex;
          flex-direction: column;
          gap: 28px;
        }

        .invite-form-container {
          padding: 24px;
          display: flex;
          flex-direction: column;
          gap: 12px;
        }

        .invite-desc {
          font-size: 0.9rem;
          color: var(--text-secondary);
          margin-bottom: 8px;
        }

        .invite-form {
          display: flex;
          gap: 16px;
          align-items: flex-end;
          flex-wrap: wrap;
        }

        @media (max-width: 576px) {
          .invite-form {
            flex-direction: column;
            align-items: stretch;
          }
        }

        .input-with-icon {
          position: relative;
          width: 100%;
        }

        .input-icon {
          position: absolute;
          left: 14px;
          top: 50%;
          transform: translateY(-50%);
          color: var(--text-muted);
        }

        .invite-btn {
          height: 46px;
          padding: 0 24px;
        }

        .collaborators-list-section {
          display: flex;
          flex-direction: column;
          gap: 16px;
        }

        .collaborators-list {
          display: flex;
          flex-direction: column;
          border-radius: 12px;
          overflow: hidden;
        }

        .collaborator-item {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 16px 20px;
          border-bottom: 1px solid var(--border-color);
        }

        .collaborator-item:last-child {
          border-bottom: none;
        }

        .collaborator-info-main {
          display: flex;
          align-items: center;
          gap: 16px;
        }

        .collaborator-avatar {
          width: 36px;
          height: 36px;
          border-radius: 50%;
          background: rgba(255, 255, 255, 0.05);
          border: 1px solid var(--border-color);
          display: flex;
          align-items: center;
          justify-content: center;
          font-weight: 700;
          font-size: 0.8rem;
          color: var(--text-secondary);
        }

        .collaborator-details {
          display: flex;
          flex-direction: column;
          gap: 4px;
        }

        .collaborator-email {
          font-weight: 600;
          font-size: 0.95rem;
        }

        .empty-state {
          padding: 48px;
          flex-direction: column;
          gap: 12px;
          color: var(--text-secondary);
        }

        .empty-icon {
          color: var(--text-muted);
        }
      `}</style>

      {/* Release Details Modal */}
      {selectedRelease && (
        <div className="modal-overlay" onClick={() => setSelectedRelease(null)}>
          <div className="modal-content glass-card animate-fade-in" onClick={(e) => e.stopPropagation()}>
            <button className="modal-close-btn" onClick={() => setSelectedRelease(null)}>
              <Icons.X size={24} />
            </button>

            <div className="release-details-header">
              {selectedRelease.appIcon ? (
                <img src={selectedRelease.appIcon} alt={selectedRelease.appName || app.name} className="release-details-icon" />
              ) : (
                <div className="release-details-icon-fallback">
                  <Icons.Smartphone size={36} />
                </div>
              )}
              <div className="release-details-title-info">
                <h3>{selectedRelease.appName || app.name}</h3>
                <code>{app.packageName}</code>
              </div>
            </div>

            <div className="release-details-grid">
              <div className="detail-item">
                <span className="detail-label">Version</span>
                <span className="detail-value">{selectedRelease.version}</span>
              </div>
              <div className="detail-item">
                <span className="detail-label">Build Number</span>
                <span className="detail-value">#{selectedRelease.buildNumber}</span>
              </div>
              <div className="detail-item">
                <span className="detail-label">Min SDK</span>
                <span className="detail-value">{selectedRelease.minSdkVersion || 'N/A'}</span>
              </div>
              <div className="detail-item">
                <span className="detail-label">Target SDK</span>
                <span className="detail-value">{selectedRelease.targetSdkVersion || 'N/A'}</span>
              </div>
              <div className="detail-item">
                <span className="detail-label">APK Size</span>
                <span className="detail-value">{selectedRelease.size}</span>
              </div>
              <div className="detail-item">
                <span className="detail-label">Upload Date</span>
                <span className="detail-value">{selectedRelease.date}</span>
              </div>
            </div>

            {selectedRelease.sha256 && (
              <div className="form-group" style={{ marginBottom: '24px' }}>
                <span className="detail-label">SHA-256 Hash</span>
                <span className="detail-value" style={{ marginTop: '4px' }}>
                  <code>{selectedRelease.sha256}</code>
                </span>
              </div>
            )}

            <div className="form-group" style={{ marginBottom: '24px' }}>
              <span className="detail-label">Release Notes</span>
              <p style={{ marginTop: '8px', whiteSpace: 'pre-wrap' }}>{selectedRelease.releaseNotes}</p>
            </div>

            {selectedRelease.permissions && selectedRelease.permissions.length > 0 && (
              <div className="form-group" style={{ marginBottom: '32px' }}>
                <span className="detail-label">Permissions ({selectedRelease.permissions.length})</span>
                <div className="permissions-list">
                  {selectedRelease.permissions.map((perm, idx) => (
                    <span key={idx} className="permission-badge">
                      {perm}
                    </span>
                  ))}
                </div>
              </div>
            )}

            <div className="form-actions" style={{ justifyContent: 'flex-end', gap: '12px' }}>
              <button className="btn btn-secondary" onClick={() => setSelectedRelease(null)}>
                Close
              </button>
              <button
                className="btn btn-primary"
                onClick={() => {
                  handleDownload(selectedRelease.buildNumber, selectedRelease.version);
                  setSelectedRelease(null);
                }}
              >
                <Icons.Download size={16} /> Download APK
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Loader Overlay */}
      {isDeleting && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            background: 'rgba(0,0,0,0.65)',
            backdropFilter: 'blur(6px)',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '20px',
            zIndex: 2000,
          }}
        >
          <div className="spinner" style={{ width: '48px', height: '48px', borderWidth: '4px' }} />
          <p style={{ color: '#fff', fontSize: '1.1rem', fontWeight: 600 }}>Deleting release…</p>
        </div>
      )}
    </div>
  );
}

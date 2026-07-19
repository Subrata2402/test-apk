import React from 'react';
import { Routes, Route, Navigate, useNavigate } from 'react-router-dom';
import LandingPage from '../pages/LandingPage';
import Dashboard from '../pages/Dashboard';
import PrivacyPolicy from '../pages/PrivacyPolicy';
import TermsOfService from '../pages/TermsOfService';
import DeviceAuthPage from '../pages/DeviceAuthPage';

export default function AppRoutes({
  user,
  apps,
  selectedAppId,
  setSelectedAppId,
  handleCreateApp,
  handleLogout,
  setIsLoginModalOpen,
  setIsCreateModalOpen,
  showAlert,
  showConfirm,
  setUser,
  onContactClick
}) {
  const navigate = useNavigate();

  return (
    <Routes>
      <Route
        path="/"
        element={
          <LandingPage
            user={user}
            onLoginClick={() => setIsLoginModalOpen(true)}
            onContactClick={onContactClick}
            onNavigate={(view) => navigate(`/${view}`)}
          />
        }
      />
      <Route
        path="/privacy"
        element={
          <PrivacyPolicy
            onBackToHome={() => navigate('/')}
          />
        }
      />
      <Route
        path="/terms"
        element={
          <TermsOfService
            onBackToHome={() => navigate('/')}
          />
        }
      />

      <Route
        path="/device"
        element={
          <DeviceAuthPage
            user={user}
            onLoginClick={() => setIsLoginModalOpen(true)}
            showAlert={showAlert}
            onGoToDashboard={() => navigate('/dashboard', { replace: true })}
          />
        }
      />
      <Route
        path="/dashboard"
        element={
          user ? (
            <Dashboard
              user={user}
              apps={apps}
              selectedAppId={selectedAppId}
              onSelectApp={setSelectedAppId}
              onCreateApp={handleCreateApp}
              onLogout={handleLogout}
              onOpenCreateModal={() => setIsCreateModalOpen(true)}
              showAlert={showAlert}
              showConfirm={showConfirm}
            />
          ) : (
            <Navigate to="/" replace />
          )
        }
      />
      {/* Fallback */}
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

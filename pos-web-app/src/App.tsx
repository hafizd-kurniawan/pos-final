import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import LoginPage from './pages/LoginPage';
import DashboardPage from './pages/DashboardPage';
import VehiclesPage from './pages/VehiclesPage';
import CustomersPage from './pages/CustomersPage';
import SalesPage from './pages/SalesPage';
import PurchasesPage from './pages/PurchasesPage';
import WorkOrdersPage from './pages/WorkOrdersPage';
import SparePartsPage from './pages/SparePartsPage';
import UsersPage from './pages/UsersPage';
import ReportsPage from './pages/ReportsPage';
import NotificationsPage from './pages/NotificationsPage';
import ProfilePage from './pages/ProfilePage';

const ProtectedRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { isAuthenticated, loading } = useAuth();

  console.log('🛡️ PROTECTED ROUTE - isAuthenticated:', isAuthenticated, 'loading:', loading);

  if (loading) {
    console.log('⏳ Still loading authentication state');
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading...</p>
        </div>
      </div>
    );
  }

  if (isAuthenticated) {
    console.log('✅ User is authenticated, showing protected content');
    return <>{children}</>;
  } else {
    console.log('❌ User not authenticated, redirecting to login');
    return <Navigate to="/login" replace />;
  }
};

const AdminRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { user } = useAuth();

  if (user?.role !== 'admin') {
    return <Navigate to="/dashboard" replace />;
  }

  return <>{children}</>;
};

const AdminOrKasirRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { user } = useAuth();

  if (user?.role !== 'admin' && user?.role !== 'kasir') {
    return <Navigate to="/dashboard" replace />;
  }

  return <>{children}</>;
};

const AppRoutes: React.FC = () => {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      
      {/* Dashboard */}
      <Route
        path="/dashboard"
        element={
          <ProtectedRoute>
            <DashboardPage />
          </ProtectedRoute>
        }
      />

      {/* Profile */}
      <Route
        path="/profile"
        element={
          <ProtectedRoute>
            <ProfilePage />
          </ProtectedRoute>
        }
      />

      {/* Notifications */}
      <Route
        path="/notifications"
        element={
          <ProtectedRoute>
            <NotificationsPage />
          </ProtectedRoute>
        }
      />

      {/* Vehicle Management */}
      <Route
        path="/vehicles"
        element={
          <ProtectedRoute>
            <VehiclesPage />
          </ProtectedRoute>
        }
      />

      {/* Customer Management */}
      <Route
        path="/customers"
        element={
          <ProtectedRoute>
            <CustomersPage />
          </ProtectedRoute>
        }
      />

      {/* Sales Management (Admin + Kasir) */}
      <Route
        path="/sales"
        element={
          <ProtectedRoute>
            <AdminOrKasirRoute>
              <SalesPage />
            </AdminOrKasirRoute>
          </ProtectedRoute>
        }
      />

      {/* Purchase Management (Admin + Kasir) */}
      <Route
        path="/purchases"
        element={
          <ProtectedRoute>
            <AdminOrKasirRoute>
              <PurchasesPage />
            </AdminOrKasirRoute>
          </ProtectedRoute>
        }
      />

      {/* Work Order Management */}
      <Route
        path="/work-orders"
        element={
          <ProtectedRoute>
            <WorkOrdersPage />
          </ProtectedRoute>
        }
      />

      {/* Spare Parts Management */}
      <Route
        path="/spare-parts"
        element={
          <ProtectedRoute>
            <SparePartsPage />
          </ProtectedRoute>
        }
      />

      {/* User Management (Admin only) */}
      <Route
        path="/users"
        element={
          <ProtectedRoute>
            <AdminRoute>
              <UsersPage />
            </AdminRoute>
          </ProtectedRoute>
        }
      />

      {/* Reports */}
      <Route
        path="/reports"
        element={
          <ProtectedRoute>
            <ReportsPage />
          </ProtectedRoute>
        }
      />

      <Route path="/" element={<Navigate to="/dashboard" replace />} />
    </Routes>
  );
};

function App() {
  return (
    <AuthProvider>
      <Router>
        <div className="App">
          <AppRoutes />
        </div>
      </Router>
    </AuthProvider>
  );
}

export default App;

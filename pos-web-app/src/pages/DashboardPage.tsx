import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import apiClient, { DashboardStats, SalesInvoice } from '../services/api';
import { 
  Car, 
  TrendingUp, 
  Wrench, 
  DollarSign, 
  ShoppingCart, 
  Plus, 
  Users, 
  BarChart3,
  CalendarDays,
  CreditCard
} from 'lucide-react';

interface StatCardProps {
  title: string;
  value: string | number;
  subtitle: string;
  icon: React.ReactNode;
  color: string;
}

const StatCard: React.FC<StatCardProps> = ({ title, value, subtitle, icon, color }) => (
  <div className="bg-white overflow-hidden shadow-lg rounded-lg border border-gray-200">
    <div className="p-5">
      <div className="flex items-center">
        <div className="flex-shrink-0">
          <div className={`p-3 rounded-full ${color}`}>
            {icon}
          </div>
        </div>
        <div className="ml-5 w-0 flex-1">
          <dl>
            <dt className="text-sm font-medium text-gray-500 truncate">{title}</dt>
            <dd className="text-lg font-semibold text-gray-900">{value}</dd>
            <dd className="text-sm text-gray-600">{subtitle}</dd>
          </dl>
        </div>
      </div>
    </div>
  </div>
);

interface ActionCardProps {
  title: string;
  icon: React.ReactNode;
  onClick: () => void;
}

const ActionCard: React.FC<ActionCardProps> = ({ title, icon, onClick }) => (
  <div 
    onClick={onClick}
    className="bg-white overflow-hidden shadow-lg rounded-lg border border-gray-200 cursor-pointer hover:shadow-xl transition-shadow duration-200"
  >
    <div className="p-6 text-center">
      <div className="mx-auto flex items-center justify-center h-16 w-16 rounded-full border-2 border-gray-300">
        {icon}
      </div>
      <h3 className="mt-4 text-sm font-medium text-gray-900">{title}</h3>
    </div>
  </div>
);

const DashboardPage: React.FC = () => {
  const { user, logout } = useAuth();
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [recentSales, setRecentSales] = useState<SalesInvoice[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchDashboardData = async () => {
      console.log('📊 FETCHING DASHBOARD DATA');
      setLoading(true);
      setError('');

      try {
        // Fetch dashboard stats
        console.log('📈 Getting dashboard stats...');
        const dashboardStats = await apiClient.getDashboardStats();
        setStats(dashboardStats);

        // Fetch recent sales
        console.log('💰 Getting recent sales...');
        const salesResponse = await apiClient.getSales(1, 5);
        setRecentSales(salesResponse.data);

        console.log('✅ Dashboard data loaded successfully');
      } catch (err: any) {
        console.error('❌ Failed to load dashboard data:', err);
        setError(err.message || 'Failed to load dashboard data');
      } finally {
        setLoading(false);
      }
    };

    fetchDashboardData();
  }, []);

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    }).format(amount);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading dashboard...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-4">
            <div>
              <h1 className="text-2xl font-bold text-gray-900">POS System</h1>
              <p className="text-sm text-gray-600">Vehicle Sales & Service Management</p>
            </div>
            <div className="flex items-center space-x-4">
              <div className="text-right">
                <p className="text-sm font-medium text-gray-900">{user?.name || user?.username}</p>
                <p className="text-xs text-gray-500 capitalize">{user?.role}</p>
              </div>
              <button
                onClick={logout}
                className="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
              >
                Logout
              </button>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Welcome Banner */}
        <div className="bg-gradient-to-r from-blue-500 to-blue-600 rounded-lg shadow-lg mb-8">
          <div className="px-6 py-8 text-white">
            <h2 className="text-2xl font-bold">Welcome back, {user?.name || user?.username}!</h2>
            <p className="mt-2 text-blue-100">Ready to manage vehicle sales and customer transactions</p>
          </div>
        </div>

        {error && (
          <div className="rounded-md bg-red-50 p-4 mb-6">
            <div className="text-sm text-red-700">{error}</div>
          </div>
        )}

        {/* Quick Overview */}
        <div className="mb-8">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Quick Overview</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <StatCard
              title="Available Vehicles"
              value={stats?.availableVehicles || 0}
              subtitle="Ready for sale"
              icon={<Car className="h-6 w-6 text-white" />}
              color="bg-green-500"
            />
            <StatCard
              title="Today's Sales"
              value={stats?.todaySales || 0}
              subtitle="Transactions"
              icon={<TrendingUp className="h-6 w-6 text-white" />}
              color="bg-blue-500"
            />
            <StatCard
              title="Pending Repairs"
              value={stats?.pendingRepairs || 0}
              subtitle="In workshop"
              icon={<Wrench className="h-6 w-6 text-white" />}
              color="bg-orange-500"
            />
            <StatCard
              title="Total Revenue"
              value={formatCurrency(stats?.totalRevenue || 0)}
              subtitle="This month"
              icon={<DollarSign className="h-6 w-6 text-white" />}
              color="bg-purple-500"
            />
          </div>
        </div>

        {/* Quick Actions */}
        <div className="mb-8">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Quick Actions</h3>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <ActionCard
              title="Create Sale"
              icon={<ShoppingCart className="h-6 w-6 text-gray-600" />}
              onClick={() => console.log('Navigate to create sale')}
            />
            <ActionCard
              title="Add Vehicle"
              icon={<Plus className="h-6 w-6 text-gray-600" />}
              onClick={() => console.log('Navigate to add vehicle')}
            />
            <ActionCard
              title="New Customer"
              icon={<Users className="h-6 w-6 text-gray-600" />}
              onClick={() => console.log('Navigate to add customer')}
            />
            <ActionCard
              title="View Reports"
              icon={<BarChart3 className="h-6 w-6 text-gray-600" />}
              onClick={() => console.log('Navigate to reports')}
            />
          </div>
        </div>

        {/* Sales Management Preview */}
        <div>
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-900">Sales Management Preview</h3>
            <button className="text-blue-600 hover:text-blue-700 text-sm font-medium">
              View All Sales →
            </button>
          </div>
          
          {recentSales.length > 0 ? (
            <div className="bg-white shadow-lg rounded-lg border border-gray-200">
              <div className="px-6 py-4 border-b border-gray-200">
                <div className="flex items-center justify-between">
                  <h4 className="text-lg font-medium text-gray-900">SAL-20240301-001</h4>
                  <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                    {formatCurrency(120000000)}
                  </span>
                </div>
                <p className="text-sm text-gray-600 mt-1">Customer: Budi Santoso</p>
              </div>
              
              <div className="px-6 py-4">
                <div className="flex items-center text-sm text-gray-600">
                  <CalendarDays className="h-4 w-4 mr-2" />
                  <span className="mr-4">1 Mar 2024</span>
                  <Car className="h-4 w-4 mr-2" />
                  <span>Daihatsu Ayla (2024)</span>
                </div>
                <div className="mt-2 flex justify-between items-center">
                  <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                    <CreditCard className="h-3 w-3 mr-1" />
                    TRANSFER
                  </span>
                  <button className="text-blue-600 hover:text-blue-700 text-sm font-medium">
                    TRANSFER
                  </button>
                </div>
              </div>
            </div>
          ) : (
            <div className="bg-white shadow-lg rounded-lg border border-gray-200 p-8 text-center">
              <ShoppingCart className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <p className="text-gray-500">No recent sales to display</p>
            </div>
          )}
        </div>
      </main>
    </div>
  );
};

export default DashboardPage;
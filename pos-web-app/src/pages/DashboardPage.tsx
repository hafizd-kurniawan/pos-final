import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import Layout from '../components/Layout';
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
  CalendarDays
} from 'lucide-react';
import { useNavigate } from 'react-router-dom';

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
  const { user } = useAuth();
  const navigate = useNavigate();
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
        // Fetch dashboard stats based on user role
        console.log('📈 Getting dashboard stats...');
        let dashboardStats: DashboardStats;
        
        if (user?.role === 'admin') {
          dashboardStats = await apiClient.getDashboardStats();
        } else if (user?.role === 'kasir') {
          dashboardStats = await apiClient.getKasirDashboard();
        } else if (user?.role === 'mekanik') {
          dashboardStats = await apiClient.getMekanikDashboard();
        } else {
          dashboardStats = await apiClient.getKasirDashboard();
        }
        
        setStats(dashboardStats);

        // Fetch recent sales if user has permission
        if (user?.role === 'admin' || user?.role === 'kasir') {
          console.log('💰 Getting recent sales...');
          const salesResponse = await apiClient.getSales(1, 5);
          setRecentSales(salesResponse.data);
        }

        console.log('✅ Dashboard data loaded successfully');
      } catch (err: any) {
        console.error('❌ Failed to load dashboard data:', err);
        setError(err.message || 'Failed to load dashboard data');
      } finally {
        setLoading(false);
      }
    };

    fetchDashboardData();
  }, [user?.role]);

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      minimumFractionDigits: 0,
    }).format(amount);
  };

  const getQuickActions = () => {
    const actions = [
      { title: 'View Reports', icon: <BarChart3 size={24} className="text-gray-600" />, onClick: () => navigate('/reports') },
    ];

    if (user?.role === 'admin' || user?.role === 'kasir') {
      actions.unshift(
        { title: 'Create Sale', icon: <ShoppingCart size={24} className="text-gray-600" />, onClick: () => navigate('/sales') },
        { title: 'Add Vehicle', icon: <Plus size={24} className="text-gray-600" />, onClick: () => navigate('/vehicles') },
        { title: 'New Customer', icon: <Users size={24} className="text-gray-600" />, onClick: () => navigate('/customers') }
      );
    }

    if (user?.role === 'mekanik') {
      actions.unshift(
        { title: 'Work Orders', icon: <Wrench size={24} className="text-gray-600" />, onClick: () => navigate('/work-orders') },
        { title: 'Spare Parts', icon: <Plus size={24} className="text-gray-600" />, onClick: () => navigate('/spare-parts') }
      );
    }

    return actions;
  };

  if (loading) {
    return (
      <Layout>
        <div className="flex items-center justify-center h-64">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
        </div>
      </Layout>
    );
  }

  if (error) {
    return (
      <Layout>
        <div className="bg-red-50 border border-red-200 rounded-md p-4">
          <div className="text-red-800">
            <strong>Network Error</strong>
            <p className="mt-2">{error}</p>
          </div>
        </div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className="space-y-6">
        {/* Welcome Banner */}
        <div className="bg-gradient-to-r from-blue-600 to-blue-800 rounded-lg shadow-lg">
          <div className="px-6 py-8 text-white">
            <h1 className="text-2xl font-bold">Welcome back, {user?.name || user?.username}!</h1>
            <p className="mt-2 text-blue-100">Ready to manage vehicle sales and customer transactions</p>
          </div>
        </div>

        {/* Quick Overview */}
        <div>
          <h2 className="text-lg font-medium text-gray-900 mb-4">Quick Overview</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <StatCard
              title="Available Vehicles"
              value={stats?.availableVehicles || 0}
              subtitle="Ready for sale"
              icon={<Car size={24} className="text-white" />}
              color="bg-green-500"
            />
            <StatCard
              title="Today's Sales"
              value={stats?.todaySales || 0}
              subtitle="Transactions"
              icon={<TrendingUp size={24} className="text-white" />}
              color="bg-blue-500"
            />
            <StatCard
              title="Pending Repairs"
              value={stats?.pendingRepairs || 0}
              subtitle="In workshop"
              icon={<Wrench size={24} className="text-white" />}
              color="bg-orange-500"
            />
            <StatCard
              title="Total Revenue"
              value={formatCurrency(stats?.totalRevenue || 0)}
              subtitle="This month"
              icon={<DollarSign size={24} className="text-white" />}
              color="bg-purple-500"
            />
          </div>
        </div>

        {/* Quick Actions */}
        <div>
          <h2 className="text-lg font-medium text-gray-900 mb-4">Quick Actions</h2>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {getQuickActions().map((action, index) => (
              <ActionCard
                key={index}
                title={action.title}
                icon={action.icon}
                onClick={action.onClick}
              />
            ))}
          </div>
        </div>

        {/* Sales Management Preview - Only for admin and kasir */}
        {(user?.role === 'admin' || user?.role === 'kasir') && (
          <div>
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-lg font-medium text-gray-900">Sales Management Preview</h2>
              <button
                onClick={() => navigate('/sales')}
                className="text-blue-600 hover:text-blue-500 text-sm font-medium"
              >
                View All Sales →
              </button>
            </div>
            
            {recentSales.length > 0 ? (
              <div className="bg-white shadow-lg rounded-lg overflow-hidden">
                <div className="px-6 py-4 border-b border-gray-200">
                  <h3 className="text-lg font-medium text-gray-900">Recent Sales</h3>
                </div>
                <div className="divide-y divide-gray-200">
                  {recentSales.map((sale) => (
                    <div key={sale.id} className="px-6 py-4 hover:bg-gray-50">
                      <div className="flex items-center justify-between">
                        <div className="flex-1">
                          <div className="flex items-center space-x-4">
                            <div className="flex-shrink-0">
                              <Car className="h-10 w-10 text-blue-500 bg-blue-100 rounded-full p-2" />
                            </div>
                            <div className="flex-1 min-w-0">
                              <p className="text-sm font-medium text-gray-900 truncate">
                                {sale.invoiceNumber}
                              </p>
                              <p className="text-sm text-gray-500 truncate">
                                Customer: {sale.customer?.name}
                              </p>
                              <p className="text-sm text-gray-500 truncate">
                                {sale.vehicle?.brand} {sale.vehicle?.model} ({sale.vehicle?.year})
                              </p>
                            </div>
                          </div>
                        </div>
                        <div className="flex items-center space-x-4">
                          <div className="text-right">
                            <p className="text-sm font-medium text-gray-900">
                              {formatCurrency(sale.sellPrice)}
                            </p>
                            <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                              sale.paymentStatus === 'paid' 
                                ? 'bg-green-100 text-green-800'
                                : sale.paymentStatus === 'pending'
                                ? 'bg-yellow-100 text-yellow-800'
                                : 'bg-red-100 text-red-800'
                            }`}>
                              {sale.paymentStatus.toUpperCase()}
                            </span>
                          </div>
                          <div className="text-sm text-gray-500">
                            <CalendarDays className="inline w-4 h-4 mr-1" />
                            {new Date(sale.createdAt).toLocaleDateString()}
                          </div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            ) : (
              <div className="bg-white shadow-lg rounded-lg p-8 text-center">
                <ShoppingCart className="mx-auto h-12 w-12 text-gray-400" />
                <h3 className="mt-2 text-sm font-medium text-gray-900">No recent sales to display</h3>
                <p className="mt-1 text-sm text-gray-500">Start by creating your first sale.</p>
                <div className="mt-6">
                  <button
                    onClick={() => navigate('/sales')}
                    className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700"
                  >
                    <Plus className="-ml-1 mr-2 h-5 w-5" />
                    Create Sale
                  </button>
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    </Layout>
  );
};

export default DashboardPage;
import React, { useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import {
  LayoutDashboard,
  Car,
  Users,
  ShoppingCart,
  Package,
  Wrench,
  Settings,
  BarChart3,
  Bell,
  Menu,
  X,
  LogOut,
  User,
  UserCheck,
  Home
} from 'lucide-react';

interface LayoutProps {
  children: React.ReactNode;
}

interface NavigationItem {
  name: string;
  href: string;
  icon: React.ReactNode;
  roles?: string[];
}

const Layout: React.FC<LayoutProps> = ({ children }) => {
  const { user, logout } = useAuth();
  const location = useLocation();
  const navigate = useNavigate();
  const [sidebarOpen, setSidebarOpen] = useState(false);

  const navigation: NavigationItem[] = [
    { name: 'Dashboard', href: '/dashboard', icon: <LayoutDashboard size={20} /> },
    { name: 'Vehicles', href: '/vehicles', icon: <Car size={20} /> },
    { name: 'Customers', href: '/customers', icon: <Users size={20} /> },
    { name: 'Sales', href: '/sales', icon: <ShoppingCart size={20} />, roles: ['admin', 'kasir'] },
    { name: 'Purchases', href: '/purchases', icon: <Package size={20} />, roles: ['admin', 'kasir'] },
    { name: 'Work Orders', href: '/work-orders', icon: <Wrench size={20} /> },
    { name: 'Spare Parts', href: '/spare-parts', icon: <Settings size={20} /> },
    { name: 'Reports', href: '/reports', icon: <BarChart3 size={20} /> },
    { name: 'Users', href: '/users', icon: <UserCheck size={20} />, roles: ['admin'] },
  ];

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const isActive = (href: string) => location.pathname === href;

  const filteredNavigation = navigation.filter(item => 
    !item.roles || item.roles.includes(user?.role || '')
  );

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Mobile sidebar */}
      <div className={`fixed inset-0 z-50 lg:hidden ${sidebarOpen ? 'block' : 'hidden'}`}>
        <div className="fixed inset-0 bg-gray-600 bg-opacity-75" onClick={() => setSidebarOpen(false)} />
        <div className="fixed inset-y-0 left-0 flex w-full max-w-xs">
          <div className="flex w-full flex-col bg-white">
            {/* Sidebar content for mobile */}
            <div className="flex h-16 items-center justify-between px-4 bg-blue-600">
              <Link to="/dashboard" className="text-white font-bold text-xl">
                POS System
              </Link>
              <button
                onClick={() => setSidebarOpen(false)}
                className="text-white hover:text-gray-200"
              >
                <X size={24} />
              </button>
            </div>
            <nav className="flex-1 space-y-1 px-2 py-4">
              {filteredNavigation.map((item) => (
                <Link
                  key={item.name}
                  to={item.href}
                  onClick={() => setSidebarOpen(false)}
                  className={`group flex items-center px-2 py-2 text-sm font-medium rounded-md ${
                    isActive(item.href)
                      ? 'bg-blue-100 text-blue-900'
                      : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                  }`}
                >
                  <span className="mr-3">{item.icon}</span>
                  {item.name}
                </Link>
              ))}
            </nav>
          </div>
        </div>
      </div>

      {/* Desktop sidebar */}
      <div className="hidden lg:fixed lg:inset-y-0 lg:flex lg:w-64 lg:flex-col">
        <div className="flex flex-col flex-grow bg-white shadow-lg">
          <div className="flex h-16 items-center px-4 bg-blue-600">
            <Link to="/dashboard" className="text-white font-bold text-xl">
              <Home className="inline mr-2" size={24} />
              POS System
            </Link>
          </div>
          <nav className="flex-1 space-y-1 px-2 py-4">
            {filteredNavigation.map((item) => (
              <Link
                key={item.name}
                to={item.href}
                className={`group flex items-center px-2 py-2 text-sm font-medium rounded-md ${
                  isActive(item.href)
                    ? 'bg-blue-100 text-blue-900'
                    : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                }`}
              >
                <span className="mr-3">{item.icon}</span>
                {item.name}
              </Link>
            ))}
          </nav>
        </div>
      </div>

      {/* Main content */}
      <div className="lg:pl-64">
        {/* Top header */}
        <header className="bg-white shadow-sm border-b border-gray-200">
          <div className="mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex h-16 items-center justify-between">
              <div className="flex items-center">
                <button
                  onClick={() => setSidebarOpen(true)}
                  className="lg:hidden text-gray-500 hover:text-gray-700"
                >
                  <Menu size={24} />
                </button>
                <h1 className="ml-4 text-2xl font-semibold text-gray-900 lg:ml-0">
                  {navigation.find(item => isActive(item.href))?.name || 'POS System'}
                </h1>
              </div>

              <div className="flex items-center space-x-4">
                {/* Notifications */}
                <Link
                  to="/notifications"
                  className="text-gray-500 hover:text-gray-700 relative"
                >
                  <Bell size={20} />
                  {/* Notification badge */}
                  <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full h-4 w-4 flex items-center justify-center">
                    2
                  </span>
                </Link>

                {/* User dropdown */}
                <div className="relative">
                  <div className="flex items-center space-x-3">
                    <div className="text-sm">
                      <p className="font-medium text-gray-900">{user?.name || user?.username}</p>
                      <p className="text-gray-500 capitalize">{user?.role}</p>
                    </div>
                    <div className="flex space-x-2">
                      <Link
                        to="/profile"
                        className="p-2 text-gray-500 hover:text-gray-700 rounded-md"
                        title="Profile"
                      >
                        <User size={18} />
                      </Link>
                      <button
                        onClick={handleLogout}
                        className="p-2 text-gray-500 hover:text-red-600 rounded-md"
                        title="Logout"
                      >
                        <LogOut size={18} />
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </header>

        {/* Page content */}
        <main className="py-8">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            {children}
          </div>
        </main>
      </div>
    </div>
  );
};

export default Layout;
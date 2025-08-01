import React from 'react';
import Layout from '../components/Layout';
import { User, Mail, Key } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';

const ProfilePage: React.FC = () => {
  const { user } = useAuth();

  return (
    <Layout>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Profile Settings</h1>
          <p className="text-gray-600">Manage your account settings and preferences</p>
        </div>

        <div className="bg-white shadow-lg rounded-lg overflow-hidden">
          <div className="px-6 py-4 border-b border-gray-200">
            <h3 className="text-lg font-medium text-gray-900">Personal Information</h3>
          </div>
          
          <div className="p-6">
            <div className="flex items-center mb-6">
              <div className="bg-blue-100 rounded-full p-4">
                <User size={32} className="text-blue-600" />
              </div>
              <div className="ml-4">
                <h2 className="text-xl font-semibold text-gray-900">{user?.name || user?.username}</h2>
                <p className="text-gray-600 capitalize">{user?.role}</p>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Username</label>
                <div className="flex items-center p-3 border border-gray-300 rounded-md bg-gray-50">
                  <User size={16} className="text-gray-400 mr-2" />
                  <span className="text-gray-900">{user?.username}</span>
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Role</label>
                <div className="flex items-center p-3 border border-gray-300 rounded-md bg-gray-50">
                  <Key size={16} className="text-gray-400 mr-2" />
                  <span className="text-gray-900 capitalize">{user?.role}</span>
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Email</label>
                <div className="flex items-center p-3 border border-gray-300 rounded-md bg-gray-50">
                  <Mail size={16} className="text-gray-400 mr-2" />
                  <span className="text-gray-900">{user?.email || 'Not provided'}</span>
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Status</label>
                <div className="flex items-center p-3 border border-gray-300 rounded-md bg-gray-50">
                  <div className={`w-3 h-3 rounded-full mr-2 ${user?.isActive ? 'bg-green-500' : 'bg-red-500'}`}></div>
                  <span className="text-gray-900">{user?.isActive ? 'Active' : 'Inactive'}</span>
                </div>
              </div>

              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-2">Member Since</label>
                <div className="flex items-center p-3 border border-gray-300 rounded-md bg-gray-50">
                  <span className="text-gray-900">
                    {user?.createdAt ? new Date(user.createdAt).toLocaleDateString() : 'Unknown'}
                  </span>
                </div>
              </div>
            </div>

            <div className="mt-8 p-6 bg-yellow-50 border border-yellow-200 rounded-lg">
              <h4 className="text-sm font-medium text-yellow-800 mb-2">Profile Management</h4>
              <p className="text-sm text-yellow-700">
                Profile editing functionality will be implemented here. Users will be able to:
              </p>
              <ul className="mt-2 text-sm text-yellow-700 space-y-1">
                <li>• Update personal information</li>
                <li>• Change password</li>
                <li>• Update email and contact details</li>
                <li>• Manage notification preferences</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
};

export default ProfilePage;
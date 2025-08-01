import React from 'react';
import Layout from '../components/Layout';
import { UserCheck, Plus } from 'lucide-react';

const UsersPage: React.FC = () => {
  return (
    <Layout>
      <div className="space-y-6">
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">User Management</h1>
            <p className="text-gray-600">Manage system users and permissions</p>
          </div>
          <button className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md flex items-center">
            <Plus size={20} className="mr-2" />
            Add User
          </button>
        </div>

        <div className="bg-white p-8 rounded-lg shadow text-center">
          <UserCheck className="mx-auto h-16 w-16 text-gray-400 mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">User Administration</h3>
          <p className="text-gray-600 mb-4">
            Complete user management system for:
          </p>
          <ul className="text-left text-gray-600 space-y-2 max-w-md mx-auto">
            <li>• Create and manage user accounts</li>
            <li>• Role-based access control (Admin, Kasir, Mekanik)</li>
            <li>• Password management and security</li>
            <li>• User activity monitoring</li>
            <li>• Permission and privilege settings</li>
            <li>• Account activation and deactivation</li>
          </ul>
        </div>
      </div>
    </Layout>
  );
};

export default UsersPage;
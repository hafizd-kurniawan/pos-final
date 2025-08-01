import React from 'react';
import Layout from '../components/Layout';
import { Bell } from 'lucide-react';

const NotificationsPage: React.FC = () => {
  return (
    <Layout>
      <div className="space-y-6">
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Notifications</h1>
            <p className="text-gray-600">System alerts and notifications</p>
          </div>
          <button className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md">
            Mark All Read
          </button>
        </div>

        <div className="bg-white p-8 rounded-lg shadow text-center">
          <Bell className="mx-auto h-16 w-16 text-gray-400 mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">Notification Center</h3>
          <p className="text-gray-600 mb-4">
            Real-time notification system for:
          </p>
          <ul className="text-left text-gray-600 space-y-2 max-w-md mx-auto">
            <li>• Low stock alerts</li>
            <li>• Work order updates</li>
            <li>• Payment reminders</li>
            <li>• System maintenance notices</li>
            <li>• User activity alerts</li>
            <li>• Business milestone notifications</li>
          </ul>
        </div>
      </div>
    </Layout>
  );
};

export default NotificationsPage;
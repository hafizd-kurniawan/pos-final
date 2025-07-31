import React from 'react';
import Layout from '../components/Layout';
import { BarChart3, Download } from 'lucide-react';

const ReportsPage: React.FC = () => {
  return (
    <Layout>
      <div className="space-y-6">
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Reports & Analytics</h1>
            <p className="text-gray-600">Business intelligence and reporting dashboard</p>
          </div>
          <button className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md flex items-center">
            <Download size={20} className="mr-2" />
            Export Report
          </button>
        </div>

        <div className="bg-white p-8 rounded-lg shadow text-center">
          <BarChart3 className="mx-auto h-16 w-16 text-gray-400 mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">Business Analytics</h3>
          <p className="text-gray-600 mb-4">
            Comprehensive reporting system including:
          </p>
          <ul className="text-left text-gray-600 space-y-2 max-w-md mx-auto">
            <li>• Sales performance analysis</li>
            <li>• Revenue and profit tracking</li>
            <li>• Vehicle inventory reports</li>
            <li>• Customer analytics</li>
            <li>• Work order efficiency metrics</li>
            <li>• PDF report generation</li>
          </ul>
        </div>
      </div>
    </Layout>
  );
};

export default ReportsPage;
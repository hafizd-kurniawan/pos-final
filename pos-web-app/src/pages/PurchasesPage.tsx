import React from 'react';
import Layout from '../components/Layout';
import { Package, Plus } from 'lucide-react';

const PurchasesPage: React.FC = () => {
  return (
    <Layout>
      <div className="space-y-6">
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Purchase Management</h1>
            <p className="text-gray-600">Manage vehicle purchases and procurement</p>
          </div>
          <button className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md flex items-center">
            <Plus size={20} className="mr-2" />
            Create Purchase
          </button>
        </div>

        <div className="bg-white p-8 rounded-lg shadow text-center">
          <Package className="mx-auto h-16 w-16 text-gray-400 mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">Purchase Management</h3>
          <p className="text-gray-600 mb-4">
            Full purchase management functionality will be implemented here including:
          </p>
          <ul className="text-left text-gray-600 space-y-2 max-w-md mx-auto">
            <li>• Create and manage purchase orders</li>
            <li>• Vehicle procurement tracking</li>
            <li>• Supplier management</li>
            <li>• Cost analysis and reporting</li>
            <li>• Purchase history and analytics</li>
          </ul>
        </div>
      </div>
    </Layout>
  );
};

export default PurchasesPage;
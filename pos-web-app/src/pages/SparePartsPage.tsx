import React from 'react';
import Layout from '../components/Layout';
import { Settings, Plus } from 'lucide-react';

const SparePartsPage: React.FC = () => {
  return (
    <Layout>
      <div className="space-y-6">
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Spare Parts Management</h1>
            <p className="text-gray-600">Manage inventory and spare parts stock</p>
          </div>
          <button className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md flex items-center">
            <Plus size={20} className="mr-2" />
            Add Spare Part
          </button>
        </div>

        <div className="bg-white p-8 rounded-lg shadow text-center">
          <Settings className="mx-auto h-16 w-16 text-gray-400 mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">Spare Parts Inventory</h3>
          <p className="text-gray-600 mb-4">
            Comprehensive spare parts management including:
          </p>
          <ul className="text-left text-gray-600 space-y-2 max-w-md mx-auto">
            <li>• Part catalog and inventory tracking</li>
            <li>• Low stock alerts and notifications</li>
            <li>• Supplier management</li>
            <li>• Barcode scanning and identification</li>
            <li>• Usage tracking and analytics</li>
            <li>• Automatic reorder points</li>
          </ul>
        </div>
      </div>
    </Layout>
  );
};

export default SparePartsPage;
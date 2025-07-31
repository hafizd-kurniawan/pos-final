import React from 'react';
import Layout from '../components/Layout';
import { Wrench, Plus } from 'lucide-react';

const WorkOrdersPage: React.FC = () => {
  return (
    <Layout>
      <div className="space-y-6">
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Work Order Management</h1>
            <p className="text-gray-600">Manage vehicle repair and maintenance tasks</p>
          </div>
          <button className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md flex items-center">
            <Plus size={20} className="mr-2" />
            Create Work Order
          </button>
        </div>

        <div className="bg-white p-8 rounded-lg shadow text-center">
          <Wrench className="mx-auto h-16 w-16 text-gray-400 mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">Work Order System</h3>
          <p className="text-gray-600 mb-4">
            Complete work order management system will include:
          </p>
          <ul className="text-left text-gray-600 space-y-2 max-w-md mx-auto">
            <li>• Create and assign work orders</li>
            <li>• Track repair progress</li>
            <li>• Mechanic assignment and scheduling</li>
            <li>• Parts usage tracking</li>
            <li>• Time and cost estimation</li>
            <li>• Quality control and completion</li>
          </ul>
        </div>
      </div>
    </Layout>
  );
};

export default WorkOrdersPage;
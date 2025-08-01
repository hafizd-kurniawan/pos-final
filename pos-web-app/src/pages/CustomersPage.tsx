import React, { useState, useEffect } from 'react';
import Layout from '../components/Layout';
import apiClient, { Customer, CreateCustomerRequest } from '../services/api';
import { Users, Plus, Edit, Trash2, Search, Phone, Mail, MapPin } from 'lucide-react';

const CustomersPage: React.FC = () => {
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [editingCustomer, setEditingCustomer] = useState<Customer | null>(null);
  const [searchTerm, setSearchTerm] = useState('');

  const fetchCustomers = async () => {
    try {
      setLoading(true);
      const response = await apiClient.getCustomers(1, 100);
      setCustomers(response.data || []);
    } catch (err: any) {
      setError(err.message);
      setCustomers([]); // Ensure customers is always an array
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCustomers();
  }, []);

  const handleCreateCustomer = async (data: CreateCustomerRequest) => {
    try {
      await apiClient.createCustomer(data);
      setShowCreateModal(false);
      fetchCustomers();
    } catch (err: any) {
      setError(err.message);
    }
  };

  const handleUpdateCustomer = async (id: number, data: Partial<CreateCustomerRequest>) => {
    try {
      await apiClient.updateCustomer(id, data);
      setEditingCustomer(null);
      fetchCustomers();
    } catch (err: any) {
      setError(err.message);
    }
  };

  const handleDeleteCustomer = async (id: number) => {
    if (window.confirm('Are you sure you want to delete this customer?')) {
      try {
        await apiClient.deleteCustomer(id);
        fetchCustomers();
      } catch (err: any) {
        setError(err.message);
      }
    }
  };

  const filteredCustomers = (customers || []).filter(customer =>
    customer.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    customer.phone?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    customer.email?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <Layout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Customer Management</h1>
            <p className="text-gray-600">Manage your customer database</p>
          </div>
          <button
            onClick={() => setShowCreateModal(true)}
            className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md flex items-center"
          >
            <Plus size={20} className="mr-2" />
            Add Customer
          </button>
        </div>

        {/* Search */}
        <div className="bg-white p-4 rounded-lg shadow">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={20} />
            <input
              type="text"
              placeholder="Search customers by name, phone, or email..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10 pr-4 py-2 w-full border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
        </div>

        {/* Error Message */}
        {error && (
          <div className="bg-red-50 border border-red-200 rounded-md p-4">
            <div className="text-red-800">{error}</div>
          </div>
        )}

        {/* Customers Grid */}
        {loading ? (
          <div className="flex justify-center py-8">
            <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredCustomers.map((customer) => (
              <div key={customer.id} className="bg-white rounded-lg shadow-lg overflow-hidden">
                <div className="p-6">
                  <div className="flex items-center mb-4">
                    <div className="bg-blue-100 rounded-full p-3">
                      <Users size={24} className="text-blue-600" />
                    </div>
                    <div className="ml-4">
                      <h3 className="text-lg font-semibold text-gray-900">{customer.name}</h3>
                      <p className="text-sm text-gray-500">Customer ID: {customer.id}</p>
                    </div>
                  </div>

                  <div className="space-y-2">
                    {customer.phone && (
                      <div className="flex items-center text-sm text-gray-600">
                        <Phone size={16} className="mr-2" />
                        {customer.phone}
                      </div>
                    )}
                    {customer.email && (
                      <div className="flex items-center text-sm text-gray-600">
                        <Mail size={16} className="mr-2" />
                        {customer.email}
                      </div>
                    )}
                    {customer.address && (
                      <div className="flex items-center text-sm text-gray-600">
                        <MapPin size={16} className="mr-2" />
                        {customer.address}
                      </div>
                    )}
                  </div>

                  <div className="mt-4 text-xs text-gray-500">
                    Created: {new Date(customer.createdAt).toLocaleDateString()}
                  </div>

                  {/* Actions */}
                  <div className="mt-6 flex space-x-2">
                    <button
                      onClick={() => setEditingCustomer(customer)}
                      className="flex-1 bg-blue-600 hover:bg-blue-700 text-white px-3 py-2 rounded-md text-sm flex items-center justify-center"
                    >
                      <Edit size={16} className="mr-1" />
                      Edit
                    </button>
                    <button
                      onClick={() => handleDeleteCustomer(customer.id)}
                      className="flex-1 bg-red-600 hover:bg-red-700 text-white px-3 py-2 rounded-md text-sm flex items-center justify-center"
                    >
                      <Trash2 size={16} className="mr-1" />
                      Delete
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Create/Edit Modal */}
      {(showCreateModal || editingCustomer) && (
        <CustomerModal
          customer={editingCustomer}
          onSave={editingCustomer ? 
            (data) => handleUpdateCustomer(editingCustomer.id, data) : 
            handleCreateCustomer
          }
          onClose={() => {
            setShowCreateModal(false);
            setEditingCustomer(null);
          }}
        />
      )}
    </Layout>
  );
};

interface CustomerModalProps {
  customer?: Customer | null;
  onSave: (data: CreateCustomerRequest) => void;
  onClose: () => void;
}

const CustomerModal: React.FC<CustomerModalProps> = ({ customer, onSave, onClose }) => {
  const [formData, setFormData] = useState<CreateCustomerRequest>({
    name: customer?.name || '',
    phone: customer?.phone || '',
    email: customer?.email || '',
    address: customer?.address || '',
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave(formData);
  };

  return (
    <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div className="relative top-20 mx-auto p-5 border w-11/12 md:w-1/2 lg:w-1/3 shadow-lg rounded-md bg-white">
        <div className="mt-3">
          <h3 className="text-lg font-medium text-gray-900 mb-4">
            {customer ? 'Edit Customer' : 'Add New Customer'}
          </h3>
          
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700">Name</label>
              <input
                type="text"
                required
                value={formData.name}
                onChange={(e) => setFormData({...formData, name: e.target.value})}
                className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700">Phone</label>
              <input
                type="tel"
                value={formData.phone}
                onChange={(e) => setFormData({...formData, phone: e.target.value})}
                className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700">Email</label>
              <input
                type="email"
                value={formData.email}
                onChange={(e) => setFormData({...formData, email: e.target.value})}
                className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700">Address</label>
              <textarea
                value={formData.address}
                onChange={(e) => setFormData({...formData, address: e.target.value})}
                rows={3}
                className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
            </div>
            
            <div className="flex justify-end space-x-3 pt-4">
              <button
                type="button"
                onClick={onClose}
                className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                type="submit"
                className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
              >
                {customer ? 'Update' : 'Create'} Customer
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default CustomersPage;
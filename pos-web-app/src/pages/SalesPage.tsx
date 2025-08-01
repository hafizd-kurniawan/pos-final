import React, { useState, useEffect } from 'react';
import Layout from '../components/Layout';
import apiClient, { SalesInvoice, CreateSalesRequest, Vehicle, Customer } from '../services/api';
import { Plus, Edit, Trash2, Search } from 'lucide-react';

const SalesPage: React.FC = () => {
  const [sales, setSales] = useState<SalesInvoice[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [editingSale, setEditingSale] = useState<SalesInvoice | null>(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [searchTerm, setSearchTerm] = useState('');

  const fetchSales = async (page: number = 1) => {
    try {
      setLoading(true);
      const response = await apiClient.getSales(page, 10);
      setSales(response.data || []);
      setTotalPages(response.pagination?.totalPages || 1);
      setCurrentPage(page);
    } catch (err: any) {
      setError(err.message);
      setSales([]); // Ensure sales is always an array
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchSales();
  }, []);

  const handleCreateSale = async (data: CreateSalesRequest) => {
    try {
      await apiClient.createSale(data);
      setShowCreateModal(false);
      fetchSales(currentPage);
    } catch (err: any) {
      setError(err.message);
    }
  };

  const handleUpdateSale = async (id: number, data: Partial<CreateSalesRequest>) => {
    try {
      await apiClient.updateSale(id, data);
      setEditingSale(null);
      fetchSales(currentPage);
    } catch (err: any) {
      setError(err.message);
    }
  };

  const handleDeleteSale = async (id: number) => {
    if (window.confirm('Are you sure you want to delete this sale?')) {
      try {
        await apiClient.deleteSale(id);
        fetchSales(currentPage);
      } catch (err: any) {
        setError(err.message);
      }
    }
  };

  const getPaymentStatusBadge = (status: string) => {
    const statusConfig = {
      paid: 'bg-green-100 text-green-800',
      pending: 'bg-yellow-100 text-yellow-800',
      partial: 'bg-blue-100 text-blue-800',
      overdue: 'bg-red-100 text-red-800',
    };
    return statusConfig[status as keyof typeof statusConfig] || 'bg-gray-100 text-gray-800';
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      minimumFractionDigits: 0,
    }).format(amount);
  };

  const filteredSales = (sales || []).filter(sale =>
    sale.invoiceNumber.toLowerCase().includes(searchTerm.toLowerCase()) ||
    sale.customer?.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    sale.vehicle?.licensePlate.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <Layout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Sales Management</h1>
            <p className="text-gray-600">Manage sales invoices and transactions</p>
          </div>
          <button
            onClick={() => setShowCreateModal(true)}
            className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md flex items-center"
          >
            <Plus size={20} className="mr-2" />
            Create Sale
          </button>
        </div>

        {/* Search */}
        <div className="bg-white p-4 rounded-lg shadow">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={20} />
            <input
              type="text"
              placeholder="Search by invoice number, customer name, or license plate..."
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

        {/* Sales List */}
        {loading ? (
          <div className="flex justify-center py-8">
            <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
          </div>
        ) : (
          <div className="bg-white shadow-lg rounded-lg overflow-hidden">
            <div className="px-6 py-4 border-b border-gray-200">
              <h3 className="text-lg font-medium text-gray-900">Sales Invoices</h3>
            </div>
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Invoice
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Customer
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Vehicle
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Amount
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Payment
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Date
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Actions
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {filteredSales.map((sale) => (
                    <tr key={sale.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900">{sale.invoiceNumber}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{sale.customer?.name}</div>
                        <div className="text-sm text-gray-500">{sale.customer?.phone}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">
                          {sale.vehicle?.brand} {sale.vehicle?.model}
                        </div>
                        <div className="text-sm text-gray-500">{sale.vehicle?.licensePlate}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900">
                          {formatCurrency(sale.sellPrice)}
                        </div>
                        <div className="text-sm text-gray-500">{sale.paymentMethod}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getPaymentStatusBadge(sale.paymentStatus)}`}>
                          {sale.paymentStatus.toUpperCase()}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {new Date(sale.createdAt).toLocaleDateString()}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <div className="flex space-x-2">
                          <button
                            onClick={() => setEditingSale(sale)}
                            className="text-blue-600 hover:text-blue-900"
                          >
                            <Edit size={16} />
                          </button>
                          <button
                            onClick={() => handleDeleteSale(sale.id)}
                            className="text-red-600 hover:text-red-900"
                          >
                            <Trash2 size={16} />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="flex justify-center space-x-2">
            {Array.from({ length: totalPages }, (_, i) => i + 1).map((page) => (
              <button
                key={page}
                onClick={() => fetchSales(page)}
                className={`px-3 py-2 rounded-md ${
                  page === currentPage
                    ? 'bg-blue-600 text-white'
                    : 'bg-white text-gray-700 hover:bg-gray-100'
                }`}
              >
                {page}
              </button>
            ))}
          </div>
        )}
      </div>

      {/* Create/Edit Modal */}
      {(showCreateModal || editingSale) && (
        <SaleModal
          sale={editingSale}
          onSave={editingSale ? 
            (data) => handleUpdateSale(editingSale.id, data) : 
            handleCreateSale
          }
          onClose={() => {
            setShowCreateModal(false);
            setEditingSale(null);
          }}
        />
      )}
    </Layout>
  );
};

interface SaleModalProps {
  sale?: SalesInvoice | null;
  onSave: (data: CreateSalesRequest) => void;
  onClose: () => void;
}

const SaleModal: React.FC<SaleModalProps> = ({ sale, onSave, onClose }) => {
  const [formData, setFormData] = useState<CreateSalesRequest>({
    vehicleId: sale?.vehicleId || 0,
    customerId: sale?.customerId || 0,
    sellPrice: sale?.sellPrice || 0,
    paymentMethod: sale?.paymentMethod || 'cash',
    paymentStatus: sale?.paymentStatus || 'pending',
    notes: sale?.notes || '',
  });

  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [vehiclesResponse, customersResponse] = await Promise.all([
          apiClient.getVehicles(1, 100, 'available'),
          apiClient.getCustomers(1, 100)
        ]);
        setVehicles(vehiclesResponse.data);
        setCustomers(customersResponse.data);
      } catch (err) {
        console.error('Failed to fetch data:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave(formData);
  };

  if (loading) {
    return (
      <div className="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div className="relative top-20 mx-auto p-5 border w-11/12 md:w-3/4 lg:w-1/2 shadow-lg rounded-md bg-white">
        <div className="mt-3">
          <h3 className="text-lg font-medium text-gray-900 mb-4">
            {sale ? 'Edit Sale' : 'Create New Sale'}
          </h3>
          
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700">Customer</label>
                <select
                  required
                  value={formData.customerId}
                  onChange={(e) => setFormData({...formData, customerId: parseInt(e.target.value)})}
                  className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                >
                  <option value={0}>Select Customer</option>
                  {customers.map((customer) => (
                    <option key={customer.id} value={customer.id}>
                      {customer.name} - {customer.phone}
                    </option>
                  ))}
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700">Vehicle</label>
                <select
                  required
                  value={formData.vehicleId}
                  onChange={(e) => setFormData({...formData, vehicleId: parseInt(e.target.value)})}
                  className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                >
                  <option value={0}>Select Vehicle</option>
                  {vehicles.map((vehicle) => (
                    <option key={vehicle.id} value={vehicle.id}>
                      {vehicle.licensePlate} - {vehicle.brand} {vehicle.model} ({vehicle.year})
                    </option>
                  ))}
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700">Sell Price</label>
                <input
                  type="number"
                  required
                  value={formData.sellPrice}
                  onChange={(e) => setFormData({...formData, sellPrice: parseFloat(e.target.value)})}
                  className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700">Payment Method</label>
                <select
                  required
                  value={formData.paymentMethod}
                  onChange={(e) => setFormData({...formData, paymentMethod: e.target.value as any})}
                  className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                >
                  <option value="cash">Cash</option>
                  <option value="transfer">Transfer</option>
                  <option value="credit">Credit</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700">Payment Status</label>
                <select
                  required
                  value={formData.paymentStatus}
                  onChange={(e) => setFormData({...formData, paymentStatus: e.target.value as any})}
                  className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                >
                  <option value="pending">Pending</option>
                  <option value="partial">Partial</option>
                  <option value="paid">Paid</option>
                  <option value="overdue">Overdue</option>
                </select>
              </div>
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700">Notes</label>
              <textarea
                value={formData.notes}
                onChange={(e) => setFormData({...formData, notes: e.target.value})}
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
                {sale ? 'Update' : 'Create'} Sale
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default SalesPage;
import axios, { AxiosInstance, AxiosResponse } from 'axios';

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  message?: string;
  error?: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

export interface LoginRequest {
  username: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  user: User;
}

export interface User {
  id: number;
  username: string;
  role: string;
  name?: string;
  email?: string;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface Customer {
  id: number;
  name: string;
  phone?: string;
  email?: string;
  address?: string;
  createdAt: string;
  updatedAt: string;
}

export interface Vehicle {
  id: number;
  licensePlate: string;
  brand: string;
  model: string;
  year: number;
  color: string;
  engineNumber?: string;
  chassisNumber?: string;
  status: 'available' | 'sold' | 'in_workshop' | 'reserved';
  purchasePrice: number;
  sellPrice: number;
  condition: string;
  mileage?: number;
  fuelType?: string;
  transmission?: string;
  description?: string;
  photoPath?: string;
  photoUrl?: string;
  createdAt: string;
  updatedAt: string;
}

export interface SalesInvoice {
  id: number;
  invoiceNumber: string;
  vehicleId: number;
  customerId: number;
  userId: number;
  sellPrice: number;
  paymentMethod: 'cash' | 'transfer' | 'credit';
  paymentStatus: 'pending' | 'partial' | 'paid' | 'overdue';
  transferProofPath?: string;
  transferProofUrl?: string;
  notes?: string;
  createdAt: string;
  updatedAt: string;
  vehicle?: Vehicle;
  customer?: Customer;
  user?: User;
}

export interface PurchaseInvoice {
  id: number;
  invoiceNumber: string;
  vehicleId: number;
  customerId: number;
  userId: number;
  purchasePrice: number;
  condition: string;
  paymentMethod: 'cash' | 'transfer';
  paymentStatus: 'pending' | 'paid';
  transferProofPath?: string;
  transferProofUrl?: string;
  notes?: string;
  createdAt: string;
  updatedAt: string;
  vehicle?: Vehicle;
  customer?: Customer;
  user?: User;
}

export interface WorkOrder {
  id: number;
  orderNumber: string;
  vehicleId: number;
  mechanicId?: number;
  description: string;
  status: 'pending' | 'in_progress' | 'completed' | 'cancelled';
  priority: 'low' | 'medium' | 'high' | 'urgent';
  estimatedCost: number;
  actualCost: number;
  estimatedDuration: number;
  actualDuration?: number;
  startDate?: string;
  completionDate?: string;
  notes?: string;
  createdAt: string;
  updatedAt: string;
  vehicle?: Vehicle;
  mechanic?: User;
  workOrderParts?: WorkOrderPart[];
}

export interface WorkOrderPart {
  id: number;
  workOrderId: number;
  sparePartId: number;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
  sparePart?: SparePart;
}

export interface SparePart {
  id: number;
  code: string;
  name: string;
  description?: string;
  brand?: string;
  category: string;
  unitPrice: number;
  sellingPrice: number;
  stock: number;
  minStock: number;
  unit: string;
  barcode?: string;
  location?: string;
  createdAt: string;
  updatedAt: string;
}

export interface Notification {
  id: number;
  userId: number;
  title: string;
  message: string;
  type: 'info' | 'warning' | 'error' | 'success';
  isRead: boolean;
  relatedId?: number;
  relatedType?: string;
  createdAt: string;
  user?: User;
}

export interface DashboardStats {
  availableVehicles: number;
  todaySales: number;
  pendingRepairs: number;
  totalRevenue: number;
  totalCustomers: number;
  totalVehicles: number;
  pendingPayments: number;
  completedSales: number;
  lowStockParts: number;
  activeWorkOrders: number;
  completedWorkOrders: number;
  monthlyRevenue: number;
  monthlyProfit: number;
}

export interface CreateUserRequest {
  username: string;
  password: string;
  role: 'admin' | 'kasir' | 'mekanik';
  name?: string;
  email?: string;
}

export interface UpdateUserRequest {
  username?: string;
  role?: 'admin' | 'kasir' | 'mekanik';
  name?: string;
  email?: string;
  isActive?: boolean;
}

export interface ChangePasswordRequest {
  currentPassword: string;
  newPassword: string;
}

export interface CreateVehicleRequest {
  licensePlate: string;
  brand: string;
  model: string;
  year: number;
  color: string;
  engineNumber?: string;
  chassisNumber?: string;
  purchasePrice: number;
  sellPrice: number;
  condition: string;
  mileage?: number;
  fuelType?: string;
  transmission?: string;
  description?: string;
}

export interface CreateCustomerRequest {
  name: string;
  phone?: string;
  email?: string;
  address?: string;
}

export interface CreateSalesRequest {
  vehicleId: number;
  customerId: number;
  sellPrice: number;
  paymentMethod: 'cash' | 'transfer' | 'credit';
  paymentStatus: 'pending' | 'partial' | 'paid' | 'overdue';
  notes?: string;
}

export interface CreatePurchaseRequest {
  vehicleId: number;
  customerId: number;
  purchasePrice: number;
  condition: string;
  paymentMethod: 'cash' | 'transfer';
  paymentStatus: 'pending' | 'paid';
  notes?: string;
}

export interface CreateWorkOrderRequest {
  vehicleId: number;
  mechanicId?: number;
  description: string;
  priority: 'low' | 'medium' | 'high' | 'urgent';
  estimatedCost: number;
  estimatedDuration: number;
  notes?: string;
}

export interface CreateSparePartRequest {
  code: string;
  name: string;
  description?: string;
  brand?: string;
  category: string;
  unitPrice: number;
  sellingPrice: number;
  stock: number;
  minStock: number;
  unit: string;
  barcode?: string;
  location?: string;
}

class ApiClient {
  private client: AxiosInstance;
  private token: string | null = null;

  constructor(baseURL: string = 'http://localhost:8080/api/v1') {
    console.log('🚀 INITIALIZING API CLIENT');
    console.log(`📍 Base URL: ${baseURL}`);
    
    this.client = axios.create({
      baseURL,
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    });

    // Load token from localStorage
    this.token = localStorage.getItem('auth_token');
    if (this.token) {
      console.log('🔑 Found existing auth token in localStorage');
      this.setAuthToken(this.token);
    }

    // Request interceptor for logging and auth
    this.client.interceptors.request.use(
      (config) => {
        console.log('🌐 OUTGOING REQUEST DEBUG');
        console.log(`📤 Method: ${config.method?.toUpperCase()}`);
        console.log(`📍 URL: ${config.baseURL}${config.url}`);
        console.log(`🔑 Auth Header: ${config.headers?.Authorization ? 'Present' : 'Missing'}`);
        console.log(`📋 Request Headers:`, config.headers);
        if (config.params) {
          console.log(`🔍 Query Params:`, config.params);
        }
        if (config.data) {
          console.log(`📊 Request Body:`, config.data);
        }
        return config;
      },
      (error) => {
        console.error('❌ REQUEST SETUP ERROR:', error);
        return Promise.reject(error);
      }
    );

    // Response interceptor for logging and error handling
    this.client.interceptors.response.use(
      (response: AxiosResponse) => {
        console.log('✅ RESPONSE SUCCESS');
        console.log(`📊 Status: ${response.status}`);
        console.log(`📍 URL: ${response.config.url}`);
        console.log(`📋 Response Headers:`, response.headers);
        console.log(`💾 Response Data:`, response.data);
        return response;
      },
      (error) => {
        console.error('❌ RESPONSE ERROR DETAILS');
        console.error(`🚨 Error Type: ${error.constructor.name}`);
        console.error(`📍 URL: ${error.config?.url}`);
        console.error(`📊 Status: ${error.response?.status}`);
        console.error(`📋 Response Headers:`, error.response?.headers);
        console.error(`💾 Response Data:`, error.response?.data);
        console.error(`🔍 Full Error:`, error);

        // Handle 401 unauthorized
        if (error.response?.status === 401) {
          console.log('🔐 Unauthorized - clearing auth token');
          this.clearAuth();
          window.location.href = '/login';
        }

        return Promise.reject(error);
      }
    );
  }

  public setAuthToken(token: string): void {
    console.log('🔑 Setting auth token');
    this.token = token;
    this.client.defaults.headers.common['Authorization'] = `Bearer ${token}`;
    localStorage.setItem('auth_token', token);
  }

  public clearAuth(): void {
    console.log('🗑️ Clearing auth token');
    this.token = null;
    delete this.client.defaults.headers.common['Authorization'];
    localStorage.removeItem('auth_token');
  }

  public isAuthenticated(): boolean {
    return !!this.token;
  }

  // Health check
  public async healthCheck(): Promise<boolean> {
    try {
      console.log('🏥 HEALTH CHECK');
      const response = await axios.get('http://localhost:8080/health', { timeout: 5000 });
      console.log('✅ Health check passed:', response.data);
      return true;
    } catch (error) {
      console.error('❌ Health check failed:', error);
      return false;
    }
  }

  // Authentication methods
  public async login(credentials: LoginRequest): Promise<LoginResponse> {
    console.log('🔑 LOGIN REQUEST');
    console.log(`📧 Username: ${credentials.username}`);
    
    const response = await this.client.post<ApiResponse<LoginResponse>>('/auth/login', credentials);
    console.log('✅ LOGIN RESPONSE RECEIVED');
    console.log(`📊 Response Status: ${response.status}`);
    console.log(`📋 Response Data:`, response.data);
    
    // Check if we have data (backend doesn't use success field)
    if (response.data.data) {
      const loginData = response.data.data;
      this.setAuthToken(loginData.token);
      console.log('🎉 LOGIN SUCCESSFUL');
      return loginData;
    }
    
    console.error('❌ LOGIN FAILED - No data in response');
    throw new Error(response.data.message || 'Login failed');
  }

  public async getProfile(): Promise<User> {
    console.log('👤 GET PROFILE REQUEST');
    const response = await this.client.get<ApiResponse<User>>('/auth/profile');
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to get profile');
  }

  public async changePassword(data: ChangePasswordRequest): Promise<void> {
    console.log('🔐 CHANGE PASSWORD REQUEST');
    const response = await this.client.post<ApiResponse<void>>('/auth/change-password', data);
    
    if (!response.data.data && response.data.message) {
      throw new Error(response.data.message);
    }
  }

  // Dashboard methods
  public async getDashboardStats(): Promise<DashboardStats> {
    console.log('📊 GET DASHBOARD STATS REQUEST');
    const response = await this.client.get<ApiResponse<DashboardStats>>('/admin/dashboard');
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to get dashboard stats');
  }

  public async getKasirDashboard(): Promise<DashboardStats> {
    console.log('📊 GET KASIR DASHBOARD REQUEST');
    const response = await this.client.get<ApiResponse<DashboardStats>>('/kasir/dashboard');
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to get kasir dashboard');
  }

  public async getMekanikDashboard(): Promise<DashboardStats> {
    console.log('📊 GET MEKANIK DASHBOARD REQUEST');
    const response = await this.client.get<ApiResponse<DashboardStats>>('/mechanic/dashboard');
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to get mekanik dashboard');
  }

  // Customer methods
  public async getCustomers(page: number = 1, limit: number = 20): Promise<PaginatedResponse<Customer>> {
    console.log('👥 GET CUSTOMERS REQUEST');
    const response = await this.client.get<ApiResponse<PaginatedResponse<Customer>>>('/customers', {
      params: { page, limit }
    });
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to get customers');
  }

  public async getCustomer(id: number): Promise<Customer> {
    console.log(`👤 GET CUSTOMER ${id} REQUEST`);
    const response = await this.client.get<ApiResponse<Customer>>(`/customers/${id}`);
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to get customer');
  }

  public async createCustomer(data: CreateCustomerRequest): Promise<Customer> {
    console.log('👤 CREATE CUSTOMER REQUEST');
    const response = await this.client.post<ApiResponse<Customer>>('/customers', data);
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to create customer');
  }

  public async updateCustomer(id: number, data: Partial<CreateCustomerRequest>): Promise<Customer> {
    console.log(`👤 UPDATE CUSTOMER ${id} REQUEST`);
    const response = await this.client.put<ApiResponse<Customer>>(`/customers/${id}`, data);
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to update customer');
  }

  public async deleteCustomer(id: number): Promise<void> {
    console.log(`👤 DELETE CUSTOMER ${id} REQUEST`);
    const response = await this.client.delete<ApiResponse<void>>(`/customers/${id}`);
    
    if (response.data.message && response.data.message.includes('success')) {
      return;
    }
    
    throw new Error(response.data.message || 'Failed to delete customer');
  }

  // Vehicle methods
  public async getVehicles(page: number = 1, limit: number = 20, status?: string): Promise<PaginatedResponse<Vehicle>> {
    console.log('🚗 GET VEHICLES REQUEST');
    const params: any = { page, limit };
    if (status) params.status = status;
    
    const response = await this.client.get<ApiResponse<PaginatedResponse<Vehicle>>>('/vehicles', { params });
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to get vehicles');
  }

  public async getVehicle(id: number): Promise<Vehicle> {
    console.log(`🚗 GET VEHICLE ${id} REQUEST`);
    const response = await this.client.get<ApiResponse<Vehicle>>(`/vehicles/${id}`);
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to get vehicle');
  }

  public async createVehicle(data: CreateVehicleRequest): Promise<Vehicle> {
    console.log('🚗 CREATE VEHICLE REQUEST');
    const response = await this.client.post<ApiResponse<Vehicle>>('/vehicles', data);
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to create vehicle');
  }

  public async updateVehicle(id: number, data: Partial<CreateVehicleRequest>): Promise<Vehicle> {
    console.log(`🚗 UPDATE VEHICLE ${id} REQUEST`);
    const response = await this.client.put<ApiResponse<Vehicle>>(`/vehicles/${id}`, data);
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to update vehicle');
  }

  public async updateVehicleStatus(id: number, status: string): Promise<Vehicle> {
    console.log(`🚗 UPDATE VEHICLE ${id} STATUS REQUEST`);
    const response = await this.client.put<ApiResponse<Vehicle>>(`/vehicles/${id}/status`, { status });
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to update vehicle status');
  }

  public async deleteVehicle(id: number): Promise<void> {
    console.log(`🚗 DELETE VEHICLE ${id} REQUEST`);
    const response = await this.client.delete<ApiResponse<void>>(`/vehicles/${id}`);
    
    if (response.data.message && response.data.message.includes('success')) {
      return;
    }
    
    throw new Error(response.data.message || 'Failed to delete vehicle');
  }

  // Sales methods
  public async getSales(page: number = 1, limit: number = 20): Promise<PaginatedResponse<SalesInvoice>> {
    console.log('💰 GET SALES REQUEST');
    const response = await this.client.get<ApiResponse<PaginatedResponse<SalesInvoice>>>('/sales', {
      params: { page, limit }
    });
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to get sales');
  }

  public async getSale(id: number): Promise<SalesInvoice> {
    console.log(`💰 GET SALE ${id} REQUEST`);
    const response = await this.client.get<ApiResponse<SalesInvoice>>(`/sales/${id}`);
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to get sale');
  }

  public async createSale(data: CreateSalesRequest): Promise<SalesInvoice> {
    console.log('💰 CREATE SALE REQUEST');
    const response = await this.client.post<ApiResponse<SalesInvoice>>('/sales', data);
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to create sale');
  }

  public async updateSale(id: number, data: Partial<CreateSalesRequest>): Promise<SalesInvoice> {
    console.log(`💰 UPDATE SALE ${id} REQUEST`);
    const response = await this.client.put<ApiResponse<SalesInvoice>>(`/sales/${id}`, data);
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to update sale');
  }

  public async deleteSale(id: number): Promise<void> {
    console.log(`💰 DELETE SALE ${id} REQUEST`);
    const response = await this.client.delete<ApiResponse<void>>(`/sales/${id}`);
    
    if (response.data.message && response.data.message.includes('success')) {
      return;
    }
    
    throw new Error(response.data.message || 'Failed to delete sale');
  }

  // Purchase methods
  public async getPurchases(page: number = 1, limit: number = 20): Promise<PaginatedResponse<PurchaseInvoice>> {
    console.log('📦 GET PURCHASES REQUEST');
    const response = await this.client.get<ApiResponse<PaginatedResponse<PurchaseInvoice>>>('/purchases', {
      params: { page, limit }
    });
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to get purchases');
  }

  public async getPurchase(id: number): Promise<PurchaseInvoice> {
    console.log(`📦 GET PURCHASE ${id} REQUEST`);
    const response = await this.client.get<ApiResponse<PurchaseInvoice>>(`/purchases/${id}`);
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to get purchase');
  }

  public async createPurchase(data: CreatePurchaseRequest): Promise<PurchaseInvoice> {
    console.log('📦 CREATE PURCHASE REQUEST');
    const response = await this.client.post<ApiResponse<PurchaseInvoice>>('/purchases', data);
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to create purchase');
  }

  // Work Order methods
  public async getWorkOrders(page: number = 1, limit: number = 20): Promise<PaginatedResponse<WorkOrder>> {
    console.log('🔧 GET WORK ORDERS REQUEST');
    const response = await this.client.get<ApiResponse<PaginatedResponse<WorkOrder>>>('/work-orders', {
      params: { page, limit }
    });
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to get work orders');
  }

  public async getMyWorkOrders(page: number = 1, limit: number = 20): Promise<PaginatedResponse<WorkOrder>> {
    console.log('🔧 GET MY WORK ORDERS REQUEST');
    const response = await this.client.get<ApiResponse<PaginatedResponse<WorkOrder>>>('/work-orders/my', {
      params: { page, limit }
    });
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to get my work orders');
  }

  public async getWorkOrder(id: number): Promise<WorkOrder> {
    console.log(`🔧 GET WORK ORDER ${id} REQUEST`);
    const response = await this.client.get<ApiResponse<WorkOrder>>(`/work-orders/${id}`);
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to get work order');
  }

  public async createWorkOrder(data: CreateWorkOrderRequest): Promise<WorkOrder> {
    console.log('🔧 CREATE WORK ORDER REQUEST');
    const response = await this.client.post<ApiResponse<WorkOrder>>('/work-orders', data);
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to create work order');
  }

  public async startWorkOrder(id: number): Promise<WorkOrder> {
    console.log(`🔧 START WORK ORDER ${id} REQUEST`);
    const response = await this.client.put<ApiResponse<WorkOrder>>(`/work-orders/${id}/start`);
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to start work order');
  }

  public async completeWorkOrder(id: number): Promise<WorkOrder> {
    console.log(`🔧 COMPLETE WORK ORDER ${id} REQUEST`);
    const response = await this.client.put<ApiResponse<WorkOrder>>(`/work-orders/${id}/complete`);
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to complete work order');
  }

  public async assignMechanic(id: number, mechanicId: number): Promise<WorkOrder> {
    console.log(`🔧 ASSIGN MECHANIC TO WORK ORDER ${id} REQUEST`);
    const response = await this.client.put<ApiResponse<WorkOrder>>(`/work-orders/${id}/assign`, { mechanicId });
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to assign mechanic');
  }

  // Spare Parts methods
  public async getSpareParts(page: number = 1, limit: number = 20): Promise<PaginatedResponse<SparePart>> {
    console.log('🔩 GET SPARE PARTS REQUEST');
    const response = await this.client.get<ApiResponse<PaginatedResponse<SparePart>>>('/spare-parts', {
      params: { page, limit }
    });
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to get spare parts');
  }

  public async getLowStockParts(): Promise<SparePart[]> {
    console.log('🔩 GET LOW STOCK PARTS REQUEST');
    const response = await this.client.get<ApiResponse<SparePart[]>>('/spare-parts/low-stock');
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to get low stock parts');
  }

  public async createSparePart(data: CreateSparePartRequest): Promise<SparePart> {
    console.log('🔩 CREATE SPARE PART REQUEST');
    const response = await this.client.post<ApiResponse<SparePart>>('/spare-parts', data);
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to create spare part');
  }

  // Admin User Management methods
  public async getUsers(page: number = 1, limit: number = 20): Promise<PaginatedResponse<User>> {
    console.log('👥 GET USERS REQUEST');
    const response = await this.client.get<ApiResponse<PaginatedResponse<User>>>('/admin/users', {
      params: { page, limit }
    });
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to get users');
  }

  public async createUser(data: CreateUserRequest): Promise<User> {
    console.log('👤 CREATE USER REQUEST');
    const response = await this.client.post<ApiResponse<User>>('/admin/users', data);
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to create user');
  }

  public async updateUser(id: number, data: UpdateUserRequest): Promise<User> {
    console.log(`👤 UPDATE USER ${id} REQUEST`);
    const response = await this.client.put<ApiResponse<User>>(`/admin/users/${id}`, data);
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to update user');
  }

  public async activateUser(id: number, isActive: boolean): Promise<User> {
    console.log(`👤 ${isActive ? 'ACTIVATE' : 'DEACTIVATE'} USER ${id} REQUEST`);
    const response = await this.client.put<ApiResponse<User>>(`/admin/users/${id}/activate`, { isActive });
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to update user status');
  }

  public async deleteUser(id: number): Promise<void> {
    console.log(`👤 DELETE USER ${id} REQUEST`);
    const response = await this.client.delete<ApiResponse<void>>(`/admin/users/${id}`);
    
    if (response.data.message && response.data.message.includes('success')) {
      return;
    }
    
    throw new Error(response.data.message || 'Failed to delete user');
  }

  // File Upload methods
  public async uploadVehiclePhoto(vehicleId: number, file: File): Promise<string> {
    console.log('📷 UPLOAD VEHICLE PHOTO REQUEST');
    const formData = new FormData();
    formData.append('file', file);
    
    const response = await this.client.post<ApiResponse<{ url: string }>>(`/files/vehicles/${vehicleId}/photo`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    
    if (response.data.data) {
      return response.data.data.url;
    }
    
    throw new Error(response.data.message || 'Failed to upload vehicle photo');
  }

  public async uploadTransferProof(saleId: number, file: File): Promise<string> {
    console.log('💳 UPLOAD TRANSFER PROOF REQUEST');
    const formData = new FormData();
    formData.append('file', file);
    
    const response = await this.client.post<ApiResponse<{ url: string }>>(`/files/sales/${saleId}/transfer-proof`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    
    if (response.data.data) {
      return response.data.data.url;
    }
    
    throw new Error(response.data.message || 'Failed to upload transfer proof');
  }

  // Notification methods
  public async getNotifications(page: number = 1, limit: number = 20): Promise<PaginatedResponse<Notification>> {
    console.log('🔔 GET NOTIFICATIONS REQUEST');
    const response = await this.client.get<ApiResponse<PaginatedResponse<Notification>>>('/notifications', {
      params: { page, limit }
    });
    
    if (response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to get notifications');
  }

  public async markNotificationAsRead(id: number): Promise<void> {
    console.log(`🔔 MARK NOTIFICATION ${id} AS READ REQUEST`);
    const response = await this.client.put<ApiResponse<void>>(`/notifications/${id}/read`);
    
    if (response.data.message && response.data.message.includes('success')) {
      return;
    }
    
    throw new Error(response.data.message || 'Failed to mark notification as read');
  }
}

// Create singleton instance
const apiClient = new ApiClient();

export default apiClient;
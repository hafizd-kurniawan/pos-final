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

export interface DashboardStats {
  availableVehicles: number;
  todaySales: number;
  pendingRepairs: number;
  totalRevenue: number;
  totalCustomers: number;
  totalVehicles: number;
  pendingPayments: number;
  completedSales: number;
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

  // Authentication
  public async login(credentials: LoginRequest): Promise<LoginResponse> {
    console.log('🔐 LOGIN REQUEST');
    const response = await this.client.post<ApiResponse<LoginResponse>>('/auth/login', credentials);
    
    if (response.data.success && response.data.data) {
      this.setAuthToken(response.data.data.token);
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Login failed');
  }

  public async getProfile(): Promise<User> {
    console.log('👤 GET PROFILE REQUEST');
    const response = await this.client.get<ApiResponse<User>>('/auth/profile');
    
    if (response.data.success && response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to get profile');
  }

  // Dashboard
  public async getDashboardStats(): Promise<DashboardStats> {
    console.log('📊 GET DASHBOARD STATS REQUEST');
    const response = await this.client.get<ApiResponse<DashboardStats>>('/kasir/dashboard');
    
    if (response.data.success && response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to get dashboard stats');
  }

  // Sales
  public async getSales(page: number = 1, limit: number = 20): Promise<PaginatedResponse<SalesInvoice>> {
    console.log('💰 GET SALES REQUEST');
    const response = await this.client.get<ApiResponse<PaginatedResponse<SalesInvoice>>>('/sales', {
      params: { page, limit }
    });
    
    if (response.data.success && response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to get sales');
  }

  public async createSale(saleData: Partial<SalesInvoice>): Promise<SalesInvoice> {
    console.log('💰 CREATE SALE REQUEST');
    const response = await this.client.post<ApiResponse<SalesInvoice>>('/sales', saleData);
    
    if (response.data.success && response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to create sale');
  }

  // Customers
  public async getCustomers(page: number = 1, limit: number = 20): Promise<PaginatedResponse<Customer>> {
    console.log('👥 GET CUSTOMERS REQUEST');
    const response = await this.client.get<ApiResponse<PaginatedResponse<Customer>>>('/customers', {
      params: { page, limit }
    });
    
    if (response.data.success && response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to get customers');
  }

  public async createCustomer(customerData: Partial<Customer>): Promise<Customer> {
    console.log('👥 CREATE CUSTOMER REQUEST');
    const response = await this.client.post<ApiResponse<Customer>>('/customers', customerData);
    
    if (response.data.success && response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to create customer');
  }

  // Vehicles
  public async getVehicles(page: number = 1, limit: number = 20, status?: string): Promise<PaginatedResponse<Vehicle>> {
    console.log('🚗 GET VEHICLES REQUEST');
    const params: any = { page, limit };
    if (status) params.status = status;
    
    const response = await this.client.get<ApiResponse<PaginatedResponse<Vehicle>>>('/vehicles', { params });
    
    if (response.data.success && response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to get vehicles');
  }

  public async createVehicle(vehicleData: Partial<Vehicle>): Promise<Vehicle> {
    console.log('🚗 CREATE VEHICLE REQUEST');
    const response = await this.client.post<ApiResponse<Vehicle>>('/vehicles', vehicleData);
    
    if (response.data.success && response.data.data) {
      return response.data.data;
    }
    
    throw new Error(response.data.message || 'Failed to create vehicle');
  }
}

// Create singleton instance
const apiClient = new ApiClient();

export default apiClient;
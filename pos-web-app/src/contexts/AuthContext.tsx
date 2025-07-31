import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import apiClient, { User, LoginRequest, LoginResponse } from '../services/api';

interface AuthContextType {
  user: User | null;
  loading: boolean;
  login: (credentials: LoginRequest) => Promise<void>;
  logout: () => void;
  isAuthenticated: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

interface AuthProviderProps {
  children: ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const initializeAuth = async () => {
      console.log('🔐 INITIALIZING AUTH CONTEXT');
      
      if (apiClient.isAuthenticated()) {
        try {
          console.log('🔍 Fetching user profile...');
          const userProfile = await apiClient.getProfile();
          console.log('✅ User profile loaded:', userProfile);
          setUser(userProfile);
        } catch (error) {
          console.error('❌ Failed to load user profile:', error);
          // Clear invalid token
          apiClient.clearAuth();
        }
      }
      
      setLoading(false);
    };

    initializeAuth();
  }, []);

  const login = async (credentials: LoginRequest) => {
    console.log('🔐 LOGIN ATTEMPT');
    setLoading(true);
    
    try {
      const loginResponse: LoginResponse = await apiClient.login(credentials);
      console.log('✅ Login successful:', loginResponse);
      setUser(loginResponse.user);
    } catch (error) {
      console.error('❌ Login failed:', error);
      throw error;
    } finally {
      setLoading(false);
    }
  };

  const logout = () => {
    console.log('🔐 LOGOUT');
    apiClient.clearAuth();
    setUser(null);
  };

  const value: AuthContextType = {
    user,
    loading,
    login,
    logout,
    isAuthenticated: !!user,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};
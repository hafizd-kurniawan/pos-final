import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';

const root = ReactDOM.createRoot(
  document.getElementById('root') as HTMLElement
);

console.log('🚀 STARTING REACT POS APPLICATION');
console.log('🌐 Environment:', process.env.NODE_ENV);
console.log('📍 API Base URL: http://localhost:8080/api/v1');

root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);

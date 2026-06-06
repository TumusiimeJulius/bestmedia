const API_BASE = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:5000/api';

async function request(endpoint, token) {
  const response = await fetch(`${API_BASE}/${endpoint}`, {
    headers: token
      ? {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
        }
      : {
          'Content-Type': 'application/json',
        },
  });

  const body = await response.json();
  if (!response.ok) {
    throw new Error(body.message || 'Unable to fetch data');
  }

  return body;
}

async function send(endpoint, data, token) {
  const response = await fetch(`${API_BASE}/${endpoint}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify(data),
  });

  const body = await response.json();
  if (!response.ok) {
    throw new Error(body.message || 'Request failed');
  }

  return body;
}

export function fetchServices() {
  return request('services');
}

export function fetchProviderServices(token) {
  return request('provider/services', token);
}

export function fetchCategories() {
  return request('categories');
}

export function createService(payload, token) {
  return send('provider/services', payload, token);
}

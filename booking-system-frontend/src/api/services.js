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

  if (!response.ok) {
    const body = await response.json();
    throw new Error(body.message || `Request failed with status ${response.status}`);
  }

  return await response.json();
}

async function send(endpoint, data, token, method = 'POST') {
  const options = {
    method,
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
  };

  // Only add body for methods that support it, and skip empty objects for DELETE
  if (method !== 'DELETE') {
    options.body = JSON.stringify(data);
  }

  const response = await fetch(`${API_BASE}/${endpoint}`, options);

  if (!response.ok) {
    const body = await response.json();
    throw new Error(body.message || `Request failed with status ${response.status}`);
  }

  return await response.json();
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

export function updateService(serviceId, payload, token) {
  return send(`provider/services/${serviceId}`, payload, token, 'PUT');
}

export function deleteService(serviceId, token) {
  return send(`provider/services/${serviceId}`, {}, token, 'DELETE');
}

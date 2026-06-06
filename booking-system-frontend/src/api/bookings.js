const API_BASE = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:5000/api';

async function request(endpoint, token, method = 'GET', data) {
  const options = {
    method,
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
  };

  if (data) {
    options.body = JSON.stringify(data);
  }

  const response = await fetch(`${API_BASE}/${endpoint}`, options);
  const body = await response.json();
  if (!response.ok) {
    throw new Error(body.message || 'Unable to fetch booking data');
  }
  return body;
}

export function fetchBookings(token) {
  return request('bookings', token);
}

export function createBooking(payload, token) {
  return request('bookings', token, 'POST', payload);
}

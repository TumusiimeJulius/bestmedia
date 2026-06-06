const API_BASE = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:5000/api';

async function request(endpoint, token, method = 'GET', data) {
  const options = {
    method,
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
  };

  // Only add body for methods that support it
  if (method !== 'DELETE' && method !== 'GET' && data) {
    options.body = JSON.stringify(data);
  } else if (method === 'PUT' && data) {
    options.body = JSON.stringify(data);
  }

  const response = await fetch(`${API_BASE}/${endpoint}`, options);

  if (!response.ok) {
    const body = await response.json();
    throw new Error(body.message || `Request failed with status ${response.status}`);
  }

  return await response.json();
}

export function fetchBookings(token) {
  return request('bookings', token);
}

export function createBooking(payload, token) {
  return request('bookings', token, 'POST', payload);
}

export function updateBooking(bookingId, payload, token) {
  return request(`bookings/${bookingId}`, token, 'PUT', payload);
}

export function deleteBooking(bookingId, token) {
  return request(`bookings/${bookingId}`, token, 'DELETE');
}

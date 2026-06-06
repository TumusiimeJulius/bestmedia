const BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:5000/api/auth';

async function sendRequest(endpoint, payload) {
  const response = await fetch(`${BASE_URL}/${endpoint}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  });

  const body = await response.json();
  if (!response.ok) {
    throw new Error(body.message || 'Server error');
  }
  return body;
}

export function registerUser(data) {
  return sendRequest('register', data);
}

export function loginUser(data) {
  return sendRequest('login', data);
}

export function forgotPassword(data) {
  return sendRequest('forgot-password', data);
}

export function verifyResetCode(data) {
  return sendRequest('verify-reset-code', data);
}

export function resetPassword(data) {
  return sendRequest('reset-password', data);
}

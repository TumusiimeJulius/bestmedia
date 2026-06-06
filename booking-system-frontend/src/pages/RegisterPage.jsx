import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { registerUser } from '../api/auth';
import { countryCodes } from '../data/countryCodes';

export default function RegisterPage() {
  const navigate = useNavigate();
  const [form, setForm] = useState({ full_name: '', email: '', phone: '', dial_code: '+1', password: '', role: 'client' });
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [loading, setLoading] = useState(false);

  const handleChange = (event) => {
    const { name, value } = event.target;
    setForm({ ...form, [name]: value });
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    setError('');
    setSuccess('');
    setLoading(true);

    try {
      // sanitize local phone (remove non-digits) and combine with dial code
      const localDigits = (form.phone || '').replace(/\D+/g, '');
      const combinedPhone = `${form.dial_code}${localDigits}`;
      const payload = { ...form, phone: combinedPhone };
      const result = await registerUser(payload);
      setSuccess(result.message || 'Account created successfully');
      setForm({ full_name: '', email: '', phone: '', dial_code: '+1', password: '', role: 'client' });
      setTimeout(() => navigate('/login'), 1200);
    } catch (err) {
      setError(err.message || 'Unable to register');
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="page-shell">
      <section className="panel auth-panel">
        <div className="panel-header">
          <h1>Create your account</h1>
          <p>Sign up as a client or provider and start using BestMedia bookings.</p>
        </div>

        <form className="form-grid" onSubmit={handleSubmit}>
          {error && <div className="status error">{error}</div>}
          {success && <div className="status success">{success}</div>}

          <label>
            Full name
            <input type="text" name="full_name" value={form.full_name} onChange={handleChange} required />
          </label>
          <label>
            Email address
            <input type="email" name="email" value={form.email} onChange={handleChange} required />
          </label>
          <label>
            Phone number
            <div style={{ display: 'flex', gap: 8 }}>
              <select name="dial_code" value={form.dial_code} onChange={handleChange} style={{ minWidth: 160 }}>
                {countryCodes.map((c) => (
                  <option key={c.code} value={c.dial_code}>{c.name} ({c.dial_code})</option>
                ))}
              </select>
              <input type="tel" name="phone" value={form.phone} onChange={handleChange} required style={{ flex: 1 }} />
            </div>
          </label>
          <label>
            Password
            <input type="password" name="password" value={form.password} onChange={handleChange} required />
          </label>
          <label>
            Account type
            <select name="role" value={form.role} onChange={handleChange}>
              <option value="client">Client</option>
              <option value="provider">Provider</option>
            </select>
          </label>

          <button type="submit" disabled={loading}>
            {loading ? 'Creating account…' : 'Create Account'}
          </button>
        </form>

        <footer className="form-footer">
          <p>
            Already have an account? <Link to="/login">Login here</Link>
          </p>
        </footer>
      </section>
    </main>
  );
}

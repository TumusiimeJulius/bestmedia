import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { registerUser } from '../api/auth';
import { countryCodes } from '../data/countryCodes';

export default function RegisterPage() {
  const navigate = useNavigate();
  const [form, setForm] = useState({
    full_name: '',
    email: '',
    phone: '',
    dial_code: '+1',
    password: '',
    confirm_password: '',
    role: 'client',
  });
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
      if (form.password !== form.confirm_password) {
        setError('Passwords do not match');
        setLoading(false);
        return;
      }

      const localDigits = (form.phone || '').replace(/\D+/g, '');
      const combinedPhone = `${form.dial_code}${localDigits}`;
      const { confirm_password, ...registrationData } = form;
      const payload = { ...registrationData, phone: combinedPhone };
      const result = await registerUser(payload);
      setSuccess(result.message || 'Account created successfully');
      setForm({
        full_name: '',
        email: '',
        phone: '',
        dial_code: '+1',
        password: '',
        confirm_password: '',
        role: 'client',
      });
      setTimeout(() => navigate('/login'), 1200);
    } catch (err) {
      setError(err.message || 'Unable to register');
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="auth-shell">
      <section className="auth-card auth-card-register">
        <div className="auth-brand">
          <p className="eyebrow">BestMedia Booking</p>
          <h1>Create your account</h1>
          <p>Join as a client or provider and keep every service request, booking, and appointment easy to manage.</p>

          <div className="auth-highlights" aria-label="Platform highlights">
            <span>Client profiles</span>
            <span>Provider tools</span>
            <span>Simple scheduling</span>
          </div>
        </div>

        <div className="auth-form-panel">
          <div className="panel-header">
            <h2>Register</h2>
            <p>Enter your details to get started.</p>
          </div>

          <form className="form-grid" onSubmit={handleSubmit}>
            {error && <div className="status error">{error}</div>}
            {success && <div className="status success">{success}</div>}

            <label>
              Full name
              <input type="text" name="full_name" value={form.full_name} onChange={handleChange} placeholder="Your full name" required />
            </label>

            <label>
              Email address
              <input type="email" name="email" value={form.email} onChange={handleChange} placeholder="name@example.com" required />
            </label>

            <label>
              Phone number
              <div className="phone-field">
                <select name="dial_code" value={form.dial_code} onChange={handleChange} aria-label="Country code">
                  {countryCodes.map((c) => (
                    <option key={c.code} value={c.dial_code}>{c.name} ({c.dial_code})</option>
                  ))}
                </select>
                <input
                  type="tel"
                  name="phone"
                  value={form.phone}
                  onChange={handleChange}
                  placeholder="Enter phone number"
                  required
                />
              </div>
            </label>

            <div className="form-row">
              <label>
                Password
                <input type="password" name="password" value={form.password} onChange={handleChange} placeholder="Create a password" required />
              </label>

              <label>
                Confirm password
                <input
                  type="password"
                  name="confirm_password"
                  value={form.confirm_password}
                  onChange={handleChange}
                  placeholder="Re-enter password"
                  required
                />
              </label>
            </div>

            <label>
              Account type
              <select name="role" value={form.role} onChange={handleChange}>
                <option value="client">Client</option>
                <option value="provider">Provider</option>
              </select>
            </label>

            <button type="submit" disabled={loading}>
              {loading ? 'Creating account...' : 'Create Account'}
            </button>
          </form>

          <footer className="form-footer">
            <p>
              Already have an account? <Link to="/login">Sign in</Link>
            </p>
          </footer>
        </div>
      </section>
    </main>
  );
}

import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { loginUser } from '../api/auth';
import { useAuth } from '../context/AuthContext';

export default function LoginPage() {
  const navigate = useNavigate();
  const { login } = useAuth();
  const [form, setForm] = useState({ email: '', password: '' });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleChange = (event) => {
    setForm({ ...form, [event.target.name]: event.target.value });
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    setError('');
    setLoading(true);

    try {
      const result = await loginUser(form);
      login(result.token);
      navigate('/dashboard');
    } catch (err) {
      setError(err.message || 'Unable to login');
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="page-shell">
      <section className="panel auth-panel">
        <div className="panel-header">
          <h1>Welcome back</h1>
          <p>Sign in to access your booking dashboard and manage clients, services, and appointments.</p>
        </div>

        <form className="form-grid" onSubmit={handleSubmit}>
          {error && <div className="status error">{error}</div>}

          <label>
            Email address
            <input type="email" name="email" value={form.email} onChange={handleChange} required />
          </label>

          <label>
            <span className="label-row">
              Password
              <Link to="/forgot-password">Forgot password?</Link>
            </span>
            <input type="password" name="password" value={form.password} onChange={handleChange} required />
          </label>

          <button type="submit" disabled={loading}>
            {loading ? 'Signing in…' : 'Sign In'}
          </button>
        </form>

        <footer className="form-footer">
          <p>
            Need an account? <Link to="/register">Register here</Link>
          </p>
        </footer>
      </section>
    </main>
  );
}

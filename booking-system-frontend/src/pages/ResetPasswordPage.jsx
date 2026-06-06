import { useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { resetPassword } from '../api/auth';

export default function ResetPasswordPage() {
  const navigate = useNavigate();
  const { state } = useLocation();
  const email = state?.email || '';
  const code = state?.code || '';
  const [password, setPassword] = useState('');
  const [password2, setPassword2] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const submit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    if (password !== password2) return setError('Passwords do not match');
    setLoading(true);
    try {
      await resetPassword({ email, code, new_password: password });
      setSuccess('Password reset successfully');
      setTimeout(() => navigate('/login'), 1200);
    } catch (err) {
      setError(err.message || 'Unable to reset password');
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="page-shell">
      <section className="panel auth-panel">
        <div className="panel-header">
          <h1>Set a new password</h1>
          <p>Create a new secure password for your account.</p>
        </div>

        <form className="form-grid" onSubmit={submit}>
          {error && <div className="status error">{error}</div>}
          {success && <div className="status success">{success}</div>}

          <label>
            Email
            <input type="email" value={email} readOnly />
          </label>

          <label>
            Code
            <input type="text" value={code} readOnly />
          </label>

          <label>
            New password
            <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} required />
          </label>

          <label>
            Confirm password
            <input type="password" value={password2} onChange={(e) => setPassword2(e.target.value)} required />
          </label>

          <button type="submit" disabled={loading}>{loading ? 'Saving…' : 'Save new password'}</button>
        </form>
      </section>
    </main>
  );
}

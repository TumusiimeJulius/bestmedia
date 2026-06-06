import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { forgotPassword } from '../api/auth';

export default function ForgotPasswordPage() {
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const submit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    setLoading(true);
    try {
      await forgotPassword({ email });
      setSuccess('Reset code sent to your email');
      // navigate to verify page with email in state
      navigate('/verify-reset', { state: { email } });
    } catch (err) {
      setError(err.message || 'Unable to send reset code');
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="page-shell">
      <section className="panel auth-panel">
        <div className="panel-header">
          <h1>Forgot password</h1>
          <p>Enter the email for your account, and we'll send a verification code.</p>
        </div>

        <form className="form-grid" onSubmit={submit}>
          {error && <div className="status error">{error}</div>}
          {success && <div className="status success">{success}</div>}

          <label>
            Email address
            <input type="email" name="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
          </label>

          <button type="submit" disabled={loading}>{loading ? 'Sending…' : 'Send code'}</button>
        </form>
      </section>
    </main>
  );
}

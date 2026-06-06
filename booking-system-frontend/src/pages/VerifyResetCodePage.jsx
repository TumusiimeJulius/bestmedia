import { useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { verifyResetCode } from '../api/auth';

export default function VerifyResetCodePage() {
  const navigate = useNavigate();
  const { state } = useLocation();
  const email = state?.email || '';
  const [code, setCode] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const submit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      await verifyResetCode({ email, code });
      navigate('/reset-password', { state: { email, code } });
    } catch (err) {
      setError(err.message || 'Invalid or expired code');
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="page-shell">
      <section className="panel auth-panel">
        <div className="panel-header">
          <h1>Verify code</h1>
          <p>Enter the code sent to your email to continue.</p>
        </div>

        <form className="form-grid" onSubmit={submit}>
          {error && <div className="status error">{error}</div>}

          <label>
            Email
            <input type="email" value={email} readOnly />
          </label>

          <label>
            Code
            <input type="text" name="code" value={code} onChange={(e) => setCode(e.target.value)} required />
          </label>

          <button type="submit" disabled={loading}>{loading ? 'Verifying…' : 'Verify code'}</button>
        </form>
      </section>
    </main>
  );
}

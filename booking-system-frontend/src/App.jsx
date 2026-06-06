import { useState } from 'react';
import { registerUser, loginUser } from './api/auth';

const initialRegister = {
  full_name: '',
  email: '',
  phone: '',
  password: '',
  role: 'client',
};

const initialLogin = {
  email: '',
  password: '',
};

function App() {
  const [view, setView] = useState('login');
  const [registerForm, setRegisterForm] = useState(initialRegister);
  const [loginForm, setLoginForm] = useState(initialLogin);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [token, setToken] = useState('');
  const [userEmail, setUserEmail] = useState('');

  const handleRegisterChange = (e) => {
    setRegisterForm({ ...registerForm, [e.target.name]: e.target.value });
  };

  const handleLoginChange = (e) => {
    setLoginForm({ ...loginForm, [e.target.name]: e.target.value });
  };

  const submitRegister = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');

    try {
      const data = await registerUser(registerForm);
      setSuccess(data.message || 'Registered successfully');
      setRegisterForm(initialRegister);
      setView('login');
    } catch (err) {
      setError(err.message);
    }
  };

  const submitLogin = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');

    try {
      const data = await loginUser(loginForm);
      setToken(data.token);
      setUserEmail(loginForm.email);
      setSuccess('Login successful');
      setLoginForm(initialLogin);
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <div className="page-shell">
      <div className="card">
        <header>
          <h1>BestMedia Booking</h1>
          <p>Register and login to access the booking dashboard.</p>
        </header>

        <div className="tab-group">
          <button className={view === 'login' ? 'active' : ''} onClick={() => { setView('login'); setError(''); setSuccess(''); }}>
            Login
          </button>
          <button className={view === 'register' ? 'active' : ''} onClick={() => { setView('register'); setError(''); setSuccess(''); }}>
            Register
          </button>
        </div>

        {error && <div className="status error">{error}</div>}
        {success && <div className="status success">{success}</div>}

        {token ? (
          <section className="welcome-panel">
            <h2>Welcome back</h2>
            <p>You are logged in as <strong>{userEmail}</strong>.</p>
            <div className="token-box">
              <label>JWT Token</label>
              <textarea readOnly value={token} />
            </div>
            <button className="secondary" onClick={() => { setToken(''); setSuccess(''); setUserEmail(''); }}>Logout</button>
          </section>
        ) : view === 'login' ? (
          <form onSubmit={submitLogin} className="form-grid">
            <label>
              Email
              <input type="email" name="email" value={loginForm.email} onChange={handleLoginChange} required />
            </label>
            <label>
              Password
              <input type="password" name="password" value={loginForm.password} onChange={handleLoginChange} required />
            </label>
            <button type="submit">Login</button>
          </form>
        ) : (
          <form onSubmit={submitRegister} className="form-grid">
            <label>
              Full Name
              <input type="text" name="full_name" value={registerForm.full_name} onChange={handleRegisterChange} required />
            </label>
            <label>
              Email
              <input type="email" name="email" value={registerForm.email} onChange={handleRegisterChange} required />
            </label>
            <label>
              Phone
              <input type="tel" name="phone" value={registerForm.phone} onChange={handleRegisterChange} required />
            </label>
            <label>
              Password
              <input type="password" name="password" value={registerForm.password} onChange={handleRegisterChange} required />
            </label>
            <label>
              Role
              <select name="role" value={registerForm.role} onChange={handleRegisterChange}>
                <option value="client">Client</option>
                <option value="provider">Provider</option>
              </select>
            </label>
            <button type="submit">Register</button>
          </form>
        )}
      </div>
    </div>
  );
}

export default App;

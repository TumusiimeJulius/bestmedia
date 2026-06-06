import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export default function OverviewPage() {
  const { user } = useAuth();

  return (
    <main className="page-shell overview-shell">
      <section className="panel overview-panel">
        <div className="panel-header">
          <p className="eyebrow">Dashboard</p>
          <h1>Welcome back, {user?.role === 'provider' ? 'Provider' : 'Client'}</h1>
          <p>
            This dashboard is tailored to your account type. Browse services and create bookings as a client, or manage your services and incoming appointments as a provider.
          </p>
        </div>

        <div className="overview-grid">
          <article className="overview-card">
            <h2>Services</h2>
            <p>{user?.role === 'provider' ? 'Manage services available for clients.' : 'Browse available provider services.'}</p>
            <Link className="button-link" to="/services">
              Go to Services
            </Link>
          </article>

          <article className="overview-card">
            <h2>Bookings</h2>
            <p>{user?.role === 'provider' ? 'See client bookings for your services.' : 'Review your upcoming bookings.'}</p>
            <Link className="button-link" to="/bookings">
              View Bookings
            </Link>
          </article>

          <article className="overview-card">
            <h2>Your account</h2>
            <p>Role: {user?.role}</p>
            <p>User ID: {user?.user_id}</p>
          </article>
        </div>
      </section>
    </main>
  );
}

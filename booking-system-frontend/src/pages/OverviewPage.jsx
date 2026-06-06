import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export default function OverviewPage() {
  const { user } = useAuth();
  const isProvider = user?.role === 'provider';

  return (
    <main className="page-shell overview-shell">
      <section className="panel overview-panel">
        <div className="panel-header">
          <p className="eyebrow">Dashboard</p>
          <h1>Welcome back, {isProvider ? 'Provider' : 'Client'}</h1>
          <p>
            {isProvider
              ? 'Manage your service portfolio, review incoming bookings, and keep your profile aligned with client demand.'
              : 'Book services quickly, track appointments, and stay organized with your upcoming bookings.'}
          </p>
        </div>

        <div className="overview-grid">
          <article className="overview-card">
            <h2>{isProvider ? 'Service catalog' : 'Browse services'}</h2>
            <p>
              {isProvider
                ? 'Create and update the services you offer, set pricing, and organize by category.'
                : 'Explore provider services with clear pricing, duration, and provider details.'}
            </p>
            <Link className="button-link" to="/services">
              Manage services
            </Link>
          </article>

          <article className="overview-card">
            <h2>{isProvider ? 'Client bookings' : 'Upcoming bookings'}</h2>
            <p>
              {isProvider
                ? 'See who booked your services and monitor booking times.'
                : 'Track your appointments and view provider details in one place.'}
            </p>
            <Link className="button-link" to="/bookings">
              View bookings
            </Link>
          </article>

          <article className="overview-card">
            <h2>Account</h2>
            <p>Role: {user?.role}</p>
            <p>User ID: {user?.user_id}</p>
          </article>
        </div>

        <div className="overview-actions">
          <article className="overview-card small-card">
            <h3>Quick start</h3>
            <p>
              {isProvider
                ? 'Add a new service and publish it so clients can book directly.'
                : 'Search services and book a convenient time slot today.'}
            </p>
          </article>

          <article className="overview-card small-card">
            <h3>Tips</h3>
            <p>
              {isProvider
                ? 'Keep your availability and rates updated for better client bookings.'
                : 'Select a service, choose date/time, and confirm your booking instantly.'}
            </p>
          </article>
        </div>
      </section>
    </main>
  );
}

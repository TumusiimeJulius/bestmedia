import { useAuth } from '../context/AuthContext';

const featureCards = [
  {
    title: 'Services & Categories',
    description: 'Your database stores services, categories, and provider pricing. Add backend routes for service management to make this interactive.',
  },
  {
    title: 'Bookings & Payments',
    description: 'Bookings, payments, refunds, and reviews are available in your schema. Connect API endpoints to manage appointments and transactions.',
  },
  {
    title: 'Provider Availability',
    description: 'Availability and provider profiles are stored in the database. Use them to build provider schedules and booking windows.',
  },
  {
    title: 'Activity & Audit Trails',
    description: 'Audit logs, activity tracking, login history, and notifications are ready for admin monitoring and analytics.',
  },
];

export default function DashboardPage() {
  const { user, logout } = useAuth();

  return (
    <main className="page-shell dashboard-shell">
      <header className="dashboard-header">
        <div>
          <p className="eyebrow">BestMedia Booking</p>
          <h1>Dashboard</h1>
          <p>Welcome back, {user?.role === 'provider' ? 'provider' : 'client'} user.</p>
        </div>

        <div className="dashboard-actions">
          <button className="secondary" onClick={logout}>
            Logout
          </button>
        </div>
      </header>

      <section className="dashboard-summary">
        <div className="summary-card">
          <span>Account</span>
          <strong>{user?.role ?? 'client'}</strong>
        </div>
        <div className="summary-card">
          <span>User ID</span>
          <strong>{user?.user_id ?? 'N/A'}</strong>
        </div>
        <div className="summary-card">
          <span>Token status</span>
          <strong>Connected</strong>
        </div>
      </section>

      <section className="grid-panel">
        {featureCards.map((item) => (
          <article key={item.title} className="feature-card">
            <h2>{item.title}</h2>
            <p>{item.description}</p>
            <div className="feature-footer">Backend route integration pending</div>
          </article>
        ))}
      </section>

      <section className="info-panel">
        <h2>Next steps</h2>
        <p>
          Your frontend is now ready for auth and a dashboard experience. To fully unlock the booking workflow, add backend routes for services, bookings, availability, and notifications.
        </p>
      </section>
    </main>
  );
}

import { Link } from 'react-router-dom';

export default function NotFoundPage() {
  return (
    <main className="page-shell notfound-shell">
      <section className="panel auth-panel">
        <h1>Page not found</h1>
        <p>We could not find that page. Go back to the login screen to continue.</p>
        <Link className="secondary" to="/login">
          Return to Login
        </Link>
      </section>
    </main>
  );
}

import { NavLink, Outlet } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export default function AppLayout() {
  const { user, logout } = useAuth();

  return (
    <div className="layout-shell">
      <aside className="sidebar">
        <div className="brand-block">
          <div>
            <p className="eyebrow">BestMedia</p>
            <h1>Booking app</h1>
          </div>
        </div>

        <nav className="sidebar-nav">
          <NavLink to="/dashboard">Overview</NavLink>
          <NavLink to="/services">Services</NavLink>
          <NavLink to="/bookings">Bookings</NavLink>
        </nav>

        <div className="sidebar-footer">
          <p className="sidebar-user">{user?.role?.toUpperCase()}</p>
          <button type="button" className="secondary" onClick={logout}>
            Logout
          </button>
        </div>
      </aside>

      <section className="content-shell">
        <Outlet />
      </section>
    </div>
  );
}

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
          <p className="sidebar-section-label">Navigation</p>
          <NavLink to="/dashboard" className={({ isActive }) => isActive ? 'nav-item active' : 'nav-item'}>
            Overview
          </NavLink>
          <NavLink to="/services" className={({ isActive }) => isActive ? 'nav-item active' : 'nav-item'}>
            Services
          </NavLink>
          <NavLink to="/bookings" className={({ isActive }) => isActive ? 'nav-item active' : 'nav-item'}>
            Bookings
          </NavLink>
          {user?.role === 'provider' && (
            <NavLink to="/created-sessions" className={({ isActive }) => isActive ? 'nav-item active' : 'nav-item'}>
              Created sessions
            </NavLink>
          )}
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

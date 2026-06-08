import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { fetchProviderServices, deleteService } from '../api/services';

export default function ProviderSessionsPage() {
  const { token, user } = useAuth();
  const navigate = useNavigate();
  const [services, setServices] = useState([]);
  const [error, setError] = useState('');
  const [message, setMessage] = useState('');
  const [loading, setLoading] = useState(false);

  const reloadServices = async () => {
    try {
      const result = await fetchProviderServices(token);
      setServices(result.services || []);
    } catch (err) {
      setError(err.message);
    }
  };

  const handleDeleteService = async (serviceId) => {
    if (!window.confirm('Are you sure you want to delete this service?')) return;

    setError('');
    setMessage('');
    setLoading(true);

    try {
      await deleteService(serviceId, token);
      setMessage('Service deleted successfully.');
      await reloadServices();
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleViewBookings = (serviceId) => {
    navigate('/bookings', { state: { filterServiceId: serviceId } });
  };

  useEffect(() => {
    async function loadServices() {
      try {
        setError('');
        setLoading(true);
        const result = await fetchProviderServices(token);
        setServices(result.services || []);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    }

    if (token && user?.role === 'provider') {
      loadServices();
    }
  }, [token, user]);

  if (user?.role !== 'provider') {
    return (
      <main className="page-shell sessions-shell">
        <section className="panel sessions-panel">
          <div className="panel-header">
            <p className="eyebrow">Access denied</p>
            <h1>Provider sessions are only available for provider accounts</h1>
          </div>
          <div className="status error">You do not have permission to view this page.</div>
        </section>
      </main>
    );
  }

  return (
    <main className="page-shell sessions-shell">
      <section className="panel sessions-panel">
        <div className="panel-header">
          <p className="eyebrow">Created services</p>
          <h1>Your created services</h1>
          <p>Manage your services, view incoming bookings, or edit service details.</p>
        </div>

        {error && <div className="status error">{error}</div>}
        {message && <div className="status success">{message}</div>}
        {loading && <div className="status success">Loading services…</div>}

        <div className="booking-list">
          {services.length === 0 ? (
            <div className="empty-state">No services created yet. Go to the Services page to create one.</div>
          ) : (
            services.map((service) => (
              <article key={service.service_id} className="booking-card">
                <div className="booking-card-header">
                  <div>
                    <h2>{service.service_name}</h2>
                    <p>{service.category_name || 'No category'}</p>
                  </div>
                  <span className="booking-status">{service.is_active ? 'Active' : 'Inactive'}</span>
                </div>

                <div className="booking-details">
                  <p>
                    <strong>Description:</strong> {service.description || 'No description'}
                  </p>
                  <p>
                    <strong>Duration:</strong> {service.duration_minutes} min
                  </p>
                  <p>
                    <strong>Price:</strong> {service.currency || 'UGX'} {Number(service.price).toFixed(2)}
                  </p>
                </div>

                <div className="booking-footer">
                  <button
                    type="button"
                    className="button-link secondary"
                    onClick={() => handleViewBookings(service.service_id)}
                  >
                    Start live session
                  </button>
                  <button
                    type="button"
                    className="button-link secondary"
                    onClick={() => navigate('/services', { state: { editServiceId: service.service_id } })}
                  >
                    Edit service
                  </button>
                  <button
                    type="button"
                    className="delete-btn"
                    onClick={() => handleDeleteService(service.service_id)}
                    disabled={loading}
                  >
                    Delete
                  </button>
                </div>
              </article>
            ))
          )}
        </div>
      </section>
    </main>
  );
}

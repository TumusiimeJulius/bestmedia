import { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { createService, fetchCategories, fetchProviderServices, fetchServices } from '../api/services';
import { createBooking } from '../api/bookings';

const initialServiceForm = {
  service_name: '',
  category_id: '',
  description: '',
  duration_minutes: '',
  price: '',
  is_active: true,
};

export default function ServicesPage() {
  const { token, user } = useAuth();
  const [services, setServices] = useState([]);
  const [categories, setCategories] = useState([]);
  const [serviceForm, setServiceForm] = useState(initialServiceForm);
  const [bookingForms, setBookingForms] = useState({});
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    async function loadData() {
      try {
        setError('');
        const [categoriesResult, servicesResult] = await Promise.all([
          fetchCategories(),
          user?.role === 'provider' ? fetchProviderServices(token) : fetchServices(),
        ]);
        setCategories(categoriesResult.categories || []);
        setServices(servicesResult.services || []);
      } catch (err) {
        setError(err.message);
      }
    }
    if (token) {
      loadData();
    }
  }, [token, user]);

  const reloadServices = async () => {
    const servicesResult = user.role === 'provider' ? await fetchProviderServices(token) : await fetchServices();
    setServices(servicesResult.services || []);
  };

  const handleServiceChange = (event) => {
    const { name, value, type, checked } = event.target;
    setServiceForm((current) => ({
      ...current,
      [name]: type === 'checkbox' ? checked : value,
    }));
  };

  const handleCreateService = async (event) => {
    event.preventDefault();
    setError('');
    setMessage('');
    setLoading(true);

    try {
      await createService(
        {
          ...serviceForm,
          category_id: serviceForm.category_id || null,
          duration_minutes: Number(serviceForm.duration_minutes),
          price: Number(serviceForm.price),
        },
        token
      );
      setMessage('Service created successfully.');
      setServiceForm(initialServiceForm);
      await reloadServices();
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleBookingChange = (serviceId, event) => {
    const { name, value } = event.target;
    setBookingForms((current) => ({
      ...current,
      [serviceId]: {
        ...current[serviceId],
        [name]: value,
      },
    }));
  };

  const handleBookService = async (serviceId) => {
    setError('');
    setMessage('');
    setLoading(true);

    try {
      const form = bookingForms[serviceId] || {};
      await createBooking(
        {
          service_id: serviceId,
          booking_date: form.booking_date,
          booking_time: form.booking_time,
          notes: form.notes,
        },
        token
      );
      setMessage('Booking created successfully.');
      setBookingForms((current) => ({ ...current, [serviceId]: {} }));
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="page-shell services-shell">
      <section className="panel services-panel">
        <div className="panel-header">
          <p className="eyebrow">Services</p>
          <h1>{user?.role === 'provider' ? 'Manage your services' : 'Browse available services'}</h1>
          <p>
            {user?.role === 'provider'
              ? 'Add, update, and review the services you provide for clients.'
              : 'Select a service and book a time slot with the provider.'}
          </p>
        </div>

        {error && <div className="status error">{error}</div>}
        {message && <div className="status success">{message}</div>}

        {user?.role === 'provider' && (
          <form className="form-grid service-form" onSubmit={handleCreateService}>
            <label>
              Service Name
              <input name="service_name" value={serviceForm.service_name} onChange={handleServiceChange} required />
            </label>
            <label>
              Category
              <select name="category_id" value={serviceForm.category_id} onChange={handleServiceChange}>
                <option value="">General</option>
                {categories.map((category) => (
                  <option key={category.category_id} value={category.category_id}>
                    {category.category_name}
                  </option>
                ))}
              </select>
            </label>
            <label>
              Description
              <textarea name="description" value={serviceForm.description} onChange={handleServiceChange} rows="4" />
            </label>
            <label>
              Duration (minutes)
              <input name="duration_minutes" type="number" min="10" value={serviceForm.duration_minutes} onChange={handleServiceChange} required />
            </label>
            <label>
              Price
              <input name="price" type="number" min="0" step="0.01" value={serviceForm.price} onChange={handleServiceChange} required />
            </label>
            <label className="checkbox-label">
              <input type="checkbox" name="is_active" checked={serviceForm.is_active} onChange={handleServiceChange} />
              Active service
            </label>
            <button type="submit" disabled={loading}>
              {loading ? 'Saving…' : 'Save service'}
            </button>
          </form>
        )}

        <div className="service-grid">
          {services.map((service) => {
            const bookingForm = bookingForms[service.service_id] || {};
            return (
              <article key={service.service_id} className="service-card">
                <div className="service-card-header">
                  <div>
                    <h2>{service.service_name}</h2>
                    <p className="service-meta">{service.category_name || 'Uncategorized'}</p>
                  </div>
                  <strong>${service.price.toFixed(2)}</strong>
                </div>
                <p>{service.description || 'No description provided.'}</p>
                <div className="service-details">
                  <span>Provider: {service.provider_name || 'Unknown'}</span>
                  <span>Duration: {service.duration_minutes} min</span>
                </div>

                {user?.role === 'provider' ? (
                  <div className="service-footer">
                    <span>Status: {service.is_active ? 'Active' : 'Inactive'}</span>
                  </div>
                ) : (
                  <div className="booking-panel">
                    <label>
                      Date
                      <input
                        type="date"
                        name="booking_date"
                        value={bookingForm.booking_date || ''}
                        onChange={(event) => handleBookingChange(service.service_id, event)}
                        required
                      />
                    </label>
                    <label>
                      Time
                      <input
                        type="time"
                        name="booking_time"
                        value={bookingForm.booking_time || ''}
                        onChange={(event) => handleBookingChange(service.service_id, event)}
                        required
                      />
                    </label>
                    <label>
                      Notes
                      <textarea
                        name="notes"
                        rows="3"
                        value={bookingForm.notes || ''}
                        onChange={(event) => handleBookingChange(service.service_id, event)}
                      />
                    </label>
                    <button type="button" onClick={() => handleBookService(service.service_id)} disabled={loading}>
                      {loading ? 'Booking…' : 'Book this service'}
                    </button>
                  </div>
                )}
              </article>
            );
          })}
        </div>
      </section>
    </main>
  );
}

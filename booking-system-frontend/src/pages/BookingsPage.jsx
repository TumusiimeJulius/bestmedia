import { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { fetchBookings } from '../api/bookings';

export default function BookingsPage() {
  const { token, user } = useAuth();
  const [bookings, setBookings] = useState([]);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    async function loadBookings() {
      try {
        setError('');
        setLoading(true);
        const result = await fetchBookings(token);
        setBookings(result.bookings || []);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    }
    if (token) {
      loadBookings();
    }
  }, [token]);

  return (
    <main className="page-shell bookings-shell">
      <section className="panel bookings-panel">
        <div className="panel-header">
          <p className="eyebrow">Bookings</p>
          <h1>{user?.role === 'provider' ? 'Your incoming bookings' : 'Your current bookings'}</h1>
          <p>
            {user?.role === 'provider'
              ? 'Review requests from clients and monitor the appointments for your services.'
              : 'Track your booked services and view provider details.'}
          </p>
        </div>

        {error && <div className="status error">{error}</div>}
        {loading && <div className="status success">Loading bookings…</div>}

        <div className="booking-list">
          {bookings.length === 0 ? (
            <div className="empty-state">No bookings found yet.</div>
          ) : (
            bookings.map((booking) => (
              <article key={booking.booking_id} className="booking-card">
                <div className="booking-card-header">
                  <div>
                    <h2>{booking.service_name}</h2>
                    <p>{booking.category_name || 'No category'}</p>
                  </div>
                  <span className="booking-status">{booking.status}</span>
                </div>

                <div className="booking-details">
                  <p>
                    <strong>Date:</strong> {booking.booking_date}
                  </p>
                  <p>
                    <strong>Time:</strong> {booking.booking_time}
                  </p>
                  <p>
                    <strong>Price:</strong> ${booking.price.toFixed(2)}
                  </p>
                  <p>
                    <strong>Duration:</strong> {booking.duration_minutes} min
                  </p>
                  {user?.role === 'provider' ? (
                    <p>
                      <strong>Client:</strong> {booking.client_name} ({booking.client_email})
                    </p>
                  ) : (
                    <p>
                      <strong>Provider:</strong> {booking.provider_name} ({booking.provider_email})
                    </p>
                  )}
                </div>

                {booking.notes && (
                  <div className="booking-notes">
                    <strong>Notes:</strong>
                    <p>{booking.notes}</p>
                  </div>
                )}
              </article>
            ))
          )}
        </div>
      </section>
    </main>
  );
}

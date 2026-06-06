import { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { fetchBookings, updateBooking, deleteBooking } from '../api/bookings';

export default function BookingsPage() {
  const { token, user } = useAuth();
  const navigate = useNavigate();
  const [bookings, setBookings] = useState([]);
  const [error, setError] = useState('');
  const [message, setMessage] = useState('');
  const [loading, setLoading] = useState(false);

  const reloadBookings = async () => {
    try {
      const result = await fetchBookings(token);
      setBookings(result.bookings || []);
    } catch (err) {
      setError(err.message);
    }
  };

  const handleDeleteBooking = async (bookingId) => {
    if (!window.confirm('Are you sure you want to delete this booking?')) return;

    setError('');
    setMessage('');
    setLoading(true);

    try {
      await deleteBooking(bookingId, token);
      setMessage('Booking deleted successfully.');
      await reloadBookings();
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const isSessionStarted = (booking) => {
    const status = String(booking?.status || '').toLowerCase();
    return ['started', 'live', 'in progress', 'in-session', 'ongoing'].includes(status);
  };

  const handleStartSession = async (bookingId) => {
    setError('');
    setMessage('');
    setLoading(true);

    try {
      await updateBooking(bookingId, { status: 'started' }, token);
      setMessage('Live session started.');
      await reloadBookings();
      navigate('/created-sessions');
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

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
        {message && <div className="status success">{message}</div>}
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
                    <strong>Price:</strong> {booking.currency || 'UGX'} {Number(booking.price).toFixed(2)}
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

                <div className="booking-footer">
                  {user?.role === 'provider' ? (
                    isSessionStarted(booking) ? (
                      <Link
                        to={`/call/${booking.booking_id}`}
                        state={{ booking }}
                        className="button-link secondary"
                      >
                        Go to live session
                      </Link>
                    ) : (
                      <button
                        type="button"
                        className="button-link secondary"
                        onClick={() => handleStartSession(booking.booking_id)}
                        disabled={loading}
                      >
                        Start session
                      </button>
                    )
                  ) : isSessionStarted(booking) ? (
                    <Link
                      to={`/call/${booking.booking_id}`}
                      state={{ booking }}
                      className="button-link secondary"
                    >
                      Join live call
                    </Link>
                  ) : (
                    <button type="button" className="button-link secondary" disabled>
                      Waiting for provider
                    </button>
                  )}

                  <button type="button" className="delete-btn" onClick={() => handleDeleteBooking(booking.booking_id)} disabled={loading}>
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

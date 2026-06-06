import { useEffect, useState } from 'react';
import { useNavigate, useParams, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { fetchBookings } from '../api/bookings';

export default function CallPage() {
  const { bookingId } = useParams();
  const { token, user } = useAuth();
  const location = useLocation();
  const navigate = useNavigate();
  const [booking, setBooking] = useState(location.state?.booking || null);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(!location.state?.booking);

  useEffect(() => {
    if (booking || !token) return;

    async function loadBooking() {
      setError('');
      setLoading(true);

      try {
        const result = await fetchBookings(token);
        const found = (result.bookings || []).find((item) => String(item.booking_id) === String(bookingId));
        if (!found) {
          setError('Booking not found or access denied.');
          return;
        }
        setBooking(found);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    }

    loadBooking();
  }, [booking, bookingId, token]);

  useEffect(() => {
    if (!booking || error || !canJoinCall) return;

    const roomName = `BestMedia-${booking.booking_id}`;
    const container = document.getElementById('jitsi-container');
    if (!container) return;

    let api = null;
    const loadJitsi = () => {
      if (!window.JitsiMeetExternalAPI) return;

      api = new window.JitsiMeetExternalAPI('meet.jit.si', {
        roomName,
        parentNode: container,
        width: '100%',
        height: '100%',
        interfaceConfigOverwrite: {
          SHOW_JITSI_WATERMARK: false,
          DEFAULT_BACKGROUND: '#0f172a',
        },
        configOverwrite: {
          disableDeepLinking: true,
          startWithAudioMuted: false,
          startWithVideoMuted: false,
        },
        userInfo: {
          displayName: user?.full_name || user?.email || 'Guest',
        },
      });
    };

    if (window.JitsiMeetExternalAPI) {
      loadJitsi();
    } else {
      const script = document.createElement('script');
      script.src = 'https://meet.jit.si/external_api.js';
      script.async = true;
      script.onload = loadJitsi;
      document.body.appendChild(script);
      return () => {
        if (api) api.dispose();
        document.body.removeChild(script);
      };
    }

    return () => {
      if (api) api.dispose();
    };
  }, [booking, error, user]);

  const isSessionStarted = (booking) => {
    const status = String(booking?.status || '').toLowerCase();
    return ['started', 'live', 'in progress', 'in-session', 'ongoing'].includes(status);
  };

  const canJoinCall = user?.role === 'provider' || isSessionStarted(booking);

  const otherPerson = user?.role === 'provider'
    ? `${booking?.client_name || 'Client'} (${booking?.client_email || ''})`
    : `${booking?.provider_name || 'Provider'} (${booking?.provider_email || ''})`;

  return (
    <main className="page-shell call-shell">
      <section className="panel call-panel">
        <div className="panel-header">
          <p className="eyebrow">Live Session</p>
          <h1>Talk with {user?.role === 'provider' ? 'your client' : 'your provider'}</h1>
          <p>
            This is a live audio/video session powered by Jitsi. Use the embedded call window below to join instantly with the other party.
          </p>
        </div>

        {loading && <div className="status success">Loading call session…</div>}
        {error && <div className="status error">{error}</div>}

        {booking && !error && (
          <>
            <div className="call-details">
              <p><strong>Service:</strong> {booking.service_name}</p>
              <p><strong>Client / Provider:</strong> {otherPerson}</p>
              <p><strong>Room:</strong> <code>{`BestMedia-${booking.booking_id}`}</code></p>
            </div>

            {canJoinCall ? (
              <>
                <div className="call-frame" id="jitsi-container">
                  <div className="empty-state">Starting the live call session...</div>
                </div>

                <div className="call-actions">
                  <button type="button" className="secondary" onClick={() => navigate(-1)}>
                    Back to bookings
                  </button>
                  <a
                    href={`https://meet.jit.si/BestMedia-${booking.booking_id}`}
                    target="_blank"
                    rel="noreferrer"
                    className="button-link"
                  >
                    Open in new tab
                  </a>
                </div>
              </>
            ) : (
              <div className="status info">
                The provider has not started the session yet. Please wait for the provider to begin the live call.
              </div>
            )}
          </>
        )}
      </section>
    </main>
  );
}

import { useEffect, useState, useRef } from 'react';
import { useNavigate, useParams, useLocation } from 'react-router-dom';
import io from 'socket.io-client';
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
  const [statusMessage, setStatusMessage] = useState('Preparing your call...');
  const [micOn, setMicOn] = useState(true);
  const [cameraOn, setCameraOn] = useState(true);
  const [peerConnected, setPeerConnected] = useState(false);

  const localVideoRef = useRef(null);
  const remoteVideoRef = useRef(null);
  const socketRef = useRef(null);
  const peerConnectionRef = useRef(null);
  const localStreamRef = useRef(null);
  const remoteStreamRef = useRef(null);
  const remoteSocketIdRef = useRef(null);

  const isSessionStarted = (booking) => {
    const status = String(booking?.status || '').toLowerCase();
    return ['started', 'live', 'in progress', 'in-session', 'ongoing'].includes(status);
  };

  const isSessionEnded = (booking) => {
    const status = String(booking?.status || '').toLowerCase();
    return ['completed', 'ended', 'finished'].includes(status);
  };

  const isBookingFree = Boolean(booking?.is_free);
  const canJoinCall = user?.role === 'provider' || isSessionStarted(booking);

  const otherPerson = user?.role === 'provider'
    ? `${booking?.client_name || 'Client'} (${booking?.client_email || ''})`
    : `${booking?.provider_name || 'Provider'} (${booking?.provider_email || ''})`;

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
        setError(err.message || 'Unable to load booking');
      } finally {
        setLoading(false);
      }
    }

    loadBooking();
  }, [booking, bookingId, token]);

  useEffect(() => {
    if (!booking || error || !canJoinCall || !token) return;

    let isCancelled = false;

    const cleanup = () => {
      if (peerConnectionRef.current) {
        peerConnectionRef.current.close();
        peerConnectionRef.current = null;
      }
      if (socketRef.current) {
        socketRef.current.disconnect();
        socketRef.current = null;
      }
      if (localStreamRef.current) {
        localStreamRef.current.getTracks().forEach((track) => track.stop());
        localStreamRef.current = null;
      }
      if (remoteVideoRef.current) {
        remoteVideoRef.current.srcObject = null;
      }
      if (localVideoRef.current) {
        localVideoRef.current.srcObject = null;
      }
    };

    const createPeerConnection = (remoteSocketId) => {
      if (peerConnectionRef.current) {
        return peerConnectionRef.current;
      }

      const pc = new RTCPeerConnection({
        iceServers: [
          { urls: 'stun:stun.l.google.com:19302' },
          { urls: 'stun:stun1.l.google.com:19302' },
        ],
      });

      const remoteStream = new MediaStream();
      remoteStreamRef.current = remoteStream;
      if (remoteVideoRef.current) {
        remoteVideoRef.current.srcObject = remoteStream;
      }

      pc.ontrack = (event) => {
        if (event.streams && event.streams[0]) {
          remoteStreamRef.current = event.streams[0];
          if (remoteVideoRef.current) remoteVideoRef.current.srcObject = event.streams[0];
        } else if (event.track) {
          remoteStreamRef.current.addTrack(event.track);
          if (remoteVideoRef.current) remoteVideoRef.current.srcObject = remoteStreamRef.current;
        }
      };

      pc.onicecandidate = (event) => {
        if (event.candidate && socketRef.current && remoteSocketIdRef.current) {
          socketRef.current.emit('ice-candidate', {
            target: remoteSocketIdRef.current,
            candidate: event.candidate,
          });
        }
      };

      if (localStreamRef.current) {
        localStreamRef.current.getTracks().forEach((track) => pc.addTrack(track, localStreamRef.current));
      }

      peerConnectionRef.current = pc;
      remoteSocketIdRef.current = remoteSocketId;
      return pc;
    };

    const createOffer = async (pc, targetId) => {
      try {
        const offer = await pc.createOffer();
        await pc.setLocalDescription(offer);
        socketRef.current.emit('offer', {
          target: targetId,
          sdp: pc.localDescription,
        });
      } catch (offerError) {
        console.error('Offer error:', offerError);
      }
    };

    const initCall = async () => {
      try {
        const localStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
        localStreamRef.current = localStream;
        if (localVideoRef.current) {
          localVideoRef.current.srcObject = localStream;
        }
        setMicOn(localStream.getAudioTracks()[0]?.enabled ?? true);
        setCameraOn(localStream.getVideoTracks()[0]?.enabled ?? true);

        const socket = io(import.meta.env.VITE_BACKEND_URL || 'http://localhost:5000', {
          transports: ['websocket'],
        });
        socketRef.current = socket;

        socket.on('connect', () => {
          socket.emit('join-room', { room: booking.booking_id, token });
        });

        socket.on('room-error', (message) => {
          setError(message);
          setStatusMessage('Unable to join call');
        });

        socket.on('auth-error', (message) => {
          setError(message || 'Authentication error');
          setStatusMessage('Unable to join call');
        });

        socket.on('other-user', (remoteId) => {
          if (isCancelled) return;
          setStatusMessage('Connecting to participant...');
          createPeerConnection(remoteId);
        });

        socket.on('user-joined', async (remoteId) => {
          if (isCancelled) return;
          setStatusMessage('Participant joined. Starting call...');
          const pc = createPeerConnection(remoteId);
          await createOffer(pc, remoteId);
        });

        socket.on('offer', async ({ sdp, from }) => {
          if (isCancelled) return;
          setStatusMessage('Receiving call from participant...');
          const pc = createPeerConnection(from);
          await pc.setRemoteDescription(new RTCSessionDescription(sdp));
          const answer = await pc.createAnswer();
          await pc.setLocalDescription(answer);
          socket.emit('answer', {
            target: from,
            sdp: pc.localDescription,
          });
          setPeerConnected(true);
          setStatusMessage('Call connected');
        });

        socket.on('answer', async ({ sdp }) => {
          if (isCancelled) return;
          if (peerConnectionRef.current) {
            await peerConnectionRef.current.setRemoteDescription(new RTCSessionDescription(sdp));
            setPeerConnected(true);
            setStatusMessage('Call connected');
          }
        });

        socket.on('ice-candidate', async ({ candidate }) => {
          if (peerConnectionRef.current && candidate) {
            try {
              await peerConnectionRef.current.addIceCandidate(new RTCIceCandidate(candidate));
            } catch (candidateError) {
              console.error('ICE candidate error:', candidateError);
            }
          }
        });

        socket.on('user-left', () => {
          setStatusMessage('Participant left the call');
          setPeerConnected(false);
          if (remoteVideoRef.current) {
            remoteVideoRef.current.srcObject = null;
          }
        });
      } catch (mediaError) {
        console.error(mediaError);
        setError('Unable to access camera or microphone');
        setStatusMessage('Camera / microphone access required');
      }
    };

    initCall();

    return () => {
      isCancelled = true;
      if (peerConnectionRef.current) {
        peerConnectionRef.current.close();
        peerConnectionRef.current = null;
      }
      if (socketRef.current) {
        socketRef.current.disconnect();
        socketRef.current = null;
      }
      if (localStreamRef.current) {
        localStreamRef.current.getTracks().forEach((track) => track.stop());
        localStreamRef.current = null;
      }
    };
  }, [booking, error, canJoinCall, token]);

  const toggleMic = () => {
    if (!localStreamRef.current) return;
    const track = localStreamRef.current.getAudioTracks()[0];
    if (!track) return;
    track.enabled = !track.enabled;
    setMicOn(track.enabled);
  };

  const toggleCamera = () => {
    if (!localStreamRef.current) return;
    const track = localStreamRef.current.getVideoTracks()[0];
    if (!track) return;
    track.enabled = !track.enabled;
    setCameraOn(track.enabled);
  };

  const handleLeaveCall = () => {
    if (peerConnectionRef.current) {
      peerConnectionRef.current.close();
      peerConnectionRef.current = null;
    }
    if (socketRef.current) {
      socketRef.current.disconnect();
      socketRef.current = null;
    }
    if (localStreamRef.current) {
      localStreamRef.current.getTracks().forEach((track) => track.stop());
      localStreamRef.current = null;
    }
    navigate(-1);
  };

  return (
    <main className="page-shell call-shell">
      <section className="panel call-panel">
        <div className="panel-header">
          <p className="eyebrow">Live Session</p>
          <h1>Talk with {user?.role === 'provider' ? 'your client' : 'your provider'}</h1>
          <p>
            Allow your browser to use camera and microphone.
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
              {isBookingFree && !isSessionEnded(booking) && (
                <p className="status info">This first session is free.</p>
              )}
              {isBookingFree && isSessionEnded(booking) && (
                <p className="status success">This first session was free.</p>
              )}
            </div>

            {canJoinCall ? (
              <>
                <div className="call-videos">
                  <div className="video-card">
                    <h2>Your camera</h2>
                    <video ref={localVideoRef} autoPlay muted playsInline className="video-element" />
                  </div>
                  <div className="video-card">
                    <h2>{user?.role === 'provider' ? 'Client view' : 'Provider view'}</h2>
                    <video ref={remoteVideoRef} autoPlay playsInline className="video-element" />
                  </div>
                </div>

                <div className="call-controls">
                  <button type="button" className="button-link secondary" onClick={toggleMic}>
                    {micOn ? 'Mute microphone' : 'Unmute microphone'}
                  </button>
                  <button type="button" className="button-link secondary" onClick={toggleCamera}>
                    {cameraOn ? 'Turn camera off' : 'Turn camera on'}
                  </button>
                  <button type="button" className="button-link danger" onClick={handleLeaveCall}>
                    Leave call
                  </button>
                </div>

                <div className="status info">{statusMessage}</div>
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

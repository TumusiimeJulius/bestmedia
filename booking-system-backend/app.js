require("dotenv").config();

const express = require("express");
const cors = require("cors");
const cookieParser = require("cookie-parser");
const http = require("http");
const { Server } = require("socket.io");
const jwt = require("jsonwebtoken");
const db = require("./config/db");

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: process.env.FRONTEND_URL || 'http://localhost:5173',
    methods: ['GET', 'POST'],
    credentials: true,
  },
});

app.use(cors({ origin: process.env.FRONTEND_URL || 'http://localhost:5173', credentials: true }));
app.use(express.json());
app.use(cookieParser());

app.get('/', (req, res) => {
    res.send('Booking API Running');
});

const authRoutes = require('./routes/authRoutes');
const authController = require('./controllers/authController');
const serviceRoutes = require('./routes/serviceRoutes');
const bookingRoutes = require('./routes/bookingRoutes');

app.post('/api/auth/forgot-password', authController.forgotPassword);
app.post('/api/auth/verify-reset-code', authController.verifyResetCode);
app.post('/api/auth/reset-password', authController.resetPassword);

app.use('/api/auth', authRoutes);
app.use('/api', serviceRoutes);
app.use('/api', bookingRoutes);

// dev helper: list registered routes
app.get('/_routes', (req, res) => {
    const routes = [];
    app._router.stack.forEach((middleware) => {
        if (middleware.route) {
            // routes registered directly on the app
            routes.push(middleware.route);
        } else if (middleware.name === 'router') {
            // router middleware
            middleware.handle.stack.forEach(function(handler) {
                const route = handler.route;
                route && routes.push(route);
            });
        }
    });
    res.json(routes.map(r => ({ path: r.path, methods: r.methods })));
});

const PORT = process.env.PORT || 5000;

io.on('connection', (socket) => {
  console.log('Socket connected:', socket.id);

  socket.on('join-room', async ({ room, token }) => {
    try {
      if (!room || !token) {
        socket.emit('room-error', 'Missing room or authentication token');
        return;
      }

      let decoded;
      try {
        decoded = jwt.verify(token, process.env.JWT_SECRET);
      } catch (verifyError) {
        socket.emit('auth-error', 'Invalid authentication token');
        return;
      }

      const [rows] = await db.query(
        `SELECT b.*, s.provider_id FROM bookings b
         JOIN services s ON b.service_id = s.service_id
         WHERE b.booking_id = ?`,
        [room]
      );

      if (!rows.length) {
        socket.emit('room-error', 'Booking not found');
        return;
      }

      const booking = rows[0];
      const userId = decoded.user_id;
      const isProvider = booking.provider_id === userId;
      const isClient = booking.client_id === userId;

      if (!isProvider && !isClient) {
        socket.emit('room-error', 'Unauthorized to join this call');
        return;
      }

      if (!isProvider && String(booking.status).toLowerCase() !== 'started') {
        socket.emit('room-error', 'Session has not started yet');
        return;
      }

      socket.join(room);
      socket.room = room;

      const clients = io.sockets.adapter.rooms.get(room) || new Set();
      const otherClients = Array.from(clients).filter((id) => id !== socket.id);

      if (otherClients.length >= 2) {
        socket.emit('room-error', 'This call already has two participants');
        socket.leave(room);
        return;
      }

      if (otherClients.length === 1) {
        socket.emit('other-user', otherClients[0]);
        socket.to(otherClients[0]).emit('user-joined', socket.id);
      }
    } catch (error) {
      console.error('Socket join error:', error);
      socket.emit('room-error', 'Unable to join call room');
    }
  });

  socket.on('offer', ({ target, sdp }) => {
    if (!target || !sdp) return;
    socket.to(target).emit('offer', { sdp, from: socket.id });
  });

  socket.on('answer', ({ target, sdp }) => {
    if (!target || !sdp) return;
    socket.to(target).emit('answer', { sdp, from: socket.id });
  });

  socket.on('ice-candidate', ({ target, candidate }) => {
    if (!target || !candidate) return;
    socket.to(target).emit('ice-candidate', { candidate, from: socket.id });
  });

  socket.on('disconnect', () => {
    if (socket.room) {
      socket.to(socket.room).emit('user-left', socket.id);
    }
  });
});

server.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});

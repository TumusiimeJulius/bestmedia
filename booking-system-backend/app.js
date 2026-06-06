require("dotenv").config();

const express = require("express");
const cors = require("cors");
const cookieParser = require("cookie-parser");

const app = express();

app.use(cors());
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

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});

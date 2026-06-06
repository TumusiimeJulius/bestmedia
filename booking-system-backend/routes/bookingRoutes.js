const express = require('express');
const { authenticate } = require('../middleware/authMiddleware');
const { createBooking, getBookings } = require('../controllers/bookingController');

const router = express.Router();

router.get('/bookings', authenticate, getBookings);
router.post('/bookings', authenticate, createBooking);

module.exports = router;

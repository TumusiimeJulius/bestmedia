const express = require('express');
const { authenticate } = require('../middleware/authMiddleware');
const { createBooking, getBookings, updateBooking, deleteBooking } = require('../controllers/bookingController');

const router = express.Router();

router.get('/bookings', authenticate, getBookings);
router.post('/bookings', authenticate, createBooking);
router.put('/bookings/:id', authenticate, updateBooking);
router.delete('/bookings/:id', authenticate, deleteBooking);

module.exports = router;

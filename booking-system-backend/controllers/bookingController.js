const db = require('../config/db');

const createBooking = async (req, res) => {
  try {
    const clientId = req.user.user_id;
    if (req.user.role === 'provider') {
      return res.status(403).json({ message: 'Only client accounts can create bookings' });
    }

    const { service_id, booking_date, booking_time, notes } = req.body;
    if (!service_id || !booking_date || !booking_time) {
      return res.status(400).json({ message: 'Service, date and time are required' });
    }

    await db.query(
      `INSERT INTO bookings (client_id, service_id, booking_date, booking_time, notes)
       VALUES (?, ?, ?, ?, ?)`,
      [clientId, service_id, booking_date, booking_time, notes || null]
    );

    res.status(201).json({ message: 'Booking created successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Unable to create booking' });
  }
};

const getBookings = async (req, res) => {
  try {
    if (req.user.role === 'provider') {
      const providerId = req.user.user_id;
      const [bookings] = await db.query(
        `SELECT b.*, s.service_name, s.price, s.duration_minutes, c.category_name,
                u.full_name AS client_name, u.email AS client_email
         FROM bookings b
         JOIN services s ON b.service_id = s.service_id
         JOIN users u ON b.client_id = u.user_id
         LEFT JOIN categories c ON s.category_id = c.category_id
         WHERE s.provider_id = ?
         ORDER BY b.booking_date DESC, b.booking_time DESC`,
        [providerId]
      );
      return res.json({ bookings });
    }

    const clientId = req.user.user_id;
    const [bookings] = await db.query(
      `SELECT b.*, s.service_name, s.price, s.duration_minutes, c.category_name,
              u.full_name AS provider_name, u.email AS provider_email
       FROM bookings b
       JOIN services s ON b.service_id = s.service_id
       JOIN users u ON s.provider_id = u.user_id
       LEFT JOIN categories c ON s.category_id = c.category_id
       WHERE b.client_id = ?
       ORDER BY b.booking_date DESC, b.booking_time DESC`,
      [clientId]
    );

    res.json({ bookings });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Unable to load bookings' });
  }
};

module.exports = {
  createBooking,
  getBookings,
};

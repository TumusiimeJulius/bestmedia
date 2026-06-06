const db = require('../config/db');

async function ensureServiceCurrencyColumn() {
  const [columns] = await db.query("SHOW COLUMNS FROM services LIKE 'currency'");
  if (!columns.length) {
    await db.query("ALTER TABLE services ADD COLUMN currency VARCHAR(3) NOT NULL DEFAULT 'UGX' AFTER price");
  }
}

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
    await ensureServiceCurrencyColumn();
    if (req.user.role === 'provider') {
      const providerId = req.user.user_id;
      const [bookings] = await db.query(
        `SELECT b.*, s.service_name, s.price, s.currency, s.duration_minutes, c.category_name,
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

    await ensureServiceCurrencyColumn();

    const clientId = req.user.user_id;
    const [bookings] = await db.query(
      `SELECT b.*, s.service_name, s.price, s.currency, s.duration_minutes, c.category_name,
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

const updateBooking = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const bookingId = req.params.id;
    const { booking_date, booking_time, notes, status } = req.body;

    const [existing] = await db.query(
      `SELECT b.*, s.provider_id FROM bookings b
       JOIN services s ON b.service_id = s.service_id
       WHERE b.booking_id = ?`,
      [bookingId]
    );

    if (!existing.length) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    const isProvider = existing[0].provider_id === userId;
    const isClient = existing[0].client_id === userId;

    if (!isProvider && !isClient) {
      return res.status(403).json({ message: 'Unauthorized to update this booking' });
    }

    const updates = {};
    if (booking_date !== undefined) updates.booking_date = booking_date;
    if (booking_time !== undefined) updates.booking_time = booking_time;
    if (notes !== undefined) updates.notes = notes;
    if (status !== undefined && isProvider) updates.status = status;

    const updateFields = Object.keys(updates)
      .map((key) => `${key} = ?`)
      .join(', ');
    const updateValues = Object.values(updates);

    await db.query(`UPDATE bookings SET ${updateFields} WHERE booking_id = ?`, [
      ...updateValues,
      bookingId,
    ]);

    res.json({ message: 'Booking updated successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Unable to update booking' });
  }
};

const deleteBooking = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const bookingId = req.params.id;

    const [existing] = await db.query(
      `SELECT b.*, s.provider_id FROM bookings b
       JOIN services s ON b.service_id = s.service_id
       WHERE b.booking_id = ?`,
      [bookingId]
    );

    if (!existing.length) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    const isProvider = existing[0].provider_id === userId;
    const isClient = existing[0].client_id === userId;

    if (!isProvider && !isClient) {
      return res.status(403).json({ message: 'Unauthorized to delete this booking' });
    }

    await db.query('DELETE FROM bookings WHERE booking_id = ?', [bookingId]);

    res.json({ message: 'Booking deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Unable to delete booking' });
  }
};

module.exports = {
  createBooking,
  getBookings,
  updateBooking,
  deleteBooking,
};

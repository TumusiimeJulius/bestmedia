const db = require('../config/db');

const getAllServices = async (req, res) => {
  try {
    const [services] = await db.query(
      `SELECT s.*, u.full_name AS provider_name, u.role AS provider_role, c.category_name
       FROM services s
       JOIN users u ON s.provider_id = u.user_id
       LEFT JOIN categories c ON s.category_id = c.category_id
       WHERE s.is_active = 1`
    );

    res.json({ services });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Unable to load services' });
  }
};

const getCategories = async (req, res) => {
  try {
    const [categories] = await db.query('SELECT category_id, category_name FROM categories');
    res.json({ categories });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Unable to load categories' });
  }
};

const getProviderServices = async (req, res) => {
  try {
    const providerId = req.user.user_id;
    const [services] = await db.query(
      `SELECT s.*, c.category_name
       FROM services s
       LEFT JOIN categories c ON s.category_id = c.category_id
       WHERE s.provider_id = ?`,
      [providerId]
    );

    res.json({ services });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Unable to load provider services' });
  }
};

const createService = async (req, res) => {
  try {
    const providerId = req.user.user_id;
    const {
      category_id,
      service_name,
      description,
      duration_minutes,
      price,
      is_active = true,
    } = req.body;

    if (!service_name || !duration_minutes || !price) {
      return res.status(400).json({ message: 'Service name, duration, and price are required' });
    }

    await db.query(
      `INSERT INTO services
       (provider_id, category_id, service_name, description, duration_minutes, price, is_active)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        providerId,
        category_id || null,
        service_name,
        description || null,
        duration_minutes,
        price,
        is_active ? 1 : 0,
      ]
    );

    res.status(201).json({ message: 'Service created successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Unable to create service' });
  }
};

module.exports = {
  getAllServices,
  getCategories,
  getProviderServices,
  createService,
};

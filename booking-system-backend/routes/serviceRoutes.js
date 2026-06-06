const express = require('express');
const { authenticate } = require('../middleware/authMiddleware');
const {
  getAllServices,
  getCategories,
  getProviderServices,
  createService,
  updateService,
  deleteService,
} = require('../controllers/serviceController');

const router = express.Router();

router.get('/services', getAllServices);
router.get('/categories', getCategories);
router.get('/provider/services', authenticate, getProviderServices);
router.post('/provider/services', authenticate, createService);
router.put('/provider/services/:id', authenticate, updateService);
router.delete('/provider/services/:id', authenticate, deleteService);

module.exports = router;

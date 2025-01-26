const express = require("express");
const router = express.Router();
const { protect } = require('../middlewares/authMiddleware');
const {
  getAllIncome,
  getIncomeById,
  createIncome,
  updateIncome,
  deleteIncome,
} = require("../controllers/Income");

router.route("/")
  .get(protect, getAllIncome)           // Get all income
  .post(protect, createIncome);         // Create new income

router.route("/:id")
  .get(protect, getIncomeById)          // Get single income by ID
  .put(protect, updateIncome)           // Update income by ID
  .delete(protect, deleteIncome);       // Delete income by ID

module.exports = router;
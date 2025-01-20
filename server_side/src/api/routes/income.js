// routes/incomeRoutes.js
const express = require("express");
const router = express.Router();
const {
  getAllIncome,
  getIncomeById,
  createIncome,
  updateIncome,
  deleteIncome,
} = require("../controllers/Income");

router.route("/")
  .get(getAllIncome)           // Get all income
  .post(createIncome);         // Create new income

router.route("/:id")
  .get(getIncomeById)          // Get single income by ID
  .put(updateIncome)           // Update income by ID
  .delete(deleteIncome);       // Delete income by ID

module.exports = router;

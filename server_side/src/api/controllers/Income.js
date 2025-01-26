const Income = require("../models/income");
const asyncHandler = require("../middlewares/async");

// @desc      Get all income
// @route     GET /api/income
// @access    Private
const getAllIncome = asyncHandler(async (req, res, next) => {
  const income = await Income.find({ user: req.user._id });
  res.json({ success: true, message: "Income retrieved successfully.", data: income });
});

// @desc      Get single income by ID
// @route     GET /api/income/:id
// @access    Private
const getIncomeById = asyncHandler(async (req, res, next) => {
  const income = await Income.findOne({ _id: req.params.id, user: req.user._id });

  if (!income) {
    return res.status(404).json({ success: false, message: "Income not found." });
  }

  res.json({ success: true, message: "Income retrieved successfully.", data: income });
});

// @desc      Create new income
// @route     POST /api/income
// @access    Private
const createIncome = asyncHandler(async (req, res, next) => {
  const { amount, description, category } = req.body;

  const income = new Income({
    user: req.user._id,
    amount,
    description,
    category,
  });

  await income.save();
  res.status(201).json({ success: true, message: "Income created successfully.", data: income });
});

// @desc      Update income
// @route     PUT /api/income/:id
// @access    Private
const updateIncome = asyncHandler(async (req, res, next) => {
  const income = await Income.findOne({ _id: req.params.id, user: req.user._id });

  if (!income) {
    return res.status(404).json({ success: false, message: "Income not found." });
  }

  const { amount, description, category } = req.body;
  income.amount = amount || income.amount;
  income.description = description || income.description;
  income.category = category || income.category;

  await income.save();
  res.json({ success: true, message: "Income updated successfully.", data: income });
});

// @desc      Delete income
// @route     DELETE /api/income/:id
// @access    Private
const deleteIncome = asyncHandler(async (req, res, next) => {
  const income = await Income.findOne({ _id: req.params.id, user: req.user._id });

  if (!income) {
    return res.status(404).json({ success: false, message: "Income not found." });
  }

  await income.deleteOne();
  res.json({ success: true, message: "Income deleted successfully." });
});

module.exports = {
  getAllIncome,
  getIncomeById,
  createIncome,
  updateIncome,
  deleteIncome,
};
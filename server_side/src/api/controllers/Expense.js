const Expense = require('../models/expense');
const asyncHandler = require('../middlewares/async');

// @desc      Get all expenses
// @route     GET /api/expenses
// @access    Private
const getAllExpense = asyncHandler(async (req, res, next) => {
    const expense = await Expense.find({ user: req.user._id });
    res.json({ success: true, message: "Expense retrieved successfully.", data: expense });
});

// @desc      Get single expense
// @route     GET /api/expenses/:id
// @access    Private
const getExpenseById = asyncHandler(async (req, res, next) => {
    const expense = await Expense.findOne({ _id: req.params.id, user: req.user._id });

    if (!expense) {
        return res.status(404).json({ success: false, message: "Expense not found." });
    }
    res.json({ success: true, message: "Expense retrieved successfully.", data: expense });
});

// @desc      Create new expense
// @route     POST /api/expenses
// @access    Private
const createExpense = asyncHandler(async (req, res, next) => {
    const { amount, description, category } = req.body;

    const expense = new Expense({
        user: req.user._id,
        amount,
        description,
        category
    });

    await expense.save();
    res.status(201).json({ success: true, message: "Expense created successfully.", data: expense });
});

// @desc      Update expense
// @route     PUT /api/expenses/:id
// @access    Private
const updateExpense = asyncHandler(async (req, res, next) => {
    const expense = await Expense.findOne({ _id: req.params.id, user: req.user._id });

    if (!expense) {
        return res.status(404).json({ success: false, message: "Expense not found." });
    }

    const { amount, description, category } = req.body;
    expense.amount = amount || expense.amount;
    expense.description = description || expense.description;
    expense.category = category || expense.category;

    await expense.save();
    res.json({ success: true, message: "Expense updated successfully.", data: expense });
});

// @desc      Delete expense
// @route     DELETE /api/expenses/:id
// @access    Private
const deleteExpense = asyncHandler(async (req, res, next) => {
    const expense = await Expense.findOne({ _id: req.params.id, user: req.user._id });

    if (!expense) {
        return res.status(404).json({ success: false, message: "Expense not found." });
    }

    await expense.deleteOne();
    res.json({ success: true, message: "Expense deleted successfully." });
});

module.exports = {
    getAllExpense,
    getExpenseById,
    createExpense,
    updateExpense,
    deleteExpense
};
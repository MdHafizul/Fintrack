const Expense = require('../models/expense');
const asyncHandler = require('../middlewares/async');

// @desc      Get all expenses
// @route     GET /api/expenses
// @access    Public
const getAllExpense = asyncHandler(async (req, res, next) => {
    const expense = await Expense.find();
    res.json({ success: true, message: "Expense retrieved successfully.", data: expense });
})

// @desc      Get single expense
// @route     GET /api/expenses/:id
// @access    Public
const getExpenseById = asyncHandler(async (req, res, next) => {
    const expense = await Expense.findById(req.params.id);

    if(!expense) {
        return res.status(404).json({ success: false, message: "Expense not found." });
    }
    res.json({ success: true, message: "Expense retrieved successfully.", data: expense });
});


// @desc      Create new expense
// @route     POST /api/expenses
// @access    Public
const createExpense = asyncHandler(async (req, res, next) => {
    const { user, amount, description, category } = req.body;

    const expense = new Expense({
        user,
        amount,
        description,
        category
    });

    await expense.save();
    res.status(201).json({ success: true, message: "Expense created successfully.", data: expense });
});

// @desc      Update expense
// @route     PUT /api/expenses/:id
// @access    Public

const updateExpense = asyncHandler(async (req, res, next) => {
    const expense = await Expense.findById(req.params.id);

    if(!expense) {
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
// @access    Public

const deleteExpense = asyncHandler(async (req, res, next) => {
    const expense = await Expense.findById(req.params.id);

    if(!expense) {
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
}


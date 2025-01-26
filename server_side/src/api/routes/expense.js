const express = require("express");
const router = express.Router();
const { protect } = require('../middlewares/authMiddleware');

const {
    getAllExpense,
    getExpenseById,
    createExpense,
    updateExpense,
    deleteExpense,
} = require("../controllers/Expense");

router.route("/")
    .get(protect, getAllExpense)           // Get all expense
    .post(protect, createExpense);         // Create new expense

router.route("/:id")
    .get(protect, getExpenseById)          // Get single expense by ID
    .put(protect, updateExpense)           // Update expense by ID
    .delete(protect, deleteExpense);       // Delete expense by ID

module.exports = router;
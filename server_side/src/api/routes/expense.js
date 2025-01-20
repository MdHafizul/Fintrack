// routes / expenseRoutes.js

const express = require("express");
const router = express.Router();

const {
    getAllExpense,
    getExpenseById,
    createExpense,
    updateExpense,
    deleteExpense,
} = require("../controllers/Expense");

router.route("/")
    .get(getAllExpense)           // Get all expense
    .post(createExpense);         // Create new expense

router.route("/:id")
    .get(getExpenseById)          // Get single expense by ID
    .put(updateExpense)           // Update expense by ID
    .delete(deleteExpense);       // Delete expense by ID

module.exports = router;
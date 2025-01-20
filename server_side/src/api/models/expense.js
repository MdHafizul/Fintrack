const mongoose = require('mongoose');
const User = require('./user');

const expenseSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: User,
        required: true
    },
    amount: {
        type: Number,
        required: true
    },
    description: {
        type: String,
        required: true
    },
    category: {
        type: String,
        required: true
    },
    createdAt: {
        type: Date,
        default: Date.now
    },
    updatedAt: {
        type: Date,
        default: Date.now
    }
});

expenseSchema.pre('save', function (next) {
    this.updatedAt = Date.now();
    next();
});

const Expense = mongoose.model('Expense', expenseSchema);
module.exports = Expense;
const express = require('express');
const asyncHandler = require('express-async-handler');
const {
    getAllUsers,
    loginUser,
    getUserById,
    registerUser,
    updateUser,
    deleteUser,
    resetPassword // Add this line
} = require('../controllers/User');

const router = express.Router();

// Get all users
router.get('/', asyncHandler(getAllUsers));

// Register a new user
router.post('/register', asyncHandler(registerUser));

// Login
router.post('/login', asyncHandler(loginUser));

// Get a user by ID
router.get('/:id', asyncHandler(getUserById));

// Update a user
router.put('/:id', asyncHandler(updateUser));

// Delete a user
router.delete('/:id', asyncHandler(deleteUser));

// Reset password
router.post('/reset-password', asyncHandler(resetPassword)); // Add this line

module.exports = router;
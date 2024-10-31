// routes/userRoutes.js

const express = require('express');
const asyncHandler = require('express-async-handler');
const {
    getAllUsers,
    loginUser,
    getUserById,
    registerUser,
    updateUser,
    deleteUser
} = require('../controllers/User');

const router = express.Router();

// Get all users
router.get('/', asyncHandler(getAllUsers));

// register a new user
router.post('/register', asyncHandler(registerUser));

// Login
router.post('/login', asyncHandler(loginUser));

// Get a user by ID
router.get('/:id', asyncHandler(getUserById));

// Update a user
router.put('/:id', asyncHandler(updateUser));

// Delete a user
router.delete('/:id', asyncHandler(deleteUser));

module.exports = router;

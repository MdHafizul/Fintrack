const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const User = require('../models/user');

// Generate JWT token
const generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET, {
        expiresIn: '30d',
    });
};

// Get all users
const getAllUsers = async (req, res) => {
    try {
        const users = await User.find();
        res.json({ success: true, message: "Users retrieved successfully.", data: users });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// Register a new user
const registerUser = async (req, res) => {
    const { username, password, email, phoneNumber } = req.body;

    // Check if all required fields are provided
    if (!username || !password || !email || !phoneNumber) {
        return res.status(400).json({ success: false, message: "All fields (username, password, email, phoneNumber) are required." });
    }

    try {
        // Create and save the new user
        const user = new User({ username, password, email, phoneNumber });
        await user.save();
        res.json({ success: true, message: "User registered successfully.", data: null });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// Login
const loginUser = async (req, res) => {
    const { username, password } = req.body;

    try {
        const user = await User.findOne({ username });

        if (!user || !(await bcrypt.compare(password, user.password))) {
            return res.status(401).json({ success: false, message: "Invalid username or password." });
        }

        res.json({
            success: true,
            message: "Login successful.",
            data: {
                _id: user._id,
                username: user.username,
                email: user.email,
                phoneNumber: user.phoneNumber,
                createdAt: user.createdAt,
                updatedAt: user.updatedAt,
            },
            token: generateToken(user._id),
        });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// Reset password
const resetPassword = async (req, res) => {
    const { email, newPassword } = req.body;

    if (!email || !newPassword) {
        return res.status(400).json({ success: false, message: "Email and new password are required." });
    }

    try {
        const user = await User.findOne({ email });

        if (!user) {
            return res.status(404).json({ success: false, message: "User not found." });
        }

        user.password = newPassword;
        await user.save();

        res.json({ success: true, message: "Password reset successfully." });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};



// Get a user by ID
const getUserById = async (req, res) => {
    try {
        const userID = req.params.id;
        const user = await User.findById(userID);
        if (!user) {
            return res.status(404).json({ success: false, message: "User not found." });
        }
        res.json({ success: true, message: "User retrieved successfully.", data: user });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// Update a user
const updateUser = async (req, res) => {
    try {
        const userID = req.params.id;
        const { username, password } = req.body;
        if (!username || !password) {
            return res.status(400).json({ success: false, message: "Username and password are required." });
        }

        const updatedUser = await User.findByIdAndUpdate(
            userID,
            { username, password },
            { new: true }
        );

        if (!updatedUser) {
            return res.status(404).json({ success: false, message: "User not found." });
        }

        res.json({ success: true, message: "User updated successfully.", data: updatedUser });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// Delete a user
const deleteUser = async (req, res) => {
    try {
        const userID = req.params.id;
        const deletedUser = await User.findByIdAndDelete(userID);
        if (!deletedUser) {
            return res.status(404).json({ success: false, message: "User not found." });
        }
        res.json({ success: true, message: "User deleted successfully." });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

module.exports = {
    getAllUsers,
    loginUser,
    resetPassword,
    getUserById,
    registerUser,
    updateUser,
    deleteUser
};
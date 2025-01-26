const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const errorHandler = require('./src/api/middlewares/error');

// Load environment variables from .env file
dotenv.config({ path: '.env' });

const app = express();
app.use(express.json());

// Get port and MongoDB URL from environment variables
const port = process.env.PORT || 5000;
const MONGO_URL = process.env.MONGO_URL;

// Import user, income, and expense routes
const userRoutes = require('./src/api/routes/user');
const incomeRoutes = require('./src/api/routes/income');
const expenseRoutes = require('./src/api/routes/expense');

// Mount the user, income, and expense routes
app.use('/api/users', userRoutes);
app.use('/api/income', incomeRoutes);
app.use('/api/expenses', expenseRoutes);

// Error handler middleware
app.use(errorHandler);

// Function to connect to MongoDB and start the server
const startServer = async () => {
  try {
    await mongoose.connect(MONGO_URL, {});
    console.log('> Connected to MongoDB');

    app.listen(port, () => {
      console.log(`> Server is up and running on port: ${port}`);
    });
  } catch (err) {
    console.error('Error connecting to MongoDB:', err);
    process.exit(1); // Exit the process with failure
  }
};

// Start the server
startServer();
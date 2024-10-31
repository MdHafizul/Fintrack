const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const bodyparser = require('body-parser');

// Load environment variables from .env file
dotenv.config({ path: '.env' });

const app = express();
app.use(bodyparser.json());

const port = process.env.PORT || 5000;
const MONGO_URL = process.env.MONGO_URL;

// Import user routes
const userRoutes = require('./src/api/routes/user');

// Mount the user routes
app.use('/api/users', userRoutes);

mongoose.connect(MONGO_URL).then(() => {
   console.log('> Connected to MongoDB');
   app.listen(port, () => console.log('> Server is up and running on port : ' + port));
}).catch((err) => { console.log(err) });

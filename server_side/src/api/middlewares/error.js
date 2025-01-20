// middleware/errorHandler.js
const errorHandler = (err, req, res, next) => {
    let statusCode = err.statusCode || 500;
    let message = err.message || "Server Error";
  
    // Log the error for debugging (only in development mode)
    console.error(err);
  
    res.status(statusCode).json({
      success: false,
      message,
    });
  };
  
  module.exports = errorHandler;
  
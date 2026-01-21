// Vercel Serverless Function entry point
// This file wraps the Express app for Vercel deployment

const app = require('../src/index');

// Export the Express app as a serverless function
module.exports = app;

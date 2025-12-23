const express = require("express");
const { query } = require("../controllers/chatbotController.js");
const router = express.Router();
const rateLimit = require("express-rate-limit");

const chatBotLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 10 minutes
  max: 10,
  keyGenerator: (req, res) => req.ip,
  message: {
    success: false,
    message: "Too many chatbot requests. Try again later.",
  },
});

// * send query to chat bot (1 to 1 conversation )
router.post("/", chatBotLimiter, query);

module.exports = router;

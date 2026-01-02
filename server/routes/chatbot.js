const express = require("express");
const {
  query,
  fetchMessagesChat,
  clearHistoryChat,
  deleteMessage,
} = require("../controllers/chatbotController.js");
const router = express.Router();
const rateLimit = require("express-rate-limit");
const { authenticateToken } = require("../middleware/auth.js");

const chatBotLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  keyGenerator: (req, res) => req.ip,
  message: {
    success: false,
    message: "Too many chatbot requests. Try again later.",
  },
});

const historyLimiter = rateLimit({
  windowMs: 1 * 60 * 1000,
  max: 50,
  message: { success: false, message: "You are scrolling too fast." },
});

// * send query to chat bot (1 to 1 conversation )
router.post("/", chatBotLimiter, authenticateToken, query);

router.get("/", historyLimiter, authenticateToken, fetchMessagesChat);
router.delete("/clear", chatBotLimiter, authenticateToken, clearHistoryChat);
router.delete("/:id", chatBotLimiter, authenticateToken, deleteMessage);

module.exports = router;

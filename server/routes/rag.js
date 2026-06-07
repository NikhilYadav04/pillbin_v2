const express = require("express");
const {
  createRAG,
  fetchRAGs,
  deleteRAG,
  clearRAGHistoryAll,
} = require("../controllers/ragController.js");
const router = express.Router();
const rateLimit = require("express-rate-limit");
const { authenticateToken } = require("../middleware/auth.js");

// * Limiter for creating/deleting
const ragLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  keyGenerator: (req, res) => req.ip,
  message: {
    success: false,
    message: "Too many RAG operations. Try again later.",
  },
});

// * Limiter for fetching (allows scrolling/pagination)
const fetchLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: 50,
  message: {
    success: false,
    message: "You are fetching data too fast.",
  },
});

// * Create new RAG document
router.post("/", ragLimiter, authenticateToken, createRAG);

// * Fetch RAG documents (Imposed fetchLimiter here)
router.get("/", fetchLimiter, authenticateToken, fetchRAGs);

// * Clear all RAG history
router.delete("/clear", ragLimiter, authenticateToken, clearRAGHistoryAll);

// * Delete specific RAG document by ID
router.delete("/:id", ragLimiter, authenticateToken, deleteRAG);

module.exports = router;

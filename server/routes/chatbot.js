const express = require("express");
const { query } = require("../controllers/chatbotController.js");
const router = express.Router();

// * send query to chat bot (1 to 1 conversation )
router.post("/", query);

module.exports = router;

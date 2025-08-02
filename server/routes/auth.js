const express = require("express");
const authController = require("../controllers/authController");
const router = express.Router();

//* Authentication Routes (No JWT required)
router.post("/signup", authController.signup);
router.post("/verify-signup", authController.verifySignup);
router.post("/signin", authController.signin);
router.post("/verify-signin", authController.verifySignin);
router.post("/refresh-token", authController.refreshToken);

module.exports = router;

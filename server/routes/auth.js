const express = require("express");
const authController = require("../controllers/authController");
const router = express.Router();
const rateLimit = require("express-rate-limit");

//* Rate Limited for OTP
const otpLimiter = rateLimit({
  windowMs: 10 * 60 * 1000,
  max: 10,
  keyGenerator: (req, res) => req.body.phoneNumber || req.ip,
  message: {
    success: false,
    message: "Too many OTP requests for this number. Try again later.",
  },
});

//* Authentication Routes (No JWT required)
router.post("/signup", otpLimiter, authController.signup);
router.post("/verify-signup", authController.verifySignup);
router.post("/signin", otpLimiter, authController.signin);
router.post("/verify-signin", authController.verifySignin);
router.post("/refresh-token", authController.refreshToken);

module.exports = router;

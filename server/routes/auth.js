const express = require("express");
const authController = require("../controllers/authController");
const router = express.Router();
const { rateLimit, ipKeyGenerator } = require("express-rate-limit");

//* Two limiters run per request: one caps a single account, the other caps a
//* single origin. Addresses always go through ipKeyGenerator because an IPv6
//* caller owns a whole /64 and can otherwise rotate past a plain req.ip key.
const otpEmailLimiter = rateLimit({
  windowMs: 10 * 60 * 1000,
  max: 5,
  keyGenerator: (req) => {
    const email =
      typeof req.body?.email === "string" ? req.body.email.trim().toLowerCase() : "";
    return email || ipKeyGenerator(req.ip);
  },
  message: {
    success: false,
    message: "Too many OTP requests for this email. Try again later.",
  },
});

const otpIpLimiter = rateLimit({
  windowMs: 10 * 60 * 1000,
  max: 30,
  keyGenerator: (req) => ipKeyGenerator(req.ip),
  message: {
    success: false,
    message: "Too many OTP requests from this network. Try again later.",
  },
});

//* Authentication Routes (No JWT required)
router.post("/signup", otpIpLimiter, otpEmailLimiter, authController.signup);
router.post("/verify-signup", authController.verifySignup);
router.post("/signin", otpIpLimiter, otpEmailLimiter, authController.signin);
router.post("/verify-signin", authController.verifySignin);
router.post("/google", authController.googleAuth);
router.post("/refresh-token", authController.refreshToken);

module.exports = router;

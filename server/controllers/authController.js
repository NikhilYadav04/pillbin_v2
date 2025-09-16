const User = require("../models/User");
const sendOTP = require("../services/fast2SMS");
const { generateToken, generateRefreshToken } = require("../utils/jwt");

//* Generate random 6-digit OTP
const generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

//* Send OTP for signup
const signup = async (req, res) => {
  try {
    const { phoneNumber } = req.body;

    if (!phoneNumber) {
      return res.status(400).json({ message: "Phone number is required" });
    }

    //* Check if user already exists
    let user = await User.findOne({ phoneNumber });

    if (user && user.isVerified) {
      return res
        .status(400)
        .json({ message: "User already exists with this phone number" });
    }

    //* Generate OTP
    const otpCode = generateOTP();
    const otpExpiry = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    //* Send OTP to user
    // const result = await sendOTP(phoneNumber, otpCode);

    // if (!result) {
    //   return res.status(400).json({
    //     success: false,
    //     message: "Error sending OTP! Please Try Again",
    //   });
    // }

    if (user) {
      //* Update existing unverified user
      user.otp = { code: otpCode, expiresAt: otpExpiry };
      await user.save();
    } else {
      //* Create new user
      user = new User({
        phoneNumber,
        otp: { code: otpCode, expiresAt: otpExpiry },
        isVerified: false,
      });
      await user.save();
    }

    //* TODO: Send OTP via SMS service (for now just log it)
    console.log(`OTP for ${phoneNumber}: ${otpCode}`);

    res.status(200).json({
      message: "OTP sent successfully",
      //* Remove this in production - only for testing
      otp: otpCode,
    });
  } catch (error) {
    console.error("Signup error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

//* Verify OTP and complete signup
const verifySignup = async (req, res) => {
  try {
    const { phoneNumber, otp } = req.body;

    if (!phoneNumber || !otp) {
      return res
        .status(400)
        .json({ message: "Phone number and OTP are required" });
    }

    const user = await User.findOne({ phoneNumber });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    //* Check if OTP is valid and not expired
    if (user.otp.code !== otp || user.otp.expiresAt < new Date()) {
      return res.status(400).json({ message: "Invalid or expired OTP" });
    }

    //* Verify user
    user.isVerified = true;
    user.otp = undefined; // Remove OTP
    await user.save();

    //* Generate JWT tokens
    const accessToken = generateToken(user._id);
    const refreshToken = generateRefreshToken(user._id);

    res.status(200).json({
      message: "Phone number verified successfully",
      accessToken,
      refreshToken,
      user: {
        id: user._id,
        phoneNumber: user.phoneNumber,
        profileCompleted: user.profileCompleted,
      },
    });
  } catch (error) {
    console.error("Verify signup error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

//* Send OTP for signin
const signin = async (req, res) => {
  try {
    const { phoneNumber } = req.body;

    if (!phoneNumber) {
      return res.status(400).json({ message: "Phone number is required" });
    }

    const user = await User.findOne({ phoneNumber, isVerified: true });

    if (!user) {
      return res
        .status(404)
        .json({ message: "User not found or not verified" });
    }

    //* Generate OTP
    const otpCode = generateOTP();
    const otpExpiry = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    //* Send OTP to user
    // const result = await sendOTP(phoneNumber, otpCode);

    // if (!result) {
    //   res.status(400).json({
    //     success: false,
    //     message: "Error sending OTP! Please Try Again",
    //   });
    // }

    user.otp = { code: otpCode, expiresAt: otpExpiry };
    await user.save();

    //* TODO: Send OTP via SMS service (for now just log it)
    console.log(`Login OTP for ${phoneNumber}: ${otpCode}`);

    res.status(200).json({
      message: "OTP sent successfully",
      //* Remove this in production - only for testing
      otp: otpCode,
    });
  } catch (error) {
    console.error("Signin error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

//* Verify OTP and signin
const verifySignin = async (req, res) => {
  try {
    const { phoneNumber, otp } = req.body;

    if (!phoneNumber || !otp) {
      return res
        .status(400)
        .json({ message: "Phone number and OTP are required" });
    }

    const user = await User.findOne({ phoneNumber, isVerified: true });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    //* Check if OTP is valid and not expired
    if (user.otp.code !== otp || user.otp.expiresAt < new Date()) {
      return res.status(400).json({ message: "Invalid or expired OTP" });
    }

    //* Clear OTP
    user.otp = undefined;
    await user.save();

    //* Generate JWT tokens
    const accessToken = generateToken(user._id);
    const refreshToken = generateRefreshToken(user._id);

    res.status(200).json({
      message: "Login successful",
      accessToken,
      refreshToken,
      user: {
        id: user._id,
        phoneNumber: user.phoneNumber,
        profileCompleted: user.profileCompleted,
        fullName: user.fullName,
        email: user.email,
      },
    });
  } catch (error) {
    console.error("Verify signin error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

//* Refresh access token
const refreshToken = async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(401).json({ message: "Refresh token required" });
    }

    const { verifyToken } = require("../utils/jwt");
    const decoded = verifyToken(refreshToken);

    if (!decoded || decoded.type !== "refresh") {
      return res.status(403).json({ message: "Invalid refresh token" });
    }

    //* Check if user exists
    const user = await User.findById(decoded.userId);
    if (!user || !user.isVerified) {
      return res
        .status(403)
        .json({ message: "User not found or not verified" });
    }

    //* Generate new access token
    const newAccessToken = generateToken(user._id);

    res.status(200).json({
      message: "Token refreshed successfully",
      accessToken: newAccessToken,
    });
  } catch (error) {
    console.error("Refresh token error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

module.exports = {
  signup,
  verifySignup,
  signin,
  verifySignin,
  refreshToken,
};

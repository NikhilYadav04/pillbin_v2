const User = require("../models/User");
const sendOTP = require("../services/fast2SMS");
const { generateToken, generateRefreshToken } = require("../utils/jwt");
const nodemailer = require("nodemailer");

//* Nodemailer transporter setup
const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: process.env.SMTP_PORT,
  secure: false,
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

//* Generate random 6-digit OTP
const generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

//* Send OTP for signup
const signup = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res
        .status(400)
        .json({ message: "Email is required", statusCode: 400 });
    }

    //* Check if user already exists
    let user = await User.findOne({ email });

    if (user && user.isVerified) {
      return res.status(400).json({
        message: "User already exists with this email",
        statusCode: 400,
      });
    }

    //* Generate OTP
    const otpCode = generateOTP();
    const otpExpiry = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    //* Send OTP to user
    const subject = "Welcome to PillBin – Your OTP for Signup";

    const html = `
      <p>Hi ${email || "there"},</p>
    
      <p>Welcome to <b>PillBin</b>! 🎉</p>
      <p>We’re excited to have you on board. Use the OTP below to complete your signup process:</p>
      
      <p style="font-size:18px;"><b>${otpCode}</b></p>
    
      <p>This OTP is valid for the next 10 minutes. Please do not share it with anyone.</p>
    
      <p>Best regards,<br/>The PillBin Team</p>
    `;

    const text = `Hi ${email || "there"},
    
    Welcome to PillBin! 🎉
    We’re excited to have you on board. Use the OTP below to complete your signup:
    
    ${otpCode}
    
    This OTP is valid for the next 10 minutes. Please do not share it with anyone.
    
    Best regards,
    The PillBin Team`;

    const info = await transporter.sendMail({
      from: `PillBin`,
      to: email,
      subject,
      text,
      html,
    });

    if (user) {
      //* Update existing unverified user
      user.otp = { code: otpCode, expiresAt: otpExpiry };
      await user.save();
    } else {
      //* Create new user
      user = new User({
        email,
        otp: { code: otpCode, expiresAt: otpExpiry },
        isVerified: false,
      });
      await user.save();
    }

    res.status(200).json({
      message: "OTP sent successfully",
      //* Remove this in production - only for testing
      otp: otpCode,
      statusCode: 200,
    });
  } catch (error) {
    console.error("Signup error:", error);
    res.status(500).json({ message: "Server error", statusCode: 500 });
  }
};

//* Verify OTP and complete signup
const verifySignup = async (req, res) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({
        message: "Email and OTP are required",
        statusCode: 400,
      });
    }

    const user = await User.findOne({ email });

    if (!user) {
      return res
        .status(404)
        .json({ message: "User not found", statusCode: 404 });
    }

    //* Check if OTP is valid and not expired
    if (user.otp.code !== otp || user.otp.expiresAt < new Date()) {
      return res
        .status(400)
        .json({ message: "Invalid or expired OTP", statusCode: 400 });
    }

    //* Verify user
    user.isVerified = true;
    user.otp = undefined; // Remove OTP
    await user.save();

    //* Generate JWT tokens
    const accessToken = generateToken(user._id);
    const refreshToken = generateRefreshToken(user._id);

    res.status(200).json({
      statusCode: 200,
      message: "Email verified successfully",
      data: {
        accessToken,
        refreshToken,
        user: {
          id: user._id,
          phoneNumber: user.phoneNumber,
          email: user.email,
          profileCompleted: user.profileCompleted,
        },
      },
    });
  } catch (error) {
    console.error("Verify signup error:", error);
    res.status(500).json({ message: "Server error", statusCode: 500 });
  }
};

//* Send OTP for signin
const signin = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res
        .status(400)
        .json({ message: "Email is required", statusCode: 400 });
    }

    const user = await User.findOne({ email });

    if (!user) {
      return res
        .status(404)
        .json({ message: "User not found or not verified", statusCode: 404 });
    }

    //* Generate OTP
    const otpCode = generateOTP();
    const otpExpiry = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    //* Send OTP to user
    //* Send OTP to user
    const subject = "Welcome to PillBin – Your OTP for SignIn";

    const html = `
       <p>Hi ${email || "there"},</p>
     
       <p>Welcome to <b>PillBin</b>! 🎉</p>
       <p>We’re excited to have you on board. Use the OTP below to complete your signin process:</p>
       
       <p style="font-size:18px;"><b>${otpCode}</b></p>
     
       <p>This OTP is valid for the next 10 minutes. Please do not share it with anyone.</p>
     
       <p>Best regards,<br/>The PillBin Team</p>
     `;

    const text = `Hi ${email || "there"},
     
     Welcome to PillBin! 🎉
     We’re excited to have you on board. Use the OTP below to complete your signup:
     
     ${otpCode}
     
     This OTP is valid for the next 10 minutes. Please do not share it with anyone.
     
     Best regards,
     The PillBin Team`;

    const info = await transporter.sendMail({
      from: `PillBin`,
      to: email,
      subject,
      text,
      html,
    });

    user.otp = { code: otpCode, expiresAt: otpExpiry };
    await user.save();

    res.status(200).json({
      message: "OTP sent successfully",
      //* Remove this in production - only for testing
      otp: otpCode,
      statusCode: 200,
      data: {
        isVerified: user.isVerified,
      },
    });
  } catch (error) {
    console.error("Signin error:", error);
    res.status(500).json({ message: "Server error", statusCode: 500 });
  }
};

//* Verify OTP and signin
const verifySignin = async (req, res) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({
        message: "Email and OTP are required",
        statusCode: 400,
      });
    }

    const user = await User.findOne({ email, isVerified: true });

    if (!user) {
      return res
        .status(404)
        .json({ message: "User not found", statusCode: 404 });
    }

    //* Check if OTP is valid and not expired
    if (user.otp.code !== otp || user.otp.expiresAt < new Date()) {
      return res
        .status(400)
        .json({ message: "Invalid or expired OTP", statusCode: 400 });
    }

    //* Clear OTP
    user.otp = undefined;
    await user.save();

    //* Generate JWT tokens
    const accessToken = generateToken(user._id);
    const refreshToken = generateRefreshToken(user._id);

    res.status(200).json({
      statusCode: 200,
      message: "Login successful",
      data: {
        accessToken,
        refreshToken,
        user: {
          id: user._id,
          phoneNumber: user.phoneNumber,
          profileCompleted: user.profileCompleted,
          fullName: user.fullName,
          email: user.email,
        },
      },
    });
  } catch (error) {
    console.error("Verify signin error:", error);
    res.status(500).json({ message: "Server error", statusCode: 500 });
  }
};

//* Refresh access token
const refreshToken = async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res
        .status(401)
        .json({ message: "Refresh token required", statusCode: 401 });
    }

    const { verifyToken } = require("../utils/jwt");
    const decoded = verifyToken(refreshToken);

    if (!decoded || decoded.type !== "refresh") {
      return res
        .status(403)
        .json({ message: "Invalid refresh token", statusCode: 403 });
    }

    //* Check if user exists
    const user = await User.findById(decoded.userId);
    if (!user || !user.isVerified) {
      return res
        .status(403)
        .json({ message: "User not found or not verified", statusCode: 403 });
    }

    //* Generate new access token
    const newAccessToken = generateToken(user._id);

    res.status(200).json({
      statusCode: 200,
      message: "Token refreshed successfully",
      accessToken: newAccessToken,
    });
  } catch (error) {
    console.error("Refresh token error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

module.exports = {
  signup,
  verifySignup,
  signin,
  verifySignin,
  refreshToken,
};

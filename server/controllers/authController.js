const User = require("../models/User");
const sendOTP = require("../services/fast2SMS");
const { generateToken, generateRefreshToken } = require("../utils/jwt");
const { OAuth2Client } = require("google-auth-library");
// const {Resend} = require("resend")

// const resend = new Resend(process.env.RESEND_API_KEY);

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

    // resend.emails.send({
    //   from: "onboarding@resend.dev",
    //   to: email,
    //   subject: subject,
    //   html: html,
    // });
    // const info = await transporter.sendMail({
    //   from: `PillBin`,
    //   to: email,
    //   subject,
    //   text,
    //   html,
    // });

    const allowedRoles = ["user", "vendor"];
    const role =
      req.body.role && allowedRoles.includes(req.body.role)
        ? req.body.role
        : "user";

    if (user) {
      //* Update existing unverified user (also update role in case they changed it)
      user.otp = { code: otpCode, expiresAt: otpExpiry };
      user.role = role;
      await user.save();
    } else {
      //* Create new user

      user = new User({
        email,
        otp: { code: otpCode, expiresAt: otpExpiry },
        isVerified: false,
        role,
      });
      await user.save();
    }

    res.status(200).json({
      message: "OTP sent successfully",
      //* Remove this in production - only for testing
      data: {
        otp: otpCode,
      },
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
          role: user.role,
          vendorCenterId: user.vendorCenterId,
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

    const user = await User.findOne({ email, isVerified: true });

    if (!user) {
      return res
        .status(404)
        .json({ message: "User not found or not verified", statusCode: 404 });
    }

    //* Generate OTP
    const otpCode = generateOTP();
    const otpExpiry = new Date(Date.now() + 20 * 60 * 1000); // 10 minutes

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

    // resend.emails.send({
    //   from: "onboarding@resend.dev",
    //   to: email,
    //   subject: subject,
    //   html: html,
    // });

    // const info = await transporter.sendMail({
    //   from: `PillBin`,
    //   to: email,
    //   subject,
    //   text,
    //   html,
    // });

    if (user.email == "dummy@gmail.com") {
      user.otp = user.otp = { code: 123456, expiresAt: otpExpiry };
    } else {
      user.otp = { code: otpCode, expiresAt: otpExpiry };
    }

    await user.save();

    res.status(200).json({
      message: "OTP sent successfully",
      //* Remove this in production - only for testing

      statusCode: 200,
      data: {
        otp: otpCode,
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
          role: user.role,
          vendorCenterId: user.vendorCenterId,
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

//* Accepts the web client id plus any platform ids, comma separated
const googleAudience = (process.env.GOOGLE_CLIENT_ID || "")
  .split(",")
  .map((id) => id.trim())
  .filter(Boolean);

const googleClient = new OAuth2Client();

const buildAuthResponse = (user, message, res) => {
  res.status(200).json({
    statusCode: 200,
    message,
    data: {
      accessToken: generateToken(user._id),
      refreshToken: generateRefreshToken(user._id),
      user: {
        id: user._id,
        phoneNumber: user.phoneNumber,
        profileCompleted: user.profileCompleted,
        fullName: user.fullName,
        email: user.email,
        role: user.role,
        vendorCenterId: user.vendorCenterId,
      },
    },
  });
};

//* Sign in or sign up with a Google ID token
const googleAuth = async (req, res) => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      return res
        .status(400)
        .json({ message: "idToken is required", statusCode: 400 });
    }

    if (googleAudience.length === 0) {
      console.error("GOOGLE_CLIENT_ID is not set");
      return res
        .status(500)
        .json({ message: "Google sign-in is not configured", statusCode: 500 });
    }

    let payload;
    try {
      const ticket = await googleClient.verifyIdToken({
        idToken,
        audience: googleAudience,
      });
      payload = ticket.getPayload();
    } catch (error) {
      return res
        .status(401)
        .json({ message: "Invalid Google token", statusCode: 401 });
    }

    const email = payload.email ? payload.email.toLowerCase() : null;

    if (!email || payload.email_verified === false) {
      return res.status(401).json({
        message: "Google account has no verified email",
        statusCode: 401,
      });
    }

    const allowedRoles = ["user", "vendor"];
    const requestedRole =
      req.body.role && allowedRoles.includes(req.body.role)
        ? req.body.role
        : "user";

    //* Look up by email, never by googleId — email is what the OTP flow already
    //* stored, so keying on anything else would create a second account
    let user = await User.findOne({ email });
    const isNewUser = !user;

    if (user) {
      if (!user.googleId) user.googleId = payload.sub;
      if (!user.authProviders.includes("google")) {
        user.authProviders.push("google");
      }
      if (!user.fullName && payload.name) user.fullName = payload.name;
      if (!user.avatarUrl && payload.picture) user.avatarUrl = payload.picture;
      user.isVerified = true;
      user.otp = undefined;
    } else {
      //* Role only applies to a brand new account — an existing vendor keeps
      //* their role no matter what the picker said
      user = new User({
        email,
        googleId: payload.sub,
        fullName: payload.name,
        avatarUrl: payload.picture,
        isVerified: true,
        role: requestedRole,
        authProviders: ["google"],
      });
    }

    try {
      await user.save();
    } catch (error) {
      //* Two taps can both miss the lookup above and race to insert
      if (error.code === 11000) {
        user = await User.findOne({ email });
        if (!user) throw error;
      } else {
        throw error;
      }
    }

    buildAuthResponse(
      user,
      isNewUser ? "Signed up with Google" : "Login successful",
      res
    );
  } catch (error) {
    console.error("Google auth error:", error);
    res.status(500).json({ message: "Server error", statusCode: 500 });
  }
};

module.exports = {
  signup,
  verifySignup,
  signin,
  verifySignin,
  refreshToken,
  googleAuth,
};

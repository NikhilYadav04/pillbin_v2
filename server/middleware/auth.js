const { verifyToken } = require("../utils/jwt");
const User = require("../models/User");

//* Middleware to verify JWT token
const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    const token = authHeader && authHeader.split(" ")[1]; // Bearer TOKEN

    if (!token) {
      return res.status(401).json({ message: "Access token required" });
    }

    const decoded = verifyToken(token);
    if (!decoded) {
      return res.status(403).json({ message: "Invalid or expired token" });
    }

    //* Check if user exists and is verified
    const user = await User.findById(decoded.userId);
    if (!user || !user.isVerified) {
      return res
        .status(403)
        .json({ message: "User not found or not verified" });
    }

    //* Add user info to request object
    req.user = {
      id: user._id,
      phoneNumber: user.phoneNumber,
      profileCompleted: user.profileCompleted,
      role: user.role,
      vendorCenterId: user.vendorCenterId,
    };

    next();
  } catch (error) {
    console.error("Auth middleware error:", error);
    return res.status(500).json({ message: "Server error" });
  }
};

//* Middleware to restrict routes to vendor-role users only
const requireVendor = (req, res, next) => {
  if (req.user.role !== "vendor") {
    return res
      .status(403)
      .json({ message: "Access restricted to vendor accounts" });
  }
  next();
};

//* Middleware to restrict routes to admin-role users only
const requireAdmin = (req, res, next) => {
  if (req.user.role !== "admin") {
    return res
      .status(403)
      .json({ message: "Access restricted to admin accounts" });
  }
  next();
};

module.exports = {
  authenticateToken,
  requireVendor,
  requireAdmin,
};

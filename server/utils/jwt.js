const jwt = require("jsonwebtoken");

//* Generate JWT token
const generateToken = (userId) => {
  return jwt.sign({ userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || "72h",
  });
};

//* Verify JWT token
const verifyToken = (token) => {
  try {
    return jwt.verify(token, process.env.JWT_SECRET);
  } catch (error) {
    return null;
  }
};

//* Generate refresh token
const generateRefreshToken = (userId) => {
  return jwt.sign(
    { userId, type: "refresh" },
    process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET,
    { expiresIn: "1d" }
  );
};

//* Short-lived, single-purpose token a donor renders as a QR at the counter.
//* The `typ` claim keeps it from ever being accepted as a session token.
const HANDOFF_TTL_SECONDS = 5 * 60;

const generateHandoffToken = (requestId, userId) => {
  return jwt.sign(
    { typ: "handoff", rid: String(requestId), uid: String(userId) },
    process.env.JWT_SECRET,
    { expiresIn: HANDOFF_TTL_SECONDS }
  );
};

const verifyHandoffToken = (token) => {
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    return decoded && decoded.typ === "handoff" ? decoded : null;
  } catch (error) {
    return null;
  }
};

module.exports = {
  generateToken,
  verifyToken,
  generateRefreshToken,
  generateHandoffToken,
  verifyHandoffToken,
  HANDOFF_TTL_SECONDS,
};

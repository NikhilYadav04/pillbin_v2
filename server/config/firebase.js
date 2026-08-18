require("dotenv").config();
const { initializeApp, getApps, cert } = require("firebase-admin/app");
const { getMessaging } = require("firebase-admin/messaging");

let configured = false;

if (getApps().length === 0) {
  const { FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY } =
    process.env;

  if (!FIREBASE_PROJECT_ID || !FIREBASE_CLIENT_EMAIL || !FIREBASE_PRIVATE_KEY) {
    console.warn(
      "⚠️  Firebase credentials missing — push notifications disabled"
    );
  } else {
    try {
      initializeApp({
        credential: cert({
          projectId: FIREBASE_PROJECT_ID,
          clientEmail: FIREBASE_CLIENT_EMAIL,
          privateKey: FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n"),
        }),
      });
      configured = true;
      console.log("✅ Firebase Admin initialized");
    } catch (error) {
      console.error("❌ Firebase Admin init failed:", error.message);
      if (process.env.NODE_ENV === "production") throw error;
    }
  }
} else {
  configured = true;
}

module.exports = { getMessaging, isConfigured: () => configured };

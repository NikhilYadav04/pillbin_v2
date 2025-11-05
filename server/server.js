const express = require("express");
const cors = require("cors");
require("dotenv").config();

const app = express();

//* Import Routes
const authRoutes = require("./routes/auth");
const userRoutes = require("./routes/user");
const medicineRoutes = require("./routes/medicine");
const medicalCenterRoutes = require("./routes/medicalCenter");
const notificationRoutes = require("./routes/notification");
const chatbotRoutes = require("./routes/chatbot");
const { connectDB } = require("./config/database");
const morgan = require("morgan");

//* Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan("dev"));

app.set('trust proxy', 1);

//* Connect to Database
connectDB();

//* Use Routes
app.use("/api/auth", authRoutes);
app.use("/api/user", userRoutes);
app.use("/api/medicine", medicineRoutes);
app.use("/api/medical-center", medicalCenterRoutes);
app.use("/api/chatbot", chatbotRoutes);
app.use("/api/notifications", notificationRoutes);

//* Default Route
app.get("/", (req, res) => {
  res.json({ message: "Medicine Tracker API Server Running!" });
});

//* Error Handling Middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: "Something went wrong!" });
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});

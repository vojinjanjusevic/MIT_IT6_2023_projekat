import dotenv from "dotenv";
import app from "./app.js";
import connectDB from "./config/db.js";

dotenv.config();

const PORT = process.env.PORT || 4000;

connectDB();

const server = app.listen(PORT, () => {
  console.log(`API running on http://localhost:${PORT}`);
});

process.on("unhandledRejection", (error) => {
  console.error("Unhandled rejection:", error.message);
  server.close(() => process.exit(1));
});

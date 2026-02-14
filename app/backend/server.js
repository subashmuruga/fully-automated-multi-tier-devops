const express = require("express");
const cors = require("cors");
const mysql = require("mysql2");

const app = express();
app.use(cors());
app.use(express.json());

// ---------------- MySQL Connection ----------------

const connection = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME
});

connection.connect((err) => {
  if (err) {
    console.error("❌ Database connection failed:", err);
  } else {
    console.log("✅ Connected to RDS MySQL!");
  }
});

// ---------------- Existing API ----------------

app.get("/api", (req, res) => {
  res.json({
    message: "Backend API is running successfully 🚀",
    status: "Healthy"
  });
});

// ---------------- DB Test API ----------------

app.get("/db-test", (req, res) => {
  connection.query("SELECT NOW() AS time", (err, results) => {
    if (err) {
      console.error(err);
      return res.status(500).json({
        error: "Database query failed"
      });
    }

    res.json({
      message: "Database connected successfully ✅",
      server_time: results[0].time
    });
  });
});

const PORT = 5000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

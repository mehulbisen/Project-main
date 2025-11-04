const express = require("express");
const bodyParser = require("body-parser");
const { connectDB } = require("./db");
const { SNSClient, PublishCommand } = require("@aws-sdk/client-sns");

const app = express();
app.use(bodyParser.json());

// Initialize SNS client
const sns = new SNSClient({ region: "ap-south-1" });

// 🏠 Root route — add this
app.get("/", (req, res) => {
  res.send("🎉 Event Booking Backend is running successfully!");
});

// Route: Get all events
app.get("/events", async (req, res) => {
  try {
    const db = await connectDB();
    const [rows] = await db.query("SELECT * FROM events");
    res.json(rows);
  } catch (err) {
    console.error("❌ Error fetching events:", err);
    res.status(500).json({ error: "Failed to fetch events" });
  }
});

// Route: Book an event
app.post("/book", async (req, res) => {
  try {
    const db = await connectDB();
    const { event_id, user_name, user_email } = req.body;

    await db.query(
      "INSERT INTO bookings (event_id, user_name, user_email) VALUES (?, ?, ?)",
      [event_id, user_name, user_email]
    );

    await sns.send(
      new PublishCommand({
        TopicArn: process.env.SNS_TOPIC_ARN,
        Message: JSON.stringify(req.body),
      })
    );

    res.json({ message: "✅ Booking created successfully!" });
  } catch (err) {
    console.error("❌ Error creating booking:", err);
    res.status(500).json({ error: "Failed to create booking" });
  }
});

// Health check endpoint
app.get("/healthz", (_, res) => res.send("ok"));

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`🚀 Backend running on port ${PORT}`));

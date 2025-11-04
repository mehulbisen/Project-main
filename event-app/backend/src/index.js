const express = require("express");
const bodyParser = require("body-parser");
const { connectDB } = require("./db");
const { SNSClient, PublishCommand } = require("@aws-sdk/client-sns");

const app = express();
app.use(bodyParser.json());

const sns = new SNSClient({ region: process.env.AWS_REGION });

app.get("/events", async (req, res) => {
  const db = await connectDB(process.env.DB_SECRET_ARN);
  const [rows] = await db.query("SELECT * FROM events");
  res.json(rows);
});

app.post("/book", async (req, res) => {
  const db = await connectDB(process.env.DB_SECRET_ARN);
  const { event_id, user_name, user_email } = req.body;
  await db.query("INSERT INTO bookings (event_id,user_name,user_email) VALUES (?,?,?)",
    [event_id, user_name, user_email]);

  await sns.send(new PublishCommand({
    TopicArn: process.env.SNS_TOPIC_ARN,
    Message: JSON.stringify(req.body)
  }));

  res.json({ message: "Booking created" });
});

app.get("/healthz", (_, res) => res.send("ok"));
app.listen(3000, () => console.log("Backend running on 3000"));

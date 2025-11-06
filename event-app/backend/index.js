// index.js
require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const db = require('./db');

const app = express();
app.use(bodyParser.json());

app.get('/health', (req, res) => res.json({ ok: true }));

// List events
app.get('/events', async (req, res) => {
  const [rows] = await db.query('SELECT * FROM events ORDER BY start_time');
  res.json(rows);
});

// Create event (simple)
app.post('/events', async (req, res) => {
  const { title, description, location, start_time, end_time, capacity } = req.body;
  const [result] = await db.query(
    'INSERT INTO events (title, description, location, start_time, end_time, capacity) VALUES (?, ?, ?, ?, ?, ?)',
    [title, description, location, start_time, end_time, capacity || 0]
  );
  res.json({ id: result.insertId });
});

// Create booking
app.post('/bookings', async (req, res) => {
  const { user_id, event_id, seats } = req.body;
  const conn = await db.getConnection();
  try {
    await conn.beginTransaction();

    // Check capacity left
    const [[event]] = await conn.query('SELECT capacity FROM events WHERE id = ? FOR UPDATE', [event_id]);
    if (!event) {
      await conn.rollback();
      return res.status(404).json({ error: 'Event not found' });
    }

    // Count booked seats
    const [[booked]] = await conn.query('SELECT COALESCE(SUM(seats),0) as booked FROM bookings WHERE event_id = ?', [event_id]);
    const bookedSeats = booked.booked || 0;
    if (bookedSeats + (seats || 1) > event.capacity) {
      await conn.rollback();
      return res.status(400).json({ error: 'Not enough capacity' });
    }

    // Insert booking
    const [ins] = await conn.query('INSERT INTO bookings (user_id, event_id, seats) VALUES (?, ?, ?)', [user_id, event_id, seats || 1]);
    await conn.commit();
    res.json({ id: ins.insertId });
  } catch (err) {
    await conn.rollback();
    console.error(err);
    res.status(500).json({ error: 'server error' });
  } finally {
    conn.release();
  }
});

// Run server
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`Backend listening on ${PORT}`);
});

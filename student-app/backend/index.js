const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const pool = require('./db');

const app = express();
app.use(cors());
app.use(bodyParser.json());

app.get('/health', (req, res) => res.json({status: 'ok'}));

app.post('/api/students', async (req, res) => {
  try {
    const { first_name, last_name, email, dob, enrollment_no, course } = req.body;
    if (!first_name || !last_name || !email) {
      return res.status(400).json({error: 'first_name, last_name, email required'});
    }
    const [result] = await pool.execute(
      `INSERT INTO students (first_name,last_name,email,dob,enrollment_no,course)
       VALUES (?,?,?,?,?,?)`,
      [first_name, last_name, email, dob, enrollment_no, course]
    );
    const id = result.insertId;
    const [rows] = await pool.execute('SELECT * FROM students WHERE id = ?', [id]);
    res.status(201).json(rows[0]);
  } catch (err) {
    if (err && err.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({error: 'email already exists'});
    }
    console.error(err);
    res.status(500).json({error: 'internal error'});
  }
});

app.get('/api/students', async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM students ORDER BY created_at DESC LIMIT 100');
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({error:'internal error'});
  }
});

app.get('/api/students/:id', async (req, res) => {
  try {
    const id = req.params.id;
    const [rows] = await pool.execute('SELECT * FROM students WHERE id = ?', [id]);
    if (!rows.length) return res.status(404).json({error:'not found'});
    res.json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({error:'internal error'});
  }
});

const port = process.env.PORT || 8080;
app.listen(port, () => console.log(`Backend listening on ${port}`));

const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'admin',
  password: process.env.DB_PASSWORD || 'password',
  database: process.env.DB_NAME || 'student_app',
  waitForConnections: true,
  connectionLimit: 10,
  port: process.env.DB_PORT || 3306,
  timezone: 'Z'
});

module.exports = pool;

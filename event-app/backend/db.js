// db.js
const mysql = require('mysql2/promise');
const { DB_HOST, DB_PORT, DB_USER, DB_PASS, DB_NAME } = process.env;

const pool = mysql.createPool({
  host: DB_HOST,
  port: DB_PORT || 3306,
  user: DB_USER,
  password: DB_PASS,
  database: DB_NAME,
  connectionLimit: 10
});

module.exports = pool;

const AWS = require("aws-sdk");
const mysql = require("mysql2/promise");

// Your actual secret ARN
const secretArn = "arn:aws:secretsmanager:ap-south-1:561137843066:secret:prod/eventapps/rds-oYOmwy";

// Initialize Secrets Manager client
const secretsManager = new AWS.SecretsManager({ region: "ap-south-1" });

// Function to fetch DB credentials
async function getDbCredentials() {
  try {
    const data = await secretsManager.getSecretValue({ SecretId: secretArn }).promise();
    const secret = JSON.parse(data.SecretString);
    console.log("✅ Successfully retrieved DB credentials from Secrets Manager");
    return {
      host: secret.host,
      user: secret.username,
      password: secret.password,
      database: secret.dbname,
    };
  } catch (err) {
    console.error("❌ Error fetching DB secret:", err);
    throw err;
  }
}

// Function to connect to the database
async function connectDB() {
  try {
    const config = await getDbCredentials();
    const connection = await mysql.createConnection(config);
    console.log("✅ Connected to MySQL database successfully!");
    return connection;
  } catch (err) {
    console.error("❌ Database connection failed:", err);
    throw err;
  }
}

module.exports = { connectDB };

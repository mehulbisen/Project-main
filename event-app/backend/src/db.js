import AWS from "aws-sdk";
import mysql from "mysql2/promise";

// Initialize AWS Secrets Manager client
const secretsManager = new AWS.SecretsManager({ region: "ap-south-1" });

// 👇 Your actual secret ARN
const secretArn = "arn:aws:secretsmanager:ap-south-1:561137843066:secret:prod/eventapps/rds-oYOmwy";

// Function to fetch DB credentials from AWS Secrets Manager
async function getDbCredentials() {
  try {
    const data = await secretsManager
      .getSecretValue({ SecretId: secretArn })
      .promise();

    const secret = JSON.parse(data.SecretString);

    // Log (optional) to verify fetching success — remove in production
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

// Function to connect to database using credentials
export async function connectToDatabase() {
  const dbConfig = await getDbCredentials();

  try {
    const connection = await mysql.createConnection(dbConfig);
    console.log("✅ Connected to MySQL database successfully!");
    return connection;
  } catch (err) {
    console.error("❌ Database connection failed:", err);
    throw err;
  }
}

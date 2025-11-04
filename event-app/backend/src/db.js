const { SecretsManagerClient, GetSecretValueCommand } = require("@aws-sdk/client-secrets-manager");
const mysql = require("mysql2/promise");

let pool;

async function connectDB(secretArn) {
  if (pool) return pool;
  const sm = new SecretsManagerClient({ region: process.env.AWS_REGION });
  const data = await sm.send(new GetSecretValueCommand({ SecretId: secretArn }));
  const creds = JSON.parse(data.SecretString);
  pool = mysql.createPool({
    host: creds.host,
    user: creds.username,
    password: creds.password,
    database: creds.dbname
  });
  return pool;
}
module.exports = { connectDB };

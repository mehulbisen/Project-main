// server.js
const express = require('express');
const path = require('path');
const { createProxyMiddleware } = require('http-proxy-middleware');
const app = express();

// Proxy API calls to backend in same task (localhost:8080)
app.use('/api', createProxyMiddleware({
  target: 'http://localhost:8080',
  changeOrigin: true,
  pathRewrite: {'^/api': '/'}
}));

// Serve static build
app.use(express.static(path.join(__dirname, 'build')));
app.get('*', (req,res) => {
  res.sendFile(path.join(__dirname,'build','index.html'));
});

const PORT = process.env.PORT || 80;
app.listen(PORT, ()=> console.log(`Frontend server listening on ${PORT}`));

'use strict';

const express = require('express');
const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const config = require('./config');

const app = express();
const port = config.port;

// 定义允许执行的脚本列表
const allowedScripts = {
  'sshx_open': 'sshx_open.sh',
  'sshx_close': 'sshx_close.sh',
  'backup_sql': 'backup_sql_to_local.sh',
  'send_to_s3': 'sent_backupfile_to_s3.sh'
};

// 添加日志函数
function log(message) {
  const timestamp = new Date().toISOString();
  const logMessage = `[${timestamp}] ${message}\n`;
  fs.appendFileSync(path.join(__dirname, 'api-exec.log'), logMessage);
  console.log(logMessage);
}

// 应用中间件
app.use(helmet());

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 分钟
  max: 100 // 每个 IP 15 分钟内最多 100 个请求
});
app.use(limiter);

// 错误处理中间件
app.use((err, req, res, next) => {
  log(`错误: ${err.message}`);
  res.status(500).json({ error: '服务器内部错误' });
});

// 执行脚本的函数
function executeScript(scriptPath) {
  return new Promise((resolve, reject) => {
    exec(`sh ${scriptPath}`, (error, stdout, stderr) => {
      if (error) {
        log(`脚本执行错误: ${error.message}`);
        reject({ error: '执行错误', message: error.message, stdout, stderr });
      } else {
        log(`脚本执行成功: ${scriptPath}`);
        resolve({ output: stdout.trim(), stderr: stderr.trim() });
      }
    });
  });
}

// API 路由
app.get('/execute', async (req, res) => {
  const scriptNumber = req.query.script;
  const scriptName = allowedScripts[scriptNumber];

  if (!scriptName) {
    return res.status(400).json({ error: '无效的脚本参数' });
  }

  const scriptPath = path.join(config.scriptsDir, scriptName);

  try {
    const result = await executeScript(scriptPath);
    res.json({
      success: true,
      scriptId: scriptNumber,
      ...result
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      scriptId: scriptNumber,
      ...error
    });
  }
});

// 获取可用脚本列表
app.get('/scripts', (req, res) => {
  const scriptList = Object.keys(allowedScripts).map(id => ({
    id,
    name: `脚本 ${id}`
  }));
  res.json(scriptList);
});

// 健康检查
app.get('/', (req, res) => {
  res.status(200).json({ status: 'OK' });
});

// 启动服务器
app.listen(port, () => {
  console.log(`服务器运行在 http://localhost:${port}/`);
});

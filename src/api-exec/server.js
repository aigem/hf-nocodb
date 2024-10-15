'use strict';

const express = require('express');
const { exec } = require('child_process');
const path = require('path');
const helmet = require('helmet');
require('dotenv').config();

const app = express();
const port = process.env.API_EXEC_PORT || 3001;

// 脚本路径配置
const scripts = {
  '1': '/home/nocodb/app/api-exec/scripts/1.sh',
  '2': '/home/nocodb/app/api-exec/scripts/2.sh'
};

// 执行脚本的函数
function executeScript(scriptPath) {
  return new Promise((resolve, reject) => {
    exec(`sh ${scriptPath}`, (error, stdout, stderr) => {
      if (error) {
        reject({ error: '执行错误', message: error.message, stdout, stderr });
      } else {
        resolve({ output: stdout.trim(), stderr: stderr.trim() });
      }
    });
  });
}

// 使用 helmet 中间件增强安全性
app.use(helmet());

// 静态文件服务
app.use(express.static(path.join(__dirname, 'public')));

// 添加 CORS 中间件
const cors = require('cors');
app.use(cors());

// 添加错误日志记录
const fs = require('fs');
const logFile = path.join(__dirname, 'error.log');

// API 路由
app.get('/api/execute', async (req, res) => {
  const scriptNumber = req.query.script;
  const scriptPath = scripts[scriptNumber];

  if (!scriptPath) {
    return res.status(400).json({ error: '无效的脚本参数' });
  }

  try {
    const result = await executeScript(scriptPath);
    res.json({
      success: true,
      scriptId: scriptNumber,
      scriptPath,
      ...result,
      params: req.query
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      scriptId: scriptNumber,
      scriptPath,
      ...error,
      params: req.query
    });
  }
});

// 获取可用脚本列表
app.get('/api/scripts', (req, res) => {
  const scriptList = Object.entries(scripts).map(([id, path]) => ({
    id,
    name: `脚本 ${id}`,
    path
  }));
  res.json(scriptList);
});

// 错误处理中间件
app.use((err, req, res, next) => {
  const errorMessage = `[${new Date().toISOString()}] ${err.stack}\n`;
  fs.appendFile(logFile, errorMessage, (appendErr) => {
    if (appendErr) console.error('无法写入错误日志:', appendErr);
  });
  console.error(err.stack);
  res.status(500).json({ error: '服务器内部错误' });
});

// 为了确保 React 路由正常工作，添加以下路由
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// 启动服务器
app.listen(port, () => {
  console.log(`服务器运行在 http://localhost:${port}/`);
});

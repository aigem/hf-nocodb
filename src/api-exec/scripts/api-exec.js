// 导入必要的模块
const http = require('http');
const { exec } = require('child_process');
const url = require('url');

// 设置服务器配置
const hostname = '127.0.0.1'; // 服务器主机名
const port = 3000; // 服务器端口

// 脚本路径配置
const scripts = {
  '1': '/home/nocodb/app/traefik/scripts/1.sh',
  '2': '/home/nocodb/app/traefik/scripts/2.sh'
};

// 执行脚本的函数
function executeScript(scriptPath) {
  return new Promise((resolve, reject) => {
    exec(`sh ${scriptPath}`, (error, stdout, stderr) => {
      if (error) {
        reject({ error: '执行错误', message: error.message });
      } else if (stderr) {
        reject({ error: '标准错误输出', message: stderr });
      } else {
        resolve({ output: stdout.trim() });
      }
    });
  });
}

// 处理 GET 请求的函数
async function handleGetRequest(req, res) {
  const parsedUrl = url.parse(req.url, true);
  const queryParams = parsedUrl.query;

  console.log(`收到 GET 请求: ${req.url}`);
  console.log('查询参数:', queryParams);

  const scriptNumber = queryParams.script;
  const scriptPath = scripts[scriptNumber];

  if (!scriptPath) {
    sendJsonResponse(res, 400, { error: '无效的脚本参数' });
    return;
  }

  try {
    const result = await executeScript(scriptPath);
    sendJsonResponse(res, 200, {
      ...result,
      params: queryParams
    });
  } catch (error) {
    sendJsonResponse(res, 500, error);
  }
}

// 发送 JSON 响应的辅助函数
function sendJsonResponse(res, statusCode, data) {
  res.statusCode = statusCode;
  res.setHeader('Content-Type', 'application/json');
  res.end(JSON.stringify(data, null, 2));
}

// 创建 HTTP 服务器
const server = http.createServer((req, res) => {
  if (req.method === 'GET') {
    handleGetRequest(req, res);
  } else {
    sendJsonResponse(res, 405, { error: '仅支持 GET 请求' });
  }
});

// 启动服务器
server.listen(port, hostname, () => {
  console.log(`服务器运行在 http://${hostname}:${port}/`);
});

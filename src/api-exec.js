// 导入必要的模块
const http = require('http');
const { exec } = require('child_process');
const url = require('url');
const querystring = require('querystring');

// 设置服务器配置
const hostname = '127.0.0.1'; // 服务器主机名
const port = 3000; // 服务器端口
const scriptPath = '/home/nocodb/app/traefik/api-exec-script.sh'; // 要执行的脚本路径

// 处理 GET 请求的函数
function handleGetRequest(req, res) {
  // 解析 URL 和查询参数
  const parsedUrl = url.parse(req.url, true);
  const queryParams = parsedUrl.query;

  // 记录请求信息
  console.log(`收到 GET 请求: ${req.url}`);
  console.log('查询参数:', queryParams);

  // 执行外部脚本
  exec(`sh ${scriptPath}`, (error, stdout, stderr) => {
    if (error) {
      // 如果执行出错，返回 500 错误
      sendResponse(res, 500, `执行错误: ${error.message}`);
      return;
    }
    if (stderr) {
      // 如果有标准错误输出，返回 500 错误
      sendResponse(res, 500, `标准错误输出: ${stderr}`);
      return;
    }
    // 构造输出，包括脚本输出和接收到的参数
    const output = `命令输出:\n${stdout}\n\n接收到的参数:\n${JSON.stringify(queryParams, null, 2)}`;
    // 发送成功响应
    sendResponse(res, 200, output);
    console.log(output);
  });
}

// 处理 POST 请求的函数
function handlePostRequest(req, res) {
  let body = '';
  // 接收 POST 数据
  req.on('data', chunk => {
    body += chunk.toString();
  });
  // 当数据接收完毕时
  req.on('end', () => {
    // 解析 POST 数据
    const postData = querystring.parse(body);
    console.log('收到 POST 数据:', postData);

    // TODO: 在这里处理 POST 数据
    const responseText = `收到 POST 请求，数据如下:\n${JSON.stringify(postData, null, 2)}`;
    // 发送响应
    sendResponse(res, 200, responseText);
  });
}

// 发送 HTTP 响应的辅助函数
function sendResponse(res, statusCode, content) {
  res.statusCode = statusCode;
  res.setHeader('Content-Type', 'text/plain; charset=utf-8');
  res.end(content);
}

// 创建 HTTP 服务器
const server = http.createServer((req, res) => {
  if (req.method === 'GET') {
    // 处理 GET 请求
    handleGetRequest(req, res);
  } else if (req.method === 'POST') {
    // 处理 POST 请求
    handlePostRequest(req, res);
  } else {
    // 对于其他类型的请求，返回 405 方法不允许
    sendResponse(res, 405, '仅支持 GET 和 POST 请求');
  }
});

// 启动服务器
server.listen(port, hostname, () => {
  console.log(`服务器运行在 http://${hostname}:${port}/`);
});

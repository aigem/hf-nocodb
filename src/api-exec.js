const http = require('http');
const { exec } = require('child_process');

const hostname = '127.0.0.1';
const port = 3000;
const scriptPath = '/home/nocodb/app/traefik/api-exec-script.sh'; 
const server = http.createServer((req, res) => {
  if (req.method === 'GET') {
    console.log(`Received request: ${req.method} ${req.url}`);
    exec(`sh ${scriptPath}`, (error, stdout, stderr) => {
      if (error) {
        res.statusCode = 500;
        res.setHeader('Content-Type', 'text/plain; charset=utf-8');
        res.end(`执行错误: ${error.message}`);
        return;
      }
      if (stderr) {
        res.statusCode = 500;
        res.setHeader('Content-Type', 'text/plain; charset=utf-8');
        res.end(`标准错误输出: ${stderr}`);
        return;
      }
      res.statusCode = 200;
      res.setHeader('Content-Type', 'text/plain; charset=utf-8');
      res.end(`命令输出:\n${stdout}`);
      console.log(`Command output:\n${stdout}`);
    });
  } else {
    res.statusCode = 405;
    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    res.end('仅支持 GET 请求');
  }
});

server.listen(port, hostname, () => {
  console.log(`服务器运行在 http://${hostname}:${port}/`);
});


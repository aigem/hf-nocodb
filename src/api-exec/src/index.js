import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';
import './index.css';

const rootElement = document.getElementById('root');

ReactDOM.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
  rootElement,
  () => {
    // 渲染完成后移除加载指示器
    const loadingElement = document.getElementById('loading');
    if (loadingElement) {
      loadingElement.remove();
    }
  }
);

// 添加错误边界
window.addEventListener('error', (event) => {
  console.error('全局错误:', event.error);
  rootElement.innerHTML = `<div style="color: red; padding: 20px;">
    加载出错: ${event.error.message}
  </div>`;
});

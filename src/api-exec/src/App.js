import React, { useState, useCallback, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Toaster, toast } from 'react-hot-toast';

export default function App() {
  const [output, setOutput] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [scripts, setScripts] = useState([]);

  useEffect(() => {
    // 获取可用脚本列表
    fetch('/api/scripts')
      .then(response => response.json())
      .then(data => setScripts(data))
      .catch(error => console.error('获取脚本列表失败:', error));
  }, []);

  const runScript = useCallback(async (scriptId) => {
    setIsLoading(true);
    try {
      const response = await fetch(`/api/execute?script=${scriptId}`);
      const data = await response.json();
      if (data.error) {
        toast.error(`错误: ${data.error}`);
        setOutput(`错误: ${data.error}\n信息: ${data.message}`);
      } else {
        toast.success('脚本执行成功');
        setOutput(`脚本输出:\n${data.output}`);
      }
    } catch (error) {
      toast.error('网络错误，请稍后重试');
      setOutput('网络错误，请稍后重试');
    } finally {
      setIsLoading(false);
    }
  }, []);

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-gradient-to-br from-purple-600 to-blue-500 text-white p-8">
      <Toaster position="top-center" />
      <motion.h1 
        className="text-5xl font-bold mb-8 text-center"
        initial={{ opacity: 0, y: -50 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
      >
        欢迎使用脚本执行器
      </motion.h1>
      <div className="flex space-x-4 mb-8">
        {scripts.map((script) => (
          <motion.button
            key={script.id}
            onClick={() => runScript(script.id)}
            disabled={isLoading}
            className="px-6 py-3 text-lg font-semibold bg-white bg-opacity-20 rounded-lg hover:bg-opacity-30 transition-all duration-200 disabled:opacity-50"
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            运行脚本 {script.name}
          </motion.button>
        ))}
      </div>
      <AnimatePresence>
        <motion.div 
          key={output}
          className="w-full max-w-2xl bg-black bg-opacity-50 p-6 rounded-lg"
          initial={{ opacity: 0, y: 50 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: -50 }}
          transition={{ duration: 0.5 }}
        >
          <pre className="whitespace-pre-wrap break-words text-sm">
            {isLoading ? '执行中...' : output || '脚本输出将显示在这里'}
          </pre>
        </motion.div>
      </AnimatePresence>
    </div>
  );
}

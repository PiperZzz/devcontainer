#!/bin/bash

echo "🚀 初始化全栈开发环境..."

# 确保脚本在错误时停止
set -e

# 显示 Node.js 和 npm 版本
echo "📦 检查 Node.js 环境..."
node --version
npm --version

# 显示 Java 版本
echo "☕ 检查 Java 环境..."
java -version

# 检查 Maven
echo "🔧 检查 Maven..."
mvn -version

# 如果存在 package.json，安装前端依赖
if [ -f "package.json" ]; then
    echo "📱 安装前端依赖..."
    npm install
    echo "✅ 前端依赖安装完成"
else
    echo "ℹ️ 未找到 package.json，跳过前端依赖安装"
fi

# 如果存在 pom.xml，预编译后端项目
if [ -f "pom.xml" ]; then
    echo "⚙️ 编译后端项目..."
    ./mvnw clean compile -DskipTests
    echo "✅ 后端项目编译完成"
else
    echo "ℹ️ 未找到 pom.xml，跳过后端编译"
fi

# 设置 Git hooks（如果需要）
if [ -d ".git" ]; then
    echo "🔗 配置 Git hooks..."
    # 这里可以添加预提交钩子等
fi

# 创建常用的开发脚本
echo "📝 创建开发快捷脚本..."

# 创建启动脚本
cat > start-dev.sh << 'EOL'
#!/bin/bash
echo "🚀 启动全栈开发环境..."

# 在后台启动 Spring Boot
echo "🌱 启动 Spring Boot 后端..."
./mvnw spring-boot:run &
BACKEND_PID=$!

# 等待后端启动
echo "⏳ 等待后端启动..."
sleep 10

# 启动 React 前端
echo "⚛️ 启动 React 前端..."
npm start &
FRONTEND_PID=$!

echo "✅ 开发环境启动完成！"
echo "📱 前端: http://localhost:3000"
echo "🔧 后端: http://localhost:8080"
echo "📊 API文档: http://localhost:8080/actuator/health"

# 等待用户中断
trap "echo '🛑 停止开发服务器...'; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit" INT TERM

wait
EOL

chmod +x start-dev.sh

# 创建快速测试脚本
cat > quick-test.sh << 'EOL'
#!/bin/bash
echo "🧪 运行快速测试..."

# 测试后端
echo "🔧 测试后端编译..."
./mvnw clean test-compile

# 测试前端
echo "📱 测试前端编译..."
npm run build

echo "✅ 快速测试完成！"
EOL

chmod +x quick-test.sh

# 显示项目结构
echo "📁 项目结构:"
tree -I 'node_modules|target|.git' -L 2 || ls -la

echo ""
echo "🎉 开发环境初始化完成！"
echo ""
echo "💡 常用命令："
echo "  启动完整开发环境: ./start-dev.sh"
echo "  仅启动后端: ./mvnw spring-boot:run"
echo "  仅启动前端: npm start"
echo "  快速测试: ./quick-test.sh"
echo ""
echo "🌐 服务地址："
echo "  前端应用: http://localhost:3000"
echo "  后端API: http://localhost:8080/api"
echo "  健康检查: http://localhost:8080/actuator/health"
echo ""
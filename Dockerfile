FROM mcr.microsoft.com/devcontainers/base:ubuntu

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 安装基础工具和依赖
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    build-essential \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    # 中文字体支持
    fonts-noto-cjk \
    # 开发工具
    vim \
    htop \
    tree \
    jq \
    # 网络工具
    netcat \
    telnet \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# 设置时区
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

# 安装 Node.js 和 npm 全局包（虽然 features 会安装 Node.js，但我们需要确保版本一致）
# 这里预装一些常用的全局包
RUN npm config set registry https://registry.npmmirror.com/ && \
    npm install -g \
    yarn \
    pnpm \
    create-react-app \
    typescript \
    ts-node \
    nodemon \
    @types/node

# 创建工作目录
WORKDIR /workspace

# 优化 npm/yarn 性能
RUN echo "registry=https://registry.npmmirror.com/" > /home/vscode/.npmrc && \
    echo "registry \"https://registry.npmmirror.com/\"" > /home/vscode/.yarnrc

# 设置 Git 全局配置默认值（用户可以后续修改）
RUN git config --global init.defaultBranch main && \
    git config --global core.autocrlf input

# 创建常用目录
RUN mkdir -p /workspace/logs /workspace/tmp

# 设置权限
RUN chown -R vscode:vscode /workspace /home/vscode

# 切换到 vscode 用户
USER vscode

# 设置用户环境
RUN echo 'export PATH=$PATH:/home/vscode/.local/bin' >> /home/vscode/.bashrc && \
    echo 'alias ll="ls -la"' >> /home/vscode/.bashrc && \
    echo 'alias la="ls -la"' >> /home/vscode/.bashrc && \
    echo 'alias mvn-run="./mvnw spring-boot:run"' >> /home/vscode/.bashrc && \
    echo 'alias react-start="npm start"' >> /home/vscode/.bashrc && \
    echo 'alias react-build="npm run build"' >> /home/vscode/.bashrc

# 设置工作目录
WORKDIR /workspace
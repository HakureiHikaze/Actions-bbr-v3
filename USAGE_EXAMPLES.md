# BBR v3 脚本优化 - 使用示例

本文档提供了优化后的 BBR v3 安装脚本的详细使用示例。

## 目录
- [基本使用](#基本使用)
- [代理配置](#代理配置)
- [缓存和断点续传](#缓存和断点续传)
- [下载链接工具](#下载链接工具)
- [高级场景](#高级场景)

---

## 基本使用

### 标准安装（无代理）

```bash
bash install.sh
```

---

## 代理配置

### 使用 HTTP/HTTPS 代理

```bash
# 方式 1: 分别设置 HTTP 和 HTTPS 代理
export HTTP_PROXY="http://proxy.example.com:8080"
export HTTPS_PROXY="http://proxy.example.com:8080"
bash install.sh

# 方式 2: 使用统一代理
export ALL_PROXY="http://proxy.example.com:8080"
bash install.sh

# 单行命令
HTTP_PROXY="http://proxy.example.com:8080" HTTPS_PROXY="http://proxy.example.com:8080" bash install.sh
```

### 使用 SOCKS5 代理

```bash
# 方式 1: 使用 SOCKS_PROXY 变量
export SOCKS_PROXY="socks5://127.0.0.1:1080"
bash install.sh

# 方式 2: 使用 ALL_PROXY 变量
export ALL_PROXY="socks5://127.0.0.1:1080"
bash install.sh

# 单行命令
ALL_PROXY="socks5://127.0.0.1:1080" bash install.sh
```

### 带认证的代理

```bash
# HTTP 代理认证
export HTTP_PROXY="http://username:password@proxy.example.com:8080"
export HTTPS_PROXY="http://username:password@proxy.example.com:8080"
bash install.sh

# SOCKS5 代理认证
export ALL_PROXY="socks5://username:password@127.0.0.1:1080"
bash install.sh
```

---

## 缓存和断点续传

### 使用默认缓存目录

脚本会自动使用 `/tmp/bbr-cache` 作为缓存目录：

```bash
# 首次运行 - 下载文件并缓存
bash install.sh

# 再次运行 - 自动使用缓存文件
bash install.sh
```

### 自定义缓存目录

```bash
# 使用自定义缓存目录
export CACHE_DIR="/home/user/bbr-downloads"
bash install.sh

# 持久化缓存目录（添加到 ~/.bashrc 或 ~/.profile）
echo 'export CACHE_DIR="/home/user/bbr-downloads"' >> ~/.bashrc
```

### 手动放置下载文件

如果您已经手动下载了 `.deb` 文件，可以将它们放入缓存目录：

```bash
# 创建缓存目录
mkdir -p /tmp/bbr-cache

# 复制已下载的文件
cp ~/Downloads/linux-*.deb /tmp/bbr-cache/

# 运行脚本 - 将自动识别并使用缓存文件
bash install.sh
```

### 断点续传

如果下载中断，脚本会自动从断点继续：

```bash
# 第一次运行 - 下载中断
bash install.sh
# 按 Ctrl+C 中断

# 再次运行 - 从断点继续下载
bash install.sh
```

---

## 下载链接工具

### 查看所有版本的下载链接

```bash
# 默认格式化输出
bash get-download-links.sh

# 输出示例：
# 版本 1: x86_64-6.12.0
# 发布时间: 2024-10-15T08:30:00Z
# 下载链接：
#   https://github.com/byJoey/Actions-bbr-v3/releases/download/x86_64-6.12.0/linux-image-6.12.0_6.12.0-1_amd64.deb
#   https://github.com/byJoey/Actions-bbr-v3/releases/download/x86_64-6.12.0/linux-headers-6.12.0_6.12.0-1_amd64.deb
```

### 生成 wget 下载脚本

```bash
# 生成下载脚本
bash get-download-links.sh --wget -o download.sh

# 执行下载
chmod +x download.sh
./download.sh

# 下载的文件将保存在 ./bbr-downloads/ 目录
```

### JSON 格式输出

```bash
# 输出 JSON 格式，方便程序处理
bash get-download-links.sh --json

# 保存到文件
bash get-download-links.sh --json -o releases.json

# 使用 jq 处理
bash get-download-links.sh --json | jq '.[] | .tag_name'
```

### 仅显示下载链接

```bash
# 仅输出下载 URL
bash get-download-links.sh --urls

# 保存到文件
bash get-download-links.sh --urls -o urls.txt
```

### 通过代理获取链接

```bash
# 使用 HTTP 代理
HTTP_PROXY="http://proxy.example.com:8080" bash get-download-links.sh

# 使用 SOCKS5 代理
ALL_PROXY="socks5://127.0.0.1:1080" bash get-download-links.sh --wget -o download.sh
```

---

## 高级场景

### 场景 1: 离线环境安装

```bash
# 在有网络的机器上获取下载链接
bash get-download-links.sh --wget -o download.sh

# 执行下载脚本
./download.sh

# 将 bbr-downloads 目录打包
tar czf bbr-packages.tar.gz bbr-downloads/

# 传输到离线机器
scp bbr-packages.tar.gz offline-server:/tmp/

# 在离线机器上解压并设置缓存
tar xzf /tmp/bbr-packages.tar.gz -C /tmp/
export CACHE_DIR="/tmp/bbr-downloads"

# 运行安装脚本
bash install.sh
```

### 场景 2: 批量服务器部署

```bash
#!/bin/bash
# deploy-bbr.sh - 批量部署脚本

SERVERS=("server1" "server2" "server3")
PROXY="socks5://127.0.0.1:1080"

# 在本地准备缓存
export ALL_PROXY="$PROXY"
export CACHE_DIR="./bbr-cache"
bash install.sh

# 打包缓存和脚本
tar czf bbr-deploy.tar.gz bbr-cache/ install.sh

# 部署到每台服务器
for server in "${SERVERS[@]}"; do
    echo "部署到 $server..."
    scp bbr-deploy.tar.gz $server:/tmp/
    ssh $server "cd /tmp && tar xzf bbr-deploy.tar.gz && \
                 CACHE_DIR=/tmp/bbr-cache bash /tmp/install.sh"
done
```

### 场景 3: 使用特定版本

```bash
# 获取所有版本链接
bash get-download-links.sh --urls

# 手动下载特定版本
wget -c https://github.com/.../linux-image-6.11.0_6.11.0-1_amd64.deb -P /tmp/bbr-cache/
wget -c https://github.com/.../linux-headers-6.11.0_6.11.0-1_amd64.deb -P /tmp/bbr-cache/

# 设置缓存目录并安装
export CACHE_DIR="/tmp/bbr-cache"
bash install.sh
# 选择选项 2（指定版本安装），然后选择对应版本
```

### 场景 4: 网络不稳定环境

```bash
# 设置代理和缓存目录，启用断点续传
export ALL_PROXY="socks5://127.0.0.1:1080"
export CACHE_DIR="/var/cache/bbr"
mkdir -p "$CACHE_DIR"

# 如果下载失败，多次重试
while ! bash install.sh; do
    echo "安装失败，5秒后重试..."
    sleep 5
done
```

---

## 环境变量参考

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `ALL_PROXY` | 统一代理设置（优先级最高） | `socks5://127.0.0.1:1080` |
| `SOCKS_PROXY` | SOCKS 代理设置 | `socks5://127.0.0.1:1080` |
| `HTTP_PROXY` | HTTP 代理设置 | `http://proxy.example.com:8080` |
| `HTTPS_PROXY` | HTTPS 代理设置 | `http://proxy.example.com:8080` |
| `CACHE_DIR` | 缓存目录路径 | `/home/user/bbr-cache` |

---

## 故障排除

### 代理连接失败

```bash
# 测试代理连接
curl --proxy socks5://127.0.0.1:1080 https://api.github.com/

# 如果失败，检查代理服务是否运行
netstat -tlnp | grep 1080
```

### 缓存文件损坏

```bash
# 清理缓存并重新下载
rm -rf /tmp/bbr-cache/*
bash install.sh
```

### 查看详细错误

```bash
# 启用调试模式
bash -x install.sh
```

---

## 总结

优化后的脚本提供了以下主要功能：

1. **灵活的代理支持** - 适应各种网络环境
2. **智能缓存机制** - 节省带宽和时间
3. **断点续传** - 应对网络不稳定
4. **独立下载工具** - 方便离线部署
5. **完善的文档** - 易于使用和排错

如有问题，请访问 [GitHub Issues](https://github.com/byJoey/Actions-bbr-v3/issues) 或加入 [Telegram 群组](https://t.me/+ft-zI76oovgwNmRh)。

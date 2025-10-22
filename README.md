# ✨BBR 管理脚本✨  

一个为 Debian/Ubuntu 用户设计的，简单、高效且功能丰富的 BBR 管理脚本。

无论是想一键安装最新的 **BBR v3** 内核，还是在不同的网络加速方案之间灵活切换，本脚本都能帮你轻松搞定。

> **我们致力于提供优雅的界面和流畅的操作，让内核管理不再是件头疼事。**

---

### 🎯 **目标用户与支持环境**

在运行脚本前，请确保你的设备符合以下要求：

| 项目 | 要求 |
| :--- | :--- |
| **支持架构** | `x86_64` / `aarch64` |
| **支持系统** | Debian 10+ / Ubuntu 18.04+ |
| **目标设备** | **云服务器 (VPS/Cloud Server)** 或 **独立服务器** |
| **引导方式** | 使用标准 `GRUB` 引导加载程序 |

> ⚠️ **重要说明**
> 本脚本**不适用**于大多数单板计算机（SBC），例如**树莓派 (Raspberry Pi)、NanoPi** 等。这些设备通常使用 U-Boot 等非 GRUB 引导方式，脚本会执行失败。

---

---

### 🌟 功能列表  

👑 **一键安装 BBR v3 内核**  
🍰 **切换加速模式（BBR+FQ、BBR+CAKE 等）**  
⚙️ **开启/关闭 BBR 加速**  
🗑️ **卸载内核，告别不需要的内核版本**  
👀 **实时查看当前 TCP 拥塞算法和队列算法**  
🎨 **美化的输出界面，让脚本更有灵魂**  

---

### 🚀 如何使用？

1. **一键运行**  
   ```bash
   bash <(curl -l -s https://raw.githubusercontent.com/byJoey/Actions-bbr-v3/refs/heads/main/install.sh)
   ```

---

### 🔧 高级功能

#### 代理支持

脚本支持通过环境变量配置代理，适用于需要通过代理访问 GitHub 的场景：

```bash
# 使用 HTTP/HTTPS 代理
export HTTP_PROXY="http://proxy.example.com:8080"
export HTTPS_PROXY="http://proxy.example.com:8080"

# 使用 SOCKS5 代理
export ALL_PROXY="socks5://127.0.0.1:1080"
# 或
export SOCKS_PROXY="socks5://127.0.0.1:1080"

# 然后运行脚本
bash install.sh
```

#### 断点续传和缓存支持

脚本已优化下载功能：
- **断点续传**：网络中断后可以从断点继续下载，不需要重新下载
- **本地缓存**：下载的文件会缓存在 `/tmp/bbr-cache` 目录（可通过 `CACHE_DIR` 环境变量自定义）
- **手动放置文件**：可以手动将 `.deb` 文件放入缓存目录，脚本会自动识别并使用

```bash
# 自定义缓存目录
export CACHE_DIR="/home/user/bbr-cache"
bash install.sh

# 手动放置文件到缓存目录
mkdir -p /tmp/bbr-cache
cp linux-*.deb /tmp/bbr-cache/
bash install.sh  # 脚本会自动使用缓存的文件
```

#### 获取下载链接脚本

新增 `get-download-links.sh` 工具，用于获取当前系统架构的所有可用版本下载链接：

```bash
# 显示所有版本的下载链接
bash get-download-links.sh

# 生成 wget 下载脚本
bash get-download-links.sh --wget -o download.sh
chmod +x download.sh && ./download.sh

# JSON 格式输出
bash get-download-links.sh --json

# 仅显示下载链接
bash get-download-links.sh --urls

# 通过代理获取
ALL_PROXY=socks5://127.0.0.1:1080 bash get-download-links.sh

# 查看帮助
bash get-download-links.sh --help
```

---

### 🌟 操作界面  

每次运行脚本，你都会进入一个活泼又实用的选项界面：

```bash
╭( ･ㅂ･)و ✧ 你可以选择以下操作哦：
  1. 🛠️  安装 BBR v3
  2. 🔍 检查是否为 BBR v3
  3. ⚡ 使用 BBR + FQ 加速
  4. ⚡ 使用 BBR + FQ_PIE 加速
  5. ⚡ 使用 BBR + CAKE 加速
  6. 🔧 开启或关闭 BBR
  7. 🗑️  卸载
```

> **小提示：** 如果选错了也没关系，脚本会乖乖告诉你该怎么办！  

---

### 🌟 常见问题  

**Q: 为什么下载失败啦？**  
A: 有可能是 GitHub 链接过期了，来群里吐槽一下吧！  

**Q: 我不是 BBR 专家，不知道选哪个加速方案？**  
A: 放心，BBR + FQ 是最常见的方案，适用于大多数场景～  

**Q: 如果不小心把系统搞崩了怎么办？**  
A: 别慌！记得备份你的内核，或者到 [Joey's Blog](https://joeyblog.net) 查看修复教程。

---

### 🌈 作者信息  

**Joey**  
📖 博客：[JoeyBlog](https://joeyblog.net)  
💬 群组：[Telegram Feedback Group](https://t.me/+ft-zI76oovgwNmRh)

---

### ❤️ 开源协议  

欢迎使用、修改和传播这个脚本！如果你觉得它对你有帮助，记得来点个 Star ⭐ 哦～  

> 💡 **免责声明：** 本脚本由作者热爱 Linux 的灵魂驱动编写，虽尽力确保安全，但任何使用问题请自负风险！
### 🌟 特别鸣谢  
感谢 [Naochen2799/Latest-Kernel-BBR3](https://github.com/Naochen2799/Latest-Kernel-BBR3) 项目提供的技术支持与灵感参考。  
## 💡 赞助声明

本项目由 [VTEXS](https://console.vtexs.com/?affid=1513) 的「开源项目免费 VPS 计划」提供算力支持。  
感谢 VTEXS 对开源社区的支持！


🎉 **快来体验不一样的 BBR 管理工具吧！** 🎉  
## Star History

<a href="https://star-history.com/#byJoey/Actions-bbr-v3&Timeline">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=byJoey/Actions-bbr-v3&type=Timeline&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=byJoey/Actions-bbr-v3&type=Timeline" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=byJoey/Actions-bbr-v3&type=Timeline" />
 </picture>
</a>

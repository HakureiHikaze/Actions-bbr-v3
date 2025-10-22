#!/bin/bash

# BBR v3 下载链接获取脚本
# 用于获取当前系统架构对应的所有可用版本的下载链接

# 颜色定义
RED='\033[31m'
GREEN='\033[1;32m'
YELLOW='\033[33m'
CYAN='\033[36m'
PURPLE='\033[1;35m'
RESET='\033[0m'

# 代理配置函数
setup_proxy() {
    CURL_PROXY_OPTS=""
    
    if [[ -n "$ALL_PROXY" ]]; then
        CURL_PROXY_OPTS="--proxy $ALL_PROXY"
    elif [[ -n "$SOCKS_PROXY" ]]; then
        CURL_PROXY_OPTS="--proxy $SOCKS_PROXY"
    elif [[ -n "$HTTP_PROXY" ]] || [[ -n "$HTTPS_PROXY" ]]; then
        [[ -n "$HTTPS_PROXY" ]] && CURL_PROXY_OPTS="--proxy $HTTPS_PROXY"
        [[ -z "$HTTPS_PROXY" && -n "$HTTP_PROXY" ]] && CURL_PROXY_OPTS="--proxy $HTTP_PROXY"
    fi
    
    if [[ -n "$CURL_PROXY_OPTS" ]]; then
        echo -e "${CYAN}检测到代理配置，将通过代理进行网络请求${RESET}"
    fi
}

# 检查必要的依赖
check_dependencies() {
    local missing_deps=()
    
    for cmd in curl jq; do
        if ! command -v $cmd &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "${RED}缺少必要的依赖：${missing_deps[*]}${RESET}"
        echo -e "${YELLOW}请先安装这些依赖，例如：sudo apt-get install ${missing_deps[*]}${RESET}"
        exit 1
    fi
}

# 美化输出的分隔线
print_separator() {
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

# 获取系统架构
get_architecture() {
    ARCH=$(uname -m)
    if [[ "$ARCH" != "aarch64" && "$ARCH" != "x86_64" ]]; then
        echo -e "${RED}不支持的系统架构：$ARCH${RESET}"
        echo -e "${YELLOW}此脚本仅支持 aarch64 (ARM64) 和 x86_64 架构${RESET}"
        exit 1
    fi
    
    if [[ "$ARCH" == "aarch64" ]]; then
        ARCH_FILTER="arm64"
    else
        ARCH_FILTER="x86_64"
    fi
}

# 获取所有发布版本
get_all_releases() {
    echo -e "${CYAN}正在从 GitHub 获取版本信息...${RESET}"
    BASE_URL="https://api.github.com/repos/byJoey/Actions-bbr-v3/releases"
    
    RELEASE_DATA=$(curl -sL $CURL_PROXY_OPTS --connect-timeout 30 --retry 3 "$BASE_URL")
    
    if [[ -z "$RELEASE_DATA" ]]; then
        echo -e "${RED}从 GitHub 获取版本信息失败。请检查网络连接或 API 状态。${RESET}"
        exit 1
    fi
    
    echo "$RELEASE_DATA"
}

# 显示所有版本的下载链接
show_download_links() {
    local release_data="$1"
    local output_format="$2"
    
    # 过滤适合当前架构的版本
    FILTERED_RELEASES=$(echo "$release_data" | jq -r --arg filter "$ARCH_FILTER" '[.[] | select(.tag_name | test($filter; "i"))] | sort_by(.published_at) | reverse')
    
    local count=$(echo "$FILTERED_RELEASES" | jq '. | length')
    
    if [[ "$count" -eq 0 ]]; then
        echo -e "${RED}未找到适合当前架构 ($ARCH) 的版本。${RESET}"
        exit 1
    fi
    
    echo -e "${GREEN}找到 $count 个适合 $ARCH 架构的版本${RESET}"
    print_separator
    
    if [[ "$output_format" == "json" ]]; then
        # JSON 格式输出
        echo "$FILTERED_RELEASES" | jq -r '.[] | {
            tag_name: .tag_name,
            published_at: .published_at,
            download_urls: [.assets[].browser_download_url]
        }'
    elif [[ "$output_format" == "wget" ]]; then
        # 生成 wget 下载命令
        echo -e "${YELLOW}# wget 下载命令（支持断点续传）${RESET}"
        echo "$FILTERED_RELEASES" | jq -r '.[] | .tag_name as $tag | .assets[].browser_download_url | "# 版本: \($tag)\nwget -c \"\(.)\" -P ./bbr-downloads/"'
    elif [[ "$output_format" == "urls" ]]; then
        # 仅显示 URL 列表
        echo "$FILTERED_RELEASES" | jq -r '.[] | .tag_name as $tag | "\n# 版本: \($tag)", (.assets[].browser_download_url)'
    else
        # 默认格式化输出
        for i in $(seq 0 $((count - 1))); do
            TAG_NAME=$(echo "$FILTERED_RELEASES" | jq -r ".[$i].tag_name")
            PUBLISHED_AT=$(echo "$FILTERED_RELEASES" | jq -r ".[$i].published_at")
            DOWNLOAD_URLS=$(echo "$FILTERED_RELEASES" | jq -r ".[$i].assets[].browser_download_url")
            
            echo -e "${GREEN}版本 $((i+1)): $TAG_NAME${RESET}"
            echo -e "${CYAN}发布时间: $PUBLISHED_AT${RESET}"
            echo -e "${YELLOW}下载链接：${RESET}"
            
            for url in $DOWNLOAD_URLS; do
                echo -e "  $url"
            done
            
            echo ""
        done
    fi
}

# 主函数
main() {
    clear
    print_separator
    echo -e "${PURPLE}BBR v3 下载链接获取工具${RESET}"
    print_separator
    
    # 检查依赖
    check_dependencies
    
    # 设置代理
    setup_proxy
    
    # 获取系统架构
    get_architecture
    
    echo -e "${CYAN}系统架构: ${GREEN}$ARCH ($ARCH_FILTER)${RESET}"
    print_separator
    
    # 解析命令行参数
    OUTPUT_FORMAT="default"
    SAVE_TO_FILE=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --json)
                OUTPUT_FORMAT="json"
                shift
                ;;
            --wget)
                OUTPUT_FORMAT="wget"
                shift
                ;;
            --urls)
                OUTPUT_FORMAT="urls"
                shift
                ;;
            --output|-o)
                SAVE_TO_FILE="$2"
                shift 2
                ;;
            --help|-h)
                echo "使用方法: $0 [选项]"
                echo ""
                echo "选项:"
                echo "  --json          以 JSON 格式输出"
                echo "  --wget          生成 wget 下载命令"
                echo "  --urls          仅输出下载链接"
                echo "  --output, -o    保存输出到文件"
                echo "  --help, -h      显示此帮助信息"
                echo ""
                echo "环境变量:"
                echo "  ALL_PROXY       设置代理 (例如: socks5://127.0.0.1:1080)"
                echo "  HTTP_PROXY      设置 HTTP 代理"
                echo "  HTTPS_PROXY     设置 HTTPS 代理"
                echo "  SOCKS_PROXY     设置 SOCKS 代理"
                echo ""
                echo "示例:"
                echo "  $0                              # 默认格式化输出"
                echo "  $0 --wget -o download.sh        # 生成 wget 脚本"
                echo "  $0 --json                       # JSON 格式输出"
                echo "  ALL_PROXY=socks5://127.0.0.1:1080 $0  # 通过代理获取"
                exit 0
                ;;
            *)
                echo -e "${RED}未知选项: $1${RESET}"
                echo "使用 --help 查看帮助信息"
                exit 1
                ;;
        esac
    done
    
    # 获取所有版本
    RELEASE_DATA=$(get_all_releases)
    
    # 显示下载链接
    if [[ -n "$SAVE_TO_FILE" ]]; then
        show_download_links "$RELEASE_DATA" "$OUTPUT_FORMAT" > "$SAVE_TO_FILE"
        echo -e "${GREEN}输出已保存到: $SAVE_TO_FILE${RESET}"
        
        if [[ "$OUTPUT_FORMAT" == "wget" ]]; then
            chmod +x "$SAVE_TO_FILE"
            echo -e "${YELLOW}提示: 文件已设置为可执行，可以直接运行下载${RESET}"
        fi
    else
        show_download_links "$RELEASE_DATA" "$OUTPUT_FORMAT"
    fi
    
    print_separator
    echo -e "${GREEN}完成！${RESET}"
}

# 运行主函数
main "$@"

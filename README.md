# bash-collection
有用的脚本们

## 列表

### tailscale
```bash
curl https://raw.githubusercontent.com/hertzyang/bash-collection/refs/heads/master/tailscale.sh | sudo bash -
```

一键加固本机的 tailscaled 服务，降权运行的同时可以正常使用网络功能，包括 MagicDNS。

先决条件：
 - 已安装 tailscale
 - 已安装 polkitd（用于允许 tailscale 配置 DNS）
 - 本机已安装并且正在使用 systemd-resolved 作为解析管理器

脚本会做什么：
 - 新建一个 `tailscale` 用户
 - 写入 polkit 规则，允许 tailscale 用户调用 `org.freedesktop.resolve1.*`
 - 写入 systemd override，* 这将会覆盖当前的 override 文件（如有） *，对 tailscaled 启用一组安全选项，并以 `tailscale` 普通用户权限运行。
 - 重新加载 systemd 配置并 * 重启 tailscaled *

 期望与目标：
 - 使用脚本后，tailscaled 以 `tailscale` 用户运行，且所有网络功能均正常，特权功能如 ssh 服务器除外。

### rsshub-lambda（ECR 一键构建）

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/hertzyang/bash-collection/refs/heads/master/rsshub.sh)
```

一键在当前 AWS Cloud Shell 环境中构建 RSSHub Lambda 容器镜像，并推送到用户自己的 Amazon ECR。

先决条件：
 - 拥有 AWS 账户及 CloudShell 使用权限

脚本会做什么：
 - 自动检测当前 AWS 账户 ID 和 region（兼容 CloudShell 环境变量）
 - 检查并创建 ECR 仓库（若不存在）
 - 登录 Amazon ECR
 - 从远程 Dockerfile 构建镜像
 - 打 tag 并推送到 ECR

输出结果：
 - 在 ECR 中生成镜像：
   ```
   <account-id>.dkr.ecr.<region>.amazonaws.com/rsshub-lambda:latest
   ```
 - 此镜像可被 AWS Lambda 使用

 ## 其他
 项目包含由大语言模型（LLM）生成的代码，不过，本项目中所有由 LLM 生成的代码均已由人工审计。

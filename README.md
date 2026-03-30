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
 - 使用脚本后，tailscaled 以 `tailscale` 用户运行，且所有网络功能均正常。

 ## 其他
 项目包含由大语言模型（LLM）生成的代码，不过，本项目中所有由 LLM 生成的代码均已由人工审计。

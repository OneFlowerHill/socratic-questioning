# deep-discussion 部署指南

`deep-discussion` 是单文件自包含技能，同一份源通过 symlink 同时暴露给 Claude Code 与 Hermes。

## 前置

- 仓库已 clone 到本地某路径（下称 `<repo>`）
- macOS / Linux：bash + `ln`
- Windows：PowerShell 或手动复制
- Hermes 已安装（`hermes` 命令可用）

## macOS / Linux

### 一键安装（推荐）

```bash
cd <repo>
bash scripts/install.sh
```

安装到：
- `~/.claude/skills/deep-discussion` → 指向 `<repo>`
- `~/.hermes/skills/software-development/deep-discussion` → 指向 `<repo>`

### 手动安装

```bash
ln -s <repo> ~/.claude/skills/deep-discussion
mkdir -p ~/.hermes/skills/software-development
ln -s <repo> ~/.hermes/skills/software-development/deep-discussion
```

### 卸载

```bash
bash scripts/install.sh --uninstall
```

## Windows

install.sh 为 bash 脚本，Windows 下用 PowerShell 手动建链或直接复制。

### PowerShell 建链（需管理员权限）

```powershell
$repo = "<repo 绝对路径>"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\skills\deep-discussion" -Target $repo
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.hermes\skills\software-development\deep-discussion" -Target $repo
```

### 直接复制（无需管理员权限）

```powershell
Copy-Item -Recurse <repo> "$env:USERPROFILE\.claude\skills\deep-discussion"
Copy-Item -Recurse <repo> "$env:USERPROFILE\.hermes\skills\software-development\deep-discussion"
```

注意：复制方式下，源更新后需重新复制；symlink 方式则自动同步。

## 验证

- Claude Code：在对话中输入 `/deep-discussion` 应能启动拷问流程。
- Hermes：`hermes skills` 应列出 `deep-discussion`（分类 `software-development`）。

## 故障排除

### 部分安装不一致（一端装上、一端没装）

install.sh 输出「部分安装：Claude=已装、Hermes=未装」时：
```bash
bash scripts/install.sh --uninstall   # 清理已装的一端
bash scripts/install.sh               # 重试
```

### 目标已存在且非同源 symlink

install.sh 不覆盖既有非同源 symlink。先查看：
```bash
ls -l ~/.claude/skills/deep-discussion ~/.hermes/skills/software-development/deep-discussion
```
确认为旧链后手动 `rm` 删除，再重试安装。

### SKILL.md name 与脚本不一致

install.sh `verify_source` 报「SKILL.md name='...' 与脚本 NAME='deep-discussion' 不一致」：说明源内容未完成改名，回到仓库执行改名步骤后再装。

### `hermes` 命令找不到

Hermes 未安装或未在 PATH。参考 Hermes 安装文档。

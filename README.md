# deep-discussion

用「拷问式访谈」打磨计划或设计的 Claude Code / Hermes 技能。

被唤起后，你进入「griller」角色，沿决策树逐枝拷问用户的计划：一次只问一个问题、每题附推荐答案、能从环境查到的事实直接查而不问。默认只聊天不落盘；只有用户明确要求保存时，才把结果写成 `CONTEXT.md`（术语表）与 `docs/adr/`（架构决策记录）。

## 何时用

- 想对一个计划 / 设计 / 决策做深度推敲。
- 想产出或更新术语表与架构决策记录。
- 需要「被拷问」来逼精确概念边界。

## 触发

仅显式触发——斜杠命令 `/deep-discussion`（可附主题，如 `/deep-discussion 我想做个内部审批流`），或明确说「开始拷问 / grill 我」。不根据对话语义自动唤起。

## 快速开始

### 安装

见 [docs/deploy.md](docs/deploy.md)。一键安装：

```bash
bash scripts/install.sh
```

### 使用

在 Claude Code 或 Hermes 对话中输入 `/deep-discussion`，进入拷问流程。需要保存结果时说「保存 / 落文档」，技能会在写入前展示摘要 / diff 并经你确认后落盘到当前工作目录。

## 文件结构

```
deep-discussion/
├── SKILL.md                  # 技能主体（拷问纪律 + 落盘规则 + 验收标准）
├── references/               # CONTEXT.md 与 ADR 的格式规范
├── scripts/install.sh        # 双端 symlink 安装
└── docs/deploy.md            # 部署指南
```

## 铁律

- 仅显式触发，禁止自动 / 隐式唤起。
- 除非用户明确要求，绝不自动创建任何文件。
- 每轮只抛一个问题，附推荐答案。
- 每次写入前展示摘要 / diff，用户确认后才写。
- CONTEXT.md 按术语名合并更新；ADR 按标题 slug 去重；重复保存幂等。

详见 `SKILL.md`。

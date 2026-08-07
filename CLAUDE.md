# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

`deep-discussion` 是一个 Claude Code 技能（skill），用「拷问式访谈」打磨计划或设计。合并了原版 `grill-me`（纯拷问）与 `grill-with-docs`（拷问+实时文档）为单文件技能，核心改动：**默认只聊天不落盘，用户显式要求时才写文件**。

## 架构

单文件自包含技能（方案 A），无子 agent、无多文件编排：

- **`SKILL.md`** — 技能主体，包含拷问循环纪律、ADR 候选门槛、按需落盘规则、会话生命周期、边界与错误处理、验收标准
- **`references/CONTEXT-FORMAT.md`** — 术语表格式规范（单/多 context 结构、推断逻辑）
- **`references/ADR-FORMAT.md`** — ADR 格式规范（模板、编号规则、三条件门槛）
- **`scripts/install.sh`** — 幂等双端 symlink 安装/卸载
- **`scripts/check-acceptance-anchors.sh`** — acceptance 行号锚点自动校验
- **`docs/deploy.md`** — 双端安装文档（含 Windows 说明 + 故障排除）
- **`README.md`** — 介绍与快速开始

双端元数据：Claude Code 读 frontmatter `name`/`description`/`platforms`；Hermes 读 `metadata.hermes.{tags, category}`。不再需要 OpenAI 兼容 agent 配置文件。

## 关键铁律（修改时必须遵守）

1. **显式触发**：技能只能通过 `/deep-discussion` 或用户明确要求唤起，禁止自动/隐式触发
2. **不自动创建文件**：除非用户明确要求，绝不自动创建任何文件
3. **一次一问**：每轮只抛一个问题，附推荐答案，沿决策树逐枝推进
4. **确认门禁**：每次写入前展示摘要/diff，用户确认后才写
5. **保存契约**：CONTEXT.md 按术语名合并更新（不整覆盖）；ADR 按标题 slug 去重（更新而非新建）；重复保存幂等

## 修改注意事项

- 全程中文：技能指令、提问、产出文档均为中文
- `SKILL.md` 行号在验收文档中有精确引用，修改后需同步更新 `docs/superpowers/plans/2026-07-29-deep-discussion-acceptance.md` 中的行号证据
- ADR 候选三条件（难回退 + 外人会疑惑 + 真实取舍）在 `SKILL.md` 和 `references/ADR-FORMAT.md` 中均有表述，修改一处需同步另一处
- DEFERRED 两项（CR-006 多 context 规则、CR-009 cwd 隔离）标注为 v1 后续增强，不阻塞当前版本

## 产出文件位置

技能运行时写入用户 cwd（非本仓库）：
- `CONTEXT.md`（根目录）— 术语表
- `docs/adr/NNNN-slug.md` — 架构决策记录
- `docs/grill-summary.md` — 可选纪要（默认关闭）

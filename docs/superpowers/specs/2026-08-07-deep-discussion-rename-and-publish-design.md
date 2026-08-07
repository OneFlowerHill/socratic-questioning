# deep-discussion 改名与发布设计（spec）

**日期**：2026-08-07
**前身**：`yy-grill-me`（拷问式访谈技能，合并原版 grill-me 与 grill-with-docs）
**决策摘要**：彻底改名 `deep-discussion` + 双端支持（Claude Code / Hermes）+ symlink 安装脚本化 + 发布到 GitHub 私有仓库

---

## 1. 背景与目标

`yy-grill-me` 是一个单文件自包含的 Claude Code 技能，用「拷问式访谈」打磨计划或设计。当前仅支持 Claude Code，安装方式为手动 symlink，且尚未纳入 git 版本控制。

本次改造目标：

1. **改名**：`yy-grill-me` → `deep-discussion`，彻底改名（目录、SKILL name、触发命令、仓库名、所有引用）。
2. **发布**：在用户的 GitHub 创建**私有**仓库 `deep-discussion` 并推送，不声明 LICENSE（与 goal-manager 一致）。
3. **双端**：技能同时支持 Claude Code 与 Hermes 智能体，装到 Hermes 的 `software-development` 分类。
4. **安装**：用 symlink 安装，参考 `goal-manager`，并升级为幂等 `install.sh` 脚本。

**成功标准**：全仓零 `yy-grill-me` 残留；SKILL.md frontmatter 含双端元数据；双端 symlink 安装可用；GitHub 私有仓库已建并推送；acceptance 行号证据经 `check-acceptance-anchors.sh` 锚点校验通过（锚点不匹配则 FAIL）。

---

## 2. 范围

### 2.1 在范围内

- 目录 `yy-grill-me/` → `deep-discussion/` 改名
- SKILL.md frontmatter 加 `platforms` + `metadata.hermes.{tags, category}`，正文引用改名
- 删除 `agents/openai.yaml` 及 `agents/` 目录
- 历史文档（specs/plans/reviews）文件名、目录名、内部引用、acceptance 行号证据**同步彻底改名**
- 新增 `scripts/install.sh`、`scripts/check-acceptance-anchors.sh`、`docs/deploy.md`、`README.md`
- `git init` + GitHub 私有仓库 `deep-discussion` 创建与推送

### 2.2 不在范围（YAGNI / 已有约定）

- 不修改技能的拷问纪律、ADR 门槛、保存契约等**语义行为**（只改名与加元数据）
- 不实现 DEFERRED 两项（CR-006 多 context 规则、CR-009 cwd 隔离），保持 v1 标注
- 不加 LICENSE（私有仓库，与 goal-manager 一致）
- 不做个人路径脱敏（私有仓库不外泄）
- 不引入 cron 注册（deep-discussion 无定时需求；goal-manager 的 cron 属部署层，本技能不涉及）
- 不写 uninstall 独立脚本（合并进 install.sh 的 `--uninstall` 参数）

---

## 3. 架构

单文件自包含技能（沿用方案 A 架构），无子 agent、无多文件编排。改名后结构：

```
deep-discussion/
├── SKILL.md                  # 核心：frontmatter 双端元数据 + 拷问纪律 + 落盘规则
├── CLAUDE.md                 # 项目开发指引
├── README.md                 # 新增：介绍 + 安装指引
├── .gitignore                # 沿用
├── references/
│   ├── CONTEXT-FORMAT.md     # 术语表格式规范
│   └── ADR-FORMAT.md         # ADR 格式规范
├── scripts/
│   ├── install.sh                     # 新增：幂等双端 symlink 安装/卸载
│   └── check-acceptance-anchors.sh    # 新增：acceptance 行号锚点自动校验
├── docs/
│   ├── deploy.md             # 新增：双端安装文档
│   └── superpowers/
│       ├── plans/            # 改名：*-deep-discussion*.md
│       ├── specs/            # 改名历史 spec + 本次新 spec
│       └── reviews/
│           └── deep-discussion/   # 目录改名
└── (删除 agents/ 目录)
```

**双端运行模型**：

```
        Claude Code  /  Hermes（双端）
                  │ 调用
                  ▼
         deep-discussion Skill（同一份源）
                  │ symlink 暴露
        ┌─────────┴─────────┐
        ▼                   ▼
 ~/.claude/skills/    ~/.hermes/skills/
   deep-discussion      software-development/
                           deep-discussion
```

一次修改源目录，双端通过 symlink 同步可见。

---

## 4. 详细改动

### 4.1 SKILL.md

**frontmatter**（4 行 → 9 行，+5）：

```yaml
---
name: deep-discussion
description: 用「拷问式访谈」打磨计划或设计。仅允许显式触发（斜杠命令 /deep-discussion，或用户明确说「开始拷问 / grill 我」），禁止在对话中自动 / 隐式唤起本技能。
platforms: [macos, linux, windows]
metadata:
  hermes:
    tags: [discussion, design, adr, planning, interview]
    category: software-development
---
```

- `name: yy-grill-me` → `deep-discussion`
- 新增 `platforms: [macos, linux, windows]`（1 行）。**Hermes 惯例**（CR-002 方案B）：airtable/goal-manager 均声明 windows，`platforms` 表「技能内容/逻辑支持平台」而非「安装脚本平台」；install.sh 为 bash/ln-s（Unix），Windows 安装在 `docs/deploy.md` 补手动说明（见 4.5）。
- 新增 `metadata.hermes.{tags, category}`（3 行：metadata / hermes / tags / category 共 4 行结构，相对原 frontmatter 净增 5 行）
- description 内 `/yy-grill-me` → `/deep-discussion`

**正文**：6 处 `yy-grill-me` → `deep-discussion`，命令 `/yy-grill-me` → `/deep-discussion`。同位文字替换，不增删行；但因 frontmatter +5 行，正文整体下移 5 行。**语义、铁律、验收标准一字不改**。

### 4.2 CLAUDE.md

3 处 `yy-grill-me` 引用 → `deep-discussion`（含项目概述、产出文件位置说明）。frontmatter 行号引用说明同步：原"SKILL.md 行号在验收文档中有精确引用"依然成立，行号基准变为改名后行号。

### 4.3 删除 agents/

删除 `agents/openai.yaml` 及 `agents/` 目录。

**前提确认（CR-003）**：已验证 goal-manager 无 `agents/` 目录、且已装到 `~/.hermes/skills/productivity/`（symlink），证明 Claude Code 与 Hermes 均通过 SKILL.md frontmatter 的 `metadata.hermes` 声明技能，**不依赖 `agents/openai.yaml` 读取隐式调用策略**。原 `allow_implicit_invocation: false` 的语义在双端由三重保障覆盖：frontmatter `metadata.hermes` + description 首句「仅允许显式触发」+ SKILL.md 正文铁律。`display_name` 由 frontmatter `name` + `description` 覆盖。

**拒绝项**：不在 frontmatter 增非标准 `implicit_invocation: false` 字段——Hermes 是否识别此字段未知（airtable/goal-manager frontmatter 均无此字段），加它可能无效甚至被解析器告警；且与「删 openai.yaml 改用 frontmatter」的既定决策相悖。未来若引入第三 OpenAI 兼容平台需机器级防护，届时再重建 `agents/` 结构。

### 4.4 历史文档彻底重命名（方案 C 核心）

**文件与目录改名**：

| 原路径 | 新路径 |
|---|---|
| `docs/superpowers/reviews/yy-grill-me/` | `docs/superpowers/reviews/deep-discussion/` |
| `docs/superpowers/plans/2026-07-29-yy-grill-me.md` | `docs/superpowers/plans/2026-07-29-deep-discussion.md` |
| `docs/superpowers/plans/2026-07-29-yy-grill-me-acceptance.md` | `docs/superpowers/plans/2026-07-29-deep-discussion-acceptance.md` |
| `docs/superpowers/specs/2026-07-29-yy-grill-me-design.md` | `docs/superpowers/specs/2026-07-29-deep-discussion-design.md` |

**内容替换**（10 个文件，全仓 grep 已确认）：`yy-grill-me` → `deep-discussion`、`/yy-grill-me` → `/deep-discussion`、技能根路径 `/skills/yy-grill-me/` → `/skills/deep-discussion/`。

涉及文件与替换次数（grep 统计）：

| 文件 | yy-grill-me 出现次数 |
|---|---|
| SKILL.md | 7 |
| CLAUDE.md | 3 |
| docs/.../plans/2026-07-29-deep-discussion-acceptance.md | 5 |
| docs/.../plans/2026-07-29-deep-discussion.md | 68 |
| docs/.../specs/2026-07-29-deep-discussion-design.md | 8 |
| docs/.../reviews/deep-discussion/index.md | 4 |
| docs/.../reviews/deep-discussion/2026-07-29-review-001/consolidated-review.md | 18 |
| docs/.../reviews/deep-discussion/2026-07-29-review-001/system-review.md | 5 |
| docs/.../reviews/deep-discussion/2026-07-29-review-001/product-review.md | 8 |
| docs/.../reviews/deep-discussion/2026-07-29-review-001/test-review.md | 4 |

**行号同步**（acceptance.md 最关键）：frontmatter +5 行导致 SKILL.md 正文整体下移 5 行，acceptance.md 内所有行号证据 +5。映射表：

| acceptance 原行号引用 | 改名后行号 | 对应内容 |
|---|---|---|
| 22 / 23 / 24 | 27 / 28 / 29 | 拷问纪律三判据（一次一问/带推荐答案/逐枝推进） |
| 28 | 33 | 铁律（绝不自动创建文件） |
| 32-34 | 37-39 | 可验证判据 |
| 36-50 | 41-55 | ADR 候选门槛（敲定 + 三条件） |
| 54-58 | 59-63 | 按需落盘 |
| 61-70 | 66-75 | 保存契约（合并/去重/幂等） |
| 71-79 | 76-84 | 触发边界 + 确认门禁 |
| 81-83 | 86-88 | 恢复 |
| 87-91 | 92-96 | 中途保存 |
| 93-96 | 98-101 | 终止/放弃 |
| 98-102 | 103-107 | 清空草稿/重启 |
| 107 | 112 | CR-006 DEFERRED |
| 109 | 114 | CR-009 DEFERRED |
| 111-119 | 116-124 | 验收标准原文 |
| 56 / 57 | 61 / 62 | references 引用闭合 |

**锚点校验（CR-006/007）**：行号映射表每个行号在 acceptance.md 旁附「内容锚点」——对应 SKILL.md 该行行首固定长度文本片段（如「第 33 行 #绝不自动创建」）。核对流程：

1. **自动化锚点校验**：运行 `bash scripts/check-acceptance-anchors.sh`，解析 acceptance.md 所有锚点，按行号定位 SKILL.md 实际行，比对行首是否匹配锚点前缀。锚点不匹配 → 产出差异清单（预期行号/实际匹配行/差异/内容摘要），退出码 1（FAIL），验收不进入人工核对。
2. **差异清单 + 独立复核**（CR-007）：锚点脚本先产出差异清单，再据清单逐条修正 acceptance 行号；修正后 acceptance.md 的 git diff 纳入验收证据，供独立复核（验证与修正分离，避免错误被「修正」而非「发现」）。
3. 锚点全部通过后，人工核对语义对应（如「拷问纪律三判据」对应行确实含三判据）。

此机制消除「+5 行」单一假设的脆弱性：即使 frontmatter 实际净增非 5 行，锚点脚本也能机械化定位实际偏移，不依赖映射表臆测。

### 4.5 安装机制

**`scripts/install.sh`**（幂等双端 symlink）：

```bash
#!/usr/bin/env bash
set -euo pipefail
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME="deep-discussion"
CLAUDE_LINK="$HOME/.claude/skills/$NAME"
HERMES_LINK="$HOME/.hermes/skills/software-development/$NAME"

# 内容完整性预检查（CR-005）：建链前验证源目录含改名后技能
verify_source() {
  local skill="$SRC/SKILL.md"
  [ -f "$skill" ] || { echo "源缺 SKILL.md: $skill（内容未完成改名？）" >&2; exit 1; }
  local got; got="$(awk -F': ' '/^name:/{print $2; exit}' "$skill")"
  [ "$got" = "$NAME" ] || { echo "SKILL.md name='$got' 与脚本 NAME='$NAME' 不一致（内容未完成改名？）" >&2; exit 1; }
}

link() {  # link <target> <link_path>
  local target="$1" link_path="$2"
  if [ -L "$link_path" ] && [ "$(readlink "$link_path")" = "$target" ]; then
    echo "已存在且指向同源，跳过: $link_path"; return 0
  fi
  if [ -e "$link_path" ] || [ -L "$link_path" ]; then
    echo "目标已存在且非同源 symlink，不覆盖: $link_path" >&2; return 1
  fi
  mkdir -p "$(dirname "$link_path")"
  ln -s "$target" "$link_path" && echo "已安装: $link_path -> $target"
}

if [ "${1:-}" = "--uninstall" ]; then
  rm -f "$CLAUDE_LINK" "$HERMES_LINK"
  echo "已卸载: $CLAUDE_LINK, $HERMES_LINK"; exit 0
fi

verify_source

# 两次 link 尽量完成，部分失败时提示恢复（CR-004）
claude_ok=0; hermes_ok=0
link "$SRC" "$CLAUDE_LINK" && claude_ok=1 || true
link "$SRC" "$HERMES_LINK" && hermes_ok=1 || true
if [ "$claude_ok$hermes_ok" != "11" ]; then
  echo "部分安装：Claude=$([ $claude_ok -eq 1 ] && echo 已装 || echo 未装)、Hermes=$([ $hermes_ok -eq 1 ] && echo 已装 || echo 未装)。可执行 'bash scripts/install.sh --uninstall' 清理后重试。" >&2
  exit 1
fi
echo "双端安装完成: $NAME"
```

- 源路径自动解析（脚本在 `scripts/`，源在上一级），无硬编码个人路径
- Claude Code：`~/.claude/skills/deep-discussion`
- Hermes：`~/.hermes/skills/software-development/deep-discussion`（自动 `mkdir -p` 分类目录）
- 幂等：同源跳过、异源报错不覆盖
- `--uninstall`：移除两处
- **内容完整性预检查**（CR-005）：建链前 `verify_source` 验证 `$SRC/SKILL.md` 存在且 frontmatter `name` == 脚本 `NAME`，防止内容未完成改名时建链
- **部分失败恢复提示**（CR-004）：两次 link 尽量完成，部分失败时输出「Claude 已装/Hermes 未装」+ 恢复指引（`--uninstall` 清理重试），非 0 退出

**`docs/deploy.md`**：

- 手动 `ln -s` 命令（goal-manager 风格，macOS/Linux）+ install.sh 用法
- **Windows 安装说明**（CR-002 方案B）：`platforms` 含 windows（Hermes 惯例，表技能内容平台），但 install.sh 为 bash/ln-s（Unix）；Windows 用户手动安装——PowerShell `New-Item -ItemType SymbolicLink -Path $env:USERPROFILE\.claude\skills\deep-discussion -Target <repo>` 或直接复制仓库目录到 skills 路径
- 验证方式：`/deep-discussion` 可触发、`hermes skills` 列出
- **故障排除章节**（CR-004）：部分安装不一致状态的识别与恢复（`--uninstall` 清理重试）

**`README.md`**：技能定位 + 快速开始（指向 deploy.md）+ 双端运行时说明。**不含字面 `yy-grill-me`**（CR-001 方案2）——旧名溯源由首次 commit message「前身为 yy-grill-me」承载（commit message 在 `.git/`，被 AC1 grep 排除，不违反零残留），使 AC1 grep 零残留自洽。

**`scripts/check-acceptance-anchors.sh`**（CR-006/007，新增）：acceptance.md 行号证据的锚点自动校验脚本。设计：

- 解析 acceptance.md 中每个行号引用旁的内容锚点（格式：`第 NN 行 #行首文本片段`）
- 按行号定位 SKILL.md 实际行，比对行首是否匹配锚点前缀
- 不匹配 → 输出差异清单（预期行号/实际匹配行/差异/内容摘要），退出码 1
- 全匹配 → 退出码 0
- 作用：消除「+5 行」单一假设脆弱性，机械化校验，验证与修正分离

### 4.6 GitHub 推送流程

```bash
# 1. 目录改名（在父目录 skills/ 下）
mv /Users/yuezhenhua/yonyou/projects/0__AI/skills/yy-grill-me \
   /Users/yuezhenhua/yonyou/projects/0__AI/skills/deep-discussion

# 2. 初始化 git
cd /Users/yuezhenhua/yonyou/projects/0__AI/skills/deep-discussion
git init
git branch -M main

# 3. .gitignore 已就位（.DS_Store / .workbuddy/ / .superpowers/sdd/）
git add .
git commit -m "feat: 初始化 deep-discussion 技能（前身为 yy-grill-me，改名+双端支持+发布）"

# 4. 推送前检查同名仓库不存在（ID-001）
gh repo view deep-discussion 2>/dev/null && { echo "仓库已存在，中止" >&2; exit 1; } || true

# 5. 创建私有仓库并推送
gh repo create deep-discussion --private --source=. --remote=origin --push
```

提交信息遵循用户级规范（中文、`type[scope]: <desc>`）。`.workbuddy/`、`.superpowers/sdd/`、`.DS_Store` 被忽略，不推送。

---

## 5. 错误处理

| 场景 | 处理 |
|---|---|
| symlink 目标已存在且异源 | install.sh 报错不覆盖，提示用户手动处理 |
| `~/.hermes/skills/software-development/` 不存在 | install.sh `mkdir -p` 自动创建 |
| `gh` 未登录或无权限 | 报错退出，提示用户 `gh auth login` |
| 目录改名时有进程占用旧路径 | 提示关闭相关进程后重试 |
| 源目录内容不完整 / frontmatter name 不匹配 | install.sh `verify_source` 非零退出，提示内容未完成改名（CR-005） |
| 部分安装不一致（一端成功一端失败） | install.sh 输出部分安装状态 + 恢复指引，`--uninstall` 清理重试（CR-004） |
| acceptance 锚点比对不一致 | check-acceptance-anchors.sh FAIL，产出差异清单，修正后重跑（CR-006/007） |
| 历史文档改名遗漏 | grep 全仓零残留校验兜底 |

---

## 6. 验收

1. **零功能性残留**：`grep -rn "yy-grill-me" .`（排除 `.git/`、`.workbuddy/`、`.superpowers/sdd/`、`docs/superpowers/specs/2026-08-07-deep-discussion-rename-and-publish-design.md`）→ 零输出。本设计 spec 文件描述改名过程含旧名属描述性引用（非功能性残留），故排除；commit message 在 `.git/` 内亦排除。历史文档（plans/reviews/旧 specs）改名后须零残留，不在排除列表
2. **行号锚点校验**（CR-006/007）：运行 `bash scripts/check-acceptance-anchors.sh`，所有行号引用的内容锚点与 SKILL.md 实际行匹配 → 退出码 0；锚点不匹配 FAIL 并产出差异清单，修正后 acceptance.md 的 git diff 纳入验收证据供独立复核
3. **frontmatter 合法**：SKILL.md frontmatter 含 `name: deep-discussion` / `platforms` / `metadata.hermes.category: software-development`；无 `agents/` 目录
4. **双端安装**：`bash scripts/install.sh` 后，`~/.claude/skills/deep-discussion` 与 `~/.hermes/skills/software-development/deep-discussion` 均为指向源的有效 symlink
5. **技能触发**（CR-008）：
   - 5a Claude Code：`/deep-discussion` 可启动拷问流程
   - 5b Hermes：`hermes skills` 列出 deep-discussion（实际触发为部署后验证，超 spec 范围，显式记录此限制）
6. **仓库**：`gh repo view deep-discussion` 确认私有、代码已推、`.workbuddy/` 与 `.superpowers/sdd/` 未泄露

---

## 7. 风险与注意

- **行号同步易错**（CR-006/007 缓解）：acceptance.md 行号证据是方案 C 最大成本；已引入 `check-acceptance-anchors.sh` 锚点自动校验 + 差异清单 + diff 纳入验收证据，消除「+5 行」单一假设脆弱性，避免凭映射表臆测。
- **frontmatter 行数计算**：净增 5 行的映射基于 goal-manager frontmatter 结构，仅作初估；锚点校验脚本（CR-006）不依赖 +5 假设，以 SKILL.md 实际行机械化比对，若净增非 5 由锚点差异清单自动定位偏移。
- **改名时序**：先改 SKILL.md/正文 → 再改 acceptance 行号（基于改名后 SKILL.md 实际行号），避免"边改边算"错位。
- **git init 时机**：目录改名后、内容改完后再 `git init`，确保首次提交即干净状态（不含旧名残留）。
- **旧 symlink 清理**：`~/.claude/skills/` 下无 yy-grill-me 旧 symlink（已确认），无需清理；若将来存在则手动 rm。

---

## 8. 非目标

- 不改技能语义行为（拷问纪律、ADR 门槛、保存契约、会话生命周期均不动）
- 不实现 DEFERRED 两项（CR-006 / CR-009）
- 不加 LICENSE、不做路径脱敏、不引入 cron
- 不写独立 uninstall 脚本（合并进 install.sh）
- Hermes 端实际触发验证不在本次 spec 范围（CR-008：部署后验证；spec 只验安装到位 + 列出）

---

## 9. 后续

本 spec 经用户审查通过后，转入 `writing-plans` 技能生成实现计划。实现计划按以下顺序执行：目录改名 → SKILL.md/CLAUDE.md 改名 + frontmatter 双端元数据 → 删除 agents/ → 历史文档改名 + 内容替换 → acceptance 行号锚点表标注 + `check-acceptance-anchors.sh` 编写 → 运行锚点脚本校验并据差异清单修正行号（diff 纳入验收证据）→ 新增 install.sh（含 verify_source + 部分失败恢复）/deploy.md（含 Windows 说明 + 故障排除）/README.md → git init + 仓库创建推送 → 验收。

# deep-discussion 改名与发布实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 `yy-grill-me` 彻底改名为 `deep-discussion`，加双端（Claude Code / Hermes）元数据，symlink 脚本化安装，发布到 GitHub 私有仓库。

**Architecture:** 单文件自包含技能（沿用方案 A）。SKILL.md frontmatter 加 `platforms` + `metadata.hermes`，删除 `agents/openai.yaml`，双端靠同一份源 + symlink 暴露。改名走方案 C（目录/文件名/内容引用/acceptance 行号全部同步）。安装靠幂等 `install.sh`，行号证据靠 `check-acceptance-anchors.sh` 锚点校验。

**Tech Stack:** Bash（install.sh / 锚点脚本）、Markdown、gh CLI、git。

## Global Constraints

本计划所有 task 隐含遵守以下约束（源自 spec，逐条抄录）：

- **全程中文**：技能指令、提问、产出文档、commit message 均为中文。
- **Git 提交格式**：`type[optional scope]: <description>`（用户级 CLAUDE.md 铁律）。
- **改名彻底**：目录名、SKILL `name`、触发命令 `/deep-discussion`、仓库名、所有功能性引用全部改名。
- **技能语义行为一字不改**：拷问纪律、ADR 门槛、保存契约、会话生命周期、边界与错误处理、验收标准——只改名与加元数据，不动语义。
- **`platforms: [macos, linux, windows]`**（Hermes 惯例，表技能内容/逻辑支持平台，非安装脚本平台）。install.sh 为 bash/ln-s（Unix），Windows 安装在 `docs/deploy.md` 给手动说明。
- **不加 LICENSE、不做路径脱敏、不引入 cron、不写独立 uninstall 脚本**（合并进 install.sh `--uninstall`）。
- **DEFERRED 两项**（CR-006 多 context 规则、CR-009 cwd 隔离）保持 v1 标注不动。
- **git init 时机**：目录改名 + 内容改完后才 `git init`，确保首次提交即干净态（Task 1-11 无 commit，Task 12 做唯一首次 commit）。

### AC1 零功能性残留——排除列表（计划层精确化）

`grep -rn "yy-grill-me" .` 须零输出，**排除以下路径**（spec AC1 原仅排除前 4 项，计划层补入后 3 项——理由见下）：

1. `.git/`（commit message 含旧名「前身为 yy-grill-me」做溯源）
2. `.workbuddy/`、`.superpowers/sdd/`（工具目录）
3. `docs/superpowers/specs/2026-08-07-deep-discussion-rename-and-publish-design.md`（本设计 spec，spec 已排除）
4. `docs/superpowers/plans/2026-08-07-deep-discussion-rename-and-publish.md`（**本实现计划**，计划层补入）
5. `docs/superpowers/reviews/deep-discussion-rename-and-publish-design/`（**本设计审核目录**，计划层补入）
6. `docs/superpowers/specs/2026-07-29-deep-discussion-design.md` 与 `docs/superpowers/plans/2026-07-29-deep-discussion*.md` 与 `docs/superpowers/reviews/deep-discussion/`（这些是改名后的历史文档——排除不是因为有旧名，而是它们改名+内容替换后**应为零残留**，若仍有旧名则不算排除、算残留）

**精确化理由**：第 4、5 项与 spec 已排除的第 3 项同质——都是「描述本次改名过程」的文档，旧名在其中是描述性引用（指代被改名的对象，如审核 CR-001 标题「README.md 旧名引用」里的「旧名」即 yy-grill-me），替换掉会让文档失去指代对象、不可读。spec AC1 原只排除了本设计 spec 文件，未覆盖本实现计划与本设计审核目录，导致 grep 零残留与「描述改名过程的文档必然含旧名」自洽性破缺。计划层把排除口径扩到全部「描述本次改名过程的文档」，使 AC1 自洽。历史文档（第 6 项）改名+内容替换后须零残留，不在此排除口径内。

---

## File Structure

改名后的目标结构：

```
deep-discussion/
├── SKILL.md                  # 改：frontmatter 加双端元数据 + 正文改名
├── CLAUDE.md                 # 改：3 处旧名 + 删 agents/ 引用 + 补新文件说明
├── README.md                 # 新增：介绍 + 安装指引（不含字面旧名）
├── .gitignore                # 不动
├── references/
│   ├── CONTEXT-FORMAT.md     # 不动
│   └── ADR-FORMAT.md         # 不动
├── scripts/
│   ├── install.sh                     # 新增：幂等双端 symlink 安装/卸载
│   └── check-acceptance-anchors.sh    # 新增：acceptance 行号锚点自动校验
├── docs/
│   ├── deploy.md             # 新增：双端安装文档 + Windows 说明 + 故障排除
│   └── superpowers/
│       ├── plans/
│       │   ├── 2026-07-29-deep-discussion.md                    # 改名（原 yy-grill-me）
│       │   ├── 2026-07-29-deep-discussion-acceptance.md        # 改名 + 行号锚点 + 行号修正
│       │   └── 2026-08-07-deep-discussion-rename-and-publish.md  # 本计划（新增，随目录迁移）
│       ├── specs/
│       │   ├── 2026-07-29-deep-discussion-design.md             # 改名（原 yy-grill-me）
│       │   └── 2026-08-07-deep-discussion-rename-and-publish-design.md  # 本设计 spec
│       └── reviews/
│           ├── deep-discussion/            # 改名（原 yy-grill-me/）
│           └── deep-discussion-rename-and-publish-design/  # 本设计审核（不改名）
└── (agents/ 目录删除)
```

---

## Task 1: 目录改名

**Files:**
- Modify: 父目录 `/Users/yuezhenhua/yonyou/projects/0__AI/skills/` 下 `yy-grill-me/` → `deep-discussion/`

**Interfaces:**
- Consumes: 无
- Produces: 新工作目录 `/Users/yuezhenhua/yonyou/projects/0__AI/skills/deep-discussion/`（后续所有 task 在此目录下操作）

- [ ] **Step 1: 确认当前不在旧目录内被进程占用**

当前 shell 工作目录是旧路径 `.../skills/yy-grill-me`。`mv` 一个含 cwd 的目录会失败或导致 cwd 失效。先 cd 到父目录。

Run:
```bash
cd /Users/yuezhenhua/yonyou/projects/0__AI/skills
```

- [ ] **Step 2: 改名**

Run:
```bash
mv yy-grill-me deep-discussion
```

- [ ] **Step 3: 进入新目录**

Run:
```bash
cd deep-discussion
```

- [ ] **Step 4: 验收**

Run:
```bash
test -d . && test -f SKILL.md && echo "PASS: 新目录就位" || echo "FAIL"
```
Expected: `PASS: 新目录就位`

- [ ] **Step 5: 不提交**

本 task 及 Task 2-11 均**不** `git commit`（spec 4.6：内容改完后才 `git init`，首次提交即干净态）。提交在 Task 12 统一做。

---

## Task 2: SKILL.md 改名 + frontmatter 双端元数据

**Files:**
- Modify: `SKILL.md`（frontmatter 4 行 → 9 行，净增 5 行；正文 7 处 `yy-grill-me` → `deep-discussion`）

**Interfaces:**
- Consumes: Task 1（新目录就位）
- Produces: frontmatter 含 `name: deep-discussion` / `platforms` / `metadata.hermes.{tags, category}`；正文行号整体下移 5 行（Task 7 行号同步的基准）

- [ ] **Step 1: 替换 frontmatter（第 1-4 行 → 9 行）**

用 Edit 工具，old_string 为当前 frontmatter 全文：

```
---
name: yy-grill-me
description: 用「拷问式访谈」打磨计划或设计。仅允许显式触发（斜杠命令 /yy-grill-me，或用户明确说「开始拷问 / grill 我」），禁止在对话中自动 / 隐式唤起本技能。
---
```

new_string：

```
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

- [ ] **Step 2: 替换正文 6 处（标题 + 触发命令等）**

用 Edit 工具 `replace_all: true`，old_string `yy-grill-me`，new_string `deep-discussion`。

注意：`replace_all` 会命中正文剩余 6 处（第6行标题 `# yy-grill-me`、第16行两处 `/yy-grill-me`、第109行 `/yy-grill-me`、第114行 `/yy-grill-me`、第121行 `/yy-grill-me`）；frontmatter 的 `name:` 已在 Step 1 改过，不会重复命中。正文中的「原版 `grill-me`」（不含 `yy-` 前缀）**不被命中、不应改动**。

- [ ] **Step 3: 验收——frontmatter 合法**

Run:
```bash
head -9 SKILL.md
```
Expected: 第2行 `name: deep-discussion`，第4行 `platforms: [macos, linux, windows]`，第5-8行 `metadata:` / `  hermes:` / `    tags: [...]` / `    category: software-development`。

- [ ] **Step 4: 验收——SKILL.md 零旧名**

Run:
```bash
grep -c "yy-grill-me" SKILL.md
```
Expected: `0`

- [ ] **Step 5: 验收——语义未动**

Run:
```bash
grep -c "拷问" SKILL.md && grep -c "确认门禁" SKILL.md && grep -c "保存契约" SKILL.md
```
Expected: 三个数都 ≥ 1（拷问纪律 / 确认门禁 / 保存契约三处语义仍在）。

---

## Task 3: CLAUDE.md 改名 + 删 agents/ 引用 + 补新文件说明

**Files:**
- Modify: `CLAUDE.md`（3 处旧名 + 第16行 `agents/openai.yaml` 引用改写 + 架构列表补新文件）

**Interfaces:**
- Consumes: Task 1
- Produces: CLAUDE.md 与改名后结构一致，无悬空引用

- [ ] **Step 1: 改第7行项目概述**

Edit，old_string `` `yy-grill-me` 是一个 Claude Code 技能（skill） ``，new_string `` `deep-discussion` 是一个 Claude Code 技能（skill） ``。

- [ ] **Step 2: 改第20行触发命令**

Edit，old_string `技能只能通过 `/yy-grill-me` 或用户明确要求唤起`，new_string `技能只能通过 `/deep-discussion` 或用户明确要求唤起`。

- [ ] **Step 3: 改第29行 acceptance 引用路径**

Edit，old_string `docs/superpowers/plans/2026-07-29-yy-grill-me-acceptance.md`，new_string `docs/superpowers/plans/2026-07-29-deep-discussion-acceptance.md`。

- [ ] **Step 4: 改架构列表——删 agents/ 引用，补新文件**

Edit，old_string：
```
- **`agents/openai.yaml`** — OpenAI 兼容 agent 配置（`allow_implicit_invocation: false`）
```

new_string：
```
- **`scripts/install.sh`** — 幂等双端 symlink 安装/卸载
- **`scripts/check-acceptance-anchors.sh`** — acceptance 行号锚点自动校验
- **`docs/deploy.md`** — 双端安装文档（含 Windows 说明 + 故障排除）
- **`README.md`** — 介绍与快速开始

双端元数据：Claude Code 读 frontmatter `name`/`description`/`platforms`；Hermes 读 `metadata.hermes.{tags, category}`。不再需要 `agents/openai.yaml`。
```

- [ ] **Step 5: 验收**

Run:
```bash
grep -c "yy-grill-me" CLAUDE.md && grep -c "agents/openai" CLAUDE.md
```
Expected: `0` 与 `0`（旧名零残留、agents/ 引用已删）。

Run:
```bash
grep -c "deep-discussion" CLAUDE.md
```
Expected: ≥ 3。

---

## Task 4: 删除 agents/ 目录

**Files:**
- Delete: `agents/`（含 `agents/openai.yaml`）

**Interfaces:**
- Consumes: Task 3（CLAUDE.md 已无 `agents/openai.yaml` 引用，删后无悬空引用）
- Produces: 无 `agents/` 目录

- [ ] **Step 1: 删除**

Run:
```bash
rm -rf agents
```

- [ ] **Step 2: 验收**

Run:
```bash
test ! -e agents && echo "PASS: agents/ 已删" || echo "FAIL"
```
Expected: `PASS: agents/ 已删`

- [ ] **Step 3: 全仓无 agents/ 残留引用**

Run:
```bash
grep -rn "agents/openai" . 2>/dev/null | grep -vE "^\./(\.git|\.workbuddy|\.superpowers/sdd)/" | grep -v "docs/superpowers/"
```
Expected: 无输出（`docs/superpowers/` 下的历史/审核文档可能描述「删除 agents/」这件事属描述性引用，不在此校验；当前文件层无 `agents/openai` 引用即可）。

---

## Task 5: 历史文档目录与文件改名

**Files:**
- Modify: 以下路径改名（`mv`）

| 原路径 | 新路径 |
|---|---|
| `docs/superpowers/reviews/yy-grill-me/` | `docs/superpowers/reviews/deep-discussion/` |
| `docs/superpowers/plans/2026-07-29-yy-grill-me.md` | `docs/superpowers/plans/2026-07-29-deep-discussion.md` |
| `docs/superpowers/plans/2026-07-29-yy-grill-me-acceptance.md` | `docs/superpowers/plans/2026-07-29-deep-discussion-acceptance.md` |
| `docs/superpowers/specs/2026-07-29-yy-grill-me-design.md` | `docs/superpowers/specs/2026-07-29-deep-discussion-design.md` |

**Interfaces:**
- Consumes: Task 1
- Produces: 历史文档新路径（Task 6 在新路径上做内容替换）

- [ ] **Step 1: reviews 目录改名**

Run:
```bash
mv docs/superpowers/reviews/yy-grill-me docs/superpowers/reviews/deep-discussion
```

- [ ] **Step 2: plans 两个文件改名**

Run:
```bash
mv docs/superpowers/plans/2026-07-29-yy-grill-me.md docs/superpowers/plans/2026-07-29-deep-discussion.md
mv docs/superpowers/plans/2026-07-29-yy-grill-me-acceptance.md docs/superpowers/plans/2026-07-29-deep-discussion-acceptance.md
```

- [ ] **Step 3: 旧 spec 改名**

Run:
```bash
mv docs/superpowers/specs/2026-07-29-yy-grill-me-design.md docs/superpowers/specs/2026-07-29-deep-discussion-design.md
```

- [ ] **Step 4: 验收——旧路径全消失**

Run:
```bash
find docs/superpowers -name "*yy-grill-me*"
```
Expected: 无输出。

- [ ] **Step 5: 验收——新路径全就位**

Run:
```bash
test -d docs/superpowers/reviews/deep-discussion \
  && test -f docs/superpowers/plans/2026-07-29-deep-discussion.md \
  && test -f docs/superpowers/plans/2026-07-29-deep-discussion-acceptance.md \
  && test -f docs/superpowers/specs/2026-07-29-deep-discussion-design.md \
  && echo "PASS" || echo "FAIL"
```
Expected: `PASS`

---

## Task 6: 历史文档内容替换（功能性引用）

**Files:**
- Modify（在新路径上替换 `yy-grill-me` → `deep-discussion`，含技能根路径 `/skills/yy-grill-me/` → `/skills/deep-discussion/`）：
  - `docs/superpowers/plans/2026-07-29-deep-discussion.md`（68 处）
  - `docs/superpowers/plans/2026-07-29-deep-discussion-acceptance.md`（5 处——仅功能性引用，行号证据的修正留给 Task 7）
  - `docs/superpowers/specs/2026-07-29-deep-discussion-design.md`（8 处）
  - `docs/superpowers/reviews/deep-discussion/index.md`（4 处）
  - `docs/superpowers/reviews/deep-discussion/2026-07-29-review-001/consolidated-review.md`（18 处）
  - `docs/superpowers/reviews/deep-discussion/2026-07-29-review-001/product-review.md`（8 处）
  - `docs/superpowers/reviews/deep-discussion/2026-07-29-review-001/system-review.md`（5 处）
  - `docs/superpowers/reviews/deep-discussion/2026-07-29-review-001/test-review.md`（4 处）

**范围边界（不替换）**：以下文件含旧名属描述性引用（描述本次改名过程），**不做内容替换**，由 AC1 排除列表覆盖：
- `docs/superpowers/specs/2026-08-07-deep-discussion-rename-and-publish-design.md`（本设计 spec）
- `docs/superpowers/plans/2026-08-07-deep-discussion-rename-and-publish.md`（本计划）
- `docs/superpowers/reviews/deep-discussion-rename-and-publish-design/`（本设计审核目录，全部文件）

**Interfaces:**
- Consumes: Task 5（新路径就位）
- Produces: 历史文档功能性引用零旧名（行号证据除外，Task 7 处理）

- [ ] **Step 1: 对 8 个历史文件做全局替换**

对以下文件逐一执行 `yy-grill-me` → `deep-discussion` 全局替换（`sed -i ''` 为 macOS 语法；Linux 用 `sed -i`）：

Run（macOS）：
```bash
for f in \
  docs/superpowers/plans/2026-07-29-deep-discussion.md \
  docs/superpowers/plans/2026-07-29-deep-discussion-acceptance.md \
  docs/superpowers/specs/2026-07-29-deep-discussion-design.md \
  docs/superpowers/reviews/deep-discussion/index.md \
  docs/superpowers/reviews/deep-discussion/2026-07-29-review-001/consolidated-review.md \
  docs/superpowers/reviews/deep-discussion/2026-07-29-review-001/product-review.md \
  docs/superpowers/reviews/deep-discussion/2026-07-29-review-001/system-review.md \
  docs/superpowers/reviews/deep-discussion/2026-07-29-review-001/test-review.md
do
  sed -i '' 's/yy-grill-me/deep-discussion/g' "$f"
done
```

注意：`sed` 全局替换会同时处理 `/yy-grill-me`（命令）、`yy-grill-me/`（目录）、`/skills/yy-grill-me/`（路径）等所有形态，因为它们都以 `yy-grill-me` 为子串。

- [ ] **Step 2: 验收——8 文件零旧名**

Run:
```bash
for f in \
  docs/superpowers/plans/2026-07-29-deep-discussion.md \
  docs/superpowers/plans/2026-07-29-deep-discussion-acceptance.md \
  docs/superpowers/specs/2026-07-29-deep-discussion-design.md \
  docs/superpowers/reviews/deep-discussion/index.md \
  docs/superpowers/reviews/deep-discussion/2026-07-29-review-001/consolidated-review.md \
  docs/superpowers/reviews/deep-discussion/2026-07-29-review-001/product-review.md \
  docs/superpowers/reviews/deep-discussion/2026-07-29-review-001/system-review.md \
  docs/superpowers/reviews/deep-discussion/2026-07-29-review-001/test-review.md
do
  echo "$(grep -c 'yy-grill-me' "$f")  $f"
done
```
Expected: 每行均为 `0  <path>`。

- [ ] **Step 3: 检查 acceptance.md 的旧名是否已清（功能性引用部分）**

Run:
```bash
grep -n "yy-grill-me" docs/superpowers/plans/2026-07-29-deep-discussion-acceptance.md || echo "PASS: 零旧名"
```
Expected: `PASS: 零旧名`。若仍有，检查是否为行号证据段（Task 7 会处理行号本身，但旧名字面应已被 sed 替换；如出现说明该处旧名在非常规上下文，需手工核查）。

---

## Task 7: acceptance 行号锚点标注 + 锚点校验脚本

**Files:**
- Create: `scripts/check-acceptance-anchors.sh`
- Modify: `docs/superpowers/plans/2026-07-29-deep-discussion-acceptance.md`（行号 +5 修正 + 每个行号引用旁加 `#行首文本` 锚点）

**Interfaces:**
- Consumes: Task 2（SKILL.md 改名后 frontmatter 9 行，正文整体下移 5 行）+ Task 6（acceptance.md 已无旧名字面）
- Produces: 锚点校验脚本 + 修正后的 acceptance.md（行号对齐改名后 SKILL.md）+ git diff 作为验收证据（Task 12 提交后可对比）

- [ ] **Step 1: 写锚点校验脚本**

创建 `scripts/check-acceptance-anchors.sh`：

```bash
#!/usr/bin/env bash
# check-acceptance-anchors.sh — 校验 acceptance.md 内 "第 NN 行 #行首文本" 锚点
# 与 SKILL.md 实际行行首是否匹配。不依赖 "+5 行" 假设，以 SKILL.md 实际行为真值。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILL="$SRC/SKILL.md"
ACCEPT="$SRC/docs/superpowers/plans/2026-07-29-deep-discussion-acceptance.md"

for f in "$SKILL" "$ACCEPT"; do
  [ -f "$f" ] || { echo "缺文件: $f" >&2; exit 2; }
done

mapfile -t SKILL_LINES < "$SKILL"
total=${#SKILL_LINES[@]}

diffs=0
checked=0

# 提取所有 "第 N 行 #锚点" 模式，转为 "N|锚点"
while IFS= read -r pair; do
  [ -z "$pair" ] && continue
  ln="${pair%%|*}"
  anchor="${pair#*|}"
  [ -z "$anchor" ] && continue
  checked=$((checked+1))

  if [ "$ln" -lt 1 ] || [ "$ln" -gt "$total" ]; then
    echo "FAIL: 行号 $ln 超出 SKILL.md 范围(1..$total)  锚点=#$anchor"
    diffs=$((diffs+1))
    continue
  fi

  actual="${SKILL_LINES[$((ln-1))]}"
  # 去行首空白
  actual_trim="${actual#"${actual%%[![:space:]]*}"}"

  if [[ "$actual_trim" == "$anchor"* ]]; then
    : # 匹配
  else
    echo "FAIL: 第 $ln 行 锚点=#$anchor"
    echo "  预期(锚点前缀): $anchor"
    echo "  实际(行首30字符): ${actual_trim:0:30}"
    diffs=$((diffs+1))
  fi
done < <(grep -oE '第[[:space:]]*[0-9]+[[:space:]]*行[[:space:]]*#[^ ，)。、【】]*' "$ACCEPT" \
         | sed -E 's/第[[:space:]]*([0-9]+)[[:space:]]*行[[:space:]]*#/\1|/')

echo ""
echo "共检查 $checked 个锚点，$diffs 处不匹配"
if [ "$diffs" -eq 0 ]; then
  echo "PASS: 全部锚点匹配 SKILL.md 实际行"
  exit 0
else
  echo "FAIL: 见上方差异清单。据清单逐条修正 acceptance.md 行号后重跑。"
  exit 1
fi
```

赋可执行权限：
```bash
chmod +x scripts/check-acceptance-anchors.sh
```

- [ ] **Step 2: 语法检查**

Run:
```bash
bash -n scripts/check-acceptance-anchors.sh && echo "PASS: 语法 OK" || echo "FAIL"
```
Expected: `PASS: 语法 OK`

- [ ] **Step 3: 据 spec 4.4 行号映射表初估，标注 acceptance.md 行号 + 锚点**

spec 4.4 给出的 +5 映射表（acceptance.md 当前行号引用 → 改名后行号）：

| acceptance 当前引用 | 改名后 | SKILL.md 行首文本（锚点） |
|---|---|---|
| 22 / 23 / 24 | 27 / 28 / 29 | `1. **一次一问` / `2. **每题给推荐答案` / `3. **沿决策树推进` |
| 28 | 33 | `7. **铁律` |
| 32-34 | 37-39 | `- **一次一问**` / `- **带推荐答案**` / `- **逐枝推进**` |
| 36-50 | 41-55 | `## ADR 候选门槛`（41）/ `- **敲定**`（45）/ `- 三条件`（46） |
| 54-58 | 59-63 | `**仅当用户显式要求保存时**`（59）/ `- **`CONTEXT.md`**`（61）/ `- **懒创建**`（63） |
| 61-70 | 66-75 | `### 保存契约`（66）/ `1. **写入前检测`（70）等 |
| 71-79 | 76-84 | `### 触发边界`（76）/ `**确认门禁`（83） |
| 81-83 | 86-88 | `### 恢复`（86） |
| 87-91 | 92-96 | `### 中途保存`（92） |
| 93-96 | 98-101 | `### 终止`（98） |
| 98-102 | 103-107 | `### 清空草稿`（103） |
| 107 | 112 | `多 context`（边界节，CR-006 DEFERRED） |
| 109 | 114 | `v1 写入目标固定为 cwd`（CR-009 DEFERRED） |
| 111-119 | 116-124 | `## 验收标准`（116） |
| 56 / 57 | 61 / 62 | references 引用（`- **`CONTEXT.md`**` / `- **`docs/adr`**`） |

**锚点格式约定**：在 acceptance.md 每个行号引用处，写成 `第 NN 行 #行首文本`，锚点紧跟 `#` 之后，以空格或中文标点结束。锚点取 SKILL.md 该行行首 3-8 个字符（足够区分即可）。

**示例**：acceptance.md 当前第25行：
```
| 1 | `/yy-grill-me` 启动结构化拷问：一次一问、带推荐答案、逐枝推进 | PASS | 第 22 行（一次一问）、第 23 行（每题给推荐答案）、第 24 行（沿决策树推进）；可验证判据见第 32–34 行 |
```
改为（Task 6 已把 `/yy-grill-me` → `/deep-discussion`，本步改行号 + 加锚点）：
```
| 1 | `/deep-discussion` 启动结构化拷问：一次一问、带推荐答案、逐枝推进 | PASS | 第 27 行 #1. **一次一问、第 28 行 #2. **每题给推荐答案、第 29 行 #3. **沿决策树推进；可验证判据见第 37–39 行 |
```

对 acceptance.md 内所有行号引用（第 25-31 行的验收表、第 41-50 行的 CR 落地表、第 58-59 行的引用完整性、第 68-73 行的 dry-run、第 79-80 行的遗留）逐处照此标注。映射表作初估，**最终行号以 Step 4 脚本校验为真值**。

- [ ] **Step 4: 运行锚点脚本，产出差异清单**

Run:
```bash
bash scripts/check-acceptance-anchors.sh || true
```

读输出：
- 若 `PASS`：跳到 Step 6。
- 若 `FAIL` + 差异清单：每条差异给出「行号 / 预期锚点 / 实际行首」，说明该行号在 SKILL.md 实际指向了别处。进入 Step 5。

- [ ] **Step 5: 据差异清单修正 acceptance.md 行号**

对每条差异：
1. 看「实际(行首30字符)」，在 SKILL.md 用 `grep -n "<实际行首文本>" SKILL.md` 找到该锚点文本的真实行号。
2. 或反向：找到 acceptance 该条想引用的语义点（如「一次一问」），在 SKILL.md `grep -n "一次一问" SKILL.md` 取实际行号。
3. 把 acceptance.md 该处的行号改为真实行号（锚点文本不变，因锚点取自 SKILL.md 实际行首，本就正确）。

重跑 Step 4，直至 `PASS`。

- [ ] **Step 6: 终验**

Run:
```bash
bash scripts/check-acceptance-anchors.sh
```
Expected: `PASS: 全部锚点匹配 SKILL.md 实际行`，退出码 0。

- [ ] **Step 7: 保留 acceptance.md 改动供 Task 12 纳入首次提交 diff**

acceptance.md 的行号修正 diff 将随 Task 12 `git add .` 纳入首次提交，作为「行号证据经锚点校验对齐」的验收证据（CR-007：验证与修正分离，diff 供独立复核）。

---

## Task 8: scripts/install.sh（幂等双端 symlink 安装）

**Files:**
- Create: `scripts/install.sh`

**Interfaces:**
- Consumes: Task 2（SKILL.md frontmatter `name: deep-discussion`，供 `verify_source` 比对）
- Produces: 可执行 `install.sh`，支持 `bash scripts/install.sh` 安装、`bash scripts/install.sh --uninstall` 卸载

- [ ] **Step 1: 写 install.sh**

创建 `scripts/install.sh`：

```bash
#!/usr/bin/env bash
# install.sh — deep-discussion 双端 symlink 安装/卸载（幂等）
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
  [ "$got" = "$NAME" ] || {
    echo "SKILL.md name='$got' 与脚本 NAME='$NAME' 不一致（内容未完成改名？）" >&2
    exit 1
  }
}

link() {  # link <target> <link_path>
  local target="$1" link_path="$2"
  if [ -L "$link_path" ] && [ "$(readlink "$link_path")" = "$target" ]; then
    echo "已存在且指向同源，跳过: $link_path"
    return 0
  fi
  if [ -e "$link_path" ] || [ -L "$link_path" ]; then
    echo "目标已存在且非同源 symlink，不覆盖: $link_path" >&2
    return 1
  fi
  mkdir -p "$(dirname "$link_path")"
  ln -s "$target" "$link_path" && echo "已安装: $link_path -> $target"
}

if [ "${1:-}" = "--uninstall" ]; then
  rm -f "$CLAUDE_LINK" "$HERMES_LINK"
  echo "已卸载: $CLAUDE_LINK, $HERMES_LINK"
  exit 0
fi

verify_source

# 两次 link 尽量完成，部分失败时提示恢复（CR-004）
claude_ok=0; hermes_ok=0
link "$SRC" "$CLAUDE_LINK" && claude_ok=1 || true
link "$SRC" "$HERMES_LINK" && hermes_ok=1 || true

if [ "$claude_ok$hermes_ok" != "11" ]; then
  echo "部分安装：Claude=$([ $claude_ok -eq 1 ] && echo 已装 || echo 未装)、Hermes=$([ $hermes_ok -eq 1 ] && echo 已装 || echo 未装)。" >&2
  echo "可执行 'bash scripts/install.sh --uninstall' 清理后重试。" >&2
  exit 1
fi

echo "双端安装完成: $NAME"
```

赋可执行权限：
```bash
chmod +x scripts/install.sh
```

- [ ] **Step 2: 语法检查**

Run:
```bash
bash -n scripts/install.sh && echo "PASS: 语法 OK" || echo "FAIL"
```
Expected: `PASS: 语法 OK`

- [ ] **Step 3: verify_source 自检（内容已完成改名时应通过）**

Run:
```bash
bash -c 'set -e; SRC="$(cd scripts/.. && pwd)"; skill="$SRC/SKILL.md"; got="$(awk -F": " "/^name:/{print \$2; exit}" "$skill")"; [ "$got" = "deep-discussion" ] && echo "PASS: verify_source 前提成立" || echo "FAIL: name=$got"'
```
Expected: `PASS: verify_source 前提成立`（确认 Task 2 已把 frontmatter name 改为 deep-discussion）。

- [ ] **Step 4: --uninstall 幂等性检查（不实际安装，仅验卸载路径不报错）**

Run:
```bash
bash scripts/install.sh --uninstall
```
Expected: `已卸载: ...`（即便原本没装也不报错，幂等）。

---

## Task 9: docs/deploy.md（双端安装文档 + Windows 说明 + 故障排除）

**Files:**
- Create: `docs/deploy.md`

**Interfaces:**
- Consumes: Task 8（install.sh 已就位，文档引用其用法）
- Produces: 部署文档，含 macOS/Linux/Windows 三平台说明 + 故障排除

- [ ] **Step 1: 写 deploy.md**

创建 `docs/deploy.md`：

````markdown
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
````

- [ ] **Step 2: 验收——文件含关键章节**

Run:
```bash
grep -c "macOS / Linux" docs/deploy.md && grep -c "Windows" docs/deploy.md && grep -c "故障排除" docs/deploy.md
```
Expected: 三个数都 ≥ 1。

- [ ] **Step 3: 验收——无旧名**

Run:
```bash
grep -c "yy-grill-me" docs/deploy.md
```
Expected: `0`。

---

## Task 10: README.md（介绍 + 快速开始，不含字面旧名）

**Files:**
- Create: `README.md`

**Interfaces:**
- Consumes: Task 9（指向 deploy.md）
- Produces: README，旧名溯源由 Task 12 commit message 承载，README 本体零旧名（CR-001 方案2）

- [ ] **Step 1: 写 README.md**

创建 `README.md`：

````markdown
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
````

- [ ] **Step 2: 验收——无旧名（CR-001 方案2 核心）**

Run:
```bash
grep -c "yy-grill-me" README.md
```
Expected: `0`。

- [ ] **Step 3: 验收——含关键信息**

Run:
```bash
grep -c "/deep-discussion" README.md && grep -c "deploy.md" README.md
```
Expected: 两个数都 ≥ 1。

---

## Task 11: 全仓零残留终检

**Files:**
- 无新建/修改，仅校验

**Interfaces:**
- Consumes: Task 2-10 全部完成
- Produces: AC1 零功能性残留通过的证据

- [ ] **Step 1: 全仓 grep（按 AC1 排除列表）**

Run:
```bash
grep -rn "yy-grill-me" . 2>/dev/null \
  | grep -vE "^\./(\.git|\.workbuddy|\.superpowers/sdd)/" \
  | grep -v "docs/superpowers/specs/2026-08-07-deep-discussion-rename-and-publish-design.md" \
  | grep -v "docs/superpowers/plans/2026-08-07-deep-discussion-rename-and-publish.md" \
  | grep -v "docs/superpowers/reviews/deep-discussion-rename-and-publish-design/" \
  || echo "PASS: 零功能性残留"
```
Expected: `PASS: 零功能性残留`。

- [ ] **Step 2: 若有残留，逐条处理**

若 Step 1 有输出（非 PASS），每条残留指向一个未改名的功能性引用。检查它属于：
- 历史文档遗漏 → 回 Task 6 补替换
- SKILL.md / CLAUDE.md 遗漏 → 回 Task 2/3 补替换
- 新文件（README/deploy/install）遗漏 → 回对应 Task 修补

修完重跑 Step 1，直至 PASS。

- [ ] **Step 3: 锚点校验再确认（Task 7 成果未被后续 task 破坏）**

Run:
```bash
bash scripts/check-acceptance-anchors.sh
```
Expected: `PASS: 全部锚点匹配 SKILL.md 实际行`，退出码 0。

- [ ] **Step 4: frontmatter 合法性终检**

Run:
```bash
head -9 SKILL.md | grep -E "name: deep-discussion|platforms:|category: software-development"
```
Expected: 三行命中。

Run:
```bash
test ! -e agents && echo "PASS: agents/ 不存在" || echo "FAIL"
```
Expected: `PASS: agents/ 不存在`。

---

## Task 12: git init + GitHub 私有仓库创建与推送

**Files:**
- 无新建/修改，仅 git 操作

**Interfaces:**
- Consumes: Task 1-11（全仓干净态就位）
- Produces: GitHub 私有仓库 `deep-discussion` 已建并推送，首次提交含全部改名成果 + acceptance 行号修正 diff

- [ ] **Step 1: 确认 .gitignore 已就位**

Run:
```bash
cat .gitignore
```
Expected 含：
```
.DS_Store
.workbuddy/
.superpowers/sdd/
```

若缺，补：用 Write 工具写 `.gitignore` 含上述三行（沿用 goal-manager 惯例，`.claude/` 可选——本仓库 `.claude/` 若有也应忽略，避免本地 Claude 配置入库）。检查：
```bash
test -d .claude && echo "有 .claude/，应加入 .gitignore" || echo "无 .claude/"
```

- [ ] **Step 2: git init + 默认分支 main**

Run:
```bash
git init
git branch -M main
```

- [ ] **Step 3: 检查待提交内容不含旧名残留 + 排除项未泄露**

Run:
```bash
git add .
git status --short | head -50
```
确认 `.workbuddy/`、`.superpowers/sdd/`、`.DS_Store` **不在**暂存列表（被 .gitignore 排除）。

- [ ] **Step 4: 推送前检查同名仓库不存在**

Run:
```bash
gh repo view deep-discussion 2>/dev/null && echo "WARN: 仓库已存在，中止，人工处理" || echo "PASS: 同名仓库不存在"
```
Expected: `PASS: 同名仓库不存在`。若 WARN，停止，与用户确认（改名仓库或换目标）。

- [ ] **Step 5: 首次提交**

Run:
```bash
git commit -m "feat: 初始化 deep-discussion 技能（前身为 yy-grill-me，改名+双端支持+发布）"
```

commit message 含「前身为 yy-grill-me」做旧名溯源（CR-001 方案2），此旧名在 `.git/` 内，被 AC1 排除，不违反零残留。

- [ ] **Step 6: 创建私有仓库并推送**

Run:
```bash
gh repo create deep-discussion --private --source=. --remote=origin --push
```

- [ ] **Step 7: 验收**

Run:
```bash
gh repo view deep-discussion --json visibility,sshUrl -q '.visibility + " " + .sshUrl'
```
Expected: `PRIVATE git@github.com:.../deep-discussion.git`（确认私有）。

Run:
```bash
gh repo view deep-discussion --json defaultBranchRef -q '.defaultBranchRef.name'
```
Expected: `main`。

Run:
```bash
git log --oneline -1
```
Expected: 首条提交信息为 `feat: 初始化 deep-discussion 技能（前身为 yy-grill-me，改名+双端支持+发布）`。

- [ ] **Step 8: 确认排除项未泄露到远程**

Run:
```bash
gh api repos/:owner/deep-discussion/contents/.workbuddy 2>/dev/null && echo "FAIL: .workbuddy 泄露" || echo "PASS: .workbuddy 未泄露"
gh api repos/:owner/deep-discussion/contents/.superpowers 2>/dev/null && echo "FAIL: .superpowers 泄露" || echo "PASS: .superpowers 未泄露"
```
Expected: 两个 `PASS`。

---

## Task 13: 双端安装验证

**Files:**
- 无新建/修改，仅安装与校验

**Interfaces:**
- Consumes: Task 8（install.sh）、Task 12（仓库就位，install.sh 仍指向本地源目录）
- Produces: 两处有效 symlink（AC4）

- [ ] **Step 1: 运行安装**

Run:
```bash
bash scripts/install.sh
```
Expected: `已安装: ~/.claude/skills/deep-discussion -> ...` 与 `已安装: ~/.hermes/skills/software-development/deep-discussion -> ...` 与 `双端安装完成: deep-discussion`。

- [ ] **Step 2: 验收——两处 symlink 有效**

Run:
```bash
test -L "$HOME/.claude/skills/deep-discussion" && echo "PASS: Claude symlink" || echo "FAIL"
test -L "$HOME/.hermes/skills/software-development/deep-discussion" && echo "PASS: Hermes symlink" || echo "FAIL"
```
Expected: 两个 `PASS`。

Run:
```bash
readlink "$HOME/.claude/skills/deep-discussion"
readlink "$HOME/.hermes/skills/software-development/deep-discussion"
```
Expected: 两个都指向本地源目录（当前 `deep-discussion/` 绝对路径）。

- [ ] **Step 3: 幂等性——重跑不报错**

Run:
```bash
bash scripts/install.sh
```
Expected: `已存在且指向同源，跳过` ×2 + `双端安装完成`。

- [ ] **Step 4: Claude Code 触发验证（AC5a）**

在 Claude Code 对话中输入 `/deep-discussion`，确认能启动拷问流程（技能被识别、进入 griller 角色、一次一问）。

记录：触发验证为人工确认，通过即 AC5a PASS。

- [ ] **Step 5: Hermes 列出验证（AC5b）**

Run:
```bash
hermes skills 2>/dev/null | grep -i deep-discussion || echo "未列出（Hermes 可能未装或命令不同——记为部署后验证）"
```

说明：Hermes 端实际触发验证显式记为部署后验证（CR-008），spec 范围只验「安装到位 + 能列出」。若 `hermes` 命令不可用，记为「Hermes 未在当前环境，AC5b 部署后验证」，不阻塞本计划验收。

---

## Task 14: 验收门禁（AC1-AC6 全套）

**Files:**
- 无新建/修改，仅全量验收

**Interfaces:**
- Consumes: Task 1-13 全部完成
- Produces: 验收报告（AC1-AC6 逐条 PASS/FAIL）

- [ ] **Step 1: AC1 零功能性残留**

Run:
```bash
grep -rn "yy-grill-me" . 2>/dev/null \
  | grep -vE "^\./(\.git|\.workbuddy|\.superpowers/sdd)/" \
  | grep -v "docs/superpowers/specs/2026-08-07-deep-discussion-rename-and-publish-design.md" \
  | grep -v "docs/superpowers/plans/2026-08-07-deep-discussion-rename-and-publish.md" \
  | grep -v "docs/superpowers/reviews/deep-discussion-rename-and-publish-design/" \
  | grep -v "^\./\.git/" \
  || echo "AC1 PASS: 零功能性残留"
```
Expected: `AC1 PASS: 零功能性残留`。

- [ ] **Step 2: AC2 行号锚点校验**

Run:
```bash
bash scripts/check-acceptance-anchors.sh
```
Expected: `PASS: 全部锚点匹配 SKILL.md 实际行`，退出码 0。acceptance.md 的行号修正 git diff 已随 Task 12 首次提交纳入（`git show --stat HEAD` 可见 acceptance.md 在变更列表）。

- [ ] **Step 3: AC3 frontmatter 合法 + 无 agents/**

Run:
```bash
grep -E "^name: deep-discussion$" SKILL.md && \
grep -E "^platforms: \[macos, linux, windows\]$" SKILL.md && \
grep -E "category: software-development" SKILL.md && \
test ! -e agents && echo "AC3 PASS" || echo "AC3 FAIL"
```
Expected: `AC3 PASS`。

- [ ] **Step 4: AC4 双端安装**

Run:
```bash
test -L "$HOME/.claude/skills/deep-discussion" && \
test -L "$HOME/.hermes/skills/software-development/deep-discussion" && \
echo "AC4 PASS" || echo "AC4 FAIL"
```
Expected: `AC4 PASS`。

- [ ] **Step 5: AC5a Claude Code 触发**

Task 13 Step 4 已验。记录结果。通过即 `AC5a PASS`。

- [ ] **Step 6: AC5b Hermes 列出**

Task 13 Step 5 已验。记录结果（部署后验证亦记明）。`AC5b: 部署后验证` 或 `AC5b PASS`。

- [ ] **Step 7: AC6 仓库私有 + 已推 + 排除项未泄露**

Run:
```bash
gh repo view deep-discussion --json visibility -q '.visibility' | grep -q PRIVATE && \
gh api repos/:owner/deep-discussion/contents/.workbuddy 2>/dev/null && echo "AC6 FAIL: .workbuddy 泄露" || \
(gh api repos/:owner/deep-discussion/contents/.superpowers 2>/dev/null && echo "AC6 FAIL: .superpowers 泄露" || echo "AC6 PASS: 私有+已推+未泄露")
```
Expected: `AC6 PASS: 私有+已推+未泄露`。

- [ ] **Step 8: 汇总验收报告**

输出 AC1-AC6 逐条结果。全 PASS 则改造完成；任一 FAIL 回对应 task 修正。

---

## Self-Review

（写计划后自审，已修正以下项）

**1. Spec 覆盖**：逐条核对 spec 各节——
- spec 4.1（SKILL.md frontmatter + 正文）→ Task 2 ✓
- spec 4.2（CLAUDE.md）→ Task 3 ✓
- spec 4.3（删 agents/）→ Task 4 ✓
- spec 4.4（历史文档改名 + 内容替换 + 行号映射 + 锚点校验）→ Task 5/6/7 ✓
- spec 4.5（install.sh + deploy.md + README.md + check-acceptance-anchors.sh）→ Task 8/9/10/7 ✓
- spec 4.6（GitHub 流程）→ Task 12 ✓
- spec 第 5 节（错误处理）→ 各 task 的故障路径 + install.sh verify_source/部分失败 + 锚点 FAIL ✓
- spec 第 6 节（验收 AC1-AC6）→ Task 14 ✓
- spec 第 9 节（执行顺序）→ Task 1-14 顺序与 spec 一致 ✓

**2. 计划层对 spec 的精确化（已在上文标注）**：
- AC1 排除列表扩展（补入本计划文件 + 本设计审核目录），消除 spec AC1 自洽矛盾。理由见 Global Constraints。
- Task 3 Step 4 把 CLAUDE.md 架构列表的 `agents/openai.yaml` 行替换为 scripts/docs/README 说明——spec 4.2 仅说「3 处旧名引用改名」，未明示 agents/ 引用行处理，计划层据「删 agents/ 后无悬空引用」推导补全。

**3. Placeholder 扫描**：无 TBD/TODO/「适当处理」/「类似上 task」——每个 step 含具体命令或代码。✓

**4. 类型/路径一致**：`NAME="deep-discussion"`、`deep-discussion` 目录、`/deep-discussion` 命令、`deep-discussion` 仓库——全 plan 一致。锚点脚本路径 `docs/superpowers/plans/2026-07-29-deep-discussion-acceptance.md` 与 Task 5 改名后路径一致。install.sh `verify_source` 比对的 `name: deep-discussion` 与 Task 2 frontmatter 一致。✓

**5. 时序张力**：spec 4.6「git init 在内容改完后」与 writing-plans「frequent commits」有张力——按 spec（用户决策优先），Task 1-11 无 commit，Task 12 单次首次 commit。已在 Global Constraints 注明。✓

# 讨论纪要归档实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 deep-discussion 的可选纪要从 `docs/grill-summary.md`（单文件、多会话不可区分）迁到 `docs/discussions/NNNN-slug.md`（命名同 ADR、按主题 slug 合并、文件内按会话段时间戳累积），并落地 6 条评审 CR 的全部 Required Action。

**Architecture:** 单文件自包含技能（方案 A），无代码、无单测。改动全为 Markdown 文档：新建 `references/DISCUSSION-FORMAT.md`（格式规范，镜像 ADR-FORMAT.md / CONTEXT-FORMAT.md 模式）、改 `SKILL.md`（纪要落点 + 保存契约 + 边界 + 验收#4 + 落盘提示）、同步 `references/ADR-FORMAT.md`（编号过滤）、`CLAUDE.md`（产出文件位置）、`docs/superpowers/plans/2026-07-29-deep-discussion-acceptance.md`（行号锚点 + 增补注记）。TDD 适配为「校验驱动」：`scripts/check-acceptance-anchors.sh` 充当红/绿 oracle——改 SKILL.md 中段 → 校验 FAIL → 据 FAIL 清单同步 acceptance.md 行号 → 校验 PASS。

**Tech Stack:** Markdown、Bash（校验脚本）、Git。无运行时代码、无单测框架。

**关联 spec:** `docs/superpowers/specs/2026-08-07-discussion-summary-format-design.md`（v2，6 条 CR 全部 ACCEPTED）

## Global Constraints

- **全程中文**：技能指令、提问、产出文档、本计划文件均中文；大写下划线标识符与枚举值保持英文。
- **Git 提交信息格式**：`type[optional scope]: <description>`（用户级铁律）。
- **不自动创建文件**：技能铁律；本计划的文件创建均由用户批准 spec 触发，属用户显式要求。
- **行号锚点原子性**：改 `SKILL.md` 中段后必须同步 `acceptance.md` 行号，且两者在同一 commit——否则中间 commit 的 `check-acceptance-anchors.sh` 为红。
- **三条件同步**：ADR 候选三条件（难回退 + 外人会疑惑 + 真实取舍）在 `SKILL.md` 与 `references/ADR-FORMAT.md` 均有表述，改一处需同步另一处（本计划不改三条件本身，但 DR-006 同步编号规则时不得误伤三条件文本）。
- **DEFERRED 两项不阻塞**：CR-006（多 context 规则）、CR-009（cwd 隔离）保持 v1 标注，不在本计划范围。
- **WIP 正交**：工作区预先存在的 WIP（`CLAUDE.md` 项目概述精简 + `SKILL.md` 文案精简/收紧触发词）与本次纪要归档改动正交，Task 1 先单独提交，后续 task 的 commit 只含纪要归档改动。
- **slug 非确定性**（DR-001）：AI 中译英非确定，slug 最终由用户在确认门禁确认/修正；H1 记中文原名辅助识别；门禁展示既有 slug 列表辅助对齐。
- **编号过滤**（DR-006）：`docs/discussions/` 与 `docs/adr/` 编号扫描均仅计 `NNNN-*.md`（4 位数字前缀）文件，非标准文件忽略。

---

## File Structure

| 文件 | 责任 | 改动类型 |
|---|---|---|
| `references/DISCUSSION-FORMAT.md` | 讨论纪要格式规范：主题/slug、编号、「会话」定义、文件内结构、合并/去重/幂等、确认门禁、边界。镜像 ADR-FORMAT.md / CONTEXT-FORMAT.md 模式。 | **新建**（Task 2） |
| `SKILL.md` | 技能主体。纪要落点（:64 可选纪要）、保存契约扩展（纳纪要 CR-001）、边界节增补（纪要目录+编号）、落盘提示（:100 加纪要选项）、验收#4（:122 扩展）。 | 修改（Task 3） |
| `docs/superpowers/plans/2026-07-29-deep-discussion-acceptance.md` | v1 验收文档。第 2/3 节行号证据同步（:75 之后引用全部重新核对）；追加 §7「2026-08-07 增补」注记。 | 修改（Task 3，与 SKILL.md 同 commit） |
| `references/ADR-FORMAT.md` | ADR 格式规范。编号规则同步「仅匹配 NNNN-*.md」过滤（DR-006）。 | 修改（Task 4） |
| `CLAUDE.md` | 项目指令。产出文件位置 :43 `docs/grill-summary.md` → `docs/discussions/NNNN-slug.md`。 | 修改（Task 5） |
| 历史 docs（07-29 spec / plan / review） | 不动。 | — |

**引用闭合关系**：`SKILL.md` :64 引用 `references/DISCUSSION-FORMAT.md`（Task 2 先建，Task 3 再引用，无悬空）。`DISCUSSION-FORMAT.md` 内引用 `docs/discussions/`、`references/ADR-FORMAT.md`（编号同源）。`CLAUDE.md` :43 与 `SKILL.md` :64 路径一致。

---

### Task 1: 基线整理 — 提交预先存在的 WIP

**Files:**
- Modify: `CLAUDE.md`（工作区已有 WIP：项目概述段精简）
- Modify: `SKILL.md`（工作区已有 WIP：description/H1/何时使用/触发方式文案精简）

**Interfaces:**
- Consumes: 工作区当前未提交的 `M CLAUDE.md` + `M SKILL.md`（均为文案精简，非本次 spec 改动）
- Produces: 干净的工作区基线——后续 task 的 commit 只含纪要归档改动，不混入 WIP

**理由:** WIP 全是行内文字精简（删「合并版」历史措辞、收紧触发为仅 `/deep-discussion`），不增删整行、行号不变，与纪要归档改动正交。先单独提交，使后续每个 task 的 commit 干净可审。

- [ ] **Step 1: 确认 WIP 内容仅为文案精简（无纪要相关改动）**

Run: `git diff --stat CLAUDE.md SKILL.md`
Expected: 两个文件各 1 处 hunk；`CLAUDE.md` 仅 `## 项目概述` 段，`SKILL.md` 仅 description/H1/首段/何时使用/触发方式。

Run: `git diff CLAUDE.md SKILL.md | grep -iE 'grill-summary|discussions|NNNN|纪要'`
Expected: 无输出（WIP 不含纪要相关文案；若有输出说明 WIP 已混入 spec 改动，需先与用户澄清再继续）。

- [ ] **Step 2: 提交 WIP**

```bash
git add CLAUDE.md SKILL.md
git commit -m "refactor: 去合并版历史措辞，收紧触发为仅 /deep-discussion"
```

- [ ] **Step 3: 确认工作区干净**

Run: `git status --short`
Expected: 无输出（工作区干净，可开始纪要归档改动）。

---

### Task 2: 新建 references/DISCUSSION-FORMAT.md

**Files:**
- Create: `references/DISCUSSION-FORMAT.md`

**Interfaces:**
- Consumes: spec §3 落盘规则 / §4 文件内结构 / §5 保存契约扩展 / §7 边界；`references/ADR-FORMAT.md`（编号同源模式）
- Produces: `references/DISCUSSION-FORMAT.md` —— 被 Task 3 的 `SKILL.md` :64 引用，闭合引用链；内含 spec §8 全部 9 条验收对应的行为契约

**理由:** spec §2 决策表「格式规则存放 = 新建 references/DISCUSSION-FORMAT.md」。独立文件、独立 commit，不动 SKILL.md 行号，校验脚本不受影响。先建此文件，Task 3 再在 SKILL.md 引用它，避免悬空引用。

- [ ] **Step 1: 写入 DISCUSSION-FORMAT.md 全文**

Create `references/DISCUSSION-FORMAT.md` with exactly:

````md
# 讨论纪要格式

讨论纪要存放于 `docs/discussions/`，采用顺序编号：`0001-slug.md`、`0002-slug.md` 等——命名规则与 ADR 一致。

用户**显式要求保存纪要**时，再懒创建 `docs/discussions/` 目录（目录不存在则自动创建，与 `docs/adr/` 一致）。

## 主题与 slug

- **主题来源**：命令参数优先（如 `/deep-discussion 内部审批流` → 主题「内部审批流」）；无参数则技能从对话推断，在确认门禁展示拟用主题供用户确认 / 修正。
- **slug**：主题归一化为短英文 kebab-case（如「内部审批流」→ `internal-approval-flow`）。中文主题由技能译成英文 slug——AI 翻译非确定，故 **slug 最终由用户在确认门禁确认 / 修正，一经确认即作为该主题的持久去重键**。
- **H1 记中文原名**：文件首行 H1 记中文主题原名（如 `# 内部审批流`），辅助人工识别——slug 是机器去重键，H1 是人读标题。
- **同主题 = slug 匹配**：保存时按 slug 扫 `docs/discussions/` 匹配既有文件；命中 → 复用序号、在该文件内追加 / 更新会话段；未命中 → 新序号、新文件。

## 编号

扫描 `docs/discussions/` 中文件名满足 `NNNN-*.md`（NNNN 为 4 位数字前缀）的文件，取最大 NNNN +1；不匹配该模式的文件（如 `README.md`、`.DS_Store`、`*.bak`）忽略不计。

## 「会话」定义

一次 `/deep-discussion` 调用 = 一次会话（非进程生命周期、非日历日期）。

- 段时间戳 = 本次调用首次保存时刻（`YYYY-MM-DD HH:MM`）。
- 同调用内多次保存 → 更新该段（时间戳不变），不追加。
- 新一次 `/deep-discussion` 调用 → 新段（新时间戳）。

## 文件内结构

一个文件 = 一个主题的会话史，按会话分段累积：

```md
---
状态: 进行中  # 可选 frontmatter，为后续生命周期管理预留扩展点；默认不填
---

# {中文主题原名}

## 会话 YYYY-MM-DD HH:MM

**关键问答**
- Q：…  A（推荐）：…
- …

**结论**
- …
- 关联 ADR：[0003-foo](../adr/0003-foo.md)
```

## 合并 / 去重 / 幂等（保存契约扩展）

落盘必须与既有内容正确交互，禁止静默覆盖或重复膨胀：

1. **写入前检测存在性**：目标 slug 文件已存在时走合并（追加 / 更新段）而非整覆盖。
2. **同会话段更新**：同会话（同段时间戳）重存 → 覆盖该 `## 会话 YYYY-MM-DD HH:MM` 段，时间戳不变，不追加。
3. **跨会话段追加**：新一次调用（新时间戳）→ 同文件追加新段时间戳。
4. **文件系统级安全网**：写入前读取目标文件，按段时间戳检测重复——即使上下文记忆丢失，同时间戳段仍按更新处理（镜像 ADR 文件系统去重，不纯靠上下文内存）。
5. **跨主题新建**：未命中既有 slug → 新文件、新序号。
6. **幂等**：用户重复说「保存」，不产生重复段。
7. **去重键** = 用户确认的 slug + 会话段时间戳。

## 确认门禁（首次保存某主题）

首次保存某主题时，门禁额外展示：

- 拟用主题（中文原名）
- 拟用 slug
- `docs/discussions/` 既有 slug 列表
- 去重语义提示：「此 slug 将作为该主题的持久去重标识；若与既有讨论相关，请对齐 slug 或选择合并到既有文件」

slug 经用户确认 / 修正后，才写入文件。后续同主题会话复用该 slug。

## 边界

- **slug 非确定性**：AI 中译英非确定，故 slug 最终由用户确认；门禁展示既有 slug 列表辅助对齐；H1 记中文原名辅助识别。不纯以 YAGNI 免责——主动缓解。
- **跨进程 / 上下文丢失**：新一次调用 = 新会话 = 新段时间戳（可区分）；上下文意外丢失时，新段时间戳使「新保存事件」可见而非静默重复，文件系统安全网兜底同时间戳碰撞。
- **既有 `docs/grill-summary.md`**：不自动迁移；cwd 已有旧文件时提示用户手动迁移或保留，不静默改写。
- **多 context 仓库**：纪要仍写到 cwd 根 `docs/discussions/`，不按 context 分仓（沿用 CR-009 DEFERRED 范围）。
- **长期生命周期管理**（文件增长、归档、清理、浏览辅助、ADR 关联维护）为 v1 范围外，后续增强；模板预留可选「状态」frontmatter 为扩展点。
````

- [ ] **Step 2: 确认文件已写入且非空**

Run: `wc -l references/DISCUSSION-FORMAT.md`
Expected: 约 60-70 行，非零。

Run: `grep -c '^## ' references/DISCUSSION-FORMAT.md`
Expected: 7（主题与 slug / 编号 / 「会话」定义 / 文件内结构 / 合并去重幂等 / 确认门禁 / 边界）。

- [ ] **Step 3: 确认未触及 SKILL.md（校验脚本基线不变）**

Run: `git status --short`
Expected: 仅 `?? references/DISCUSSION-FORMAT.md`（新建未跟踪），无 `M SKILL.md`。

Run: `bash scripts/check-acceptance-anchors.sh`
Expected: `PASS: 全部锚点匹配 SKILL.md 实际行`（未改 SKILL.md，基线绿）。

- [ ] **Step 4: 提交**

```bash
git add references/DISCUSSION-FORMAT.md
git commit -m "feat: 新建 references/DISCUSSION-FORMAT.md 讨论纪要格式规范"
```

---

### Task 3: SKILL.md 纪要归档改动 + acceptance.md 行号同步（原子 commit）

**Files:**
- Modify: `SKILL.md`（5 处：:64 可选纪要、保存契约段 +2 条、:100 落盘提示、边界节 +1 条、:122 验收#4）
- Modify: `docs/superpowers/plans/2026-07-29-deep-discussion-acceptance.md`（第 2/3 节行号同步 + 追加 §7 增补注记）

**Interfaces:**
- Consumes: `references/DISCUSSION-FORMAT.md`（Task 2 已建，:64 引用之）；spec §3/§4/§5/§6/§8
- Produces: `SKILL.md` 纪要落点闭合（:64 指向 DISCUSSION-FORMAT.md）；`acceptance.md` 行号锚点重新对齐改后 SKILL.md 并通过校验；§7 增补注记记录本次变更与 spec 关联

**理由:** 5 处 SKILL.md 改动属同一主题（纪要归档），且任一处行号偏移都会让 `acceptance.md` 锚点失配——故全部 SKILL.md 改动 + acceptance.md 同步 + §7 注记必须同一 commit，commit 前校验 PASS。这是「校验驱动 TDD」的核心循环：改 SKILL.md（红）→ 同步 acceptance.md（绿）→ commit。

- [ ] **Step 1: 改 SKILL.md :64 可选纪要段（单行扩展，引用 DISCUSSION-FORMAT.md）**

在 `SKILL.md` 找到当前 `:64` 行：

```
- **可选纪要**：仅当用户额外要求「连过程也存 / 要纪要」时，生成 `docs/grill-summary.md`，记录关键问答与最终结论（默认关闭）。
```

替换为（保持单行，行号不变）：

```
- **可选纪要**：仅当用户额外要求「连过程也存 / 要纪要」时，生成 `docs/discussions/NNNN-slug.md`——按主题归档、命名同 ADR、多会话按段累积；格式见 `references/DISCUSSION-FORMAT.md`（默认关闭）。
```

- [ ] **Step 2: 改 SKILL.md 保存契约段 — 在第 5 条后追加第 6/7 条（纪要纳入 CR-001）**

在 `SKILL.md` 找到保存契约第 5 条（当前 `:74`）：

```
5. **序号唯一性**：扫描 `docs/adr/` 现有最大号 +1（重复决策的更新逻辑见上一条，保证不重复新建）。
```

在其后追加 2 行（保留其后空行）：

```
6. **纪要按段合并**：纪要按用户确认的 slug 去重——同 slug 再存 → 复用既有文件、在该文件内追加 / 更新会话段（同会话段时间戳则更新、新会话段则追加），不新建整文件；只有新 slug 才追加新序号。
7. **纪要幂等**：用户重复说「保存纪要」，不产生重复段（按段时间戳去重，文件系统级安全网兜底上下文记忆丢失）。
```

> 此步 +2 行，导致后续行号 +2。

- [ ] **Step 3: 改 SKILL.md :100 落盘提示（单行扩展，加纪要选项）**

在 `SKILL.md` 找到当前 `:100` 行（终止/放弃段）：

```
- 用户确认「达成共同理解」时，**主动提示**：「结果仍在对话中、尚未保存为文件。需要我现在落盘吗？（CONTEXT.md / docs/adr/）」
```

替换为（保持单行，行号不变；因 Step 2 的 +2，此行实际位置已偏移至 :102）：

```
- 用户确认「达成共同理解」时，**主动提示**：「结果仍在对话中、尚未保存为文件。需要我现在落盘吗？（CONTEXT.md / docs/adr/）」；若用户此前要求过纪要，一并提示「连同纪要保存到 `docs/discussions/` 吗？」
```

- [ ] **Step 4: 改 SKILL.md 边界节 — 在「多 context 仓库」条后追加「纪要目录与编号」**

在 `SKILL.md` 找到边界节的「多 context 仓库」条（当前 `:112`，因 Step 2 的 +2 实际位置 :114）：

```
- **多 context 仓库**：若检测到根目录 `CONTEXT-MAP.md`，按 `references/CONTEXT-FORMAT.md` 中的多 context 推断规则选择对应 context；无法确定则询问用户（v1 沿用原版逻辑，不重新定义——对应评审 CR-006 DEFERRED）。
```

在其后插入 1 行：

```
- **纪要目录与编号**：用户显式要求保存纪要时，若 `docs/discussions/` 不存在则自动创建（与 `docs/adr/` 一致，无需用户手动建目录）；编号扫描仅计 `NNNN-*.md` 文件最大号 +1，非标准文件忽略。
```

> 此步再 +1 行，累计 +3。

- [ ] **Step 5: 改 SKILL.md 验收#4（单行扩展，覆盖 spec §8 关键条）**

在 `SKILL.md` 找到验收标准第 4 条（当前 `:122`，因 +3 实际位置 :125）：

```
4. 用户额外要求时，才生成 `docs/grill-summary.md`。
```

替换为（保持单行）：

```
4. 用户额外要求纪要时，才生成 `docs/discussions/NNNN-slug.md`（非 `docs/grill-summary.md`）：slug 经用户确认、H1 记中文原名、段标题含 `## 会话 YYYY-MM-DD HH:MM`；同会话重存幂等（同段时间戳）、跨会话同主题追加新段、不同主题新文件；显式保存时自动建目录；编号仅计 `NNNN-*.md`。详见 `references/DISCUSSION-FORMAT.md`。
```

- [ ] **Step 6: 运行校验脚本 — 预期 FAIL（行号偏移）**

Run: `bash scripts/check-acceptance-anchors.sh`
Expected: `FAIL` —— 输出形如 `FAIL: 第 N 行 锚点=#...` 的清单，因 Step 2/4 各加行使 :75 之后所有 acceptance.md 引用的行号失配。此为预期红态。

- [ ] **Step 7: 据 FAIL 清单同步 acceptance.md 行号**

对 Step 6 输出的**每个** `FAIL: 第 N 行 锚点=#X`：

a. 用 grep 在改后 SKILL.md 定位锚点 X 的实际行号：

```bash
grep -n "X 的行首文本" SKILL.md
```

（X 为 acceptance.md 中「第 N 行 #X」的锚点文本；取其行首若干字符作 grep 模式）

b. 在 `docs/superpowers/plans/2026-07-29-deep-discussion-acceptance.md` 中找到引用该锚点的「第 N 行 #X」，把 N 改为 grep 产出的实际行号。

c. 重点核对 acceptance.md 第 2/3/4/5/6 节中**当前引用值 ≥ :75 的所有行号**（受 +3 偏移影响）：
   - 第 2 节表格：`:76 :81 :84 :100 :106-107 :120 :121 :122 :123 :124 :125 :126`
   - 第 3 节表格：`:76 :80 :81 :82 :84 :86 :88 :92 :94 :95 :96 :98 :100 :101 :103 :106 :107 :112 :115`
   - 第 4 节：`:112`（多 context 引用）
   - 第 5 节 dry-run：`:100 :106 :107`
   - 第 6 节：`:112 :115`

   （:75 之前的引用如 :23 :27-29 :33 :35 :37-39 :45 :47-55 :59-64 :66-74 不受影响，无需核对。）

d. 同时核对 §3 表格中保存契约条目：因新增第 6/7 条，原 :74（第 5 条序号唯一性）之后需补 :75（第 6 条纪要按段合并）、:76（第 7 条纪要幂等）两行证据行——在 acceptance.md §3 的 CR-001 行号证据末尾补记「第 6 条纪要按段合并 第 N 行」「第 7 条纪要幂等 第 N+1 行」（N 为 grep 产出值）。

> 这一步是「校验驱动 TDD」的绿态修复：脚本已告诉你哪些锚点失配，grep 给出实际行号，人工回填 acceptance.md。完成本步后进入 Step 8 复验。

- [ ] **Step 8: 在 acceptance.md 末尾追加 §7 增补注记**

在 `docs/superpowers/plans/2026-07-29-deep-discussion-acceptance.md` 末尾（当前最后一行 `**最终结论**...` 之后）追加：

```md

---

## 7. 2026-08-07 增补：讨论纪要归档到 docs/discussions/

**关联 spec**：`docs/superpowers/specs/2026-08-07-discussion-summary-format-design.md`（v2，经 spec-review 6 条 CR 全部 ACCEPTED）

**变更摘要**：可选纪要文件从 `docs/grill-summary.md` 迁到 `docs/discussions/NNNN-slug.md`，命名同 ADR，支持多会话按主题 slug 合并 + 段时间戳区分。

**SKILL.md 行号影响**：本次改动在 SKILL.md :64（可选纪要）、保存契约段（新增第 6/7 条纪要按段合并 / 纪要幂等）、:100（落盘提示加纪要选项）、边界节（新增纪要目录与编号条）、验收#4（:122 扩展）五处落点；以上第 2/3 节行号证据已同步为改后行号（运行 `scripts/check-acceptance-anchors.sh` 校验通过）。

**新增 references**：`references/DISCUSSION-FORMAT.md`（纪要格式规范，镜像 ADR-FORMAT.md）。

**新增验收（spec §8 关键条，落点见上文验收#4 扩展 + DISCUSSION-FORMAT.md 行为契约）**：

- 写到 `docs/discussions/NNNN-slug.md`，不再出现 `docs/grill-summary.md`
- 显式保存时自动建目录
- 首次保存门禁展示主题 + slug + 既有 slug 列表 + 去重语义提示；slug 经用户确认
- H1 中文原名；段标题含时间戳
- 同会话重存幂等；跨会话同主题追加段；不同主题新文件
- 编号仅计 `NNNN-*.md`

**DR-006 同步**：`references/ADR-FORMAT.md` 编号规则同步「仅匹配 NNNN-*.md」过滤（见 Task 4）。

**CLAUDE.md 同步**：产出文件位置 :43 `docs/grill-summary.md` → `docs/discussions/NNNN-slug.md`（见 Task 5）。
```

- [ ] **Step 9: 重跑校验脚本 — 预期 PASS**

Run: `bash scripts/check-acceptance-anchors.sh`
Expected:
```
共检查 N 个锚点，0 处不匹配
PASS: 全部锚点匹配 SKILL.md 实际行
```

若仍 FAIL：据 FAIL 清单回到 Step 7 继续核对未覆盖的锚点，直到 PASS。

- [ ] **Step 10: 引用完整性自检**

Run: `grep -n 'DISCUSSION-FORMAT' SKILL.md`
Expected: :64 行（可选纪要）含 `references/DISCUSSION-FORMAT.md`；:125 行（验收#4）含 `references/DISCUSSION-FORMAT.md`。

Run: `test -f references/DISCUSSION-FORMAT.md && echo OK`
Expected: `OK`（Task 2 已建，引用闭合）。

Run: `grep -c 'grill-summary' SKILL.md`
Expected: `0`（SKILL.md 内已无 `grill-summary` 残留）。

- [ ] **Step 11: 提交 SKILL.md + acceptance.md（原子 commit）**

```bash
git add SKILL.md docs/superpowers/plans/2026-07-29-deep-discussion-acceptance.md
git commit -m "feat: 纪要归档到 docs/discussions/（命名同 ADR + 多会话按主题合并）

- SKILL.md :64/保存契约/边界/落盘提示/验收#4 五处落点
- references/DISCUSSION-FORMAT.md 格式规范（Task 2 已建）
- acceptance.md 行号同步 + §7 增补注记
- 落地 spec v2 6 条 CR（DR-001..006）"
```

---

### Task 4: references/ADR-FORMAT.md 编号过滤（DR-006）

**Files:**
- Modify: `references/ADR-FORMAT.md`（编号段单行扩展）

**Interfaces:**
- Consumes: spec DR-006 / §6 改动清单
- Produces: `references/ADR-FORMAT.md` 编号规则与 `DISCUSSION-FORMAT.md` 编号规则一致（均仅计 `NNNN-*.md`）

**理由:** DR-006 要求编号扫描过滤规则在两处同步。`DISCUSSION-FORMAT.md`（Task 2）已含过滤；本 task 同步 `ADR-FORMAT.md`。不动 SKILL.md，校验脚本不受影响，可独立 commit。

- [ ] **Step 1: 改 ADR-FORMAT.md 编号段（单行扩展）**

在 `references/ADR-FORMAT.md` 找到编号段（当前 `:27`）：

```
扫描 `docs/adr/` 中已有最大编号并 +1。
```

替换为（保持单行）：

```
扫描 `docs/adr/` 中文件名满足 `NNNN-*.md`（NNNN 为 4 位数字前缀）的文件，取最大 NNNN +1；不匹配该模式的文件（如 `README.md`、`.DS_Store`）忽略不计。
```

- [ ] **Step 2: 确认三条件文本未被误伤**

Run: `grep -A3 '## 何时提供 ADR' references/ADR-FORMAT.md`
Expected: 仍含「1. **难回退**」「2. **外人会疑惑**」「3. **真实取舍**」三条件原文（本 task 只改编号段，不动三条件）。

- [ ] **Step 3: 校验脚本基线不变（未触 SKILL.md）**

Run: `bash scripts/check-acceptance-anchors.sh`
Expected: `PASS: 全部锚点匹配 SKILL.md 实际行`。

- [ ] **Step 4: 提交**

```bash
git add references/ADR-FORMAT.md
git commit -m "feat: ADR-FORMAT 编号扫描仅计 NNNN-*.md（DR-006 同步）"
```

---

### Task 5: CLAUDE.md 产出文件位置 :43 同步

**Files:**
- Modify: `CLAUDE.md`（产出文件位置段 :43）

**Interfaces:**
- Consumes: spec §6 改动清单
- Produces: `CLAUDE.md` :43 与 `SKILL.md` :64 路径一致（均 `docs/discussions/NNNN-slug.md`）

**理由:** spec §6 要求 CLAUDE.md :43 同步。Task 1 已提交 WIP，工作区干净，此 task 只改 :43 一行，独立 commit。不动 SKILL.md，校验脚本不受影响。

- [ ] **Step 1: 改 CLAUDE.md 产出文件位置段**

在 `CLAUDE.md` 找到产出文件位置段（当前 `:43`）：

```
- `docs/grill-summary.md` — 可选纪要（默认关闭）
```

替换为：

```
- `docs/discussions/NNNN-slug.md` — 可选讨论纪要（默认关闭，命名同 ADR）
```

- [ ] **Step 2: 确认 CLAUDE.md 内无 grill-summary 残留**

Run: `grep -c 'grill-summary' CLAUDE.md`
Expected: `0`。

- [ ] **Step 3: 校验脚本基线不变**

Run: `bash scripts/check-acceptance-anchors.sh`
Expected: `PASS: 全部锚点匹配 SKILL.md 实际行`。

- [ ] **Step 4: 提交**

```bash
git add CLAUDE.md
git commit -m "docs: CLAUDE.md 产出文件位置同步纪要归档路径"
```

---

### Task 6: 最终校验 + dry-run 验收（不改文件，不 commit）

**Files:**
- 无文件改动（纯校验 + 推理）

**Interfaces:**
- Consumes: Task 1-5 全部产出
- Produces: 验收结论——spec §8 逐条 PASS 证据 + 全链引用完整性确认

**理由:** 收尾验收。对照 spec §8 的 9 条验收标准做 dry-run 推理（依据 SKILL.md + DISCUSSION-FORMAT.md 文本），确认全部可满足；跑校验脚本确认锚点绿；确认全链引用闭合。不改文件、不 commit。

- [ ] **Step 1: 校验脚本最终 PASS**

Run: `bash scripts/check-acceptance-anchors.sh`
Expected:
```
共检查 N 个锚点，0 处不匹配
PASS: 全部锚点匹配 SKILL.md 实际行
```

- [ ] **Step 2: 全链引用完整性**

Run: `grep -n 'DISCUSSION-FORMAT' SKILL.md CLAUDE.md`
Expected: SKILL.md 两处（:64 可选纪要 + 验收#4）、CLAUDE.md 一处（架构段列 references，若 CLAUDE.md 架构段未列 DISCUSSION-FORMAT.md，需补——见 Step 3）。

Run: `test -f references/DISCUSSION-FORMAT.md && test -f references/ADR-FORMAT.md && test -f references/CONTEXT-FORMAT.md && echo OK`
Expected: `OK`（三个 references 齐全）。

Run: `grep -rn 'grill-summary' SKILL.md CLAUDE.md references/ docs/superpowers/plans/2026-07-29-deep-discussion-acceptance.md`
Expected: 仅 `acceptance.md` 历史段落（§1-6 的 v1 证据）可能残留作为「旧路径」引用——若有新文件仍用 `grill-summary` 作产出路径，视为遗漏。预期：SKILL.md / CLAUDE.md / DISCUSSION-FORMAT.md / ADR-FORMAT.md 内 `0` 残留。

- [ ] **Step 3: 补 CLAUDE.md 架构段 references 清单（若缺失）**

Run: `grep -c 'DISCUSSION-FORMAT' CLAUDE.md`
Expected: `≥ 1`（:43 产出文件位置段已含路径；若架构段 references 列表未列 DISCUSSION-FORMAT.md，补一行）。

若架构段（`## 架构` 下的 references 列表）未列 DISCUSSION-FORMAT.md，在 `references/ADR-FORMAT.md` 条目后补：

```
- **`references/DISCUSSION-FORMAT.md`** — 讨论纪要格式规范（主题/slug、编号、会话分段、合并/去重/幂等、确认门禁、边界）
```

若已补，则 amend 进 Task 5 的 commit（`git commit --amend --no-edit`）；否则跳过本步。注意：CLAUDE.md 改动会让 Task 1 的 WIP 提交保持不变（本补在 Task 5 之后，归 Task 5 范畴）。

> 实际操作：Task 5 Step 1 已改 :43；若 Step 3 发现架构段也需补列，回到 Task 5 一并处理后再提交。本 task 仅做检测，不单独 commit。

- [ ] **Step 4: dry-run 验收 spec §8 逐条**

对 spec `docs/superpowers/specs/2026-08-07-discussion-summary-format-design.md` §8 的 9 条验收，依据 `SKILL.md` + `references/DISCUSSION-FORMAT.md` 文本逐条推理（不实际执行技能）：

| # | spec §8 验收 | 证据落点 | 结论 |
|---|---|---|---|
| 1 | 写到 `docs/discussions/NNNN-slug.md`，不再出现 `docs/grill-summary.md` | SKILL.md :64 + 验收#4 | PASS |
| 2 | 显式保存时自动建目录 | DISCUSSION-FORMAT.md 首段 + SKILL.md 边界节「纪要目录与编号」 | PASS |
| 3 | 首次保存门禁展示主题+slug+既有列表+提示；slug 用户确认 | DISCUSSION-FORMAT.md「确认门禁」节 | PASS |
| 4 | H1 中文原名；段标题时间戳 | DISCUSSION-FORMAT.md「主题与 slug」+「文件内结构」 | PASS |
| 5 | 同会话重复保存幂等（同段时间戳） | DISCUSSION-FORMAT.md「合并/去重/幂等」第 2/4/6 条 | PASS |
| 6 | 跨会话同主题追加新时间戳段 | DISCUSSION-FORMAT.md「合并/去重/幂等」第 3 条 + 「会话」定义 | PASS |
| 7 | 跨会话不同主题新文件新序号 | DISCUSSION-FORMAT.md「合并/去重/幂等」第 5 条 + 编号 | PASS |
| 8 | 编号仅计 NNNN-*.md | DISCUSSION-FORMAT.md「编号」+ ADR-FORMAT.md「编号」+ SKILL.md 边界节 | PASS |
| 9 | 默认不生成；无额外要求时目录不被创建 | SKILL.md :64「默认关闭」+ 验收#4 + DISCUSSION-FORMAT.md 首段「显式要求时懒创建」 | PASS |

若任一条无法定位证据 → 回到对应 task 补漏。

- [ ] **Step 5: 6 条 CR 落地核对**

| CR | Required Action | 落点 | 状态 |
|---|---|---|---|
| CR-001 slug 非确定性 | slug 用户确认 + H1 中文原名 + 门禁展示既有列表 | DISCUSSION-FORMAT.md「主题与 slug」「确认门禁」+ SKILL.md :64 | OK |
| CR-002 主题提取规则 | 命令参数优先；无参数推断+门禁；同主题=slug 匹配 | DISCUSSION-FORMAT.md「主题与 slug」 | OK |
| CR-003 目录创建歧义 | 显式保存时自动建目录 | DISCUSSION-FORMAT.md 首段 + SKILL.md 边界节 | OK |
| CR-004 段去重易失+同日不可区分 | 段标题时间戳 + 文件系统安全网 | DISCUSSION-FORMAT.md「会话定义」「合并/去重/幂等」第 4 条 | OK |
| CR-005 长期生命周期 | §7 已知局限 + 可选状态 frontmatter | DISCUSSION-FORMAT.md「边界」末条 + 文件内结构 frontmatter | OK |
| CR-006 编号扫描过滤 | 仅计 NNNN-*.md；同步 ADR-FORMAT.md | DISCUSSION-FORMAT.md「编号」+ ADR-FORMAT.md「编号」 | OK |

- [ ] **Step 6: 推送分支（可选，由用户决定）**

```bash
git log --oneline feat/discussion-summary-format ^main
```
Expected: 列出 Task 1-5 的 5 个 commit（WIP 整理 / DISCUSSION-FORMAT 新建 / SKILL+acceptance 原子 / ADR-FORMAT 同步 / CLAUDE.md 同步）。

若用户要求推送：`git push -u origin feat/discussion-summary-format`。否则保留本地待用户审。

---

## Self-Review

**1. Spec 覆盖核对**（对照 spec §2/§3/§4/§5/§6/§7/§8）：

- §2 关键决策表（多会话区分/主题提取/排版/格式存放）→ Task 2 DISCUSSION-FORMAT.md 全覆盖 ✓
- §3 落盘规则（路径/命名/编号/去重/懒创建/默认关闭/确认门禁）→ Task 2 + Task 3（:64 / 边界节）✓
- §4 文件内结构（模板/同会话重存/安全网/跨会话同主题/跨会话不同主题）→ Task 2「文件内结构」「合并/去重/幂等」✓
- §5 保存契约扩展（存在性/按段合并/文件系统级段去重/幂等/去重键）→ Task 2 第 1-7 条 + Task 3 SKILL.md 保存契约第 6/7 条 ✓
- §6 改动清单（SKILL.md / DISCUSSION-FORMAT.md / ADR-FORMAT.md / CLAUDE.md / acceptance.md / 本 spec / 历史 docs 不动）→ Task 1-5 全覆盖；历史 docs 不动 ✓
- §7 边界与迁移（slug 非确定性/主题提取/跨进程/既有 grill-summary 不迁移/多 context/已知局限）→ Task 2「边界」节 ✓
- §8 验收 9 条 → Task 6 Step 4 逐条 ✓

**2. Placeholder 扫描**：本计划无 TBD/TODO/"implement later"；每处改动均给 exact 替换文本；acceptance.md 行号同步用脚本 FAIL 清单 + grep 作 oracle（行号值由工具动态产出，非占位符）✓

**3. 类型/命名一致性**：`NNNN-slug.md`（4 位数字 + kebab-case slug）在 SKILL.md / DISCUSSION-FORMAT.md / ADR-FORMAT.md / CLAUDE.md / acceptance.md §7 全部一致；`## 会话 YYYY-MM-DD HH:MM` 段标题格式在 DISCUSSION-FORMAT.md「文件内结构」「会话定义」「合并/去重/幂等」三处一致；slug 去重键 = 用户确认的 slug + 会话段时间戳，在 DISCUSSION-FORMAT.md 第 7 条 + SKILL.md 保存契约第 6 条一致 ✓

**4. 行号原子性**：Task 3 把 SKILL.md 5 处改动 + acceptance.md 同步 + §7 注记放在同一 commit，commit 前 Step 9 校验 PASS，避免中间 commit 红 ✓

**5. 潜在风险**：
- Task 3 Step 7 的行号同步依赖执行者据 FAIL 清单逐条 grep——若漏核对某锚点，Step 9 复验会暴露（仍 FAIL），回到 Step 7 补。校验脚本兜底 ✓
- Task 6 Step 3 的 CLAUDE.md 架构段补列可能让 Task 5 的 commit 范围扩大——已在 Task 5 Step 4 之前处理（回 Task 5 一并提交），不产生独立 commit ✓

无遗漏，计划完整。

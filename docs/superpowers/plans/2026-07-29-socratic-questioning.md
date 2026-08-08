# socratic-questioning 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现合并版「拷问」技能 `socratic-questioning`——单文件 `SKILL.md`（主 agent 直接充当 grill 者）+ 两份中文格式参考文件，默认只聊天不落盘，仅在用户显式要求时才把结果写成 `CONTEXT.md` 与 `docs/adr/`。

**Architecture:** 纯指令型技能（markdown），无代码、无子 agent、无外部调用。所有行为由 `SKILL.md` 指令驱动；两份 `references/*.md` 仅作格式规范被引用。本计划已把评审中 8 条 ACCEPTED 变更（CR-001/002/003/004/005/007/008/010）拆解进对应任务；2 条 DEFERRED（CR-006 多 context 规则、CR-009 cwd 隔离）以"沿用原版 / 后续增强"方式在任务中显式标注，不在 v1 实现。

**Tech Stack:** WorkBuddy Skill（Markdown frontmatter + 指令正文）；触发通过 `/socratic-questioning` 斜杠命令绑定到 `name: socratic-questioning`；无运行时依赖。

## Global Constraints

以下为规格（2026-07-29-socratic-questioning-design.md）中的项目级硬性要求，逐字照搬，每个任务默认继承：

- 结构方案：**方案 A**——单文件自包含 `SKILL.md`，主 agent 直接充当 grill 者，**不拆子 agent**。
- 触发方式：斜杠命令 **`/socratic-questioning`** 启动会话（可附带主题）。
- 语言：**全程中文**（技能指令、提问、产出文档均为中文）。
- 文档内容：对齐原版 `CONTEXT.md`（术语表）+ `docs/adr/*`（决策记录）。
- 落盘触发：**仅当用户明确要求保存时**；会话中或结束后均可。
- 落盘位置：**当前工作目录（cwd）**——根目录 `CONTEXT.md` + `docs/adr/`。
- 可选纪要：`docs/grill-summary.md` **保留但默认关闭**，仅当用户额外要求才生成。
- 铁律：**除非用户明确要求，绝不自动创建任何文件**（本技能相对原版最大的行为差异，必须严格执行）。
- 范围之外 YAGNI：不引入子 agent / 多文件编排；不做自动 PR、issue 等外部集成；不主动维护 `CONTEXT-MAP.md`；不在未获要求时生成任何过程记录类文件。

## 已接受评审变更映射（决定"要写什么"）

| CR | 严重度 | 决策 | 落地点 |
|----|--------|------|--------|
| CR-001 落盘契约 | P1 | ACCEPTED | SKILL.md「保存契约」小节 |
| CR-002 ADR 门槛 | P1 | ACCEPTED | SKILL.md「ADR 候选门槛」+ ADR-FORMAT.md 正反例 |
| CR-003 触发边界+门禁 | P1 | ACCEPTED ⭐ | SKILL.md「触发边界与确认门禁」 |
| CR-004 中途落盘张力 | P1 | ACCEPTED | SKILL.md「中途保存」 |
| CR-005 终止/放弃路径 | P2 | ACCEPTED | SKILL.md「终止/放弃」 |
| CR-007 纪律可验证 | P1 | ACCEPTED | SKILL.md「拷问纪律的可验证判据」 |
| CR-008 无回滚 | P2 | ACCEPTED | 并入 CR-003 的 diff 预览；SKILL.md「恢复」 |
| CR-010 重启重置可观测 | P2 | ACCEPTED | SKILL.md「清空草稿/重启」 |
| CR-006 多 context 规则 | P2 | DEFERRED | v1 沿用 CONTEXT-FORMAT.md 原版推断逻辑（翻译任务已含），不重定义 |
| CR-009 cwd 隔离 | P2 | DEFERRED | v1 保持写 cwd；在 SKILL.md「边界与错误处理」标注为后续增强 |

---

## File Structure

```
socratic-questioning/
├── SKILL.md                          # 主技能：拷问循环 + ADR门槛 + 按需落盘(含保存契约/触发门禁) + 会话生命周期 + 边界 + 验收
└── references/
    ├── CONTEXT-FORMAT.md             # 术语表格式（译自 domain-modeling/CONTEXT-FORMAT.md，中文）
    └── ADR-FORMAT.md                 # ADR 格式（译自 domain-modeling/ADR-FORMAT.md，中文，含三条件+正反例）
```

每个文件单一职责：`SKILL.md` 是行为指令的唯一权威；`references/` 仅描述产出文档的格式，不被执行、只被引用。

---

## Task 1: 创建 SKILL.md 骨架与核心拷问循环（含铁律与纪律判据）

**Files:**
- Create: `socratic-questioning/SKILL.md`

**Interfaces:**
- 产出：可被 WorkBuddy 以 `/socratic-questioning` 唤起的技能文件，含 frontmatter(`name: socratic-questioning`) 与「核心拷问循环」「ADR 候选门槛」「铁律」三节。
- 后续任务在其上追加「按需落盘 / 会话生命周期 / 边界 / 验收」等节。

- [ ] **Step 1: 写失败检查——确认文件尚不存在**

```bash
test -f socratic-questioning/SKILL.md && echo "EXISTS" || echo "MISSING"
```

Expected: `MISSING`

- [ ] **Step 2: 写入 SKILL.md 骨架 + 核心拷问循环（含 CR-007 判据与铁律）**

将以下内容完整写入 `socratic-questioning/SKILL.md`（注意 frontmatter 的 `name` 取 `socratic-questioning`，description 用中文；`/socratic-questioning` 是用户面向入口，在 WorkBuddy 命令绑定中映射到本技能）：

````markdown
---
name: socratic-questioning
description: 用「拷问式访谈」打磨计划或设计。当用户想被深度追问以对齐理解、或明确要求把讨论结果落成 CONTEXT.md / ADR 文档时使用。触发词含「拷问 / grill / 对齐理解 / 帮我捋清楚」。
---

# socratic-questioning（合并版「拷问」技能）

把原版 `grill-me`（relentless 拷问式访谈）与 `grill-with-docs`（访谈中实时产出 CONTEXT.md 与 ADR）合并为单文件技能：**默认只聊天、不落盘**；只有用户明确要求保存时，才把结果写成 `CONTEXT.md` 与 `docs/adr/`。

## 何时使用

- 用户想对一个计划 / 设计 / 决策做深度推敲。
- 用户说「帮我 grill 一下」「拷问我」「把这件事想清楚」。
- 用户想产出或更新术语表（CONTEXT.md）与架构决策记录（ADR）。

触发方式：斜杠命令 `/socratic-questioning`（可附带主题，如 `/socratic-questioning 我想做个内部审批流`）。也可由上述自然语言意图唤起。

## 核心拷问循环（全程中文）

被唤起后，你进入「griller」角色，遵循以下纪律：

1. **一次一问**：每轮回复只抛**一个问题**，等用户回答后再继续；绝不一次甩多个问题。（允许就当前问题做少量解释，但不得包含第二个独立问题。）
2. **每题给推荐答案**：每个问题都要附上你的推荐答案，供用户参考或反驳（「我的建议是……」）。
3. **沿决策树推进**：走遍每个决策分支；有依赖关系的决策，先解前置依赖。
4. **事实 vs 决定**：能从环境获取的事实（读文件、查工具、看代码）直接查，别拿去问用户；「决定」属于用户，必须抛回确认，不可自作主张。
5. **逼精确**：挑战模糊 / 重载术语，构造边界场景逼用户把概念边界说清。
6. **内部累积草稿（不落盘）**：对话中只在上下文里维护两份草稿——术语表草稿（术语→定义 + 应避免的同义词）、决策候选草稿。
7. **铁律（最高优先级）**：**除非用户明确要求，绝不自动创建任何文件。** 在用户确认「达成共同理解」之前，不写文件、不改代码、不执行任何动作。

### 拷问纪律的可验证判据（验收用）

- **一次一问**：同一回复中出现 2 个及以上以问号结尾的独立问题 = 违例。
- **带推荐答案**：问题后无任何明确推荐立场 = 违例。
- **逐枝推进**：人工评审清单——① 是否每个决策点都问到；② 依赖是否先解前置；③ 是否有跳过分支。三项全满足即通过。

## ADR 候选门槛

某决策只有在**「敲定」且同时满足三条件**时才标为 ADR 候选、落盘为一条 ADR：

- **敲定** = 用户明确确认该决策，或会话已到达「达成共同理解」。
- 三条件（全部满足才写，任一不满足则仅留对话内草稿）：
  1. **难回退**——日后改变主意成本很高。
     - 正例：「选定 PostgreSQL 作为主数据库」（换库成本极高）。
     - 反例：「本次迭代先用 mock 数据跑通流程」（随时可换）。
  2. **外人会疑惑**——后人看代码会问「为什么这么做？」
     - 正例：「用领域事件而非同步 HTTP 做上下文间通信」（后人会疑惑）。
     - 反例：「API 返回 JSON」（常识，无人疑惑）。
  3. **真实取舍**——存在真正备选方案且你为具体理由选了其一。
     - 正例：「为降低延迟选读写分离，牺牲了一致性」（有得有失）。
     - 反例：「大家都用 REST」（无真正备选）。
````

- [ ] **Step 3: 写通过检查——确认关键句存在**

```bash
grep -q "绝不自动创建任何文件" socratic-questioning/SKILL.md && echo "OK_IRONRULE" || echo "FAIL"
grep -q "name: socratic-questioning" socratic-questioning/SKILL.md && echo "OK_NAME" || echo "FAIL"
grep -q "拷问纪律的可验证判据" socratic-questioning/SKILL.md && echo "OK_DISCIPLINE" || echo "FAIL"
grep -q "难回退" socratic-questioning/SKILL.md && echo "OK_ADR" || echo "FAIL"
```

Expected: 四行均为 `OK_*`（无 `FAIL`）

- [ ] **Step 4: 提交**

```bash
git -C socratic-questioning add SKILL.md
git -C socratic-questioning commit -m "feat(socratic-questioning): 骨架 + 核心拷问循环 + 铁律 + 纪律判据 + ADR门槛(CR-002/CR-007)"
```

---

## Task 2: 追加「按需落盘」（保存契约 CR-001 + 触发边界与门禁 CR-003 + 恢复 CR-008）

**Files:**
- Modify: `socratic-questioning/SKILL.md`（在「ADR 候选门槛」节后追加「按需落盘」整节）

**Interfaces:**
- 依赖：Task 1 已写入 frontmatter 与「ADR 候选门槛」。
- 产出：SKILL.md 中新增「按需落盘」节，含落盘位置、懒创建、可选纪要、**保存契约（CR-001）**、**触发边界与写入前确认门禁（CR-003）**、**恢复（CR-008）**。这是铁律的系统级保障核心。

- [ ] **Step 1: 写失败检查——确认「按需落盘」节尚不存在**

```bash
grep -q "## 按需落盘" socratic-questioning/SKILL.md && echo "EXISTS" || echo "MISSING"
```

Expected: `MISSING`

- [ ] **Step 2: 在文件末尾追加「按需落盘」整节**

在 `socratic-questioning/SKILL.md` 现有内容末尾追加（注意：保留 Task 1 已写内容，仅追加）：

````markdown

## 按需落盘（核心改动）

**仅当用户显式要求保存时**执行，写到**当前工作目录（cwd）**。

- **`CONTEXT.md`**（根目录）：统一语言 / 术语表，格式见 `references/CONTEXT-FORMAT.md`。
- **`docs/adr/NNNN-slug.md`**：每个敲定且达标的决策写一条 ADR，序号扫描 `docs/adr/` 现有最大号 +1，格式见 `references/ADR-FORMAT.md`。
- **懒创建**：没有术语就不建 `CONTEXT.md`；没有达标决策就不建 `docs/adr/`。
- **可选纪要**：仅当用户额外要求「连过程也存 / 要纪要」时，生成 `docs/grill-summary.md`，记录关键问答与最终结论（默认关闭）。

### 保存契约（CR-001）

落盘必须与既有 / 历史内容正确交互，禁止静默覆盖或重复膨胀：

1. **写入前检测存在性**：目标文件 / 目录已存在时，不整文件覆盖，走下方合并 / 去重逻辑。
2. **CONTEXT.md 合并更新**：按术语名合并——既有术语保留并更新定义，新术语追加；不整覆盖。
3. **ADR 去重**：按决策标题归一化 slug 去重；再次保存同一决策时**更新**既有 ADR，而非新建；只有全新决策才追加新序号。
4. **幂等**：用户重复说「保存」，不产生重复 ADR / 重复术语条目。
5. **序号唯一性**：扫描 `docs/adr/` 最大号 +1；会话内已占用该号时，带短会话标识后缀避免碰撞。

### 触发边界与写入前确认门禁（CR-003）

「显式保存请求」按以下三类处理：

- **强触发（直接走确认门禁后落盘）**：「保存 / 落文档 / 导出 / 写文件 / 生成 CONTEXT.md / 生成 ADR / 把结果存下来」等明确表达。
- **近似表达（先追问，不直接写）**：「帮我留着 / 记一下 / 存一下这个想法 / 这个挺关键的你记着」→ 回复确认意图：「你是想让我把当前结果保存到文件吗？」等用户确认后才写。
- **非保存语义（不写）**：「我自己在笔记里记一下」等用户自行记录 → 不写。

**确认门禁（铁律的系统级保障）**：每次真正写入前，向用户展示将写入内容的摘要 / diff（尤其 CONTEXT.md 的合并结果、将新建 / 更新的 ADR 列表），并询问「确认写入 cwd 的 `CONTEXT.md` / `docs/adr/` 吗？」用户确认后才写。此预览同时充当轻量回滚保障（见下方「恢复」）。

### 恢复（CR-008）

不内置撤销，但确认门禁的 diff 预览让用户在写入前可放弃；并声明：**可恢复性依赖 cwd 的版本控制（git）**。若 cwd 未受版本控制，写操作实际不可逆，需在落盘前提示用户。
````

- [ ] **Step 3: 写通过检查——确认三类触发与契约要点存在**

```bash
grep -q "强触发" socratic-questioning/SKILL.md && echo "OK_TRIGGER" || echo "FAIL"
grep -q "近似表达" socratic-questioning/SKILL.md && echo "OK_APPROX" || echo "FAIL"
grep -q "确认门禁" socratic-questioning/SKILL.md && echo "OK_GATE" || echo "FAIL"
grep -q "写入前检测存在性" socratic-questioning/SKILL.md && echo "OK_CONTRACT" || echo "FAIL"
grep -q "幂等" socratic-questioning/SKILL.md && echo "OK_IDEMPOTENT" || echo "FAIL"
```

Expected: 五行均为 `OK_*`

- [ ] **Step 4: 提交**

```bash
git -C socratic-questioning add SKILL.md
git -C socratic-questioning commit -m "feat(socratic-questioning): 按需落盘-保存契约(CR-001)+触发边界与确认门禁(CR-003)+恢复(CR-008)"
```

---

## Task 3: 追加「会话生命周期」与「边界与错误处理」「验收标准」（CR-004/005/010 + 边界更新）

**Files:**
- Modify: `socratic-questioning/SKILL.md`（追加「会话生命周期」「边界与错误处理」「验收标准」三节；其中「边界与错误处理」须覆盖 cwd 不可写、重启、铁律、多 context 与 CR-009 标注）

**Interfaces:**
- 依赖：Task 2 的「按需落盘」节。
- 产出：SKILL.md 末尾三节，闭合 CR-004（中途保存仅写已确认）、CR-005（终止提示）、CR-010（重启可观测 + 纯净度等式），并给出可测试的验收标准。

- [ ] **Step 1: 写失败检查——确认「会话生命周期」节尚不存在**

```bash
grep -q "## 会话生命周期" socratic-questioning/SKILL.md && echo "EXISTS" || echo "MISSING"
```

Expected: `MISSING`

- [ ] **Step 2: 追加「会话生命周期」「边界与错误处理」「验收标准」**

在 `socratic-questioning/SKILL.md` 末尾追加：

````markdown

## 会话生命周期

### 中途保存（CR-004）

- **用户显式保存请求覆盖第 7 点纪律**（属用户主动，非自动）。
- 中途保存**仅写入已被用户确认 / 敲定的决策与术语**；仍在演化、未确认的草稿不落盘。
- 若中途保存发生在所有决策敲定前，明确提示：「当前为草稿态，最终以达成共同理解后的保存为准」。

### 终止 / 放弃（CR-005）

- 用户确认「达成共同理解」时，**主动提示**：「结果仍在对话中、尚未保存为文件。需要我现在落盘吗？（CONTEXT.md / docs/adr/）」
- 非标准退出（「够了 / 停 / 不聊了」且未确认理解）：默认提示保存，或明确告知「将丢弃未保存的草稿」。

### 清空草稿 / 重启（CR-010）

- 「清空草稿 / 重启拷问」丢弃内部累积的术语与决策草稿。
- **可观测性**：重启时给出明确外部信号（如回复「已清空之前的草稿，重新开始」），作为重置已发生的证据。
- **纯净度等式**：重启后首次保存产出 == 本轮新确认集合（不含任何重启前内容）。

## 边界与错误处理

- **cwd 不可写 / 落盘失败**：提示用户并询问替代路径，不静默失败。
- **多 context 仓库**：若检测到根目录 `CONTEXT-MAP.md`，按 `references/CONTEXT-FORMAT.md` 中的多 context 推断规则选择对应 context；无法确定则询问用户（v1 沿用原版逻辑，不重新定义——对应评审 CR-006 DEFERRED）。
- **铁律**：除非用户明确要求，绝不自动创建任何文件。
- **范围之外（YAGNI）**：不引入子 agent；不做自动 PR / issue 等外部集成；不主动维护 `CONTEXT-MAP.md`；不在未获要求时生成任何过程记录类文件；**v1 写入目标固定为 cwd（可配置目标目录为后续增强——对应评审 CR-009 DEFERRED）**。

## 验收标准

1. `/socratic-questioning` 能启动一次结构化拷问：一次一问、带推荐答案、逐枝推进（判据见上文「拷问纪律的可验证判据」）。
2. 纯聊天、用户不要求保存时，工作目录**不产生任何文件**。
3. 用户显式说「保存 / 落文档」后，在 cwd 生成 `CONTEXT.md`（有术语时）与 `docs/adr/`（有达标决策时），格式符合 references 规范；重复保存幂等、不重复、不整覆盖既有内容。
4. 用户额外要求时，才生成 `docs/grill-summary.md`。
5. 全程中文，文档内容与原版语义一致。
6. 近似表达（「帮我留着」）触发追问而非直接写入；每次写入前出现确认门禁。
7. 用户确认「达成共同理解」时出现落盘提示；重启拷问后首次保存不含重启前内容。
````

- [ ] **Step 3: 写通过检查——确认 CR-004/005/010 要点与 DEFERRED 标注存在**

```bash
grep -q "中途保存" socratic-questioning/SKILL.md && echo "OK_MID" || echo "FAIL"
grep -q "主动提示" socratic-questioning/SKILL.md && echo "OK_TERM" || echo "FAIL"
grep -q "纯净度等式" socratic-questioning/SKILL.md && echo "OK_RESET" || echo "FAIL"
grep -q "CR-009 DEFERRED" socratic-questioning/SKILL.md && echo "OK_DEFERRED" || echo "FAIL"
grep -c "验收标准" socratic-questioning/SKILL.md | grep -q "2" && echo "OK_ACCEPT" || echo "FAIL"
```

Expected: 五行均为 `OK_*`

- [ ] **Step 4: 提交**

```bash
git -C socratic-questioning add SKILL.md
git -C socratic-questioning commit -m "feat(socratic-questioning): 会话生命周期(CR-004/005/010)+边界+验收标准"
```

---

## Task 4: 创建 references/CONTEXT-FORMAT.md（中文翻译，含单/多 context 推断）

**Files:**
- Create: `socratic-questioning/references/CONTEXT-FORMAT.md`

**Interfaces:**
- 依赖：Task 1–3 已在 SKILL.md 中引用 `references/CONTEXT-FORMAT.md`。
- 产出：中文术语表格式规范。Task 3 的多 context 规则指向本文的推断逻辑（闭合 CR-006 DEFERRED 的"沿用原版"要求）。

- [ ] **Step 1: 写失败检查——确认文件不存在**

```bash
test -f socratic-questioning/references/CONTEXT-FORMAT.md && echo "EXISTS" || echo "MISSING"
```

Expected: `MISSING`

- [ ] **Step 2: 写入中文翻译（结构对齐原版 domain-modeling/CONTEXT-FORMAT.md）**

将以下内容完整写入 `socratic-questioning/references/CONTEXT-FORMAT.md`：

````markdown
# CONTEXT.md 格式

## 结构

```md
# {上下文名称}

{一两句话说明这个上下文是什么、为什么存在。}

## 语言

**Order（订单）**：
{一两句话描述该术语}
_避免_：Purchase, transaction（采购、交易）

**Invoice（发票）**：
交付后发给客户的付款请求。
_避免_：Bill, payment request（账单、付款请求）

**Customer（客户）**：
下单的个人或组织。
_避免_：Client, buyer, account（客户、买家、账户）
```

## 规则

- **要有立场。** 同一概念有多种叫法时，挑最好的一个，其余列在 `_避免_` 下。
- **定义要紧凑。** 最多一两句话。定义它「是什么」，而非「做什么」。
- **只收录本项目上下文特有的术语。** 通用编程概念（超时、错误类型、工具模式）即便项目大量使用也不收录。添加前先问：这是本上下文独有的概念，还是通用编程概念？只有前者才收录。
- **自然成簇时按子标题分组。** 若所有术语属于同一内聚领域，平铺列表即可。

## 单 context 与多 context 仓库

**单 context（多数仓库）**：仓库根目录一个 `CONTEXT.md`。

**多 context**：根目录 `CONTEXT-MAP.md` 列出各 context 的位置与关系：

```md
# Context Map

## Contexts

- [Ordering](./src/ordering/CONTEXT.md) — 接收并跟踪客户订单
- [Billing](./src/billing/CONTEXT.md) — 生成发票并处理付款
- [Fulfillment](./src/fulfillment/CONTEXT.md) — 管理仓储拣货与发货

## Relationships

- **Ordering → Fulfillment**：Ordering 发出 `OrderPlaced` 事件；Fulfillment 消费以开始拣货
- **Fulfillment → Billing**：Fulfillment 发出 `ShipmentDispatched` 事件；Billing 消费以生成发票
- **Ordering ↔ Billing**：共享 `CustomerId` 与 `Money` 类型
```

技能推断适用哪种结构：

- 若存在 `CONTEXT-MAP.md`，读取它来定位各 context。
- 若仅有根目录 `CONTEXT.md`，为单 context。
- 若两者都不存在，在首个术语确定时按需懒创建根目录 `CONTEXT.md`。

存在多 context 时，推断当前主题归属哪一个；若不确定，询问用户。
````

- [ ] **Step 3: 写通过检查——确认结构与多 context 推断规则存在**

```bash
grep -q "_避免_" socratic-questioning/references/CONTEXT-FORMAT.md && echo "OK_AVOID" || echo "FAIL"
grep -q "CONTEXT-MAP.md" socratic-questioning/references/CONTEXT-FORMAT.md && echo "OK_MULTI" || echo "FAIL"
grep -q "若不确定，询问用户" socratic-questioning/references/CONTEXT-FORMAT.md && echo "OK_ASK" || echo "FAIL"
```

Expected: 三行均为 `OK_*`

- [ ] **Step 4: 提交**

```bash
git -C socratic-questioning add references/CONTEXT-FORMAT.md
git -C socratic-questioning commit -m "docs(socratic-questioning): 中文术语表格式(CONTEXT-FORMAT)"
```

---

## Task 5: 创建 references/ADR-FORMAT.md（中文翻译，含三条件与正反例）

**Files:**
- Create: `socratic-questioning/references/ADR-FORMAT.md`

**Interfaces:**
- 依赖：Task 1–3 已在 SKILL.md 中引用 `references/ADR-FORMAT.md`。
- 产出：中文 ADR 格式规范，含「何时提供 ADR」三条件及「哪些算」示例，与 SKILL.md「ADR 候选门槛」的敲定/三条件正反例保持一致口径。

- [ ] **Step 1: 写失败检查——确认文件不存在**

```bash
test -f socratic-questioning/references/ADR-FORMAT.md && echo "EXISTS" || echo "MISSING"
```

Expected: `MISSING`

- [ ] **Step 2: 写入中文翻译（结构对齐原版 domain-modeling/ADR-FORMAT.md）**

将以下内容完整写入 `socratic-questioning/references/ADR-FORMAT.md`：

````markdown
# ADR 格式

ADR 存放于 `docs/adr/`，采用顺序编号：`0001-slug.md`、`0002-slug.md` 等。

首个 ADR 需要时再懒创建 `docs/adr/` 目录。

## 模板

```md
# {决策的简短标题}

{1-3 句话：背景是什么、我们决定了什么、为什么。}
```

仅此而已。一条 ADR 可以只是一个段落。价值在于记录「做了什么决定」以及「为什么」——而非填满各个小节。

## 可选小节

仅当确有价值时才加入。多数 ADR 不需要。

- **Status** frontmatter（`proposed | accepted | deprecated | superseded by ADR-NNNN`）——决策被 revisit 时有用
- **Considered Options（候选方案）**——仅当被否决的替代方案值得记住时
- **Consequences（后果）**——仅当非显然的下游影响需要点明时

## 编号

扫描 `docs/adr/` 中已有最大编号并 +1。

## 何时提供 ADR

以下三条必须**全部**为真：

1. **难回退**——日后改变主意成本很高
2. **外人会疑惑**——未来读者会看代码并想「他们为什么这么干？」
3. **真实取舍**——存在真正备选方案，你为具体理由选了其一

若决策易回退，跳过——反正你会改回去。若不令人疑惑，没人会好奇。若无真正备选，除「我们做了显而易见的事」之外没什么可记录的。

### 哪些算

- **架构形态。**「我们用 monorepo。」「写模型是事件溯源，读模型投影进 Postgres。」
- **context 间集成模式。**「Ordering 与 Billing 通过领域事件通信，而非同步 HTTP。」
- **带来锁定的技术选型。** 数据库、消息总线、认证 provider、部署目标。不是每个库——只是那些换掉要花一个季度的事。
- **边界与范围决策。**「客户数据归 Customer context 所有；其他 context 仅以 ID 引用。」明确的「不做」与「做」同样有价值。
- **对显然路径的刻意偏离。**「因 X 我们用手写 SQL 而非 ORM。」任何合理读者会假设相反做法的场景。这能阻止下一位工程师去「修复」一个刻意的选择。
- **代码中不可见的约束。**「因合规要求我们不能用 AWS。」「因合作伙伴 API 契约，响应须低于 200ms。」
- **当拒绝理由不显然时的被否决备选。** 若你考虑过 GraphQL 却因微妙理由选了 REST，记下来——否则半年后别人又会提议 GraphQL。
````

- [ ] **Step 3: 写通过检查——确认三条件与示例存在**

```bash
grep -q "难回退" socratic-questioning/references/ADR-FORMAT.md && echo "OK_HARD" || echo "FAIL"
grep -q "外人会疑惑" socratic-questioning/references/ADR-FORMAT.md && echo "OK_SURPRISE" || echo "FAIL"
grep -q "真实取舍" socratic-questioning/references/ADR-FORMAT.md && echo "OK_TRADEOFF" || echo "FAIL"
grep -q "哪些算" socratic-questioning/references/ADR-FORMAT.md && echo "OK_EXAMPLES" || echo "FAIL"
```

Expected: 四行均为 `OK_*`

- [ ] **Step 4: 提交**

```bash
git -C socratic-questioning add references/ADR-FORMAT.md
git -C socratic-questioning commit -m "docs(socratic-questioning): 中文ADR格式(ADR-FORMAT)"
```

---

## Task 6: 整体验收评审（手动 dry-run + 条款核对）

**Files:**
- Read: `socratic-questioning/SKILL.md`、`socratic-questioning/references/CONTEXT-FORMAT.md`、`socratic-questioning/references/ADR-FORMAT.md`
- Read（参考）: `docs/superpowers/specs/2026-07-29-socratic-questioning-design.md`、`docs/superpowers/reviews/socratic-questioning/2026-07-29-review-001/consolidated-review.md`

**Interfaces:**
- 依赖：Task 1–5 全部完成。
- 产出：一份验收结论（写入 `docs/superpowers/plans/2026-07-29-socratic-questioning-acceptance.md`），逐条核对规格验收标准与 8 条 ACCEPTED 变更的落地情况。

- [ ] **Step 1: 内容一致性核对——三条核心纪律判据、铁律、触发门禁齐全**

```bash
for kw in "一次一问" "每题给推荐答案" "沿决策树推进" "绝不自动创建任何文件" "确认门禁" "保存契约" "难回退" "纯净度等式" "CR-009 DEFERRED" "CR-006 DEFERRED"; do
  grep -q "$kw" socratic-questioning/SKILL.md && echo "OK: $kw" || echo "MISSING: $kw"
done
```

Expected: 全部 `OK:`

- [ ] **Step 2: 引用完整性核对——SKILL.md 引用的两份 reference 均存在且非空**

```bash
test -s socratic-questioning/references/CONTEXT-FORMAT.md && echo "OK_CTX" || echo "FAIL"
test -s socratic-questioning/references/ADR-FORMAT.md && echo "OK_ADR" || echo "FAIL"
```

Expected: 两行均为 `OK_*`

- [ ] **Step 3: 模拟 `/socratic-questioning` 行为 dry-run（人工评审清单）**

按 SKILL.md 走一遍假设对话，确认：
1. 用户不要求保存时，全程不产生任何文件（铁律）。
2. 用户说「帮我留着」（近似表达）→ 出现追问而非写入。
3. 用户说「保存」→ 出现确认门禁（展示将写内容摘要）→ 确认后才写。
4. 重复说「保存」→ 不重复产生 ADR / 术语条目（幂等）。
5. 用户确认「达成共同理解」→ 出现落盘提示。
6. 「清空草稿 / 重启」后首次保存不含重启前内容（纯净度等式）。

- [ ] **Step 4: 写验收结论文件**

将上方核对结果整理为 `docs/superpowers/plans/2026-07-29-socratic-questioning-acceptance.md`，标注：规格 7 条验收标准全部可满足；8 条 ACCEPTED 变更已落地；2 条 DEFERRED（CR-006/CR-009）按"沿用原版/后续增强"明确标注，不阻塞 v1。

- [ ] **Step 5: 提交**

```bash
git -C socratic-questioning add docs/superpowers/plans/2026-07-29-socratic-questioning-acceptance.md
git -C socratic-questioning commit -m "docs(socratic-questioning): 实现验收结论(8 ACCEPTED 落地, 2 DEFERRED 标注)"
```

---

## Self-Review（计划自检）

**1. 规格覆盖：**
- 背景/目标/触发 → Task 1（何时使用 + `/socratic-questioning`）。
- 核心拷问循环（6 项纪律）→ Task 1。
- ADR 候选门槛 → Task 1（敲定 + 三条件 + 正反例）。
- 按需落盘（位置/懒创建/可选纪要）→ Task 2。
- 边界与错误处理 → Task 3。
- 验收标准（原 5 条）→ Task 3 扩展为 7 条（含 CR-003/CR-004/CR-010 可验证项）。
- 文件结构（SKILL.md + 2 references）→ Task 1/4/5。
- 8 条 ACCEPTED 变更 → 全部映射进 Task 1–3；2 条 DEFERRED → Task 3 边界节显式标注。

**2. 占位符扫描：** 无 TBD/TODO；每个步骤均含完整写入内容或确切检查命令。

**3. 类型一致性：** 本计划无函数签名；文件间引用（`references/CONTEXT-FORMAT.md`、`references/ADR-FORMAT.md`）在 Task 1 引用、Task 4/5 落地，路径一致。CR 编号在 Task 2/3 与审查产物一致。

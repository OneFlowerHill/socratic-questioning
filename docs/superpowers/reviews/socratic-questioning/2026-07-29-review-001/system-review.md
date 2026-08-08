# System Review

## 输出语言

本审核的所有描述性内容均使用中文撰写；所有大写下划线格式的标识符与枚举值（P0/P1/P2、CONFIRMED_DEFECT/MATERIAL_RISK、HIGH/MEDIUM/LOW、REVERSIBLE/PARTIALLY_REVERSIBLE/IRREVERSIBLE/UNKNOWN、REQUIRES_REVIEW、COMPLETED、REVIEWED/NOT_APPLICABLE、PENDING_DECISION 等）及 YAML 索引的 key/枚举值保持英文。

## Review Metadata

### Review ID

SYS-REVIEW-2026-07-29-001

### Reviewer

yy-system-critic

### Review Type

SYSTEM_REVIEW

### Design Spec

/Users/yuezhenhua/yonyou/AI/skills/socratic-questioning/docs/superpowers/specs/2026-07-29-socratic-questioning-design.md

### Review Date

2026-07-29

### Review Status

COMPLETED

---

## Review Scope

本审核从系统可靠性、数据完整性、操作韧性、安全边界、可逆性与长期可维护性角度评估该设计文档。

该设计描述的对象是一个**以 LLM 指令驱动的单文件技能（SKILL.md）**：主 agent 充当「griller」，在对话上下文内累积草稿，仅在用户明确要求时向**当前工作目录（cwd）**写入本地文件（CONTEXT.md、docs/adr/、可选 docs/grill-summary.md）。因此，本审核关注的风险集中在「文件写入的确定性、幂等性、冲突处理、动作门禁与回滚能力」，以及「指令级约束缺乏系统级硬性保障」带来的结构性风险。

本审核不：
- 重新设计该技能；
- 产出实现计划；
- 评审 SKILL.md 的措辞风格；
- 替代详细的提示词测试或生产验证。

本审核假设该设计最终将在生产环境中被实际调用与运行。

---

## Findings

### SC-001 — 落盘时直接覆盖 cwd 既有文件，缺乏预存在检测与合并机制

#### Severity

P1

#### Evidence Class

MATERIAL_RISK

#### Confidence

HIGH

#### Location

Design Spec 第 3.2 节（按需落盘）、第 2 节「落盘位置：当前工作目录（cwd）」、第 6 节验收标准第 3 条。

#### Risk

当用户在**已存在** CONTEXT.md、docs/adr/ 或 docs/grill-summary.md 的 cwd 中运行 /grill 并要求保存时，技能会按 3.2 的「写到当前工作目录」规则直接写入。规格仅在「没有术语就不建 CONTEXT.md；没有达标的决策就不建 docs/adr/」层面定义「懒创建」的**负向**条件，但**未定义目标文件已存在时的行为**（覆盖 / 合并 / 跳过 / 报错）。结果是：既有内容会被静默覆盖，造成数据丢失——尤其当这些文件来自先前的 grill 会话、grill-with-docs 或其他工具时。

#### Trigger Condition

1. cwd 已存在 CONTEXT.md（可能来自先前会话或其他工具）。
2. 用户启动 `/socratic-questioning` 并推进访谈。
3. 用户说「保存 / 落文档」。
4. 技能按 3.2 直接写 cwd，未做 pre-write 检查。
5. 既有 CONTEXT.md 被整体覆盖，用户此前内容丢失。

#### Causal Chain

```text
目标文件已存在
    ↓
技能无 pre-write 存在性检测
    ↓
直接 write 覆盖
    ↓
既有内容丢失且不可恢复（除非 cwd 处于版本控制）
```

#### Consequence

数据完整性影响：既有术语表 / ADR / 纪要被静默覆盖，属于不可逆或仅部分可逆的数据丢失。该风险与验收标准第 2 条「纯聊天不产生任何文件」并不冲突，但在「保存」路径上直接破坏用户对既有文件的预期。

#### Likelihood

MEDIUM。用户在已有项目 / 仓库 / 先前会话产物的 cwd 中使用该技能是常见场景，而非边缘情况。

#### Reversibility

PARTIALLY_REVERSIBLE。仅当 cwd 处于 git 版本控制且文件已被跟踪时，可通过版本历史恢复；否则实际不可逆。

#### Recommendation

落盘前必须检测目标文件是否已存在；对已存在的文件应明确规定行为（合并/追加、询问用户、或跳过重名），且 CONTEXT.md 不应整文件覆盖而应更新/合并。至少应在写入前对已有文件给出冲突提示，禁止静默覆盖。

#### Evidence

- 第 3.2 节：「写到当前工作目录」「懒创建：没有术语就不建 CONTEXT.md；没有达标的决策就不建 docs/adr/」——只定义了「不存在则不建」，未定义「存在则如何」。
- 第 2 节：落盘位置固定为 cwd。
- 第 6 节验收标准第 3 条仅要求「生成」文件，未要求对既有文件做保护。

#### Assumptions

- CONFIRMED — 设计明确将落盘位置固定为 cwd，且未提及任何存在性检查。
- INFERRED — 用户极可能在已含 CONTEXT.md / docs/adr/ 的目录中使用该技能（与 grill-with-docs 生态一致）。

#### Reversibility Analysis

- 可回滚：仅依赖外部 git 历史（若文件被跟踪）。
- 不可回滚：若 cwd 无版本控制，或既有内容从未提交，则写操作不可恢复。
- 恢复是否需人工干预：是（需用户手动从 git 还原或重新整理）。
- 恢复是否依赖不可用系统：依赖 git 可用性，而技能本身不提供任何写入前快照。

#### Operational Impact

`NO_MATERIAL_OPERATIONAL_IMPACT_IDENTIFIED`（该风险主要影响数据完整性而非运行期运维，但会转化为用户侧的恢复工单/咨询）。

#### Security Impact

`NO_MATERIAL_SECURITY_IMPACT_IDENTIFIED`（无认证/授权边界被突破，但属于数据完整性范畴，详见 Consequence）。

#### Maintenance Impact

长期后果：由于写入语义未对「已存在文件」定义，未来维护者难以判断「保存」究竟是新建还是更新，易在重构时引入覆盖 bug；且缺乏统一契约会增加跨技能（如 grill-with-docs）共存时的冲突。

#### Source References

* Design Spec 第 3.2 节
* Design Spec 第 2 节（落盘位置）
* Design Spec 第 6 节验收标准第 3 条

---

### SC-002 — ADR 序号按「扫描最大号 +1」生成，缺乏并发安全与重复保存的更新语义

#### Severity

P1

#### Evidence Class

MATERIAL_RISK

#### Confidence

MEDIUM

#### Location

Design Spec 第 3.2 节（ADR 序号扫描 docs/adr/ 现有最大号 +1）。

#### Risk

ADR 文件名序号通过扫描 docs/adr/ 现有最大号 +1 生成。在序号生成与文件写入之间既无锁、也无幂等/更新保障，导致两类数据一致性问题：

(a) **并发覆盖**：同一 cwd 内并发运行两个 /grill 会话（或多个终端、多次快速保存）时，二者可能读到相同的最大号，生成同名文件，后写者覆盖前写者。
(b) **重复保存的内容漂移**：用户先保存一次生成 ADR-0001…0003，之后再次 grill 并保存时，技能只追加新 ADR（0004…），而 CONTEXT.md 每次被**整文件重写**。若用户在两次保存之间手动补充了术语，第二次整写会丢失这些补充；同时新会话可能就同一决策重新生成一条 ADR，造成决策记录重复/不一致。

#### Trigger Condition

1. docs/adr/ 已存在 ADR-0001…0003。
2. 用户再开一个 grill 会话并保存（或同一时刻另一会话保存）。
3. 序号扫描读到 3 → 计划写 0004。
4. 并发/重复保存的另一路径也读到 3 → 同样写 0004。
5. 后写者覆盖前写者，或两次保存产生语义重复/冲突的 ADR 与不一致的 CONTEXT.md。

#### Causal Chain

```text
无锁扫描序号
    ↓
并发/重复保存读到相同序号
    ↓
同名文件覆盖 或 内容漂移
    ↓
ADR 重复/覆盖、术语表与决策记录不一致
```

#### Consequence

数据完整性影响：ADR 重复或覆盖、决策记录不一致、CONTEXT.md 在重复保存时被整写覆盖（与 SC-001 叠加）。该缺陷依赖于「序号扫描与写入非原子」这一结构性假设。

#### Likelihood

MEDIUM。并发会话虽不频繁，但「先保存 → 再 grill → 再保存」的重复保存路径非常常见；后者足以触发内容漂移。

#### Reversibility

PARTIALLY_REVERSIBLE。被覆盖的 ADR 可经 git 恢复；但重复/不一致的语义需人工合并。

#### Recommendation

明确 ADR 生成的并发与重复保存语义：序号生成应在写入前再次确认（或使用带会话/时间戳的唯一 slug 降低碰撞）；对 CONTEXT.md 定义更新/合并而非整写；对「再次保存」应区分「新建 ADR」与「更新已有 ADR」，避免重复决策记录。

#### Evidence

- 第 3.2 节：「序号扫描 docs/adr/ 现有最大号 +1」。
- 第 3.2 节：CONTEXT.md「格式符合 references 规范」写入，未提更新/合并。

#### Assumptions

- CONFIRMED — 设计以扫描目录最大值的方式定序号，未提及锁或唯一性保障。
- INFERRED — 用户会在同一 cwd 多次保存（设计第 5 节支持「用户想重来」，隐含多次会话）。

#### Reversibility Analysis

- 可回滚：ADR 文件若被 git 跟踪可恢复。
- 不可回滚：语义重复/不一致需人工判别合并，无法自动还原到一致状态。
- 恢复依赖：外部 git。

#### Operational Impact

`NO_MATERIAL_OPERATIONAL_IMPACT_IDENTIFIED`（主要表现为数据一致性，非运行期运维事件）。

#### Security Impact

`NO_MATERIAL_SECURITY_IMPACT_IDENTIFIED`

#### Maintenance Impact

长期后果：序号规则与「整写 CONTEXT.md」的隐式契约若不写入文档，维护者无从得知重复保存的预期行为，重构时极易破坏一致性。

#### Source References

* Design Spec 第 3.2 节（ADR 序号规则）
* Design Spec 第 5 节（用户想重来）

---

### SC-003 — 保存动作完全依赖自然语言意图识别，无写入前二次确认（动作门禁脆弱）

#### Severity

P2

#### Evidence Class

MATERIAL_RISK

#### Confidence

MEDIUM

#### Location

Design Spec 第 3.2 节（「落盘位置、触发词以自然语言识别，不强制特定命令」）、第 5 节「铁律：除非用户明确要求，绝不自动创建任何文件」。

#### Risk

落盘意图通过「保存 / 落文档 / 导出」等自然语言触发词识别，无结构化命令。LLM 对模糊表述的判定可能**误触发**（如用户说「先记下这点」「存一下这个想法」被解读为保存）或**漏触发**。更严重的是，「铁律」仅靠指令约束 LLM，无系统级硬性拦截；一旦 LLM 误判，即在 cwd 产生非预期文件，直接破坏验收标准第 2 条与第 5 节的铁律。

#### Trigger Condition

1. 用户表达含糊（「记下来」「存一下」）。
2. LLM 将其归类为保存触发。
3. 在用户实际只想继续聊时写入 cwd 文件。
4. 工作目录出现非预期文件，违反铁律。

#### Causal Chain

```text
自然语言触发无结构化命令
    ↓
意图误判（模糊表述）
    ↓
未授权写入
    ↓
违反「绝不自动创建文件」铁律、污染 cwd
```

#### Consequence

正确性与信任边界影响：非预期文件被创建（并可能触发 SC-001 的覆盖）；铁律被违反。该风险源于「行为约束完全寄托于模型指令合规性」这一结构，而非确定性系统机制。

#### Likelihood

MEDIUM。自然语言歧义在日常对话中常见；且铁律缺乏可执行的系统保障。

#### Reversibility

PARTIALLY_REVERSIBLE。非预期写入可经 git 恢复或删除，但与 SC-001 叠加时可能已覆盖既有内容。

#### Recommendation

对「保存/落盘」意图引入显式的二次确认步骤（如「将在 cwd 写入 CONTEXT.md 与 docs/adr/，确认？」），将铁律从「指令约束」提升为「写入前确认门禁」；并对高歧义触发词要求澄清，而非直接写入。

#### Evidence

- 第 3.2 节：「落盘位置、触发词（保存/落文档/导出）均以自然语言识别，不强制特定命令。」
- 第 5 节：「铁律：除非用户明确要求，绝不自动创建任何文件」。

#### Assumptions

- CONFIRMED — 设计明确以自然语言识别触发，且铁律以指令形式存在。
- INFERRED — LLM 对模糊保存表述存在误判可能（这是指令驱动系统的已知结构性弱点）。

#### Reversibility Analysis

- 可回滚：误写文件可删除/还原。
- 不可回滚：若误写同时覆盖了既有文件（SC-001），则依赖 git。
- 恢复依赖：外部 git / 用户手动清理。

#### Operational Impact

`NO_MATERIAL_OPERATIONAL_IMPACT_IDENTIFIED`

#### Security Impact

`NO_MATERIAL_SECURITY_IMPACT_IDENTIFIED`（属行为正确性与信任边界，非传统安全边界）。

#### Maintenance Impact

长期后果：动作门禁的正确性完全依赖提示词措辞，维护者在调整 SKILL.md 时难以保证铁律不被回归破坏，缺乏可测试的系统级断言。

#### Source References

* Design Spec 第 3.2 节
* Design Spec 第 5 节（铁律）

---

### SC-004 — 落盘后无回滚/恢复路径，已写文件仅能依赖外部 git 恢复

#### Severity

P2

#### Evidence Class

MATERIAL_RISK

#### Confidence

HIGH

#### Location

Design Spec 第 5 节（「用户想重来：支持清空草稿 / 重启拷问，丢弃内部累积的术语与决策草稿」）、第 3.2 节（按需落盘）。

#### Risk

技能在 cwd 写入文件后，未定义任何回滚或恢复机制。「重启拷问」只丢弃**对话上下文内的草稿**，对已落盘文件无效。若写入覆盖了既有内容（SC-001）或写错位置，恢复完全依赖 cwd 是否处于版本控制。对未纳入 git 的工作目录，写操作实际不可逆。设计将「可恢复性」这一关键责任外部化给了用户环境，却未在任何验收标准或边界处理中声明该前提。

#### Trigger Condition

1. 文件已写入 cwd。
2. 用户发现内容错误或位置错误。
3. 技能无内置撤销/快照。
4. 若 cwd 无 git，则无法恢复。

#### Causal Chain

```text
文件写入 cwd
    ↓
技能无内置回滚/快照
    ↓
恢复仅依赖外部 git
    ↓
无版本控制时数据不可逆丢失
```

#### Consequence

恢复影响：不可恢复的数据丢失（当 cwd 无 git 时）；即便有 git，也需用户具备版本控制知识才能手动还原。这是「按需落盘」这一高副作用操作的恢复空白。

#### Likelihood

LOW。多数 cwd 为受版本控制的仓库；但设计并未假设或校验这一点，且存在非 git 工作目录场景。

#### Reversibility

PARTIALLY_REVERSIBLE（有 git，依赖人工还原）/ 在缺 git 时实际为 IRREVERSIBLE。

#### Recommendation

在落盘前对将写入/覆盖的文件做一次性快照（或将「保存」设计为可预览 diff），使写入具备基本可撤销性；并在技能说明或验收标准中明确「可恢复性依赖 cwd 版本控制」这一前提，避免用户误以为技能自身提供回滚。

#### Evidence

- 第 5 节：「重启拷问」仅丢弃内部草稿，对落盘文件无作用。
- 第 3.2 节：写入 cwd，无回滚描述。

#### Assumptions

- CONFIRMED — 设计未提供任何落盘后的回滚机制。
- UNKNOWN — 用户 cwd 是否处于版本控制未知（设计未假设）。

#### Reversibility Analysis

- 可回滚：依赖 git 历史（若文件被跟踪）。
- 不可回滚：非 git 目录或无提交历史时。
- 恢复需人工干预：是。

#### Operational Impact

`NO_MATERIAL_OPERATIONAL_IMPACT_IDENTIFIED`

#### Security Impact

`NO_MATERIAL_SECURITY_IMPACT_IDENTIFIED`

#### Maintenance Impact

长期后果：恢复逻辑缺失意味着任何写错位置的事故都需用户介入，增加支持成本；且该前提若不文档化，后续维护者可能误以为写入是安全的。

#### Source References

* Design Spec 第 5 节
* Design Spec 第 3.2 节

---

### SC-005 — 写入目标恒为 cwd，缺乏目标目录/会话隔离，易污染工作区与仓库

#### Severity

P2

#### Evidence Class

MATERIAL_RISK

#### Confidence

MEDIUM

#### Location

Design Spec 第 2 节（落盘位置：当前工作目录 cwd）、第 5 节（多 context：仅检测到 CONTEXT-MAP.md 时响应）。

#### Risk

落盘位置固定为 cwd 根目录，无目标目录参数、无会话标识。不同主题 / 不同时间的 grill 会话都写入同一 cwd，无法隔离；且 cwd 可能是受版本控制的仓库根，CONTEXT.md / docs/adr/ 会被写入仓库并可能被误提交。多 context（CONTEXT-MAP.md）仅「检测到时正确响应」，默认写目标仍是未区分的 cwd，意味着即便存在多 context 体系，本技能的默认写入仍可能与既有 context 体系混同。

#### Trigger Condition

1. 用户在项目仓库根目录（cwd）运行 `/socratic-questioning`。
2. 用户要求保存。
3. CONTEXT.md、docs/adr/ 写入仓库根。
4. 被 git 跟踪 / 误提交，污染仓库；或与另一主题的会话产物混在同一目录。

#### Causal Chain

```text
无目标目录参数
    ↓
固定写 cwd
    ↓
与仓库/其他会话文件混同
    ↓
工作区污染、潜在误提交、多会话内容混淆
```

#### Consequence

可维护性与数据隔离影响：仓库被非预期文件污染、不同主题的术语/决策相互混淆、误提交风险。该风险源于「写入目标不可配置」这一结构性简化。

#### Likelihood

MEDIUM。在仓库根目录运行工具是常态；多主题复用同一 cwd 也常见。

#### Reversibility

PARTIALLY_REVERSIBLE。误提交的文件可经 git 撤销；但内容混淆需人工梳理。

#### Recommendation

提供可选的显式目标目录（或在触发保存时确认写入位置），避免无条件写入仓库根；对检测到 CONTEXT-MAP.md 的多 context 场景，应明确本技能写入归属于哪个 context，而非默认落到未区分的 cwd。

#### Evidence

- 第 2 节：落盘位置固定为 cwd。
- 第 5 节：多 context 仅「检测到时响应」，默认写目标仍是 cwd。

#### Assumptions

- CONFIRMED — 设计固定落盘位置为 cwd，且未提供目标目录参数。
- INFERRED — 用户可能在仓库根目录使用该技能。

#### Reversibility Analysis

- 可回滚：误提交可经 git 撤销。
- 不可回滚：内容混淆需人工判别。
- 恢复依赖：外部 git / 用户手动整理。

#### Operational Impact

`NO_MATERIAL_OPERATIONAL_IMPACT_IDENTIFIED`

#### Security Impact

`NO_MATERIAL_SECURITY_IMPACT_IDENTIFIED`

#### Maintenance Impact

长期后果：缺乏目标隔离使跨项目/跨会话的术语与决策难以管理，且与生态内既有 CONTEXT-MAP 多 context 体系缺乏明确衔接，增加后期重构成本。

#### Source References

* Design Spec 第 2 节
* Design Spec 第 5 节（多 context）

---

## Finding Summary

| Finding ID | Severity | Evidence Class                 | Confidence      | Likelihood      | Reversibility                                        | Short Description |
| ---------- | -------- | ------------------------------ | --------------- | --------------- | ---------------------------------------------------- | ----------------- |
| SC-001     | P1       | MATERIAL_RISK                  | HIGH            | MEDIUM          | PARTIALLY_REVERSIBLE                                 | 落盘直接覆盖 cwd 既有文件，无预存在检测/合并 |
| SC-002     | P1       | MATERIAL_RISK                  | MEDIUM          | MEDIUM          | PARTIALLY_REVERSIBLE                                 | ADR 序号扫描+1 缺乏并发安全与重复保存更新语义 |
| SC-003     | P2       | MATERIAL_RISK                  | MEDIUM          | MEDIUM          | PARTIALLY_REVERSIBLE                                 | 保存触发仅靠自然语言识别，无写入前二次确认 |
| SC-004     | P2       | MATERIAL_RISK                  | HIGH            | LOW             | PARTIALLY_REVERSIBLE                                 | 落盘后无回滚/恢复路径，仅依赖外部 git |
| SC-005     | P2       | MATERIAL_RISK                  | MEDIUM          | MEDIUM          | PARTIALLY_REVERSIBLE                                 | 写入恒为 cwd，缺乏目标目录/会话隔离 |

---

## System Risk Coverage

| Risk Dimension                   | Status          | Finding IDs       |
| -------------------------------- | --------------- | ----------------- |
| Data Integrity and Consistency   | REVIEWED        | SC-001, SC-002    |
| Security Boundaries              | REVIEWED        | SC-003            |
| Authentication and Authorization | NOT_APPLICABLE  | —（单用户本地技能，无认证/授权边界） |
| Availability and Resilience      | NOT_APPLICABLE  | —（纯本地 LLM 技能，无服务可用性维度） |
| Failure Recovery                 | REVIEWED        | SC-004            |
| External Dependencies            | NOT_APPLICABLE  | —（无外部服务依赖，仅读写本地文件系统） |
| Concurrency and Race Conditions  | REVIEWED        | SC-002            |
| Data Lifecycle and Migration     | REVIEWED        | SC-001, SC-005    |
| Backward Compatibility           | REVIEWED        | SC-002, SC-005    |
| Operational Complexity           | REVIEWED        | SC-003, SC-004    |
| Maintenance Burden               | REVIEWED        | SC-001, SC-002, SC-005 |
| Irreversible Decisions           | REVIEWED        | SC-001, SC-004    |
| Over-Engineering                 | NOT_APPLICABLE  | —（方案 A 明确 YAGNI，未见不成比例复杂度） |
| Observability and Diagnosis      | NOT_APPLICABLE  | —（无运行期可观测性需求；风险为写前行为而非运行诊断） |

---

## Irreversible Decisions

### ID-001 — 落盘语义采用「直接覆盖 cwd 既有文件」而非「检测+合并/确认」

#### Decision

设计将落盘位置固定为 cwd，且对目标文件已存在时的行为未做任何定义（默认即覆盖/新建）。

#### Why It Is Difficult to Reverse

一旦用户习惯了该行为、或既有项目已因该行为产生被覆盖/误提交的历史，纠正为「合并/确认」语义会改变既有用户预期，并需重新定义 CONTEXT.md 的更新契约；属于对外可见的行为契约承诺。

#### Reversal Cost

MEDIUM

#### Risk

若实际应以「合并/更新」为准，则当前设计为数据丢失埋下结构性隐患（见 SC-001）。

#### Recommendation

在实现前明确「已存在文件」的处理契约，并写入 references 格式规范或验收标准。

#### Status

OPEN

---

### ID-002 — 保存触发仅以自然语言识别，不提供结构化命令

#### Decision

设计明确「触发词以自然语言识别，不强制特定命令」（第 3.2 节）。

#### Why It Is Difficult to Reverse

若后续希望引入确定性命令（如显式 `/socratic-questioning-save`）以降低误触发，需改变用户交互契约与技能描述，属于对外接口承诺。

#### Reversal Cost

LOW

#### Risk

动作门禁脆弱，铁律依赖模型合规（见 SC-003）。

#### Recommendation

至少引入写入前二次确认，作为对自然语言触发的补充保障。

#### Status

OPEN

---

## Over-Engineering and Complexity Risks

本设计采用方案 A（单文件自包含 SKILL.md，主 agent 直接充当 grill 者，不拆子 agent），并在第 7 节明确 YAGNI 边界（不引入子 agent 编排、不做外部系统集成、不主动维护多 context 体系）。经评估，**未发现不成比例或产生实质工程/运维/维护风险的复杂度**。因此本节标记为 NOT_APPLICABLE，无 OC 条目。

---

## Unresolved System Questions

### Q-001 — cwd 是否处于版本控制未知，且设计未声明该前提

#### Question

用户运行 `/socratic-questioning` 的 cwd 是否处于 git 版本控制？设计是否假设/要求这一点？

#### Why It Matters

SC-001 与 SC-004 的可逆性（PARTIALLY_REVERSIBLE vs 实际 IRREVERSIBLE）直接取决于该前提。若设计无意假设 git，则数据丢失风险高于当前评估。

#### Required Clarification

需明确：技能是否假定 cwd 为 git 仓库，或是否应在写入前检测版本控制状态并据此调整提示/保护。

#### Status

OPEN

---

### Q-002 — 重复保存时 CONTEXT.md 与 ADR 的「更新 vs 新建」语义未定义

#### Question

用户第二次及以后保存时，CONTEXT.md 应如何更新（合并？整写？），ADR 应如何避免重复决策记录？

#### Why It Matters

SC-002 的内容漂移与重复 ADR 风险依赖于该语义的缺失；若不澄清，实现会各自发挥，造成跨版本不一致。

#### Required Clarification

需定义「再次保存」的明确契约：CONTEXT.md 更新策略与 ADR 去重/更新策略。

#### Status

OPEN

---

## Review Limitations

- 设计文档未提供 SKILL.md 的实际提示词文本，无法验证「铁律」「一次一问」等指令在模型上的真实合规强度（影响 SC-003 置信度）。
- 未提供用户典型 cwd 环境特征（是否 git 仓库、是否已有 CONTEXT.md），影响 SC-001/SC-004 的可逆性判定精度。
- 未提供 references/CONTEXT-FORMAT.md 与 ADR-FORMAT.md 的内容，无法验证格式规范是否已包含「已存在文件」处理约定。
- 该对象为 LLM 指令驱动技能，其「系统行为」本质上由模型推理决定，部分风险（SC-003）属「指令约束 vs 系统保障」的结构性薄弱，而非确定性代码缺陷。

---

## Reviewer Conclusion

### Critical Finding Count

* P0: 0
* P1: 2
* P2: 3

### Risk Summary

* Security risks: 0（无传统安全边界被突破；SC-003 属行为正确性/信任边界）
* Data integrity risks: 3（SC-001, SC-002, SC-005）
* Availability and resilience risks: 0
* Operational risks: 0（NO_MATERIAL_OPERATIONAL_IMPACT_IDENTIFIED）
* Maintenance risks: 3（SC-001, SC-002, SC-005 的长期维护后果）
* Irreversible decisions: 2（ID-001, ID-002）
* Over-engineering risks: 0

### Review Result

REQUIRES_REVIEW

本审核识别了以「文件写入的确定性、幂等性、冲突处理、动作门禁与回滚能力」为核心的一组系统级风险，供 Consolidation 阶段考量。

System Critic 不决定这些 Finding 最终是被接受、拒绝、延期还是以其他方式处置；最终处置由 Decision Protocol 决定。

---

## Machine-Readable Finding Index

```yaml
review:
  review_id: "SYS-REVIEW-2026-07-29-001"
  reviewer: "yy-system-critic"
  review_type: "SYSTEM_REVIEW"
  status: "COMPLETED"

findings:
  - id: "SC-001"
    severity: "P1"
    evidence_class: "MATERIAL_RISK"
    confidence: "HIGH"
    title: "落盘直接覆盖 cwd 既有文件，无预存在检测/合并"
    location: "Design Spec 第 3.2 节、第 2 节（落盘位置）、第 6 节验收标准第 3 条"
    likelihood: "MEDIUM"
    reversibility: "PARTIALLY_REVERSIBLE"
    source_references:
      - "Design Spec 第 3.2 节"
      - "Design Spec 第 2 节"
      - "Design Spec 第 6 节"
    risk_dimensions:
      - "Data Integrity and Consistency"
      - "Irreversible Decisions"
    status: "PENDING_DECISION"

  - id: "SC-002"
    severity: "P1"
    evidence_class: "MATERIAL_RISK"
    confidence: "MEDIUM"
    title: "ADR 序号扫描+1 缺乏并发安全与重复保存更新语义"
    location: "Design Spec 第 3.2 节（ADR 序号规则）"
    likelihood: "MEDIUM"
    reversibility: "PARTIALLY_REVERSIBLE"
    source_references:
      - "Design Spec 第 3.2 节"
      - "Design Spec 第 5 节"
    risk_dimensions:
      - "Data Integrity and Consistency"
      - "Concurrency and Race Conditions"
      - "Backward Compatibility"
    status: "PENDING_DECISION"

  - id: "SC-003"
    severity: "P2"
    evidence_class: "MATERIAL_RISK"
    confidence: "MEDIUM"
    title: "保存触发仅靠自然语言识别，无写入前二次确认"
    location: "Design Spec 第 3.2 节、第 5 节（铁律）"
    likelihood: "MEDIUM"
    reversibility: "PARTIALLY_REVERSIBLE"
    source_references:
      - "Design Spec 第 3.2 节"
      - "Design Spec 第 5 节"
    risk_dimensions:
      - "Security Boundaries"
      - "Operational Complexity"
    status: "PENDING_DECISION"

  - id: "SC-004"
    severity: "P2"
    evidence_class: "MATERIAL_RISK"
    confidence: "HIGH"
    title: "落盘后无回滚/恢复路径，仅依赖外部 git"
    location: "Design Spec 第 5 节、第 3.2 节"
    likelihood: "LOW"
    reversibility: "PARTIALLY_REVERSIBLE"
    source_references:
      - "Design Spec 第 5 节"
      - "Design Spec 第 3.2 节"
    risk_dimensions:
      - "Failure Recovery"
      - "Irreversible Decisions"
    status: "PENDING_DECISION"

  - id: "SC-005"
    severity: "P2"
    evidence_class: "MATERIAL_RISK"
    confidence: "MEDIUM"
    title: "写入恒为 cwd，缺乏目标目录/会话隔离"
    location: "Design Spec 第 2 节、第 5 节（多 context）"
    likelihood: "MEDIUM"
    reversibility: "PARTIALLY_REVERSIBLE"
    source_references:
      - "Design Spec 第 2 节"
      - "Design Spec 第 5 节"
    risk_dimensions:
      - "Data Lifecycle and Migration"
      - "Maintenance Burden"
      - "Backward Compatibility"
    status: "PENDING_DECISION"

irreversible_decisions:
  - id: "ID-001"
    status: "OPEN"
    title: "落盘语义采用直接覆盖 cwd 既有文件而非检测+合并/确认"
  - id: "ID-002"
    status: "OPEN"
    title: "保存触发仅以自然语言识别，不提供结构化命令"

complexity_risks: []

open_questions:
  - id: "Q-001"
    status: "OPEN"
    question: "cwd 是否处于版本控制未知，且设计未声明该前提"
  - id: "Q-002"
    status: "OPEN"
    question: "重复保存时 CONTEXT.md 与 ADR 的更新 vs 新建语义未定义"
```

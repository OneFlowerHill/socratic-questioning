# Product Review

## Review Metadata

### Review ID

PR-20260807-001

### Reviewer

product-reviewer

### Review Type

PRODUCT_REVIEW

### Design Spec

/Users/yuezhenhua/yonyou/projects/0__AI/skills/deep-discussion/docs/superpowers/specs/2026-08-07-discussion-summary-format-design.md

### Review Date

2026-08-07

### Review Status

COMPLETED

---

## Review Scope

本次评审从产品正确性、业务规则完整性、用户行为、工作流完整性及运维可用性角度评估该设计规格。

本次评审不评估：

- 实现质量
- 源码质量
- 详细系统架构
- 技术选型
- 基础设施设计
- 性能优化
- 测试实现细节

本次评审的目标是识别产品层面的需求歧义、不完整、矛盾、不安全或定义不足以支撑实现的问题。

---

## 规格完整性检查清单

| 维度 | 状态 | 说明 |
|---|---|---|
| 问题定义 | PRESENT | 第1节明确描述了当前单文件的局限及改进目标 |
| 期望结果 | PRESENT | 第1节列出三条目标，第8节给出验收标准 |
| 业务规则 | REVIEWED | 第3-5节定义了落盘规则、去重、幂等行为；存在缺口（见PR-001/PR-002） |
| 工作流 | REVIEWED | 保存→扫目录→去重→写入的主流程已定义；异常路径存在缺口（见PR-002/PR-003） |
| 状态与迁移 | NOT_APPLICABLE | 纪要文件本身非状态机驱动实体 |
| 边界条件 | REVIEWED | 第7节覆盖了slug歧义、旧文件迁移、多context、跨进程等边界；存在缺口（见PR-003/PR-004） |
| 数据生命周期 | REVIEWED | 文件创建和更新有定义，但长期管理（归档/清理）缺失（见PR-004） |
| 假设声明 | REVIEWED | 多处于第7节显式声明为YAGNI或已知取舍 |

---

## Findings

### PR-001 — Slug翻译非确定性将导致同主题文件分裂

#### Severity

P1

#### Evidence Class

CONFIRMED_DEFECT

#### Confidence

HIGH

#### Location

设计规格第3节「落盘规则」—— slug 生成规则；第2节关键设计决策「按主题合并（严格同 ADR）」模型。

#### The Gap

设计规格规定「中文主题由技能译成短英文 slug（如『内部审批流』→ `internal-approval-flow`）」，且去重模型为「按主题 slug 去重——同主题再存 → 复用既有文件序号」。但 AI 驱动的中译英翻译本质上是非确定性的——同一中文主题在不同调用中可能产生不同的英文 slug。

例如：
- 「内部审批流程」可能译为 `internal-approval-flow` 或 `internal-approval-process`
- 「用户登录优化」可能译为 `user-login-optimization` 或 `user-login-improvement`
- 「数据导出功能」可能译为 `data-export-feature` 或 `data-export-function`

当翻译结果不同时，同一主题会被分散到多个文件中，直接破坏了设计规格自身声明的核心设计决策「按主题合并（严格同 ADR）」。

此缺陷与 ADR 场景有本质区别：ADR 的 slug 是从**用户手工给定的标题**经确定性规则（kebab-case 化）派生，不存在翻译步骤；而纪要的 slug 多了一层 AI 翻译，引入了非确定性。

#### Trigger Scenario

1. 用户在第一次会话中讨论「内部审批流程」，技能将主题译为 `internal-approval-flow`，保存到 `docs/discussions/0001-internal-approval-flow.md`。
2. 用户在第二次会话中再次讨论同一主题「内部审批流程」。
3. 技能重新翻译主题，本次产生的 slug 为 `internal-approval-process`。
4. 技能扫描 `docs/discussions/` 后未找到匹配的 slug 文件（已有的是 `internal-approval-flow`，与本次 `internal-approval-process` 不同）。
5. 技能创建一个新文件 `docs/discussions/0002-internal-approval-process.md`，而非在已有文件中追加会话段。
6. 同一主题的讨论历史被分裂到两个文件中，「按主题合并」的承诺被打破。

#### Consequence

- **用户影响**：用户期望在同一文件看到同一主题的所有讨论历史，实际却分散在多个文件中，降低纪要的可追溯性。
- **数据影响**：随着时间推移，同一主题可能积累多个碎片化文件，历史浏览变得困难。
- **产品承诺落空**：设计规格第 2 节将「按主题合并」作为关键设计决策，但其 slug 生成规则直接导致该决策在某些场景下无法兑现。

#### Recommendation

设计规格需明确定义主题→slug 的确定性映射规则，消除翻译非确定性。可行方案包括：

1. **用户显式命名 slug**：在确认门禁中，展示拟用 slug 的同时允许用户直接修改 slug 文本（当前已支持），但还需在确认门禁中主动提示：「此 slug 将用于后续同主题会话去重。后续会话若使用相同的 slug 拼写，将合并到同一文件」。这样把去重的一致性责任从 AI 翻译转移到用户的显式输入。
2. **在确认门禁中展示已有文件列表**：保存时列出 `docs/discussions/` 下已有文件及 slug，让用户判断是否合并到已有文件，而非仅依赖 AI 翻译匹配。
3. **用户提供原始中文主题作为去重键**：使用用户输入的原中文主题（而非翻译后的英文 slug）作为去重的第一关键词。

最低要求：设计规格应在 slug 歧义声明（第 7 节）中补充说明翻译非确定性的具体风险，并明确推荐用户在确认门禁中核对/修正 slug 的流程。

#### Evidence

设计规格原文：

- 第 2 节关键设计决策表：「多会话区分模型 | 按主题合并（严格同 ADR） | 同主题 slug → 同一文件；不同主题 → 不同文件」
- 第 3 节命名规则：「slug = 主题归一化 kebab-case；中文主题由技能译成短英文 slug（如『内部审批流』→ `internal-approval-flow`）」
- 第 3 节去重规则：「按主题 slug 去重——同主题再存 → 复用既有文件序号」

核心矛盾：去重依赖 slug 一致性，但 slug 生成本身是非确定性的 AI 翻译过程。现有实现（ADR）中 slug 由用户给出的确定性标题派生，不存在翻译步骤，因此不具备可比性。

#### Assumptions

- CONFIRMED：设计规格规定由 AI 将中文主题翻译为英文 slug。
- CONFIRMED：AI 翻译在不同调用中可能产生不同结果（这是大语言模型的已知特性）。
- INFERRED：用户期望「按主题合并」意味着同一主题的多次会话归入同一文件。

#### Source References

- 设计规格第 2 节「关键设计决策」表格
- 设计规格第 3 节「落盘规则」——命名与去重
- 设计规格第 7 节「slug 歧义」（当前仅讨论了同主题不同中文措辞的情况，未涉及翻译不确定性）

---

### PR-002 — `docs/discussions/` 目录不存在时的行为存在歧义

#### Severity

P1

#### Evidence Class

CONFIRMED_DEFECT

#### Confidence

HIGH

#### Location

设计规格第 3 节「落盘规则」——「懒创建」条款与路径规则的交互。

#### The Gap

设计规格第 3 节声明「懒创建：用户没额外要求就不建 `docs/discussions/`」。但同时规定用户要求纪要时写入路径为 `docs/discussions/NNNN-slug.md`。

这两种规则在以下场景产生歧义：用户显式要求保存纪要（即「额外要求」已满足），但 `docs/discussions/` 目录尚不存在。此时：
- 若严格解释「懒创建」，应拒绝写入并提示用户手动创建目录；
- 若以用户显式请求优先，应自动创建目录并写入纪要文件。

设计规格未明确说明在这种「用户已要求纪要但目录不存在」的场景下应如何处理。同技能中的 `docs/adr/` 已有相同问题的隐含答案（SKILL.md 第 62-63 行：没达标决策就不建 `docs/adr/`，但用户要求保存且有达标决策时目录自然会被创建），但纪要场景未做对应的澄清。

#### Trigger Scenario

1. 用户首次在某个 cwd 中使用 `/deep-discussion`（该 cwd 从未保存过纪要，无 `docs/discussions/` 目录）。
2. 用户讨论结束、达成共同理解后说：「把过程纪要也保存下来」。
3. 技能需要写入 `docs/discussions/0001-some-topic.md`，但 `docs/discussions/` 目录不存在。
4. 设计规格未定义此时应自动创建目录还是提示用户手动创建。
5. 如果不同实现者做出不同选择，将产生不一致的用户体验。

#### Consequence

- **用户影响**：用户可能在发出明确的保存指令后收到错误提示（要求手动创建目录），造成困惑和操作摩擦。
- **产品行为不一致**：同一技能的不同版本或不同 AI 模型可能在相同场景下表现出不同行为（自动创建 vs. 拒绝）。
- **工作流中断**：如果实现者选择「拒绝写入并要求手动创建」，则用户需要离开对话去创建目录，破坏拷问流程的连续性。

#### Recommendation

明确以下规则：

> 「懒创建」指：无用户显式保存请求时不创建 `docs/discussions/` 目录。但当用户显式要求保存纪要时，若目录不存在则**自动创建** `docs/discussions/` 目录（与 `docs/adr/` 的行为一致），然后写入纪要文件。无需用户手动创建目录。

此澄清应写入设计规格第 3 节或第 7 节的边界说明中，并在 SKILL.md 的「边界与错误处理」节中反映。

#### Evidence

设计规格原文：

- 第 3 节：「懒创建：用户没额外要求就不建 `docs/discussions/`」
- 第 3 节路径：「`docs/discussions/NNNN-slug.md`（不再放 docs 根目录）」
- 第 8 节验收标准：「默认不生成；无额外要求时 `docs/discussions/` 不被创建」

不存在描述「用户要求保存但目录不存在」行为的文本。

SKILL.md 第 62-63 行（作为对照）：「没有术语就不建 `CONTEXT.md`；没有达标决策就不建 `docs/adr/`」——这里隐含的规则是：有术语/有决策时目录自然随创建文件而产生。纪要场景应做同样澄清。

#### Assumptions

- CONFIRMED：「懒创建」条款存在于设计规格第 3 节。
- CONFIRMED：用户显式要求保存纪要是目录创建的触发条件（第 3 节「默认关闭」条款）。
- INFERRED：用户期望发出保存指令后文件能被成功写入，无需手动创建目录。

#### Source References

- 设计规格第 3 节「落盘规则」——懒创建与路径
- 设计规格第 8 节「验收」——默认不生成条款
- SKILL.md 第 62-63 行——ADR 目录的对照行为

---

### PR-003 — 跨进程的"新会话"定义未能匹配用户的认知模型

#### Severity

P2

#### Evidence Class

MATERIAL_RISK

#### Confidence

MEDIUM

#### Location

设计规格第 4 节「文件内结构」——跨会话同主题行为；第 7 节「跨 Claude 进程」条款。

#### The Gap

设计规格第 7 节声明「新进程不知上次段日期 → 按『新会话』追加新段（可接受：本就是不同会话）」。但「会话」在产品认知中存在两个不同的定义：

- **技术定义**：一次 Claude Code 进程的生命周期（规格采用此定义）；
- **用户定义**：用户围绕同一主题的连续讨论过程（可能跨越多次进程重启）。

当用户在一次长讨论中因断开重连或主动重启 Claude Code 后继续同一主题时，从技术角度看这是「新会话」、会追加新段；但从用户认知看，这仍然是**同一轮**讨论的延续，期望更新同一个会话段而非追加新段。

此外，设计规格第 4 节规定「同会话重存：更新本段（覆盖该 `## 会话 YYYY-MM-DD` 段），不追加；技能在上下文内记住本次会话写的文件 + 段日期」。这意味着「同会话」判断完全依赖上下文内存，一旦上下文丢失（进程重启），同一天内的继续讨论也将被识别为「新会话」并追加新段，而非更新已有段。

#### Trigger Scenario

1. 用户在上午 10:00 开始 `/deep-discussion` 讨论「API 认证方案」，中途保存了一次纪要到 `docs/discussions/0003-api-authentication.md`，生成了 `## 会话 2026-08-07` 段。
2. 用户在上午 10:30 因会话超时或主动关闭，重新打开 Claude Code 继续同一主题的讨论。
3. 用户在 10:35 再次做了一些问答后要求保存纪要。
4. 按设计规格，新进程不知上次段日期，本次被识别为「新会话」，在文件中追加一个新的 `## 会话 2026-08-07` 段（同一日期）。
5. 文件中出现两个同日的「会话 2026-08-07」段，用户难以区分哪段对应上午的讨论、哪段对应上午重启后的继续讨论。

#### Consequence

- **用户影响**：同一日多次重启后，文件内可能出现多个同日期段，用户无法直观辨别各段对应的时间点。
- **数据组织混乱**：两个 `## 会话 2026-08-07` 标题并列，失去分段的意义——分段本为区分不同轮讨论，但同日期多段反而造成混淆。
- **已知风险的接受度**：设计规格将此标记为「可接受」，但未评估用户实际使用中的频率——对于长讨论（最可能触发纪要保存的场景），进程重启是常见事件。

#### Recommendation

1. 在会话段标题中加入时间戳，使同日内多段可区分：`## 会话 2026-08-07 10:00` 与 `## 会话 2026-08-07 10:35`。
2. 最低要求：在设计规格第 7 节「跨 Claude 进程」条款中，将「追加新段（可接受）」修改为「追加新段并确保段标题可区分（如含时间戳）」，让风险从隐式变为显式缓解。

#### Evidence

设计规格原文：

- 第 4 节：「同会话重存：更新本段（覆盖该 `## 会话 YYYY-MM-DD` 段），不追加；技能在上下文内记住本次会话写的文件 + 段日期」
- 第 7 节：「跨 Claude 进程：新进程不知上次段日期 → 按『新会话』追加新段（可接受：本就是不同会话）」

模板中的段标题格式为 `## 会话 YYYY-MM-DD`（仅含日期，无时间）。

#### Assumptions

- CONFIRMED：同会话判断依赖上下文内存（第 4 节）。
- CONFIRMED：跨进程时按新会话处理（第 7 节）。
- INFERRED：实际使用中，长讨论场景下进程重启的频率不可忽略。

#### Source References

- 设计规格第 4 节「文件内结构」——同会话重存规则
- 设计规格第 7 节「跨 Claude 进程」条款
- 设计规格第 4 节模板中的段标题格式

---

### PR-004 — 讨论纪要文件的长期生命周期管理缺失

#### Severity

P2

#### Evidence Class

MATERIAL_RISK

#### Confidence

MEDIUM

#### Location

设计规格全文——未涉及纪要文件创建之后的长期管理行为。

#### The Gap

设计规格定义了纪要文件的创建、分段追加和同会话更新，但未定义创建之后的任何生命周期行为：

- **文件会无限增长吗？** 同一主题跨越数月/数年、积累数十次会话段后，文件是否会变得过长而难以浏览？
- **过时纪要如何处理？** 当决策已落地为 ADR、讨论内容已过时时，纪要文件是否应被归档或标记？
- **用户如何发现历史纪要？** 随着 `docs/discussions/` 下文件增多，用户缺乏按时间线或主题浏览所有讨论历史的手段。
- **纪要与 ADR 的关联如何维护？** 模板第 4 节展示了「关联 ADR：[0003-foo](../adr/0003-foo.md)」的链接语法，但未定义何时、由谁、在什么条件下建立或更新此关联。

虽然原 `docs/grill-summary.md` 同样没有生命周期管理，但新方案将单一文件转变为按主题分文件的目录结构后，文件的持久性和组织性显著提升，用户对长期管理的期望自然随之提高。

#### Trigger Scenario

1. 用户在过去 6 个月中，就「API 认证方案」进行了 15 次 `/deep-discussion` 会话，每次均要求保存纪要。
2. `docs/discussions/0003-api-authentication.md` 现已包含 15 个 `## 会话 YYYY-MM-DD` 段，文件超过 2000 行。
3. 用户想回顾第 3 次会话中讨论的某个结论，但只能逐段浏览，缺乏导航手段（无目录、无摘要、无搜索辅助）。
4. 用户想确定哪些讨论结论已落实为 ADR、哪些仍悬而未决，但文件中缺乏汇总性的状态标注。

#### Consequence

- **用户体验退化**：随着时间推移，纪要文件的可用性下降（信息密度低、导航困难）。
- **知识管理价值减损**：纪要的核心价值是追溯决策过程，但如果文件变得难以浏览，其追溯价值大打折扣。
- **与 ADR 的关系模糊**：用户可能不确定某个讨论是否已「关闭」（即结论已沉淀为 ADR），增加认知负担。

#### Recommendation

此问题不要求在当前规格中完整解决，但建议至少做如下补充：

1. 在设计规格中增加一个「已知局限」或「后续增强」声明，承认纪要文件的长期管理尚未定义，是已知的 v1 范围外项。
2. 可选：在 `DISCUSSION-FORMAT.md` 模板中预留「状态」元数据字段（如 `**状态**：进行中 / 已沉淀为 ADR / 已归档`），为后续增强留出扩展点。

此条属于 v1 可接受的技术债务，但应在规格中记录以降低未来意外。

#### Evidence

设计规格全文搜索「归档」「清理」「删除」「生命周期」「长期」等关键词均无命中。第 4 节模板展示了文件内结构但未涉及文件级别的长期管理。

#### Assumptions

- CONFIRMED：设计规格未定义纪要文件的长期生命周期。
- INFERRED：用户期望纪要文件在创建后保持可浏览性；随着时间推移和段数增加，可浏览性会下降。

#### Source References

- 设计规格第 4 节「文件内结构」模板
- 设计规格第 7 节「边界与迁移」（仅涉及迁移，不涉及长期管理）

---

## Finding Summary

| Finding ID | Severity | Evidence Class | Confidence | Short Description |
| ---------- | -------- | -------------- | ---------- | ----------------- |
| PR-001     | P1       | CONFIRMED_DEFECT | HIGH     | Slug翻译非确定性导致同主题文件分裂 |
| PR-002     | P1       | CONFIRMED_DEFECT | HIGH     | docs/discussions/目录不存在时的创建行为歧义 |
| PR-003     | P2       | MATERIAL_RISK   | MEDIUM    | 跨进程"新会话"定义与用户认知模型错位 |
| PR-004     | P2       | MATERIAL_RISK   | MEDIUM    | 讨论纪要文件的长期生命周期管理缺失 |

---

## Product Risk Coverage

| Risk Dimension                | Status          | Finding IDs |
| ----------------------------- | --------------- | ----------- |
| State Machine Vulnerabilities | NOT_APPLICABLE  | —           |
| Hard Boundaries and Limits    | REVIEWED        | PR-003      |
| Data Lifecycle                | REVIEWED        | PR-004      |
| Backward Compatibility        | REVIEWED        | —           |
| Implicit Assumptions          | REVIEWED        | PR-001, PR-003 |
| Business Rule Conflicts       | REVIEWED        | PR-001, PR-002 |
| Temporal Consistency          | REVIEWED        | PR-004      |
| User Workflow Integrity       | REVIEWED        | PR-002      |
| Administrative Operability    | REVIEWED        | PR-004      |
| Abuse and Misuse Scenarios    | NOT_APPLICABLE  | —           |

- **State Machine Vulnerabilities**: NOT_APPLICABLE — 纪要文件本身不是状态机驱动的实体，创建/追加/更新操作不涉及复杂的状态迁移。
- **Abuse and Misuse Scenarios**: NOT_APPLICABLE — 此技能为单用户本地工具，纪要写入在确认门禁保护下执行，滥用场景的风险低。
- **Backward Compatibility**: REVIEWED — 设计规格第 7 节已声明旧文件不自动迁移，提示用户手动处理，该策略可接受。

---

## Unresolved Product Questions

### Q-001 — 用户如何在确认门禁中判断 slug 是否正确对应历史主题

#### Question

当技能在确认门禁中展示拟用 slug（如 `internal-approval-flow`）时，用户需要判断此 slug 是否匹配之前讨论过的同一主题。但在大型 `docs/discussions/` 目录中，用户可能不记得已有文件的确切 slug 拼写。设计规格第 7 节仅说「首次保存在确认门禁展示拟用 slug，用户可改」，但未说明是否为用户提供已有文件的上下文以供判断。

#### Why It Matters

如果用户无法准确判断 slug 是否匹配已有主题，则「按主题合并」的去重模型可能因用户操作的偏差而失效——用户可能错误地创建了新文件，或错误地合并到了无关文件中。

#### Required Clarification

确认门禁中是否需要展示 `docs/discussions/` 下已有文件的 slug 列表以辅助用户决策。

#### Status

OPEN

---

## Review Limitations

- **翻译非确定性的实证范围有限**：PR-001 基于大语言模型的已知特性（非确定性输出）推断 slug 翻译可能出现不一致，但未在实际的 deep-discussion 会话中实证复现此问题。置信度标记为 HIGH 需要注明：此置信度来源于 LLM 行为的广泛文献记录和业界共识，而非针对本 spec 的专项测试。
- **纪要实际使用频率未知**：PR-003 和 PR-004 的风险评估基于对「典型用户行为」的推断（长讨论可能跨进程；文件可能随时间累积），但缺乏 deep-discussion 技能的实际使用统计数据。如果典型使用模式是短讨论、单次完成，则这些风险的实际影响会降低。

---

## Reviewer Conclusion

### Critical Finding Count

- P0: 0
- P1: 2
- P2: 2

### Review Result

REQUIRES_REVIEW

本次评审识别出 2 个 P1 确认缺陷（slug 翻译非确定性导致去重失效、目录创建行为歧义）和 2 个 P2 重大风险（跨进程会话认知错位、长期生命周期缺失），须在 Consolidation 阶段被考虑。

PR-001（slug 翻译非确定性）是本次评审中最关键的发现——它直接触及设计规格核心决策「按主题合并」的可行性，且与规格第 2 节声称的「严格同 ADR」模型存在本质差异（ADR slug 是从用户给定的确定性标题派生，而纪要 slug 经过了一层非确定性的 AI 翻译）。建议设计规格在进入实现前明确解决此问题。

PR-002（目录创建歧义）是一个可通过一句话澄清修复的缺陷，风险低但影响面广（每位首次使用纪要功能的用户都会触发此路径）。

Product Reviewer 不确定 Findings 最终是否被接受、拒绝、延迟或通过其他方式解决。

最终处置由 Decision Protocol 确定。

---

## Machine-Readable Finding Index

```yaml
review:
  review_id: "PR-20260807-001"
  reviewer: "product-reviewer"
  review_type: "PRODUCT_REVIEW"
  status: "COMPLETED"

findings:
  - id: "PR-001"
    severity: "P1"
    evidence_class: "CONFIRMED_DEFECT"
    confidence: "HIGH"
    title: "Slug翻译非确定性导致同主题文件分裂"
    location: "设计规格第3节slug生成规则与第2节去重模型"
    source_references:
      - "设计规格第2节关键设计决策表"
      - "设计规格第3节命名规则与去重规则"
      - "设计规格第7节slug歧义"
    risk_dimensions:
      - "Business Rule Conflicts"
      - "Implicit Assumptions"
    status: "PENDING_DECISION"

  - id: "PR-002"
    severity: "P1"
    evidence_class: "CONFIRMED_DEFECT"
    confidence: "HIGH"
    title: "docs/discussions/目录不存在时的创建行为歧义"
    location: "设计规格第3节懒创建条款与路径规则"
    source_references:
      - "设计规格第3节懒创建与路径"
      - "设计规格第8节验收标准"
      - "SKILL.md第62-63行（对照行为）"
    risk_dimensions:
      - "Business Rule Conflicts"
      - "User Workflow Integrity"
    status: "PENDING_DECISION"

  - id: "PR-003"
    severity: "P2"
    evidence_class: "MATERIAL_RISK"
    confidence: "MEDIUM"
    title: "跨进程的新会话定义与用户认知模型错位"
    location: "设计规格第4节同会话重存规则与第7节跨进程条款"
    source_references:
      - "设计规格第4节文件内结构——同会话重存规则"
      - "设计规格第7节跨Claude进程条款"
      - "设计规格第4节模板段标题格式"
    risk_dimensions:
      - "Hard Boundaries and Limits"
      - "Implicit Assumptions"
    status: "PENDING_DECISION"

  - id: "PR-004"
    severity: "P2"
    evidence_class: "MATERIAL_RISK"
    confidence: "MEDIUM"
    title: "讨论纪要文件的长期生命周期管理缺失"
    location: "设计规格全文——未涉及创建之后的生命周期管理"
    source_references:
      - "设计规格第4节文件内结构模板"
      - "设计规格第7节边界与迁移"
    risk_dimensions:
      - "Data Lifecycle"
      - "Temporal Consistency"
      - "Administrative Operability"
    status: "PENDING_DECISION"

open_questions:
  - id: "Q-001"
    status: "OPEN"
    question: "用户如何在确认门禁中判断slug是否正确对应历史主题——确认门禁是否需要展示已有文件slug列表"
```

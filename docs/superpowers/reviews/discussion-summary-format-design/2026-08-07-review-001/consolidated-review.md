# Consolidated Review

## Review Metadata

### Review ID

CR-DDSUM-20260807-001

### Review Type

CONSOLIDATED_REVIEW

### Design Spec

/Users/yuezhenhua/yonyou/projects/0__AI/skills/deep-discussion/docs/superpowers/specs/2026-08-07-discussion-summary-format-design.md

### Consolidation Date

2026-08-07

### Consolidator

main-agent

### Review Status

COMPLETED

---

## Consolidation Scope

本文件合并以下独立评审的产出：

* `product-reviewer`
* `system-critic`
* `test-designer`

合并目的：

1. 识别描述同一底层问题的发现；
2. 合并重复发现而不丢失重要证据；
3. 保留实质不同的发现；
4. 识别评审者之间的冲突；
5. 建立统一的发现标识；
6. 保留原始评审者视角；
7. 为 Design Spec 所有者或 Superpowers 工作流准备单一评审文档；
8. 为记录每条发现的最终决策提供稳定结构。

本文档是合并产物。

它不是原始评审者报告的替代品。

原始评审者发现仍是其各自视角的来源。

---

## Source Reviews

| Reviewer            | Review Type    | Review ID      | Source File | Status    |
| ------------------- | -------------- | -------------- | ----------- | --------- |
| product-reviewer | PRODUCT_REVIEW | PR-20260807-001 | product-review.md | AVAILABLE |
| system-critic    | SYSTEM_REVIEW  | SC-20260807-001 | system-review.md | AVAILABLE |
| test-designer    | TEST_REVIEW    | TD-20260807-001 | test-review.md | AVAILABLE |

---

## Consolidation Principles

本次合并遵循以下原则：

### 1. 不以相似关键词合并

两条发现仅因提及同一组件、措辞相似、严重度相同或后果相似而合并是被禁止的。

仅在描述同一底层问题或失效机制时才允许合并。

### 2. 保留独立视角

当 Product、System、Test 评审者从不同方面识别同一底层问题时，合并为一条发现并保留不同视角。

### 3. 不强制合并

两条发现真正独立时保持分离。合并的目的是去重，而非人为减少发现数量。

### 4. 不静默解决冲突

评审者对风险是否存在、严重度、可能性、后果或解读产生分歧时，必须显式记录。

### 5. 证据优先于评审者权威

不因某条发现由特定评审者提出、严重度高或多人提及而接受它。

### 6. 不确定性保持可见

不将推断行为转为确认行为、不将可能后果转为确定后果、不将假设转为需求。

---

## Consolidator Predispositions

> 以下为合并者在 Phase 1（上下文获取）期间形成的关键判断，用于审计合并阶段可能的认知偏差。

### Predisposition 1

本 spec 是小型、边界清晰的增量改动（`docs/grill-summary.md` → `docs/discussions/NNNN-slug.md`），行为契约（§3）与验收标准（§8）结构完整。但「按主题合并」是整个设计的核心承诺，而该去重链（主题→slug→文件→去重）的两端（主题提取与 slug 翻译）都依赖 LLM 的非确定性行为。这一观察可能使合并者倾向于确认 PR-001 / SC-001 / TD-001 / TD-002 这类「slug / 主题规则未定义」发现的 P1 严重度，因为其直接打击核心设计目标。

### Predisposition 2

我在上下文获取时注意到：SKILL.md 中 ADR 去重的 slug 来自「决策标题」，该标题在结构化 ADR 流程中由技能从敲定决策提炼，用户通常明确知晓；而纪要主题来自自由对话，可能与用户预期措辞不一致。这一差异使「严格同 ADR」的声明在纪要场景下的风险更高。这可能导致我在评估「YAGNI 免责」的有效性时更保守。

### Predisposition 3

spec 中引用的行号（SKILL.md :64/:122、CLAUDE.md :43）脆弱，但 spec 已声明会同步验收文档（§6），且该问题属于实现期维护事项而非设计契约缺陷。我不预期也不引导任何评审者将其作为独立 finding。

---

# Consolidated Findings

## CR-001 — 主题→slug 映射的非确定性破坏「按主题合并」

### Consolidated Severity

P1

### Consolidation Confidence

HIGH

### Finding Status

PENDING_DECISION

### Underlying Problem

设计规格以「按主题合并」为核心多会话区分模型（§2），并规定去重按「主题 slug」（§3、§5）。但主题→slug 的映射由 AI 将中文主题翻译成英文 slug 生成（§3 命名规则），该翻译行为在 LLM 中天然非确定：同一主题在不同会话、不同措辞、甚至不同模型版本下可能产出不同 slug。翻译规则本身未定义（无提取步骤、无归一化算法、无翻译失败的兜底），因此「同主题 slug → 同一文件」的承诺无法稳定兑现，文件命名不可复现，「按主题合并」的核心价值在多措辞 / 多会话 / 长周期场景下失效。

### Evidence

#### Confirmed Evidence

* Design Spec §2 关键设计决策表：「多会话区分模型 | 按主题合并（严格同 ADR） | 同主题 slug → 同一文件；不同主题 → 不同文件」
* Design Spec §3 命名规则：「slug = 主题归一化 kebab-case；中文主题由技能译成短英文 slug（如『内部审批流』→ `internal-approval-flow`）」
* Design Spec §3 去重规则：「按主题 slug 去重——同主题再存 → 复用既有文件序号」
* Design Spec §5：「纪要去重键 = 主题 slug + 会话段」
* Design Spec §7 承认 slug 歧义并标记为 YAGNI；同时提供「首次保存在确认门禁展示拟用 slug，用户可改」的缓解。

#### Inferred Evidence

* AI 翻译非确定性是 LLM 的已知特性：同一中文输入在多次调用中可能产出不同英文翻译（PR-001 提供了多组同义示例）。
* 中文同义变体丰富（「审批流 / 审批流程 / 审批流程设计 / 内部审批流」），用户间隔数天数周后重提同一议题时很可能使用不同措辞，从而产出不同 slug。
* ADR 场景的 slug 源自用户/技能在结构化流程中提炼的决策标题，确定性高于自由对话中提取的纪要主题，故「严格同 ADR」声明在纪要场景下不成立。

#### Unknowns

* 具体模型在相同中文输入下的翻译一致性未实测。
* `references/DISCUSSION-FORMAT.md` 尚未创建，最终 slug 规则与模板细节未定稿。
* 用户是否会主动在确认门禁中核对 / 修正 slug，取决于使用习惯，无法预判。

### Trigger Scenario

1. 用户在会话 A 讨论主题「内部审批流程」，技能译为 `internal-approval-flow`，写入 `docs/discussions/0001-internal-approval-flow.md`。
2. 用户在会话 B 再次讨论同一主题，但措辞为「审批流程设计」。
3. 技能将其译为 `internal-approval-process`（或 `approval-process-design`），与既有 slug 不匹配。
4. 技能扫描 `docs/discussions/` 未命中既有 slug → 判定为新主题 → 分配新序号。
5. 同一主题的讨论历史被分裂到两个文件，「按主题合并」承诺落空。

### Consequence

* Business Impact: 「按主题合并」这一核心设计决策无法稳定兑现，多会话区分能力退化，纪要的归类价值受损。
* User Impact: 用户期望在同一文件看到同一主题的全部讨论历史，实际分散在多个文件中，可追溯性下降。
* Data Impact: 纪要碎片化，去重键（主题 slug + 会话段）失效，同一逻辑主题被当作多个主题处理。
* Operational Impact: 碎片化文件需用户手动合并，且随主题数量与时间累积清理成本上升。
* Maintenance Impact: slug 依赖 AI 翻译能力，底层模型升级可能改变翻译行为，导致技能行为随模型版本漂移。
* Verification Impact: 文件命名不可复现，「同主题→同文件」无客观验证标准。
* Security Impact: NONE_IDENTIFIED
* Availability Impact: NONE_IDENTIFIED

### Reviewer Perspectives

#### Product Perspective

**Source Findings:**

* PR-001

**Assessment:**

PR-001 将该问题定性为 P1 CONFIRMED_DEFECT（HIGH 置信度）。核心论点：去重依赖 slug 一致性，而 slug 生成为非确定性 AI 翻译，二者矛盾；且与 ADR 场景存在本质差异（ADR slug 从用户给定的确定性标题派生，纪要 slug 多一层 AI 翻译）。建议在确认门禁中主动提示 slug 的持久去重语义，或将去重键改用用户提供的中文主题。

#### System Perspective

**Source Findings:**

* SC-001

**Assessment:**

SC-001 将其定性为 P2 MATERIAL_RISK（MEDIUM 置信度，Likelihood MEDIUM，Reversibility REVERSIBLE）。从数据组织与维护负担角度论证：同一主题讨论历史碎片化导致检索失败；并额外指出模型升级可能改变翻译行为。建议在确认门禁增加「请确认 slug 与既有主题关联」的提示；可选在保存时做语义相似度匹配。SC 认为该风险已在 §7 显式承认并有确认门禁缓解，故定 P2。

#### Test Perspective

**Source Findings:**

* TD-001

**Assessment:**

TD-001 将其定性为 P1 CONFIRMED_GAP（HIGH 置信度，Finding Type UNTESTABLE_REQUIREMENT）。从可验证性角度论证：翻译规则未定义 → 命名不可复现 → 测试者无法判断输出的 slug 是否正确。并指出当前唯一安全网（确认门禁展示 slug）依赖人工审查，且用户可能不理解 slug 对后续去重的影响。

### Relationship Classification

SAME_ROOT_CAUSE

#### Relationship Explanation

PR-001（产品）、SC-001（系统）、TD-001（验证）从三个独立视角描述同一底层问题：主题→slug 映射依赖非确定性 AI 翻译且规则未定义，破坏「按主题合并」的去重模型。三者的失效机制一致（同主题产生不同 slug → 文件分裂），证据互相印证。合并为一条保留三视角。

### Conflict Analysis

#### Conflict Status

MINOR_INTERPRETATION_DIFFERENCE

#### Conflicting Positions

SC-001 判定为 P2（认为 §7 已承认风险且确认门禁提供缓解，架构可靠性可接受）；PR-001 / TD-001 判定为 P1（认为该问题直接打破核心设计承诺且不可验证，应进入实现前解决）。三方对风险存在的结论一致，仅在严重度与缓解有效性上存在解读差异。

#### Conflict Evidence

* SC-001 依赖 §7「YAGNI + 确认门禁用户可改」作为缓解依据。
* PR-001 / TD-001 认为确认门禁的缓解效果取决于用户能否识别 slug 与既有主题的关联，而用户可能不记得之前保存时的 slug 拼写，故缓解不可靠。

#### Resolution

该冲突可从证据层面部分缓解：确认门禁确实提供了一层缓解，但其有效性依赖用户记忆与判断，无法保证。因此合并严重度取 P1（更高值），理由见 Severity Change Rationale。是否需要在确认门禁中额外展示既有 slug 列表以强化缓解，作为待决策事项放入 Decision Queue。

### Recommended Resolution

最小约束：在确认门禁的 slug 展示中主动提示——「此 slug 将由 AI 生成并作为该主题的持久去重标识。若该主题与之前讨论有关联，请核对 / 修正 slug 以确保合并到既有文件」。

更可取（建议至少择一纳入 spec）：

1. 在 spec §3 或 §7 中定义主题→slug 的确定性生成流程（例如：提取关键名词短语 → 翻译为英文 → kebab-case 归一化），或明确定义 slug 的最终确定权归用户（用户确认 / 修改 slug，并在文件内记录中文原名辅助识别）。
2. 在确认门禁中展示 `docs/discussions/` 下既有文件的 slug 列表，辅助用户判断是否应合并到既有文件。
3. 保存时扫描既有文件标题行做语义相似度潜在匹配提示（可延后）。

### Source References

#### Product Review

* PR-001

#### System Review

* SC-001

#### Test Review

* TD-001

#### Design Spec References

* Design Spec §2 关键设计决策表
* Design Spec §3 落盘规则（命名 / 去重）
* Design Spec §5 保存契约扩展（去重键）
* Design Spec §7 边界与迁移（slug 歧义）

### Consolidation Decision

MERGED

#### Decision Rationale

三条源发现描述同一底层问题（slug 翻译非确定性破坏按主题合并），证据互相印证、失效机制一致，符合合并条件（Same Root Problem + Same Material Risk + Same Required Decision）。合并后保留产品、系统、验证三视角。

### Severity Change Rationale

源发现严重度为 PR-001（P1）、TD-001（P1）、SC-001（P2）。合并后定为 P1。理由：PR-001 与 TD-001 均以 HIGH 置信度独立论证该问题打破核心设计决策「按主题合并」并导致核心行为不可验证（PR-001 Trigger Scenario 步骤 5、TD-001 Verification Gap），其材料性高于 SC-001 所评估的操作性影响；三条独立证据相互印证，非机械取最高值。SC-001 的 P2 反映其侧重缓解可用性评估，不改变合并结论。

---

## CR-002 — 主题提取规则未定义，「同主题」判断无客观标准

### Consolidated Severity

P1

### Consolidation Confidence

HIGH

### Finding Status

PENDING_DECISION

### Underlying Problem

「按主题合并」的去重链输入端——「主题」本身——的来源与判别标准未定义。spec 未说明技能如何从对话中提取主题（用户命令参数 / 首轮提问推断 / 全程语义摘要）、什么构成「同一主题」（措辞不同但语义相同是否算同一主题）、以及一次会话涉及多个主题时纪要如何归属。没有该规则，「同主题→同文件」行为无法被客观验证，不同实现 / 测试者可能对同一对会话做出不同判断。

### Evidence

#### Confirmed Evidence

* Design Spec §2 关键设计决策：「多会话区分模型 | 按主题合并（严格同 ADR）」。
* Design Spec §3 去重规则：「按主题 slug 去重——同主题再存 → 复用既有文件序号」。
* Design Spec 通篇未定义「主题」的来源与提取方式。

#### Inferred Evidence

* 去重正确性依赖技能首先正确识别「当前会话讨论的主题」，该识别步骤无任何规则约束。
* ADR 场景中主题（决策标题）通常由用户 / 结构化流程明确声明；纪要场景中主题可能隐含在对话中，二者的确定方式不同，spec 未区分。

#### Unknowns

* 用户是否总是通过 `/deep-discussion <主题>` 提供显式主题，或经常省略主题参数。

### Trigger Scenario

1. 用户在一次会话中讨论「内部审批流的状态机设计」，要求保存纪要。
2. 技能从对话中推断主题并生成 slug。
3. 用户在另一次会话中讨论「审批流的权限模型」，再次要求保存纪要。
4. 测试者需判断：这两次会话是否应视为「同一主题」而合并到同一文件。
5. spec 未提供判断依据，不同的测试者 / Claude 运行可能做出不同但均「合理」的判断。

### Consequence

* Business Impact: 「按主题合并」的核心价值（多会话可区分且相关会话可关联）无法被可靠验证，产品行为跨场景不一致。
* User Impact: 用户可能发现同一主题内容分散多文件，或不同主题被意外合并。
* Verification Impact: 主题提取与同一性别定标准缺失，「同主题→同文件」无客观验证方法。
* Security Impact: NONE_IDENTIFIED
* Availability Impact: NONE_IDENTIFIED
* Operational Impact: NONE_IDENTIFIED
* Maintenance Impact: NONE_IDENTIFIED
* Data Impact: 纪要归属规则不明确，可能产生错误归类。

### Reviewer Perspectives

#### Product Perspective

**Source Findings:**

* （无）

**Assessment:**

产品评审未单独识别此问题；其 PR-001 的关注点集中在 slug 生成环节，未下探到主题提取输入。

#### System Perspective

**Source Findings:**

* （无）

**Assessment:**

系统评审未单独识别此问题。

#### Test Perspective

**Source Findings:**

* TD-002

**Assessment:**

TD-002（P1 CONFIRMED_GAP，HIGH 置信度，Finding Type UNTESTABLE_REQUIREMENT）从可验证性角度识别：主题提取规则缺失使「按主题合并」的前提不可验证。并指出该 Gap 与 TD-001 相互关联但独立——TD-001 关注「给定主题后如何生成 slug」，TD-002 关注「如何从对话中提取主题」，两者共同构成去重行为的验证前置条件。

### Relationship Classification

RELATED

#### Relationship Explanation

CR-002 与 CR-001 同属「主题→文件」去重链的不同环节：CR-001 覆盖「给定主题后生成 slug」的翻译非确定性，CR-002 覆盖「从对话中提取主题」的规则缺失。两者连接但可独立决策（分别定义主题提取规则与 slug 确定性规则）。按「Related Findings 应保持分离以支持独立决策」原则，保留为独立合并发现。

### Conflict Analysis

#### Conflict Status

NO_CONFLICT

#### Conflicting Positions

无评审者对该问题提出相反结论。

#### Conflict Evidence

不适用。

#### Resolution

不适用。

### Recommended Resolution

在 spec 中补充主题提取规则，至少覆盖：

1. 用户以 `/deep-discussion <主题>` 附带主题时，主题从命令参数提取；
2. 用户未附带主题时，技能从首轮对话推断，并在确认门禁中展示拟用主题（连同 slug）供确认或修改；
3. 明确定义「同一主题」的判定标准（例如：slug 相同即同一主题，且 slug 最终由用户确认）。

### Source References

#### Product Review

* （无）

#### System Review

* （无）

#### Test Review

* TD-002

#### Design Spec References

* Design Spec §2 关键设计决策 — 多会话区分模型
* Design Spec §3 落盘规则 — 去重
* Design Spec §4 文件内结构
* Design Spec §5 保存契约扩展

### Consolidation Decision

KEPT_SEPARATE

#### Decision Rationale

单源发现（仅 TD-002），且与 CR-001 属不同可独立决策的环节。保留为独立合并发现以支持独立的决策跟踪（CR-001 与 CR-002 可能分别被接受 / 延迟）。

### Severity Change Rationale

No severity change from source findings（源 TD-002 为 P1，合并保持 P1）。

---

## CR-003 — `docs/discussions/` 目录懒创建与显式保存请求的交互歧义

### Consolidated Severity

P1

### Consolidation Confidence

HIGH

### Finding Status

PENDING_DECISION

### Underlying Problem

spec §3 同时声明「懒创建：用户没额外要求就不建 `docs/discussions/`」与「用户额外要求时写入 `docs/discussions/NNNN-slug.md`」。当用户已显式要求保存纪要、但目录尚不存在时，行为未定义：是自动创建目录并写入，还是拒绝写入并提示用户手动创建？SKILL.md 中 `docs/adr/` 的对照行为隐含「有达标决策时目录随文件创建」，但纪要场景未做对应澄清。

### Evidence

#### Confirmed Evidence

* Design Spec §3：「懒创建：用户没额外要求就不建 `docs/discussions/`」。
* Design Spec §3 路径：「`docs/discussions/NNNN-slug.md`（不再放 docs 根目录）」。
* Design Spec §8 验收：「默认不生成；无额外要求时 `docs/discussions/` 不被创建」。
* Design Spec 不存在描述「用户要求保存但目录不存在」行为的文本。

#### Inferred Evidence

* SKILL.md 第 62–63 行：「没有术语就不建 `CONTEXT.md`；没有达标决策就不建 `docs/adr/`」——隐含规则是：有内容时目录自然随文件创建。纪要场景应有同样澄清。

#### Unknowns

* 无重大未知；该歧义可通过一句话澄清消除。

### Trigger Scenario

1. 用户首次在某个 cwd 使用 `/deep-discussion`（该 cwd 从未保存过纪要，无 `docs/discussions/` 目录）。
2. 用户达成共同理解后说「把过程纪要也保存下来」。
3. 技能需写入 `docs/discussions/0001-some-topic.md`，但目录不存在。
4. spec 未定义此时自动创建目录还是提示用户手动创建。
5. 不同实现者可能做出不同选择，产生不一致的用户体验。

### Consequence

* Business Impact: 产品行为跨实现不一致——同一技能在不同模型 / 版本下可能自动创建或拒绝写入。
* User Impact: 用户发出明确保存指令后可能收到「请手动创建目录」的错误提示，造成困惑与操作摩擦；若实现者选择拒绝，用户需离开对话创建目录，打断拷问流程连续性。
* Operational Impact: 每位首次使用纪要功能的用户都会触发此路径，影响面广。
* Security Impact: NONE_IDENTIFIED
* Availability Impact: NONE_IDENTIFIED
* Maintenance Impact: NONE_IDENTIFIED
* Data Impact: NONE_IDENTIFIED
* Verification Impact: 该路径无明确预期结果，无法为验收标准 #8 之外的场景编写客观测试。

### Reviewer Perspectives

#### Product Perspective

**Source Findings:**

* PR-002

**Assessment:**

PR-002（P1 CONFIRMED_DEFECT，HIGH 置信度）从产品工作流完整性角度识别：懒创建条款与显式保存请求的交互未定义，导致目录创建行为歧义。建议明确「懒创建」仅约束无显式请求时的行为，用户显式要求保存时自动创建目录（与 `docs/adr/` 一致）。

#### System Perspective

**Source Findings:**

* （无）

**Assessment:**

系统评审未单独识别此问题（其 Data Lifecycle 维度评估认为「懒创建策略」无材料级别风险，但未覆盖目录不存在的显式保存路径）。

#### Test Perspective

**Source Findings:**

* （无）

**Assessment:**

测试评审未单独识别此问题。

### Relationship Classification

INDEPENDENT

#### Relationship Explanation

该问题根因独立于 CR-001 / CR-002（目录创建行为），也独立于 CR-004（会话段去重）。解决它不会自动解决其他发现，反之亦然。

### Conflict Analysis

#### Conflict Status

NO_CONFLICT

#### Conflicting Positions

无评审者对目录创建行为提出相反结论。

#### Conflict Evidence

不适用。

#### Resolution

不适用。

### Recommended Resolution

在 spec §3 或 §7 明确：

> 「懒创建」指：无用户显式保存请求时不创建 `docs/discussions/` 目录。但当用户显式要求保存纪要时，若目录不存在则**自动创建** `docs/discussions/` 目录（与 `docs/adr/` 的行为一致），然后写入纪要文件。无需用户手动创建目录。

并同步反映到 SKILL.md 的「边界与错误处理」节。

### Source References

#### Product Review

* PR-002

#### System Review

* （无）

#### Test Review

* （无）

#### Design Spec References

* Design Spec §3 落盘规则（懒创建 / 路径）
* Design Spec §8 验收
* SKILL.md 第 62–63 行（对照行为）

### Consolidation Decision

KEPT_SEPARATE

#### Decision Rationale

单源发现（仅 PR-002），问题独立、一句话可修复。保留为独立合并发现。

### Severity Change Rationale

No severity change from source findings（源 PR-002 为 P1，合并保持 P1）。

---

## CR-004 — 会话段去重依赖易失上下文内存，同日多段不可区分且失效静默

### Consolidated Severity

P2

### Consolidation Confidence

MEDIUM

### Finding Status

PENDING_DECISION

### Underlying Problem

spec §4 规定「同会话重存：更新本段……技能在上下文内记住本次会话写的文件 + 段日期」，即会话级去重完全依赖易失的上下文内存。当进程重启（跨进程场景，§7 规定按新会话追加）、上下文窗口截断、或「清空草稿 / 重启」（CR-010）导致记忆丢失时，去重静默失效，同一主题同一天可能产生多个 `## 会话 YYYY-MM-DD` 段。段标题仅含日期、无时间戳，同日多段无法区分；且失效无任何警告，用户只能事后人工检查发现。

### Evidence

#### Confirmed Evidence

* Design Spec §4：「同会话重存：更新本段（覆盖该 `## 会话 YYYY-MM-DD` 段），不追加；技能在上下文内记住本次会话写的文件 + 段日期」。
* Design Spec §7：「跨 Claude 进程：新进程不知上次段日期 → 按『新会话』追加新段（可接受：本就是不同会话）」。
* Design Spec §4 模板段标题格式为 `## 会话 YYYY-MM-DD`（仅日期，无时间）。

#### Inferred Evidence

* 长对话下上下文窗口可能滚动，早期记忆被逐出（LLM 上下文管理特性）。
* CR-010 清空草稿 / 重启同时清除纪要写入记忆，但用户可能未意识到。
* 进程重启是长讨论（最可能触发纪要保存的场景）中的常见事件。

#### Unknowns

* 实际使用中长讨论跨进程 / 上下文截断的频率未统计。
* Claude Code 上下文压缩机制对「写入记忆」的保留程度未知。

### Trigger Scenario

1. 用户上午讨论「API 认证方案」，保存纪要至 `docs/discussions/0003-api-authentication.md`，生成 `## 会话 2026-08-07` 段。
2. 用户 10:30 因会话超时或主动关闭，重新打开 Claude Code 继续同一主题。
3. 用户再次保存纪要——新进程不知上次段日期，本次被识别为「新会话」，追加一个新的 `## 会话 2026-08-07` 段。
4. 文件中出现两个同日「会话 2026-08-07」段，用户难以区分各段对应的时间点。
5. （另一触发路径）同一会话内上下文窗口滚动逐出早期记忆，再次保存时追加重复段，且无任何提示。

### Consequence

* User Impact: 同一日多段并列、标题相同，分段失去区分不同轮讨论的意义，反而造成混淆。
* Data Impact: 重复 / 混淆的会话段降低纪要准确性与可读性。
* Verification Impact: 在上下文记忆丢失场景下，无任何可观测信号区分「正常去重」与「静默失效」。
* Operational Impact: 用户只能在事后人工检查文件内容时发现重复段——正是纪要旨在避免的认知负担。
* Business Impact: 纪要的可追溯价值受损。
* Security Impact: NONE_IDENTIFIED
* Availability Impact: NONE_IDENTIFIED
* Maintenance Impact: NONE_IDENTIFIED

### Reviewer Perspectives

#### Product Perspective

**Source Findings:**

* PR-003

**Assessment:**

PR-003（P2 MATERIAL_RISK，MEDIUM 置信度）从用户认知模型角度识别：技术「会话」（进程生命周期）与用户「会话」（同一轮讨论）定义错位；进程重启后同日继续讨论会被追加新段而非更新已有段，产生同日重复段。建议在段标题加入时间戳使其可区分。

#### System Perspective

**Source Findings:**

* （无）

**Assessment:**

系统评审未将其列为 finding，但在 SC Q-001（open question）中提出会话身份边界问题：同一进程内同日多次独立讨论应合并还是分开、跨日连续讨论应拆分还是继续，均未定义。该 open question 与 CR-004 同属会话身份 / 段标识语义，归入本发现的待澄清范围。

#### Test Perspective

**Source Findings:**

* TD-003

**Assessment:**

TD-003（P2 MATERIAL_RISK，MEDIUM 置信度，Finding Type BLIND_SPOT）从可验证性角度识别：会话内去重完全依赖上下文内存，上下文丢失（截断 / CR-010 / 模型切换）时静默失效，产生重复段且无警告。建议增加文件系统级别的检测作为补充安全网（写入前读取目标文件，检测同日期段是否存在，存在则更新而非追加）。

### Relationship Classification

SAME_ROOT_CAUSE

#### Relationship Explanation

PR-003（跨进程）与 TD-003（上下文丢失）是不同的触发条件，但根因相同：会话段去重依赖易失的上下文内存，段标识（仅日期）无法区分同日多段，失效静默。二者共享根因（Same Root Cause），合并保留两触发路径。PR-003 的「时间戳」建议与 TD-003 的「文件系统检测」建议互补，不冲突。

### Conflict Analysis

#### Conflict Status

NO_CONFLICT

#### Conflicting Positions

无评审者提出相反结论；两建议互补。

#### Conflict Evidence

不适用。

#### Resolution

不适用。

### Recommended Resolution

最小约束：在 spec §7「跨 Claude 进程」条款中将「追加新段（可接受）」修改为「追加新段并确保段标题可区分（如含时间戳：`## 会话 2026-08-07 10:00`）」。

补充安全网（建议纳入）：同会话去重增加文件系统级检测——写入前读取目标文件，若已存在同日期段，即使上下文记忆丢失仍按「更新现有段」处理；检测到记忆与文件状态不一致时向用户提示。

### Source References

#### Product Review

* PR-003

#### System Review

* SC Q-001（open question，关联）

#### Test Review

* TD-003

#### Design Spec References

* Design Spec §4 文件内结构（同会话重存规则 / 段标题格式）
* Design Spec §7 边界与迁移（跨 Claude 进程条款）

### Consolidation Decision

MERGED

#### Decision Rationale

两条源发现共享同一根因（会话段去重依赖易失内存 + 段标识不可区分），合并为一条保留两触发路径。PR-003 偏用户认知视角，TD-003 偏验证盲点视角，合并后均保留。

### Severity Change Rationale

No severity change from source findings（源 PR-003 与 TD-003 均为 P2，合并保持 P2）。

---

## CR-005 — 纪要文件的长期生命周期管理缺失

### Consolidated Severity

P2

### Consolidation Confidence

MEDIUM

### Finding Status

PENDING_DECISION

### Underlying Problem

spec 定义了纪要文件的创建、分段追加与同会话更新，但未定义创建之后的任何生命周期行为：文件是否会随会话段累积无限增长、过时内容如何处理、用户如何发现 / 浏览历史纪要、纪要与 ADR 的关联（模板中的「关联 ADR」链接）何时由谁维护。将单文件 `docs/grill-summary.md` 转为按主题分目录结构后，文件的持久性与组织性显著提升，用户对长期管理的期望随之提高，而 spec 未覆盖。

### Evidence

#### Confirmed Evidence

* Design Spec §4 模板展示「关联 ADR：[0003-foo](../adr/0003-foo.md)」链接语法。
* Design Spec 全文搜索「归档 / 清理 / 删除 / 生命周期 / 长期」等关键词均无命中。
* Design Spec §7 仅覆盖迁移（旧文件不自动迁移），不覆盖长期管理。

#### Inferred Evidence

* 同一主题跨数月 / 数年、积累数十次会话段后，文件会变得过长而难以浏览。
* 纪要核心价值是追溯决策过程；文件难以浏览时追溯价值大打折扣。

#### Unknowns

* 纪要文件的实际使用规模与用户对长期管理的期望强度未统计。

### Trigger Scenario

1. 用户在过去 6 个月就「API 认证方案」进行了 15 次 `/deep-discussion` 会话，均要求保存纪要。
2. `docs/discussions/0003-api-authentication.md` 现含 15 个会话段，文件超过 2000 行。
3. 用户想回顾第 3 次会话的结论，只能逐段浏览，缺乏目录 / 摘要 / 搜索辅助。
4. 用户想确定哪些讨论结论已落实为 ADR、哪些仍悬而未决，但文件缺乏汇总性状态标注。

### Consequence

* User Impact: 纪要文件可用性随时间下降（信息密度低、导航困难）。
* Business Impact: 纪要的知识管理价值减损，决策追溯能力下降。
* Operational Impact: 用户无法快速判断某讨论是否已「关闭」（已沉淀为 ADR）。
* Maintenance Impact: 长期维护成本未定义。
* Security Impact: NONE_IDENTIFIED
* Availability Impact: NONE_IDENTIFIED
* Data Impact: NONE_IDENTIFIED
* Verification Impact: NONE_IDENTIFIED

### Reviewer Perspectives

#### Product Perspective

**Source Findings:**

* PR-004

**Assessment:**

PR-004（P2 MATERIAL_RISK，MEDIUM 置信度）从数据生命周期与运维可用性角度识别长期管理缺失，并建议在 spec 中增加「已知局限 / 后续增强」声明，可选在 `DISCUSSION-FORMAT.md` 模板中预留「状态」元数据字段为后续增强留扩展点。该条属 v1 可接受的技术债务，但应在 spec 中记录。

#### System Perspective

**Source Findings:**

* （无）

**Assessment:**

系统评审的 Data Lifecycle 维度评估认为 §7 已定义迁移路径、无材料级生命周期风险，未识别长期管理为 finding。

#### Test Perspective

**Source Findings:**

* （无）

**Assessment:**

测试评审未单独识别此问题。

### Relationship Classification

INDEPENDENT

#### Relationship Explanation

该问题根因独立于其他发现：长期生命周期管理缺失不依赖 slug / 主题规则（CR-001/002）、目录创建（CR-003）、或会话段去重（CR-004）。解决它不会自动解决其他发现。

### Conflict Analysis

#### Conflict Status

NO_CONFLICT

#### Conflicting Positions

无评审者对生命周期管理提出相反结论（系统评审评估过但判定无材料风险，属评估深度差异而非冲突）。

#### Conflict Evidence

不适用。

#### Resolution

不适用。

### Recommended Resolution

不在当前规格中完整解决，但建议：

1. 在 spec 增加「已知局限 / 后续增强」声明，承认纪要长期管理（归档 / 清理 / 浏览辅助 / ADR 关联维护）为 v1 范围外项。
2. 可选：在 `DISCUSSION-FORMAT.md` 模板预留「状态」元数据字段（如 `**状态**：进行中 / 已沉淀为 ADR / 已归档`），为后续增强留扩展点。

### Source References

#### Product Review

* PR-004

#### System Review

* （无）

#### Test Review

* （无）

#### Design Spec References

* Design Spec §4 文件内结构模板
* Design Spec §7 边界与迁移

### Consolidation Decision

KEPT_SEPARATE

#### Decision Rationale

单源发现（仅 PR-004），问题独立，保留为独立合并发现以支持独立决策（可作为 DEFERRED 候选）。

### Severity Change Rationale

No severity change from source findings（源 PR-004 为 P2，合并保持 P2）。

---

## CR-006 — 编号扫描对非标准文件名的过滤规则未定义

### Consolidated Severity

P2

### Consolidation Confidence

MEDIUM

### Finding Status

PENDING_DECISION

### Underlying Problem

spec §3 规定编号通过「扫描 `docs/discussions/` 已有最大号 +1」生成，但未定义对目录中不匹配 `NNNN-slug.md` 模式的文件的处理。可能的非标准文件包括：用户手动创建的 README.md、从旧版 `docs/grill-summary.md` 迁移但未改名的文件、临时 / 备份文件（如 `.bak`）、系统文件（如 `.DS_Store`）。扫描逻辑若不过滤，可能提取到非数字前缀或异常大的「编号」，导致 max+1 计算错误。

### Evidence

#### Confirmed Evidence

* Design Spec §3 编号：「扫描 `docs/discussions/` 已有最大号 +1」。
* Design Spec 未定义编号扫描的过滤规则。

#### Inferred Evidence

* `references/ADR-FORMAT.md` 的编号规则同样只说「扫描最大号 +1」，未定义过滤——两个目录共享同一未定义行为；但 ADR 目录通常由技能独占写入，非标准文件引入风险较低，而 `docs/discussions/` 面向用户可见纪要，用户更可能手动操作该目录。

#### Unknowns

* 实际实现中扫描逻辑是否过滤非 `NNNN-*.md` 文件。

### Trigger Scenario

1. `docs/discussions/` 已有 `0001-internal-approval-flow.md` 和 `0002-data-model.md`。
2. 用户手动创建了一个 `README.md` 文件。
3. 用户进行新的会话并要求保存纪要。
4. 技能扫描目录获取最大编号。
5. 若扫描逻辑未过滤非 `NNNN-*.md` 文件，行为不确定——可能忽略 README 正确得到 0003，也可能因解析失败产生编号错误。

### Consequence

* User Impact: 目录存在非标准文件时，编号可能产生意外结果（跳号、编号错误或写操作失败）。
* Operational Impact: 一旦发生，用户难以排查原因——因为 spec 未定义期望行为。
* Verification Impact: 无客观标准验证「无论目录中存在何种非标准文件，编号始终 = 匹配 `NNNN-slug.md` 的最大编号 +1」。
* Security Impact: NONE_IDENTIFIED
* Availability Impact: NONE_IDENTIFIED
* Data Impact: 编号错误可能导致文件名冲突或覆盖风险（低概率）。
* Maintenance Impact: 与 ADR-FORMAT.md 共享同一未定义行为，若修复需同步两处。

### Reviewer Perspectives

#### Product Perspective

**Source Findings:**

* （无）

**Assessment:**

产品评审未单独识别此问题。

#### System Perspective

**Source Findings:**

* （无）

**Assessment:**

系统评审评估编号间隙（delete 后 max+1 跳过）无损数据完整性，但未覆盖非标准文件名过滤。

#### Test Perspective

**Source Findings:**

* TD-004

**Assessment:**

TD-004（P2 CONFIRMED_GAP，MEDIUM 置信度，Finding Type UNTESTABLE_REQUIREMENT）从边界验证角度识别编号扫描过滤缺失，并指出该 Gap 同时存在于 ADR 编号规则，建议在本 spec 明确定义过滤规则时同步更新 ADR-FORMAT.md。

### Relationship Classification

INDEPENDENT

#### Relationship Explanation

该问题根因独立：编号扫描的过滤规则与 slug / 主题规则（CR-001/002）、目录创建（CR-003）、会话段去重（CR-004）、生命周期（CR-005）均无依赖。

### Conflict Analysis

#### Conflict Status

NO_CONFLICT

#### Conflicting Positions

无评审者对编号扫描提出相反结论。

#### Conflict Evidence

不适用。

#### Resolution

不适用。

### Recommended Resolution

在 spec §3 明确定义编号扫描的过滤规则。最小建议：

> 扫描 `docs/discussions/` 目录，仅匹配文件名满足 `NNNN-*.md` 模式（NNNN 为 4 位数字）的文件，取其中最大 NNNN +1 作为新编号；不匹配该模式的文件忽略不计。

若采纳，建议同步更新 `references/ADR-FORMAT.md` 以保持一致性。

### Source References

#### Product Review

* （无）

#### System Review

* （无）

#### Test Review

* TD-004

#### Design Spec References

* Design Spec §3 落盘规则 — 编号
* references/ADR-FORMAT.md — 编号规则（共享同一模式）

### Consolidation Decision

KEPT_SEPARATE

#### Decision Rationale

单源发现（仅 TD-004），问题独立，保留为独立合并发现。

### Severity Change Rationale

No severity change from source findings（源 TD-004 为 P2，合并保持 P2）。

---

# Unmerged Source Findings

本次合并中无未合并的源发现——全部 9 条源发现均被引用到某个合并发现中。

# Duplicate and Superseded Findings

无。9 条源发现均以「合并引用」方式纳入合并发现（CR-001 至 CR-006），未被标记为 DUPLICATE 或 REPRESENTED_ELSEWHERE。

# Cross-Reviewer Conflicts

无材料级冲突。CR-001 存在严重度解读差异（SC-001 P2 vs PR-001/TD-001 P1），已作为 MINOR_INTERPRETATION_DIFFERENCE 在 CR-001 中记录并给出合并结论。

# Coverage Gaps

"No coverage gaps — all three source reviews are available."

# Coverage Matrix

| Consolidated Finding | Product | System | Test    | Primary Risk Area |
| -------------------- | ------- | ------ | ------- | ----------------- |
| CR-001               | PR-001  | SC-001 | TD-001  | 主题去重链（slug 确定性） |
| CR-002               | —       | —      | TD-002  | 主题提取规则 |
| CR-003               | PR-002  | —      | —       | 目录创建行为 |
| CR-004               | PR-003  | —      | TD-003  | 会话段去重可靠性 |
| CR-005               | PR-004  | —      | —       | 生命周期管理 |
| CR-006               | —       | —      | TD-004  | 编号扫描过滤 |

# Review Coverage Summary

| Review Dimension       | Product  | System   | Test     | Consolidated Findings |
| ---------------------- | -------- | -------- | -------- | --------------------- |
| Business Rules         | REVIEWED | REVIEWED | REVIEWED | CR-001, CR-003 |
| User Workflow          | REVIEWED | —        | REVIEWED | CR-002, CR-003 |
| State Transitions      | NOT_APPLICABLE | NOT_APPLICABLE | REVIEWED | — |
| Data Integrity         | REVIEWED | REVIEWED | REVIEWED | CR-001, CR-006 |
| Security               | NOT_APPLICABLE | NOT_APPLICABLE | NOT_APPLICABLE | — |
| Availability           | —        | NOT_APPLICABLE | —        | — |
| Failure Recovery       | REVIEWED | REVIEWED | REVIEWED | CR-004 |
| Backward Compatibility | REVIEWED | REVIEWED | REVIEWED | CR-005 |
| Temporal Behavior      | REVIEWED | REVIEWED | REVIEWED | CR-004, CR-005 |
| Operational Complexity | REVIEWED | REVIEWED | REVIEWED | CR-003, CR-005 |
| Testability            | —        | —        | REVIEWED | CR-001, CR-002, CR-004, CR-006 |
| Observability          | —        | NOT_APPLICABLE | REVIEWED | CR-004 |

---

# Superpowers Instructions

## What to Read

- **Consolidated Review**: 本文档
- **Source Reviews**: 见上方 Source Reviews 表格中的文件路径

## What to Decide

对下方 Decision Queue 中的每条合并发现设定决策：

| CR-ID | Title | Severity | Decision (choose one) |
|-------|-------|----------|----------------------|
| CR-001 | 主题→slug 映射的非确定性破坏「按主题合并」 | P1 | ___ |
| CR-002 | 主题提取规则未定义，「同主题」判断无客观标准 | P1 | ___ |
| CR-003 | `docs/discussions/` 目录懒创建与显式保存请求的交互歧义 | P1 | ___ |
| CR-004 | 会话段去重依赖易失上下文内存，同日多段不可区分 | P2 | ___ |
| CR-005 | 纪要文件的长期生命周期管理缺失 | P2 | ___ |
| CR-006 | 编号扫描对非标准文件名的过滤规则未定义 | P2 | ___ |

**Decision options**: PENDING_DECISION, ACCEPTED, REJECTED, DEFERRED, PARTIALLY_ACCEPTED, DUPLICATE, INVALIDATED

## Decision Template

For each finding, copy and fill in the following in the Decision Records section below:

```markdown
## DR-<NNN> — CR-<NNN>

### Decision Status

ACCEPTED_DECISION / ACCEPTED / REJECTED / DEFERRED / PARTIALLY_ACCEPTED / DUPLICATE / INVALIDATED

### Decision Owner

<your name or role>

### Decision Rationale

<Why this decision was made — must address the finding's validity, materiality,
and evidence>

### Required Action

<If ACCEPTED: what must change in the Design Spec>

### Decision Date

<YYYY-MM-DD>
```

## Hard Rules

1. A Finding with status PENDING_DECISION cannot have a final review state of APPROVED
2. All P0 findings must be resolved (not PENDING_DECISION) before the final review state can be anything other than BLOCKED
3. Every decision must have a Decision Owner, Rationale, and Date

## Final Review State

After all decisions are recorded, determine the final review state:

| Condition | State |
|-----------|-------|
| Any unresolved P0 finding | BLOCKED |
| Accepted P1/P2 changes outstanding | CHANGES_REQUIRED |
| No blocking finding, conditions remain | CONDITIONAL_APPROVAL |
| All required changes incorporated | APPROVED |
| Review records incomplete | INCOMPLETE |

Write the final review state at the bottom of the Consolidation Conclusion section.

---

# Decision Queue

> 合并阶段不代替 Spec 所有者做最终决策。以下每条发现的最终处置由 Decision Protocol 决定。

## DQ-001 — CR-001

### Problem

主题→slug 映射依赖非确定性 AI 翻译且规则未定义，破坏「按主题合并」的核心去重模型，文件命名不可复现。

### Severity

P1

### Evidence Summary

§2 关键决策「按主题合并（严格同 ADR）」；§3 命名「中文主题由技能译成短英文 slug」+ 去重「按主题 slug 去重」；§7 承认 slug 歧义为 YAGNI 并提供确认门禁缓解。PR-001 / TD-001 均 HIGH 置信度判定 P1，SC-001 判 P2。

### Recommended Resolution

在确认门禁主动提示 slug 的持久去重语义，或定义确定性 slug 生成流程 / 将 slug 最终确定权交给用户。

### Decision Required

是否接受 CR-001，以及选择哪种 slug 确定性方案（提示 / 确定性规则 / 用户确认为准）。

### Decision Status

ACCEPTED

## DQ-002 — CR-002

### Problem

「主题」的来源与提取规则未定义，「同主题→同文件」无法客观验证。

### Severity

P1

### Evidence Summary

§2「按主题合并」依赖主题识别，但 spec 通篇未定义主题提取方式与同一性标准；TD-002（P1 CONFIRMED_GAP，HIGH）。

### Recommended Resolution

补充主题提取规则（命令参数优先 / 首轮推断 + 确认门禁展示 / 同一性判定标准）。

### Decision Required

是否接受 CR-002，以及主题提取的具体规则。

### Decision Status

ACCEPTED

## DQ-003 — CR-003

### Problem

`docs/discussions/` 目录懒创建与用户显式保存请求的交互未定义。

### Severity

P1

### Evidence Summary

§3 懒创建条款 + 路径规则 + §8 验收；PR-002（P1 CONFIRMED_DEFECT，HIGH）。SKILL.md 中 `docs/adr/` 隐含「有内容时目录随文件创建」。

### Recommended Resolution

明确「用户显式要求保存时自动创建目录」。

### Decision Required

是否接受 CR-003 的目录自动创建澄清。

### Decision Status

ACCEPTED

## DQ-004 — CR-004

### Problem

会话段去重依赖易失上下文内存，进程重启 / 上下文截断后同日多段不可区分且失效静默。

### Severity

P2

### Evidence Summary

§4 同会话重存依赖「上下文内记住」；§7 跨进程按新会话追加；段标题仅日期。PR-003（P2）、TD-003（P2）。

### Recommended Resolution

段标题加时间戳 + 文件系统级同段检测作为补充安全网。

### Decision Required

是否接受 CR-004，以及选择时间戳 / 文件系统检测中的哪种或全部。

### Decision Status

ACCEPTED

## DQ-005 — CR-005

### Problem

纪要文件长期生命周期管理（增长 / 归档 / 浏览辅助 / ADR 关联维护）未定义。

### Severity

P2

### Evidence Summary

spec 全文无归档 / 清理 / 生命周期关键词；§4 模板含「关联 ADR」链接但未定义维护方。PR-004（P2 MATERIAL_RISK，MEDIUM）。

### Recommended Resolution

在 spec 增加「已知局限 / 后续增强」声明，可选预留「状态」元数据字段。

### Decision Required

是否接受 CR-005 的「已知局限声明」，或作为 DEFERRED。

### Decision Status

ACCEPTED

## DQ-006 — CR-006

### Problem

编号扫描对非 `NNNN-*.md` 文件的过滤规则未定义。

### Severity

P2

### Evidence Summary

§3 编号「扫描已有最大号 +1」，未定义过滤；ADR-FORMAT.md 共享同一未定义行为。TD-004（P2 CONFIRMED_GAP，MEDIUM）。

### Recommended Resolution

定义「仅匹配 `NNNN-*.md`，不匹配忽略」的过滤规则，并同步 ADR-FORMAT.md。

### Decision Required

是否接受 CR-006 的过滤规则定义。

### Decision Status

ACCEPTED

---

# Decision Records

> 决策由 Spec 所有者（Claude，经用户授权「逐条设定决策」）于 2026-08-07 记录。
> 6 条合并发现全部 ACCEPTED，相应 Required Action 已纳入 Design Spec 修订（spec v2）。

## DR-001 — CR-001

### Decision Status

ACCEPTED

### Decision Owner

spec-owner（Claude，经用户授权）

### Decision Rationale

PR-001 / SC-001 / TD-001 三方独立评审从产品、系统、验证三视角确认同一根因：AI 中译英 slug 非确定性破坏「按主题合并」核心去重模型。证据充分（spec §2/§3/§5/§7）。关键洞见：ADR slug 源自用户给定的确定性决策标题（kebab-case 派生，无翻译步骤），纪要 slug 多一层 AI 翻译，故 spec 原文「严格同 ADR」的声明在纪要场景不成立——接受此判据。材料性成立，不驳回；亦不延迟（直接打击核心设计目标，须进实现前解决）。

### Required Action

1. §2 重写「按主题合并（严格同 ADR）」为「按主题合并：slug 去重机制同 ADR（文件系统扫描 + slug 匹配），但 slug 确定权归用户——在确认门禁确认/修正，因 AI 翻译非确定」。
2. §3 命名规则补充：「slug 在确认门禁由用户确认/修正，一经确认即作为该主题的持久去重键」。
3. §3 确认门禁补充：「首次保存时展示 docs/discussions/ 既有 slug 列表 + 去重语义提示」。
4. §4 模板 H1 记中文主题原名辅助识别，弥补英文 slug 不可读。

### Decision Date

2026-08-07

## DR-002 — CR-002

### Decision Status

ACCEPTED

### Decision Owner

spec-owner（Claude，经用户授权）

### Decision Rationale

TD-002（P1，HIGH）指出「主题」来源与提取规则缺失，使「同主题→同文件」不可客观验证。证据成立（spec 通篇未定义主题提取方式与同一性标准）。与 CR-001 共同构成去重链验证前置条件，须一并解决。

### Required Action

§3/§4 补充主题提取规则：命令参数优先提取；无参数则技能推断 + 门禁展示供确认；「同主题」判定 = slug 匹配（用户确认）。

### Decision Date

2026-08-07

## DR-003 — CR-003

### Decision Status

ACCEPTED

### Decision Owner

spec-owner（Claude，经用户授权）

### Decision Rationale

PR-002（P1，HIGH）指出「懒创建」条款与用户显式保存请求的目录创建行为歧义。证据成立（§3/§8 仅定义「无请求不建」，未定义「有请求但目录不存在」）。SKILL.md 中 docs/adr/ 隐含「有内容时目录随文件创建」，纪要应一致。一句话可修复且影响面广，接受。

### Required Action

§3/§7 明确「懒创建 = 无显式保存请求时不建目录；用户显式要求保存时自动创建 docs/discussions/，与 docs/adr/ 一致」；SKILL.md「边界与错误处理」节同步。

### Decision Date

2026-08-07

## DR-004 — CR-004

### Decision Status

ACCEPTED

### Decision Owner

spec-owner（Claude，经用户授权）

### Decision Rationale

PR-003 + TD-003（均 P2）共享根因：会话段去重纯依赖易失上下文内存，段标题仅日期致同日多段不可区分、失效静默。证据成立（§4「上下文内记住」、§7 跨进程按新会话、段标题仅日期）。镜像 ADR 文件系统去重可增强可靠性，时间戳使同日多段可区分，接受。

### Required Action

1. §4 段标题加时间戳 `## 会话 YYYY-MM-DD HH:MM`。
2. §4/§5 增文件系统级安全网：写入前读目标文件，若存在同时间戳段则更新而非追加。
3. §7 跨进程/上下文丢失条款改为「新调用 = 新段时间戳可区分，文件系统安全网兜底同时间戳碰撞」。
4. §4 定义「会话」= 一次 /deep-discussion 调用，段时间戳 = 本次调用首次保存时刻，同调用内重存更新该段（时间戳不变）。

### Decision Date

2026-08-07

## DR-005 — CR-005

### Decision Status

ACCEPTED

### Decision Owner

spec-owner（Claude，经用户授权）

### Decision Rationale

PR-004（P2）指出纪要文件长期生命周期管理（归档/清理/浏览辅助/ADR 关联维护）缺失。属 v1 范围外，但应在 spec 显式记录为已知局限。证据成立（spec 全文无生命周期关键词）。接受为已知局限声明 + 预留可选扩展点。

### Required Action

1. §7 增「已知局限/后续增强」声明：长期生命周期管理为 v1 范围外，后续增强。
2. references/DISCUSSION-FORMAT.md 模板预留可选 frontmatter「状态」字段（默认不填）为扩展点。

### Decision Date

2026-08-07

## DR-006 — CR-006

### Decision Status

ACCEPTED

### Decision Owner

spec-owner（Claude，经用户授权）

### Decision Rationale

TD-004（P2）指出编号扫描对非 NNNN-*.md 文件的过滤规则未定义，且 references/ADR-FORMAT.md 共享同一缺口。证据成立（§3 仅「扫 max+1」）。docs/discussions/ 面向用户可见纪要，须定义过滤。接受并同步 ADR-FORMAT.md。

### Required Action

1. §3 编号规则补充过滤「仅匹配 NNNN-*.md（4 位数字前缀），不匹配忽略」。
2. references/ADR-FORMAT.md 同步同一过滤规则。
3. §6 改动清单增加 references/ADR-FORMAT.md 同步改动。

### Decision Date

2026-08-07

# Finding Lifecycle

每条合并发现的生命周期：

```text
PENDING_DECISION
  ↓
ACCEPTED / REJECTED / DEFERRED / PARTIALLY_ACCEPTED / DUPLICATE / INVALIDATED
```

一条发现不得因被拒绝 / 延迟 / 视为不必要 / 在后续修订中修复而从评审中消失。

其历史必须保留以供未来分析。

---

# Review Statistics

## Finding Counts

### By Source Review

* Product Findings: 4
* System Findings: 1
* Test Findings: 4

### After Consolidation

* Consolidated Findings: 6
* Unmerged Findings: 0
* Duplicate Findings: 0
* Superseded Findings: 0
* Cross-Reviewer Conflicts: 0（CR-001 存在 1 处 MINOR_INTERPRETATION_DIFFERENCE，非材料冲突）

### By Severity

* P0: 0
* P1: 3
* P2: 3

### By Status

* PENDING_DECISION: 6
* ACCEPTED: 0
* REJECTED: 0
* DEFERRED: 0
* PARTIALLY_ACCEPTED: 0
* DUPLICATE: 0
* INVALIDATED: 0

---

# Consolidation Conclusion

### Consolidation Result

COMPLETED

### Decision Readiness

PENDING_DECISION

### Summary

三份独立评审（Product 4 条、System 1 条、Test 4 条，共 9 条源发现）已成功合并为 6 条合并发现。无 MISSING 评审、无材料级冲突、Source Finding Integrity Check 通过（9 = 9 + 0 + 0）。

核心关注集中在一个主导主题：**主题→slug 映射的确定性**（CR-001，合并 PR/SC/TD 三视角，P1）及其关联的主题提取规则（CR-002，P1）。二者共同决定「按主题合并」这一核心设计承诺能否兑现。其余为边界行为澄清（CR-003 目录创建，P1）、会话段去重可靠性（CR-004，P2）、生命周期管理（CR-005，P2）与编号扫描过滤（CR-006，P2）。

所有 6 条发现均待决策（PENDING_DECISION）。合并者不声明 spec 通过或否决——最终处置由 Spec 所有者或 Superpowers 工作流决定。

### Final Review State

APPROVED

6 条合并发现全部 ACCEPTED（DR-001..006），相应 Required Action 已纳入 Design Spec 修订（spec v2，2026-08-07）。无 P0、无 REJECTED、无 DEFERRED。spec 可进入实现阶段。

---

# Machine-Readable Consolidation Index

```yaml
review:
  review_id: "CR-DDSUM-20260807-001"
  review_type: "CONSOLIDATED_REVIEW"
  status: "COMPLETED"
  design_spec: "docs/superpowers/specs/2026-08-07-discussion-summary-format-design.md"
  round: 1
  spec_stem: "discussion-summary-format-design"
  final_review_state: "APPROVED"

source_reviews:
  - reviewer: "product-reviewer"
    review_type: "PRODUCT_REVIEW"
    review_id: "PR-20260807-001"
    source_file: "docs/superpowers/reviews/discussion-summary-format-design/2026-08-07-review-001/product-review.md"
    status: "AVAILABLE"

  - reviewer: "system-critic"
    review_type: "SYSTEM_REVIEW"
    review_id: "SC-20260807-001"
    source_file: "docs/superpowers/reviews/discussion-summary-format-design/2026-08-07-review-001/system-review.md"
    status: "AVAILABLE"

  - reviewer: "test-designer"
    review_type: "TEST_REVIEW"
    review_id: "TD-20260807-001"
    source_file: "docs/superpowers/reviews/discussion-summary-format-design/2026-08-07-review-001/test-review.md"
    status: "AVAILABLE"

consolidated_findings:
  - id: "CR-001"
    title: "主题→slug 映射的非确定性破坏「按主题合并」"
    severity: "P1"
    confidence: "HIGH"
    status: "ACCEPTED"
    source_findings:
      product:
        - "PR-001"
      system:
        - "SC-001"
      test:
        - "TD-001"
    finding_type: "UNTESTABLE_REQUIREMENT"
    relationship_classification: "SAME_ROOT_CAUSE"
    conflict_status: "MINOR_INTERPRETATION_DIFFERENCE"
    source_references:
      - "Design Spec §2 关键设计决策表"
      - "Design Spec §3 落盘规则（命名 / 去重）"
      - "Design Spec §5 保存契约扩展（去重键）"
      - "Design Spec §7 边界与迁移（slug 歧义）"
    processing_status: "RESOLVED"
    severity_escalation: false
    severity_change_rationale: "PR-001/TD-001 均 HIGH 置信度判定 P1（打破核心设计决策 + 核心行为不可验证），SC-001 P2；合并取 P1 为三条独立证据相互印证，非机械取最高值。"

  - id: "CR-002"
    title: "主题提取规则未定义，「同主题」判断无客观标准"
    severity: "P1"
    confidence: "HIGH"
    status: "ACCEPTED"
    source_findings:
      product: []
      system: []
      test:
        - "TD-002"
    finding_type: "UNTESTABLE_REQUIREMENT"
    relationship_classification: "RELATED"
    conflict_status: "NO_CONFLICT"
    source_references:
      - "Design Spec §2 关键设计决策 — 多会话区分模型"
      - "Design Spec §3 落盘规则 — 去重"
      - "Design Spec §4 文件内结构"
      - "Design Spec §5 保存契约扩展"
    processing_status: "RESOLVED"
    severity_escalation: false
    severity_change_rationale: "No severity change from source findings."

  - id: "CR-003"
    title: "docs/discussions/ 目录懒创建与显式保存请求的交互歧义"
    severity: "P1"
    confidence: "HIGH"
    status: "ACCEPTED"
    source_findings:
      product:
        - "PR-002"
      system: []
      test: []
    finding_type: "N/A"
    relationship_classification: "INDEPENDENT"
    conflict_status: "NO_CONFLICT"
    source_references:
      - "Design Spec §3 落盘规则（懒创建 / 路径）"
      - "Design Spec §8 验收"
      - "SKILL.md 第 62–63 行（对照行为）"
    processing_status: "RESOLVED"
    severity_escalation: false
    severity_change_rationale: "No severity change from source findings."

  - id: "CR-004"
    title: "会话段去重依赖易失上下文内存，同日多段不可区分"
    severity: "P2"
    confidence: "MEDIUM"
    status: "ACCEPTED"
    source_findings:
      product:
        - "PR-003"
      system: []
      test:
        - "TD-003"
    finding_type: "BLIND_SPOT"
    relationship_classification: "SAME_ROOT_CAUSE"
    conflict_status: "NO_CONFLICT"
    source_references:
      - "Design Spec §4 文件内结构（同会话重存 / 段标题格式）"
      - "Design Spec §7 边界与迁移（跨 Claude 进程）"
    processing_status: "RESOLVED"
    severity_escalation: false
    severity_change_rationale: "No severity change from source findings."

  - id: "CR-005"
    title: "纪要文件的长期生命周期管理缺失"
    severity: "P2"
    confidence: "MEDIUM"
    status: "ACCEPTED"
    source_findings:
      product:
        - "PR-004"
      system: []
      test: []
    finding_type: "N/A"
    relationship_classification: "INDEPENDENT"
    conflict_status: "NO_CONFLICT"
    source_references:
      - "Design Spec §4 文件内结构模板"
      - "Design Spec §7 边界与迁移"
    processing_status: "RESOLVED"
    severity_escalation: false
    severity_change_rationale: "No severity change from source findings."

  - id: "CR-006"
    title: "编号扫描对非标准文件名的过滤规则未定义"
    severity: "P2"
    confidence: "MEDIUM"
    status: "ACCEPTED"
    source_findings:
      product: []
      system: []
      test:
        - "TD-004"
    finding_type: "UNTESTABLE_REQUIREMENT"
    relationship_classification: "INDEPENDENT"
    conflict_status: "NO_CONFLICT"
    source_references:
      - "Design Spec §3 落盘规则 — 编号"
      - "references/ADR-FORMAT.md — 编号规则"
    processing_status: "RESOLVED"
    severity_escalation: false
    severity_change_rationale: "No severity change from source findings."

unmerged_findings: []

duplicate_or_represented: []

conflicts: []

decision_queue:
  - id: "DQ-001"
    finding_id: "CR-001"
    severity: "P1"
    processing_status: "RESOLVED"

  - id: "DQ-002"
    finding_id: "CR-002"
    severity: "P1"
    processing_status: "RESOLVED"

  - id: "DQ-003"
    finding_id: "CR-003"
    severity: "P1"
    processing_status: "RESOLVED"

  - id: "DQ-004"
    finding_id: "CR-004"
    severity: "P2"
    processing_status: "RESOLVED"

  - id: "DQ-005"
    finding_id: "CR-005"
    severity: "P2"
    processing_status: "RESOLVED"

  - id: "DQ-006"
    finding_id: "CR-006"
    severity: "P2"
    processing_status: "RESOLVED"

decisions:
  - id: "DR-001"
    finding_id: "CR-001"
    decision: "ACCEPTED"
    date: "2026-08-07"
    owner: "spec-owner"
  - id: "DR-002"
    finding_id: "CR-002"
    decision: "ACCEPTED"
    date: "2026-08-07"
    owner: "spec-owner"
  - id: "DR-003"
    finding_id: "CR-003"
    decision: "ACCEPTED"
    date: "2026-08-07"
    owner: "spec-owner"
  - id: "DR-004"
    finding_id: "CR-004"
    decision: "ACCEPTED"
    date: "2026-08-07"
    owner: "spec-owner"
  - id: "DR-005"
    finding_id: "CR-005"
    decision: "ACCEPTED"
    date: "2026-08-07"
    owner: "spec-owner"
  - id: "DR-006"
    finding_id: "CR-006"
    decision: "ACCEPTED"
    date: "2026-08-07"
    owner: "spec-owner"

statistics:
  source_findings:
    product: 4
    system: 1
    test: 4
  consolidated_findings: 6
  unmerged_findings: 0
  duplicate_findings: 0
  represented_elsewhere_findings: 0
  conflicts: 0
  p0: 0
  p1: 3
  p2: 3
```

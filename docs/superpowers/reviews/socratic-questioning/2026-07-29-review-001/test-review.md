# Test Review

## 输出语言

本审核的所有描述性内容使用中文撰写；所有大写下划线格式的标识符与枚举值（P0/P1/P2、CONFIRMED_GAP/MATERIAL_RISK、HIGH/MEDIUM/LOW、ACCEPTANCE_TEST/UNTESTABLE_REQUIREMENT/BLIND_SPOT、REQUIRES_REVIEW、COMPLETED、REVIEWED/NOT_APPLICABLE、PENDING_DECISION、OPEN 等）保持英文；Machine-Readable YAML 索引的 key 与枚举值保持英文，title 等描述性字段使用中文。

## Review Metadata

### Review ID

TEST-REVIEW-2026-07-29-001

### Reviewer

yy-test-designer

### Review Type

TEST_REVIEW

### Design Spec

/Users/yuezhenhua/yonyou/AI/skills/socratic-questioning/docs/superpowers/specs/2026-07-29-socratic-questioning-design.md

### Review Date

2026-07-29

### Review Status

COMPLETED

---

## Review Scope

本审核评估该 Design Spec 能否在落地实现前被客观验证。

聚焦：

* 缺失的验收标准；
* 不可测的需求；
* 未定义的期望结果；
* 缺失的边界条件；
* 失败/恢复行为缺口；
* 数据完整性验证缺口；
* 状态转换验证缺口；
* 向后兼容验证缺口；
* 运维可观测性缺口；
* 长期回归风险。

本审核不：评审代码质量、重设系统架构、指定实现技术、产出完整测试计划、替代安全/性能/生产验证、做出最终批准决策。

本审核目的：判断 Design Spec 是否把可观测行为定义得足够清晰，可被客观验证。无法被客观验证的需求即定义不足。

---

## Findings

### TD-001 — 落盘触发意图边界未定义，无法判定"显式要求保存"

#### Severity

P1

#### Evidence Class

CONFIRMED_GAP

#### Confidence

HIGH

#### Finding Type

UNTESTABLE_REQUIREMENT

#### Location

Design Spec 第 3.2 节「按需落盘」、第 2 节落盘触发决策、验收标准第 3 条。

#### Verification Gap

Design Spec 规定"仅当用户显式要求保存时执行"，并以自然语言识别触发词（保存/落文档/导出），"不强制特定命令"。但"显式要求"的具体语义边界未定义：哪些表达算"显式要求保存"、哪些不算，没有可判定的依据。验收标准第 3 条仅覆盖了"用户说保存/落文档"这一明确样例，未定义边界。因此无法客观判断：当用户说出"好的，记住这个""这个结论挺重要，存档一下""回头我再看"等近似表达时，系统应保存还是不保存。

#### Trigger Scenario

1. 用户完成一轮拷问，未说出"保存/落文档/导出"等强触发词。
2. 用户说："这个术语表挺关键的，你帮我留着。"（近似表达）
3. Design Spec 未定义该表达是否构成"显式要求保存"。
4. 实现可能保存、也可能不保存，两种行为都无法被判定为"错误"，验收标准无法给出 pass/fail。

#### Expected Verification

测试人员应能依据 Design Spec 确定：给定一条用户输入，系统应当落盘或不落盘，且该判定可被客观核对。当前应为每条候选表达定义"触发 / 不触发 / 需追问澄清"的明确分类。

#### Verification Method

No objective verification method is currently defined. 验收标准第 3 条只断言"用户说保存/落文档后生成文件"，未覆盖边界表达；缺少用于判定"显式要求"的可执行规则或可观测的决策依据。

#### Consequence

不同实现/不同次运行可能对同类表达给出不同落盘结果，却都满足 Design Spec；"绝不自动创建文件"这一铁律（第 5 节）可能在边界处被无声违反或过度保守，难以通过验收判定发现。

#### Evidence

Design Spec 3.2："落盘位置、触发词（保存/落文档/导出）均以自然语言识别，不强制特定命令。" 验收标准第 3 条仅以"用户说'保存/落文档'"为样例。第 5 节铁律："除非用户明确要求，绝不自动创建任何文件"。显式证据：触发判定规则未定义；推断：近似表达的归类将依赖实现者主观判断。

#### Recommendation

定义"显式保存请求"的最小可判定集合与边界样例，至少覆盖：强触发词、近似表达、可视为询问澄清的表达三类，并给出每类的期望行为（落盘 / 不落盘 / 追问）。

#### Source References

* 第 3.2 节 按需落盘
* 第 2 节 落盘触发 决策行
* 验收标准 第 3 条

#### Reviewer Notes

落盘"不创建文件"这一负向结果本身可由"检查工作目录无新增文件"客观验证（验收标准第 2 条已覆盖）；本缺口在于"何时应当落盘"的正向触发判定边界缺失，不否定第 2 条的可测性。

---

### TD-002 — ADR 候选"三条件"达标判定主观，无法客观核对是否应落盘

#### Severity

P1

#### Evidence Class

CONFIRMED_GAP

#### Confidence

HIGH

#### Finding Type

UNTESTABLE_REQUIREMENT

#### Location

Design Spec 第 3.1 节第 6 点（决策候选达标条件）、第 3.2 节「懒创建」。

#### Verification Gap

Design Spec 规定仅当某决策同时满足"难回退 + 外人会疑惑 + 真实取舍"三条件时才标为 ADR 候选并落盘 `docs/adr/`。这三条均为高度主观、未量化的判断，没有可观测的判定依据。可观测结果（文件是否存在）可被检查，但"该文件是否*应当*存在"无法被客观确定。两名胜任的评审者可能对同一决策是否达标得出相反结论，且两者都能声称满足 Design Spec。

#### Trigger Scenario

1. 拷问中产生一个决策：例如"审批流使用同步调用"。
2. 该决策是否"难回退/外人会疑惑/真实取舍"需主观评估。
3. Design Spec 未给出任一条件的判定标准或可观测信号。
4. 实现者判定为达标并生成 ADR，或判定为不达标而不生成——两种结果均无法被验收判定为错误。

#### Expected Verification

测试人员应能依据 Design Spec 核对：某条敲定决策是否应进入 `docs/adr/`。当前应为三条件各提供至少一条可判定的判定线索（例如"难回退"的判定参考：是否存在已依赖该决策的其他产物）。

#### Verification Method

No objective verification method is currently defined. 验收标准第 3 条仅断言"有达标决策时生成 docs/adr/"，但"达标"本身无客观标准。

#### Consequence

`docs/adr/` 目录内容的正确性与完整性无法被验收验证；可能漏建关键 ADR 或误建非必要 ADR，且两种情况都能通过验收，导致文档产出与原版预期语义偏离而无从发现。

#### Evidence

显式证据：第 3.1 节"仅当某决策同时满足'难回退 + 外人会疑惑 + 真实取舍'三条件时，才标为 ADR 候选"。第 3.2 节"没有达标的决策就不建 docs/adr/"。推断：三条件为定性判断，无量化或可观测锚点。

#### Recommendation

为三条件各给出至少一条可判定线索或示例阈值（正例/反例），使"是否达标"可由评审者依据 Design Spec 一致判定，而非依赖个人主观。

#### Source References

* 第 3.1 节 第 6 点
* 第 3.2 节 懒创建
* 验收标准 第 3 条

#### Reviewer Notes

本缺口影响"正确性"而非"可观测性"——文件存在与否可见，但其应否存在不可验证。

---

### TD-003 — 拷问行为纪律（一次一问/带推荐答案/逐枝推进）无客观可验证的成功条件

#### Severity

P1

#### Evidence Class

CONFIRMED_GAP

#### Confidence

HIGH

#### Finding Type

UNTESTABLE_REQUIREMENT

#### Location

Design Spec 第 3.1 节第 1、2、3 点；验收标准第 1 条。

#### Verification Gap

验收标准第 1 条要求"`/socratic-questioning` 能启动一次结构化拷问：一次一问、带推荐答案、逐枝推进"。这三项均为对 LLM 行为纪律的描述，缺少可客观测定的成功条件：

* "一次一问"：一次回复中问题数量是 1 还是"以一个问题为主"算合规？无判定阈值。
* "带推荐答案"：每个问题是否必须附推荐答案？附了但与问题弱相关算不算合规？无标准。
* "逐枝推进/走遍每个决策分支"：何为"走遍"？由谁、依何种证据判定所有分支已覆盖？无可观测的完成判据。

这些行为发生在对话上下文中，结果仅体现为自然语言文本，无法被独立测试者以确定性方式判定 pass/fail。

#### Trigger Scenario

1. 启动 `/socratic-questioning`，agent 在某一轮回复中给出 1 个主问题并附带 2 句补充说明。
2. 测试者需判定该轮是否违反"一次一问"。
3. Design Spec 未定义"一次一问"的违规边界（如允许多少辅助文字）。
4. 不同测试者可能给出不同结论，验收无法达成一致。

#### Expected Verification

测试人员应能依据 Design Spec 判定：给定一段会话记录，拷问循环是否满足三条纪律。当前应定义每条纪律的可判定违例条件（例如"一轮回复包含超过 1 个以问号结尾的独立问题"视为违规）。

#### Verification Method

No objective verification method is currently defined. 验收标准第 1 条使用定性描述，无量化或可观测的判定阈值。

#### Consequence

核心行为（本技能价值所在）的验收依赖主观判断；实现可能在"一次多问""漏给推荐答案""跳过分支"的情况下仍被判定为通过，使技能质量不可控。

#### Evidence

显式证据：第 3.1 节第 1 点"一次只抛一个问题"、第 2 点"每个问题都附上推荐答案"、第 3 点"走遍每个决策分支"。验收标准第 1 条同义复述。推断：均为行为纪律描述，缺可测判据。

#### Recommendation

为每条纪律补充可判定违例条件与至少 1 个正例/反例；若完全依赖 LLM 自觉难以自动化，至少定义人工评审的核对清单与通过门槛。

#### Source References

* 第 3.1 节 第 1、2、3 点
* 验收标准 第 1 条

#### Reviewer Notes

此类 LLM 行为纪律天然难以完全自动化验证，但 Design Spec 至少应给出可复核的客观门槛，而非完全交由主观。

---

### TD-004 — "清空草稿/重启拷问"的内部状态重置不可观测，可能产生脏草稿污染

#### Severity

P2

#### Evidence Class

MATERIAL_RISK

#### Confidence

MEDIUM

#### Finding Type

BLIND_SPOT

#### Location

Design Spec 第 5 节「用户想重来：支持清空草稿/重启拷问，丢弃内部累积的术语与决策草稿」。

#### Verification Gap

"清空草稿/重启拷问"针对的是对话上下文中的内部累积草稿（术语表草稿、决策候选），而非磁盘文件（第 3.1 节第 6 点明确草稿"只在对话上下文里"维护、不落盘）。因此重置动作没有外部可观测的副作用：测试者无法通过观察工作目录、文件或接口状态来确认草稿已被丢弃。

风险在于：若重置不彻底，残留草稿可能在后续保存时被错误写入 `CONTEXT.md` 或 `docs/adr/`，而该错误在正常功能验收（"用户要求保存后生成文件"）中无法被发现——因为文件确实"生成了"，只是内容混入了应被丢弃的旧草稿。

#### Trigger Scenario

1. 第一轮拷问累积了术语 A、B 与决策候选 X。
2. 用户要求"清空草稿/重启拷问"。
3. 实现仅重置了表层标志，内部仍保留 X。
4. 用户重新拷问并只确认了术语 C，要求保存。
5. 生成的 `CONTEXT.md`/`docs/adr/` 混入已应丢弃的 X，且因"要求保存后确实生成了文件"，功能验收通过——污染未被发现。

#### Expected Verification

若重置正确，后续保存产出的文档不应包含重启前已丢弃的草稿内容。测试应能对比"重启前累积集合"与"重启后首次保存产出"，确认被丢弃项不出现。当前无外部信号可建立该对比。

#### Verification Method

No objective verification method is currently defined. 草稿为纯对话内部状态，无落盘、无事件、无接口暴露；验收标准未覆盖重启后的内容纯净度。

#### Consequence

脏草稿污染可在无外部失败信号的情况下进入交付文档，且常规验收（仅检查"文件是否生成"）无法发现；属于生产/使用中的静默错误。

#### Evidence

显式证据：第 3.1 节第 6 点"只在对话上下文里维护两份草稿"；第 5 节"丢弃内部累积的术语与决策草稿"。推断：内部状态无外部可观测锚点。

#### Recommendation

定义重启后内容纯净度的可验证方法，例如要求实现在重启时给出可观测确认（日志/事件/标记），或定义"重启后首次保存产出必须等于本轮新确认集合"的验收等式。

#### Source References

* 第 3.1 节 第 6 点
* 第 5 节 用户想重来

#### Reviewer Notes

置信度为 MEDIUM：取决于具体实现是否对内部草稿做隔离；但 Design Spec 当前未提供任何可观测证据，故风险成立。

---

### TD-005 — 多 context（CONTEXT-MAP.md）的"按原版逻辑"未在本 Spec 定义，行为不可验证

#### Severity

P2

#### Evidence Class

MATERIAL_RISK

#### Confidence

MEDIUM

#### Finding Type

BLIND_SPOT

#### Location

Design Spec 第 5 节「多 context 仓库：若检测到 CONTEXT-MAP.md，按原版逻辑推断应使用哪个 context；若无法确定则询问用户」，并引用 `CONTEXT-FORMAT.md` 中的多 context 说明。

#### Verification Gap

Design Spec 要求"按原版逻辑推断应使用哪个 context"，但"原版逻辑"指向 Matt 原版技能，并未在本 Design Spec 或其 `references/` 文件中给出可核验的定义；`CONTEXT-FORMAT.md` 在本 Spec 中仅被描述为"译自原版、中文"，其是否包含足以判定 context 选择的规则未在本 Spec 内确认。因此当仓库存在 `CONTEXT-MAP.md` 时，系统选择哪个 context 是否正确，无法依据本 Design Spec 客观验证。

若实现选错 context（例如把术语写入错误的 context 文件），可能仅在多 context 仓库场景下发生，且表面仍"生成了 CONTEXT.md"，常规单 context 验收（验收标准第 2、3 条）无法发现。

#### Trigger Scenario

1. 用户在含 `CONTEXT-MAP.md` 的多 context 仓库中启动 `/socratic-questioning`。
2. 存在多个可选 context（如 `frontend`、`backend`）。
3. Design Spec 未定义选择算法，"原版逻辑"未在 Spec 内可查。
4. 实现选错 context 并落盘，单 context 验收通过，错误静默留存。

#### Expected Verification

测试人员应能依据本 Design Spec 判定：给定 `CONTEXT-MAP.md`，系统是否选择了正确的 context。当前应把"原版逻辑"的关键判定规则纳入本 Spec 或明确引用可查文件的具体章节。

#### Verification Method

No objective verification method is currently defined within this Design Spec. `CONTEXT-FORMAT.md` 内容未在本 Spec 内展开，其多 context 说明是否含可判定规则未知。

#### Consequence

多 context 场景下的错误 context 选择属静默失败，常规验收覆盖不到；可能导致术语/ADR 落错位置，污染仓库文档体系。

#### Evidence

显式证据：第 5 节"按原版逻辑推断应使用哪个 context；若无法确定则询问用户（参考 CONTEXT-FORMAT.md 中的多 context 说明）"。推断："原版逻辑"为本 Spec 外部依赖，未在 Spec 内给出可核验定义。

#### Recommendation

将多 context 选择的判定规则（或至少其关键条件与优先级）纳入本 Design Spec 或可查的 references 文件，并定义可验证的选型期望与"无法确定时询问用户"的触发条件。

#### Source References

* 第 5 节 多 context 仓库
* 第 4 节 references/CONTEXT-FORMAT.md 说明

#### Reviewer Notes

本缺口为外部依赖型：若 `CONTEXT-FORMAT.md` 实际已含完整规则，则只需在 Spec 内显式引用其章节即可闭合，风险降级。

---

## Testability Coverage

| Verification Dimension                 | Status          | Finding IDs |
| -------------------------------------- | --------------- | ----------- |
| Happy Path Verification                | REVIEWED        | TD-001, TD-002, TD-003 |
| Boundary and Limit Verification        | REVIEWED        | TD-001, TD-002 |
| Duplicate and Idempotency Verification | NOT_APPLICABLE  | — |
| Invalid Input Verification             | REVIEWED        | TD-001 |
| Failure and Timeout Verification       | NOT_APPLICABLE  | — |
| Partial Failure Verification           | NOT_APPLICABLE  | — |
| Data Integrity Verification            | REVIEWED        | TD-002, TD-004 |
| State Transition Verification          | REVIEWED        | TD-004 |
| Permission Boundary Verification       | NOT_APPLICABLE  | — |
| Backward Compatibility Verification    | NOT_APPLICABLE  | — |
| Temporal Verification                  | NOT_APPLICABLE  | — |
| Migration Verification                 | NOT_APPLICABLE  | — |
| External Dependency Verification       | REVIEWED        | TD-005 |
| Observability Verification             | REVIEWED        | TD-004, TD-005 |
| Recovery Verification                  | REVIEWED        | TD-004 |

说明（NOT_APPLICABLE 原因）：

* Duplicate and Idempotency / Failure and Timeout / Partial Failure / Permission Boundary / Backward Compatibility / Temporal / Migration：本技能为交互式对话技能，无幂等重试、超时、外部事务、权限边界、历史版本兼容、时间依赖或数据迁移等高相关场景，故标记 NOT_APPLICABLE。

---

## Unresolved Verification Questions

### Q-001 — "显式要求保存"的判定边界如何定义？

#### Question

哪些用户输入表达构成"显式要求保存"、哪些不算、哪些应追问澄清？

#### Why It Matters

直接决定 TD-001 的验收可判定性，也关系到"绝不自动创建文件"铁律是否在边界处被违反。

#### Required Clarification

需 Design Spec 补充触发/不触发/追问三类的样例与判定依据。

#### Status

OPEN

---

### Q-002 — ADR 候选"三条件"的可判定线索是什么？

#### Question

"难回退 / 外人会疑惑 / 真实取舍"各自以什么可观测或可复核的线索判定？

#### Why It Matters

决定 TD-002 中 `docs/adr/` 产出正确性的可验证性。

#### Required Clarification

需为三条件各提供判定线索与正/反例。

#### Status

OPEN

---

### Q-003 — 多 context 选择的"原版逻辑"是否已在本 Spec 可查文件中定义？

#### Question

`CONTEXT-FORMAT.md` 是否包含可据以验证 context 选择的规则？若否，本 Spec 是否需补充？

#### Why It Matters

决定 TD-005 多 context 场景的可验证性与静默失败风险。

#### Required Clarification

需确认 references 文件内容或在本 Spec 内补充选型规则。

#### Status

OPEN

---

## Review Limitations

* 本审核未读取 `references/CONTEXT-FORMAT.md` 与 `references/ADR-FORMAT.md` 实际内容，TD-005 对其是否含可判定规则的判断基于 Design Spec 的描述性引用，存在不确定性（已在 Reviewer Notes 标注）。
* 本技能核心行为由 LLM 在对话上下文中执行，部分行为（TD-003、TD-004）天然缺乏外部可观测锚点，相关缺口的置信度受实现方式影响。

---

## Reviewer Conclusion

### Critical Testability Finding Count

* P0: 0
* P1: 3
* P2: 2

### Finding Type Breakdown

* Acceptance Tests: 0
* Untestable Requirements: 3
* Blind Spots: 2

### Review Result

REQUIRES_REVIEW

本审核识别出多项验证缺口、不可测需求与生产盲点，须由 Consolidation 阶段考虑。

Test Designer 不决定 Findings 最终被接受、拒绝、推迟或以其他方式处置。

最终处置由 Decision Protocol 决定。

---

## Machine-Readable Finding Index

```yaml
review:
  review_id: "TEST-REVIEW-2026-07-29-001"
  reviewer: "yy-test-designer"
  review_type: "TEST_REVIEW"
  status: "COMPLETED"

findings:
  - id: "TD-001"
    severity: "P1"
    evidence_class: "CONFIRMED_GAP"
    confidence: "HIGH"
    finding_type: "UNTESTABLE_REQUIREMENT"
    title: "落盘触发意图边界未定义，无法判定显式要求保存"
    source_references:
      - "第 3.2 节 按需落盘"
      - "第 2 节 落盘触发 决策行"
      - "验收标准 第 3 条"
    status: "PENDING_DECISION"
  - id: "TD-002"
    severity: "P1"
    evidence_class: "CONFIRMED_GAP"
    confidence: "HIGH"
    finding_type: "UNTESTABLE_REQUIREMENT"
    title: "ADR 候选三条件达标判定主观，无法客观核对是否应落盘"
    source_references:
      - "第 3.1 节 第 6 点"
      - "第 3.2 节 懒创建"
      - "验收标准 第 3 条"
    status: "PENDING_DECISION"
  - id: "TD-003"
    severity: "P1"
    evidence_class: "CONFIRMED_GAP"
    confidence: "HIGH"
    finding_type: "UNTESTABLE_REQUIREMENT"
    title: "拷问行为纪律无客观可验证的成功条件"
    source_references:
      - "第 3.1 节 第 1、2、3 点"
      - "验收标准 第 1 条"
    status: "PENDING_DECISION"
  - id: "TD-004"
    severity: "P2"
    evidence_class: "MATERIAL_RISK"
    confidence: "MEDIUM"
    finding_type: "BLIND_SPOT"
    title: "清空草稿重启拷问的内部状态重置不可观测，可能脏草稿污染"
    source_references:
      - "第 3.1 节 第 6 点"
      - "第 5 节 用户想重来"
    status: "PENDING_DECISION"
  - id: "TD-005"
    severity: "P2"
    evidence_class: "MATERIAL_RISK"
    confidence: "MEDIUM"
    finding_type: "BLIND_SPOT"
    title: "多 context 的按原版逻辑未在本 Spec 定义，行为不可验证"
    source_references:
      - "第 5 节 多 context 仓库"
      - "第 4 节 references/CONTEXT-FORMAT.md 说明"
    status: "PENDING_DECISION"

open_questions:
  - id: "Q-001"
    status: "OPEN"
    question: "显式要求保存的判定边界如何定义？"
  - id: "Q-002"
    status: "OPEN"
    question: "ADR 候选三条件的可判定线索是什么？"
  - id: "Q-003"
    status: "OPEN"
    question: "多 context 选择的原版逻辑是否已在本 Spec 可查文件中定义？"
```

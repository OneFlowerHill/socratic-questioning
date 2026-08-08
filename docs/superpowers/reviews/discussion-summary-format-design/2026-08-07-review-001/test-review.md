# Test Review

## Review Metadata

### Review ID

TD-20260807-001

### Reviewer

test-designer

### Review Type

TEST_REVIEW

### Design Spec

docs/superpowers/specs/2026-08-07-discussion-summary-format-design.md

### Review Date

2026-08-07

### Review Status

COMPLETED

---

## Review Scope

本评审评估 Design Spec 定义的行为在实施前是否可被客观验证。

评审聚焦于：

- 验收标准缺失；
- 不可测试的需求；
- 未定义的预期结果；
- 缺失的边界条件；
- 失败恢复缺口；
- 数据完整性验证缺口；
- 状态迁移验证缺口；
- 向后兼容验证缺口；
- 运维可观测性缺口；
- 长期回归风险。

本评审不涉及：

- 代码质量；
- 系统架构重新设计；
- 实施技术选型；
- 创建完整测试计划；
- 替代安全测试、性能测试或生产验证；
- 作出最终批准决定。

本评审的目的是判断 Design Spec 是否将可观察行为定义得足够清晰，可被客观验证。

无法被客观验证的需求，定义尚不充分。

---

## Findings

### TD-001 — 中文主题→英文 slug 翻译规则未定义，导致文件命名不可复现

#### Severity

P1

#### Evidence Class

CONFIRMED_GAP

#### Confidence

HIGH

#### Finding Type

UNTESTABLE_REQUIREMENT

#### Location

Design Spec §3 落盘规则 — 命名规则："slug = 主题归一化 kebab-case；中文主题由技能译成短英文 slug"

#### Verification Gap

Design Spec 要求将中文主题翻译为英文 slug 作为文件名的一部分，但未定义翻译算法或规则。同一段对话内容，两次独立运行（或不同测试者测试）可能产生不同的 slug，从而导致：

- 同一主题被保存到不同文件中（slug 不同），破坏了"按主题合并"的核心行为；
- 不同主题被保存到同一文件中（slug 碰巧相同），导致无关内容合并。

当前唯一的安全网是 §7 中的"确认门禁展示拟用 slug，用户可改"，但这依赖人工审查，且用户可能不理解 slug 对后续去重的影响。

#### Trigger Scenario

1. 用户在中文环境下进行了一次 socratic-questioning，主题为"内部审批流"。
2. 用户要求保存纪要。
3. 技能将中文主题翻译为 slug（例如可能生成 `internal-approval-flow`）。
4. 用户随后在另一次会话中用不同措辞描述同一主题（例如"审批流程设计"），要求保存纪要。
5. 技能可能生成不同的 slug（例如 `approval-process-design`），创建了第二个文件。
6. 两个文件实际上讨论同一主题，但无法按 Spec 设计的"同主题合并"行为工作。

#### Expected Verification

测试者应能验证：给定同一语义主题（即使用词不同），技能生成相同 slug，从而保存到同一文件。

#### Verification Method

No objective verification method is currently defined. slug 翻译规则未定义，无法判断技能输出的 slug 是否正确。

#### Consequence

"按主题合并"是该 Spec 最核心的行为特性（区别于旧版单文件 `docs/grill-summary.md`）。如果 slug 生成不一致，多会话区分能力将不可靠地工作——测试中可能偶然正确，但不同措辞或不同 Claude 运行可能产生不同结果。用户数据可能分散在多个文件中，失去纪要归类价值。

#### Evidence

Design Spec §3 明确定义 "slug = 主题归一化 kebab-case；中文主题由技能译成短英文 slug（如「内部审批流」→ `internal-approval-flow`）"，但仅给出了一个示例，未定义翻译规则、归一化步骤或可复现的算法。

对比：SKILL.md 的 ADR 编号规则（扫描 `docs/adr/` 已有最大号 +1）是可客观验证的——扫描目录、取最大编号、加一，结果确定。而 slug 生成没有对应的确定性规则。

#### Recommendation

至少定义以下规则之一，使 slug 生成可复现：

1. 定义 slug 的生成流程：例如"从对话中提取关键名词短语→翻译为英文→kebab-case 归一化"，并给出判断标准；
2. 或在确认门禁中要求用户显式确认/修改 slug（当前已有），并明确声明："slug 一旦确定即作为该主题的永久标识，后续同主题会话应复用此 slug"——这样 slug 的最终确定权在用户手中，可验证性强于自动生成。

#### Source References

- Design Spec §3 落盘规则 — 命名
- Design Spec §7 边界与迁移 — slug 歧义
- Design Spec §2 关键设计决策 — "按主题合并（严格同 ADR）"

#### Reviewer Notes

该 Spec 本质是对 AI 技能（LLM 驱动）的行为规范。LLM 驱动的话题提取和翻译天然具有非确定性。从此角度看，完全确定性的 slug 生成可能需要额外机制（如用户确认 slug 并记录到文件中）。当前 Spec 在 §7 中已承认"沿用 ADR 同款风险（YAGNI）"，但 ADR 的 slug 由用户在确认门禁中看到并确认；本 Spec 的纪要 slug 面临同样问题但未明确说明用户确认 slug 的责任边界。

---

### TD-002 — 主题提取规则未定义，导致"同主题→同文件"去重不可验证

#### Severity

P1

#### Evidence Class

CONFIRMED_GAP

#### Confidence

HIGH

#### Finding Type

UNTESTABLE_REQUIREMENT

#### Location

Design Spec §2 关键设计决策 — 多会话区分模型："按主题合并（严格同 ADR）"；§3 去重规则："按主题 slug 去重——同主题再存 → 复用既有文件序号"

#### Verification Gap

"按主题合并"的前提是技能能正确识别"当前会话讨论的是什么主题"。但 Spec 未定义主题提取规则：

- 主题如何从对话中提取？是从用户的初始提问、从整段对话语义、还是从用户手动指定？
- 什么构成"同一主题"？措辞不同但语义相同的对话是否算同一主题？
- 如果一次会话涉及多个主题，纪要如何归属？

没有主题提取规则，"同主题→同文件"的行为无法被客观验证。测试者只能通过反复实验观察实际行为，但无法判断行为的正确性——因为没有正确性标准。

#### Trigger Scenario

1. 用户在一次会话中讨论了"内部审批流的状态机设计"。
2. 用户要求保存纪要。技能提取主题并生成 slug。
3. 用户在另一次会话中讨论了"审批流的权限模型"。
4. 用户再次要求保存纪要。
5. 测试者需要判断：这两次会话是否应视为"同一主题"从而合并到同一文件？Spec 未提供判断依据。
6. 不同的测试者（或不同的 Claude 运行）可能做出不同的判断，但都是"合理"的。

#### Expected Verification

测试者应能根据客观标准判断：给定两段对话内容，它们是否属于同一主题，从而纪要应合并到同一文件还是分开保存。

#### Verification Method

No objective verification method is currently defined. 主题提取和同一性别定标准缺失。

#### Consequence

"按主题合并"的核心价值——多会话可区分且相关会话可关联——无法被可靠验证。产品行为可能在不同使用场景下表现不一致，用户可能发现同一主题的内容分散在多个文件中，或不同主题被意外合并。

#### Evidence

Design Spec §2 中"按主题合并（严格同 ADR）"直接决定了 §3 的去重规则、§4 的文件内结构和 §5 的保存契约扩展。但 Spec 通篇未定义"主题"的来源和判别标准。

ADR 场景中，主题通常由用户明确声明（决策标题），而纪要场景中主题可能隐含在对话中。两者的"主题确定方式"不同，Spec 未区分这两种场景。

#### Recommendation

在 Spec 中补充主题提取规则，至少覆盖以下场景：

1. 用户使用 `/socratic-questioning 我想做个内部审批流` 时，主题从命令参数中提取；
2. 用户未附带主题参数时，技能从首轮对话中推断主题，并在确认门禁中展示拟用主题（连同 slug），供用户确认或修改；
3. 明确定义"同一主题"的判断标准（例如：slug 相同即同一主题，slug 由用户最终确认）。

#### Source References

- Design Spec §2 关键设计决策 — 多会话区分模型
- Design Spec §3 落盘规则 — 去重
- Design Spec §4 文件内结构
- Design Spec §5 保存契约扩展

#### Reviewer Notes

此 Gap 与 TD-001（slug 翻译规则未定义）相互关联但独立：TD-001 关注"给定主题后如何生成 slug"；TD-002 关注"如何从对话中提取主题"。两者共同构成"按主题合并"行为的验证前置条件。

---

### TD-003 — 会话内去重依赖上下文内存，上下文丢失时静默失效

#### Severity

P2

#### Evidence Class

MATERIAL_RISK

#### Confidence

MEDIUM

#### Finding Type

BLIND_SPOT

#### Location

Design Spec §4 文件内结构 — 行为规则："同会话重存：更新本段（覆盖该 `## 会话 YYYY-MM-DD` 段），不追加；技能在上下文内记住本次会话写的文件 + 段日期"

#### Verification Gap

Spec 定义的同会话幂等机制完全依赖"技能在上下文内记住"——即依靠 Claude 对话上下文的内存。如果对话上下文因以下原因丢失或重置，会话内去重将静默失效：

- 对话历史过长导致上下文窗口截断，早期记忆被逐出；
- 用户在同一会话中进行了"清空草稿/重启拷问"（CR-010），但未意识到这也清除了纪要写入记忆；
- 会话中途发生模型切换或上下文重建。

在这些场景中，后续保存操作可能产生重复的 `## 会话 YYYY-MM-DD` 段，而技能不会给出任何警告。

#### Trigger Scenario

1. 用户开始一次 socratic-questioning 会话，主题为"内部审批流"。
2. 用户要求保存纪要。技能写入文件，并在上下文内记住文件路径和段日期。
3. 对话继续进行了大量讨论（长篇对话），上下文窗口滚动，早期记忆被逐出。
4. 用户再次要求"把最新的结论也存一下"。
5. 技能已丢失之前写入的记忆，可能：
   - 追加一个新的同日期段（重复段）；或
   - 重新扫目录匹配文件后追加新段（但无法识别应更新现有段）。
6. 结果：文件中出现重复的会话段，且无任何错误提示。

#### Expected Verification

测试者应能验证：无论对话长度或上下文状态如何，同会话内多次保存始终产生幂等结果（更新同段，不追加新段）。

#### Verification Method

No objective verification method is currently defined for scenarios where context memory is lost. 当前的设计未提供除上下文内存之外的会话去重机制。

在正常短对话场景中，该行为是可验证的（检查文件内容无重复段）。但在长对话或上下文异常场景中，没有可观测的信号来区分"正常去重"和"静默失效"。

#### Consequence

用户可能在不知情的情况下产生重复的纪要段，降低纪要的可读性和准确性。由于失效是静默的，用户只能在事后人工检查文件内容时发现——而这正是纪要旨在避免的认知负担。

#### Evidence

Design Spec §4 明确将去重机制定义为"技能在上下文内记住"——这是一种纯内存机制，无持久化备份。

对比：SKILL.md 的 ADR 去重（CR-001 §3）依赖文件系统扫描（按 slug 匹配既有文件），不依赖上下文内存，因此更可靠。

#### Recommendation

建议为同会话去重增加文件系统级别的检测作为补充安全网：

1. 写入前读取目标文件的当前内容；
2. 检测是否已存在同日期 `## 会话 YYYY-MM-DD` 段；
3. 若已存在，即使上下文记忆丢失，仍按"更新现有段"处理；
4. 可选：若检测到上下文记忆与文件系统实际状态不一致，向用户发出提示。

#### Source References

- Design Spec §4 文件内结构 — 行为规则
- Design Spec §5 保存契约扩展 — 幂等规则
- SKILL.md CR-001 §3 ADR 去重规则（对比参考）

#### Reviewer Notes

该风险的置信度评为 MEDIUM 而非 HIGH，原因是：
- 在典型使用场景（短到中长度对话）中，上下文内存通常是可靠的；
- Claude Code 的上下文管理机制（如摘要压缩）可能在一定程度上保留关键信息。
但该机制完全依赖 LLM 上下文，缺乏文件系统级别的防御性检查，构成了真实的生产盲点。

---

### TD-004 — 编号扫描对目录中非标准文件名的处理未定义

#### Severity

P2

#### Evidence Class

CONFIRMED_GAP

#### Confidence

MEDIUM

#### Finding Type

UNTESTABLE_REQUIREMENT

#### Location

Design Spec §3 落盘规则 — 编号："扫描 `docs/discussions/` 已有最大号 +1"

#### Verification Gap

Spec 定义编号通过"扫描 `docs/discussions/` 已有最大号 +1"生成，但未定义如何处理目录中不匹配 `NNNN-slug.md` 模式的文件。可能的非标准文件包括：

- 用户手动创建的 README.md 或其他说明文件；
- 从旧版 `docs/grill-summary.md` 手动迁移但未改名的文件；
- 临时文件或备份文件（如 `0001-topic.md.bak`）；
- 系统文件（如 `.DS_Store`）。

如果扫描逻辑不加过滤，可能提取到非数字前缀或异常大的"编号"，导致 max+1 计算错误。

#### Trigger Scenario

1. `docs/discussions/` 目录中已有两个标准纪要文件：`0001-internal-approval-flow.md` 和 `0002-data-model.md`。
2. 用户在该目录中手动创建了一个 `README.md` 文件。
3. 用户进行新的 socratic-questioning 会话，要求保存纪要。
4. 技能扫描 `docs/discussions/` 目录获取最大编号。
5. 如果扫描逻辑未过滤非 `NNNN-*.md` 文件，行为不确定——可能忽略 README.md 正确得到 0003，也可能因为解析失败而产生错误。

#### Expected Verification

测试者应能验证：无论 `docs/discussions/` 目录中存在何种非标准文件，编号始终 = 匹配 `NNNN-slug.md` 模式的文件中的最大编号 +1。

#### Verification Method

No objective verification method is currently defined. Spec 未声明编号扫描的过滤规则。

#### Consequence

在用户目录中存在非标准文件时，编号可能产生意外结果（跳号、编号错误或写操作失败）。虽然这不是高频场景，但一旦发生，用户难以排查原因——因为 Spec 未定义期望行为。

#### Evidence

Design Spec §3 仅声明"扫描 `docs/discussions/` 已有最大号 +1"，未定义文件过滤规则。

对比：`references/ADR-FORMAT.md` 的编号规则同样只说"扫描 `docs/adr/` 中已有最大编号并 +1"，同样未定义过滤规则——这意味着两个目录共享同一未定义行为，但 ADR 目录通常由技能独占写入，而非标准文件引入的风险较低；`docs/discussions/` 目录面向用户可见的纪要，用户更可能手动操作该目录。

#### Recommendation

在 Spec 中明确定义编号扫描的文件过滤规则。最小建议：

> 扫描 `docs/discussions/` 目录，仅匹配文件名满足 `NNNN-*.md` 模式（其中 NNNN 为 4 位数字）的文件，取其中最大 NNNN +1 作为新编号。不匹配该模式的文件忽略不计。

#### Source References

- Design Spec §3 落盘规则 — 编号
- `references/ADR-FORMAT.md` — 编号规则（共享同一模式）

#### Reviewer Notes

该 Gap 同时存在于 ADR 编号规则中，但本评审仅针对当前 Design Spec 的范围。若在此 Spec 中明确定义过滤规则，建议同步更新 ADR-FORMAT.md 以保持一致性。

---

## Testability Coverage

| Verification Dimension                 | Status        | Finding IDs |
| -------------------------------------- | ------------- | ----------- |
| Happy Path Verification                | REVIEWED      | —           |
| Boundary and Limit Verification        | REVIEWED      | TD-004      |
| Duplicate and Idempotency Verification | REVIEWED      | TD-003      |
| Invalid Input Verification             | NOT_APPLICABLE | —           |
| Failure and Timeout Verification       | REVIEWED      | —           |
| Partial Failure Verification           | NOT_APPLICABLE | —           |
| Data Integrity Verification            | REVIEWED      | TD-003      |
| State Transition Verification          | REVIEWED      | —           |
| Permission Boundary Verification       | NOT_APPLICABLE | —           |
| Backward Compatibility Verification    | REVIEWED      | —           |
| Temporal Verification                  | REVIEWED      | —           |
| Migration Verification                 | NOT_APPLICABLE | —           |
| External Dependency Verification       | NOT_APPLICABLE | —           |
| Observability Verification             | REVIEWED      | TD-003      |
| Recovery Verification                  | REVIEWED      | —           |

NOT_APPLICABLE 说明：
- **Invalid Input Verification**：该 Spec 不涉及用户输入校验，输入为用户自然语言指令。
- **Partial Failure Verification**：纪要写入为单文件操作，不存在多步骤部分失败场景。
- **Permission Boundary Verification**：文件写入权限沿用现有 SKILL.md §边界与错误处理机制，本 Spec 无新增权限逻辑。
- **Migration Verification**：Spec §7 明确声明"不自动迁移"，迁移由用户手动完成，不涉及自动化迁移验证。
- **External Dependency Verification**：纪要仅写入本地文件系统，无外部依赖。

---

## Unresolved Verification Questions

### Q-001 — 主题如何从对话中提取？

#### Question

Design Spec 将"主题"作为去重的核心键（§2: "按主题合并"；§3: "按主题 slug 去重"），但未定义技能如何从对话中识别和提取"主题"。主题是用户显式声明的（如 `/socratic-questioning 内部审批流`），还是技能从对话中推断的？如果是推断的，推断规则是什么？

#### Why It Matters

如果主题提取不可复现，"按主题合并"的整个行为链（主题→slug→文件→去重）都不可验证。这是 TD-002 的基础问题。

#### Required Clarification

明确主题的来源和提取方式：
1. 是否优先使用用户显式指定的主题（命令参数）？
2. 无显式主题时，从对话哪部分推断（首轮提问/全程摘要/用户确认）？
3. 推断结果是否在确认门禁中展示并要求用户确认？

#### Status

OPEN

---

### Q-002 — slug 翻译如何处理一词多译和同义聚合？

#### Question

Spec 使用"内部审批流 → `internal-approval-flow`"作为翻译示例，但中文到英文的翻译存在一词多译（如"审批"可译为 approval / review / authorization）和同义聚合（如"审批流""审批流程""审批工作流"应映射到同一 slug）。Spec 期望技能如何处理这些情况？

#### Why It Matters

一词多译和同义聚合直接影响 slug 的稳定性和"同主题合并"的正确性。这是 TD-001 的具体化问题。

#### Required Clarification

在 Spec 中补充 slug 生成的约束条件：
1. slug 是否必须以用户最终确认为准（即用户有否决权）？
2. 是否需要在文件中记录"主题中文原名"以辅助人工识别？
3. 技能是否应提示用户"该主题已有纪要文件 [NNNN-slug]，是否合并？"

#### Status

OPEN

---

## Review Limitations

1. **AI 技能的非确定性本质**：本 Spec 规范的是一个 LLM 驱动的 AI 技能行为，其部分行为（话题提取、中文翻译）天然具有非确定性。本评审在"可客观验证"的框架下评估这些行为，提出的 Gap 反映了确定性验证标准与 AI 非确定性之间的张力。部分 Gap 可能需要接受一定程度的非确定性作为 AI 技能的固有特性，而非追求完全确定性的算法定义。

2. **未审查 DISCUSSION-FORMAT.md 模板**：Design Spec 计划新建 `references/DISCUSSION-FORMAT.md`，但该文件尚不存在，无法评审其格式规范是否与 Spec 的行为契约一致。本评审仅基于 Spec §4 中描述的文件内结构模板进行评估。

3. **会话生命周期交互未深入测试**：Spec 的保存行为与 SKILL.md 定义的会话生命周期（CR-004 中途保存、CR-005 终止/放弃、CR-010 清空草稿/重启）存在交互，但 Spec 未详细描述这些交互场景下的纪要行为。本评审假设保存触发条件沿用现有 SKILL.md 规则，未对交互边界做穷举分析。

---

## Reviewer Conclusion

### Critical Testability Finding Count

- P0: 0
- P1: 2
- P2: 2

### Finding Type Breakdown

- Acceptance Tests: 0
- Untestable Requirements: 3
- Blind Spots: 1

### Review Result

REQUIRES_REVIEW

本评审识别出两个 P1 验证缺口（slug 翻译规则未定义、主题提取规则未定义），它们共同导致该 Spec 最核心的行为特性——"按主题合并、多会话区分"——在关键环节上缺乏可客观验证的标准。

其余核心行为（文件路径、段结构、确认门禁、懒创建、默认关闭）均定义了可观察结果，是可验证的。

P2 发现涉及边界场景（上下文内存丢失、非标准文件处理），在典型使用中影响较小但值得在 Spec 中明确处理方式以防止未来歧义。

Test Designer 不决定 Findings 最终被接受、拒绝、延迟还是以其他方式解决。最终处置由 Decision Protocol 决定。

---

## Machine-Readable Finding Index

```yaml
review:
  review_id: "TD-20260807-001"
  reviewer: "test-designer"
  review_type: "TEST_REVIEW"
  status: "COMPLETED"

findings:
  - id: "TD-001"
    severity: "P1"
    evidence_class: "CONFIRMED_GAP"
    confidence: "HIGH"
    finding_type: "UNTESTABLE_REQUIREMENT"
    title: "中文主题→英文 slug 翻译规则未定义，导致文件命名不可复现"
    source_references:
      - "Design Spec §3 落盘规则 — 命名"
      - "Design Spec §7 边界与迁移 — slug 歧义"
      - "Design Spec §2 关键设计决策 — 按主题合并"
    status: "PENDING_DECISION"

  - id: "TD-002"
    severity: "P1"
    evidence_class: "CONFIRMED_GAP"
    confidence: "HIGH"
    finding_type: "UNTESTABLE_REQUIREMENT"
    title: "主题提取规则未定义，导致\"同主题→同文件\"去重不可验证"
    source_references:
      - "Design Spec §2 关键设计决策 — 多会话区分模型"
      - "Design Spec §3 落盘规则 — 去重"
      - "Design Spec §4 文件内结构"
      - "Design Spec §5 保存契约扩展"
    status: "PENDING_DECISION"

  - id: "TD-003"
    severity: "P2"
    evidence_class: "MATERIAL_RISK"
    confidence: "MEDIUM"
    finding_type: "BLIND_SPOT"
    title: "会话内去重依赖上下文内存，上下文丢失时静默失效"
    source_references:
      - "Design Spec §4 文件内结构 — 行为规则"
      - "Design Spec §5 保存契约扩展 — 幂等规则"
      - "SKILL.md CR-001 §3 ADR 去重规则（对比参考）"
    status: "PENDING_DECISION"

  - id: "TD-004"
    severity: "P2"
    evidence_class: "CONFIRMED_GAP"
    confidence: "MEDIUM"
    finding_type: "UNTESTABLE_REQUIREMENT"
    title: "编号扫描对目录中非标准文件名的处理未定义"
    source_references:
      - "Design Spec §3 落盘规则 — 编号"
      - "references/ADR-FORMAT.md — 编号规则（共享同一模式）"
    status: "PENDING_DECISION"

open_questions:
  - id: "Q-001"
    status: "OPEN"
    question: "主题如何从对话中提取？Spec 未定义主题的来源和提取方式。"
  - id: "Q-002"
    status: "OPEN"
    question: "slug 翻译如何处理一词多译和同义聚合？Spec 仅给了一个示例，未定义翻译约束规则。"
```

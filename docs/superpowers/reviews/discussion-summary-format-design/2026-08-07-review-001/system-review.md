# System Review

## 输出语言

本审核的所有描述性内容使用中文撰写。所有大写下划线格式的标识符和枚举值保持英文。

## Review Metadata

### Review ID

SC-20260807-001

### Reviewer

system-critic

### Review Type

SYSTEM_REVIEW

### Design Spec

/Users/yuezhenhua/yonyou/projects/0__AI/skills/deep-discussion/docs/superpowers/specs/2026-08-07-discussion-summary-format-design.md

### Review Date

2026-08-07

### Review Status

COMPLETED

---

## Review Scope

This review evaluates the Design Spec from the
perspective of system reliability, security, data integrity, operational
resilience, architectural complexity, reversibility, and long-term
maintainability.

This review does not:

* redesign the system;
* produce an implementation plan;
* review source-code style;
* optimize implementation details;
* make the final approval decision;
* replace detailed security testing or production validation.

The purpose of this review is to identify system-level risks that could cause
data loss, security breaches, production outages, unrecoverable failures,
excessive operational burden, or unnecessary architectural complexity.

The review assumes that the Design Spec will eventually be implemented and
operated in production.

---

## Findings

### SC-001 — AI 翻译生成 slug 的非确定性削弱按主题合并的核心价值

#### Severity

P2

#### Evidence Class

MATERIAL_RISK

#### Confidence

MEDIUM

#### Location

Design Spec: 第 3 节落盘规则（§3）与第 7 节边界与迁移（§7），涉及 slug 生成规则与去重键定义

#### Risk

设计规格依赖 AI 将中文讨论主题翻译为英文 slug（§3 命名规则："中文主题由技能译成短英文 slug"），但 AI 翻译具有内在非确定性。同一条讨论主题在不同会话中用不同措辞表达时，可能生成不同的英文 slug，导致主题被碎片化到多个文件中，直接削弱"按主题合并"这一核心设计目标。

#### Trigger Condition

1. 用户在会话 A 中讨论主题并触发保存，AI 将中文主题翻译为 slug-A（如「审批流程设计」→ `approval-process-design`）。
2. 用户在会话 B 中重新讨论本质相同但措辞不同的主题（如「审批流设计」「内部审批流程」等）。
3. AI 将这些变体翻译为不同的 slug（如 `approval-flow-design` 或 `internal-approval-process`）。
4. 技能扫描 `docs/discussions/`，未命中既有 slug → 判定为"新主题" → 分配新序号。
5. 用户获得多个分立的讨论文件，但实际上它们属于同一主题范畴。

#### Consequence

- **数据组织影响**：同一主题的讨论历史分散在多个文件中，用户无法通过 slug 匹配检索到全部历史。
- **逻辑影响**：按主题合并的去重键（§5："纪要去重键 = 主题 slug + 会话段"）失效——同一个逻辑主题被当作多个不同主题处理。
- **可能影响**：如果用户后续想回顾"关于审批流的所有讨论"，需要手动翻阅多个文件，而非打开单一主题文件即可看到完整会话史。

规格在 §7 中将此标记为"ADR 同款风险（YAGNI）"，但讨论主题的自由度远高于 ADR 标题（ADR 标题通常来自技能内的结构化决策表述，而讨论主题完全由用户自然语言提供），因此该风险的实际概率和影响均高于 ADR 场景。

#### Likelihood

MEDIUM

触发条件只需要用户在不同会话中对同一议题使用不同措辞即可成立。考虑到中文自然语言的同义变体丰富（"审批流 / 审批流程 / 审批流程设计 / 内部审批流"），且用户可能在间隔数天或数周后重新提及同一话题而不记得当初的具体措辞，该条件在实际使用中会以中等频率出现。

#### Reversibility

REVERSIBLE

碎片化后的文件可以通过手动合并恢复——将多个文件的会话段集中到同一个文件并更新 slug。但合并操作需用户手动执行，无自动化恢复路径。

#### Recommendation

最小约束：保留当前 slug 生成机制，但在确认门禁的 slug 展示中增加一条提示——「此 slug 由 AI 自动生成。如果该主题与您之前的讨论有关联，请确认或修改 slug 以确保合并到既有文件」。这不是要求改变技术方案，只是在用户交互层面增加一重觉察。

更进一步的选项（可延后）：在保存时扫描 `docs/discussions/` 中既有文件的标题行，用语义相似度检查是否有潜在匹配文件，如有则主动提示用户是否合并。

#### Evidence

- §3 命名规则明确定义"中文主题由技能译成短英文 slug"，但未定义翻译失败的兜底行为（如翻译结果为空或纯非 ASCII 字符时的处理）。
- §3 去重规则定义"按主题 slug 去重——同主题再存 → 复用既有文件序号"——去重的正确性完全依赖 slug 的一致性。
- §7 明确承认 slug 歧义风险，并将其标记为 YAGNI，但未对讨论主题特有的自由表述变体做额外分析。
- §7 同时声明"首次保存在确认门禁展示拟用 slug，用户可改"——这提供了部分缓解，但缓解效果取决于用户能否主动识别 slug 与既有主题的关联。

#### Assumptions

- CONFIRMED：slug 由 AI 从中文主题翻译生成（§3）。
- CONFIRMED：去重依赖 slug 精确匹配（§5）。
- CONFIRMED：确认门禁展示拟用 slug（§7）。
- INFERRED：用户可能无法在确认门禁中识别 slug 碎片化问题（因为用户可能不记得之前保存时使用的 slug）。
- UNKNOWN：AI 翻译的一致性能否在相同中文输入下保证相同输出。

#### Reversibility Analysis

- **可回滚**：生成错误 slug 的文件可以重命名并合并到正确文件中；文件为纯文本 Markdown，无结构化依赖。
- **不可回滚**：无。所有操作均为文件级，可手动修正。
- **残留数据**：如果碎片化已发生，原 slug 文件中的历史会话段需手动迁移。
- **恢复方式**：手动操作，无自动工具。用户需阅读两个文件，确定合并方案，手动编辑。
- **恢复依赖**：仅依赖用户对主题关联的识别能力，不依赖外部系统。

#### Operational Impact

NO_MATERIAL_OPERATIONAL_IMPACT_IDENTIFIED

该风险不涉及部署、监控、告警或在线运维。确认门禁已提供基本的写前校验。

#### Security Impact

NO_MATERIAL_SECURITY_IMPACT_IDENTIFIED

slug 生成与文件写入均在用户本地文件系统内进行，不涉及认证、授权、数据暴露或信任边界。

#### Maintenance Impact

- **长期维护**：如果碎片化发生，用户需手动整理文件，这会随着讨论主题数量增长而累积清理成本。
- **调试影响**：无。
- **依赖管理**：slug 翻译依赖 AI 能力，未来 AI 模型升级可能改变翻译行为——同一输入在不同模型版本下可能产生不同 slug。这可能导致技能行为随底层 AI 模型变化而不一致。

#### Source References

* Design Spec §3 — 落盘规则（命名 / 编号 / 去重规则）
* Design Spec §5 — 保存契约扩展（去重键定义）
* Design Spec §7 — 边界与迁移（slug 歧义承认）

---

## Finding Summary

| Finding ID | Severity | Evidence Class | Confidence | Likelihood | Reversibility | Short Description |
| ---------- | -------- | -------------- | ---------- | ---------- | ------------- | ----------------- |
| SC-001     | P2       | MATERIAL_RISK  | MEDIUM     | MEDIUM     | REVERSIBLE    | AI 翻译生成 slug 的非确定性导致讨论主题文件碎片化，削弱按主题合并的核心价值 |

---

## System Risk Coverage

Record which system risk dimensions were evaluated.

| Risk Dimension                   | Status      | Finding IDs |
| -------------------------------- | ----------- | ----------- |
| Data Integrity and Consistency   | REVIEWED    | SC-001      |
| Security Boundaries              | NOT_APPLICABLE | —        |
| Authentication and Authorization | NOT_APPLICABLE | —        |
| Availability and Resilience      | NOT_APPLICABLE | —        |
| Failure Recovery                 | REVIEWED    | —           |
| External Dependencies            | NOT_APPLICABLE | —        |
| Concurrency and Race Conditions  | NOT_APPLICABLE | —        |
| Data Lifecycle and Migration     | REVIEWED    | —           |
| Backward Compatibility           | REVIEWED    | —           |
| Operational Complexity           | NOT_APPLICABLE | —        |
| Maintenance Burden               | REVIEWED    | SC-001      |
| Irreversible Decisions           | REVIEWED    | —           |
| Over-Engineering                 | NOT_APPLICABLE | —        |
| Observability and Diagnosis      | NOT_APPLICABLE | —        |

**NOT_APPLICABLE 说明**：

- **Security Boundaries** / **Authentication and Authorization**：本规格仅涉及本地文件系统写入，不跨越进程边界或网络边界，无信任域概念。
- **Availability and Resilience**：技能为单用户交互式 CLI 工具，无可用的持续性服务概念；文件写入为同步操作，无"服务不可用"场景。
- **External Dependencies**：除文件系统外无外部依赖（不调用 API、不使用数据库、不访问网络）。
- **Concurrency and Race Conditions**：单用户交互式场景，不存在并发写入路径。即使两个 Claude 进程同时运行，它们操作的是不同 cwd 或通过确认门禁串行化。
- **Operational Complexity**：无部署、无监控、无告警、无 on-call。技能为按需运行的 Claude Code 技能。
- **Over-Engineering**：设计整体简洁，与现有 ADR/CONTEXT 模式对齐，无过度抽象或多余组件。
- **Observability and Diagnosis**：不存在运行时观测需求——所有操作均为用户可见的交互式文件读写。

**REVIEWED 但无 Finding 的维度说明**：

- **Failure Recovery**：规格继承 CR-008 的恢复策略（依赖 cwd 版本控制），并增加了确认门禁作为写前安全网（§3）。会话段更新操作（同会话重存）的边界检测虽非形式化定义，但基于固定模板 `## 会话 YYYY-MM-DD` 的模式匹配在实践中可靠性高。该维度未识别出超越现有 CR-008 框架的新增风险。
- **Data Lifecycle and Migration**：规格 §7 明确定义了旧文件 `docs/grill-summary.md` 的迁移路径（提示用户手动迁移，不静默改写），并声明 `docs/discussions/` 的懒创建策略。无材料级别的数据生命周期风险。
- **Backward Compatibility**：规格声明历史文档（07-29 spec/plan/review）不改动（§6），旧文件不自动迁移（§7）。无版本倾斜或回滚场景——文件格式为纯 Markdown 文本段，新旧格式可共存。
- **Irreversible Decisions**：无不可逆决策。所有文件为 Markdown 纯文本，可随时重命名、合并、删除。编号间隙（如果 delete 后 max+1 跳过）无损数据完整性，与 ADR 行为一致。

---

## Irreversible Decisions

经审查，本设计规格中**未识别出不可逆决策**。

设计规格引入的唯一持久化制品为 Markdown 文件的目录结构与命名约定（`docs/discussions/NNNN-slug.md` + 内部 `## 会话 YYYY-MM-DD` 分段）。这些均为纯文本格式，可随时通过文件操作（重命名、合并、迁移）修正。slug 映射关系也无结构绑定——更改 slug 只需重命名文件。

---

## Over-Engineering and Complexity Risks

经审查，**未识别出过度工程化或过度复杂性的材料风险**。

设计规格引入的复杂度增量微小：

- 新增一个目录 `docs/discussions/`（懒创建，默认不建）
- 新增一个 references 文件 `DISCUSSION-FORMAT.md`（镜像现有 ADR-FORMAT.md / CONTEXT-FORMAT.md 模式）
- 扩展 CR-001 保存契约以覆盖纪要（增补第三条去重键，与既有两条并列）

设计与现有架构模式高度对齐——命名规则镜像 ADR（`NNNN-slug.md`），分段结构镜像 ADR 的幂等更新，保存契约扩展沿用既有 CR-001 框架。不引入新的外部依赖、新的文件格式、新的并发模型或新的状态管理机制。

---

## Unresolved System Questions

### Q-001 — 同一 Claude 进程内多次调用 `/deep-discussion` 的会话身份边界未定义

#### Question

规格以日历日期 `YYYY-MM-DD` 作为会话段的标识（§4："技能在上下文内记住本次会话写的文件 + 段日期"），但对"同一日历日内多次独立讨论"与"跨日连续讨论"两种场景的区分未明确。

具体而言：
- 用户在同一个 Claude 进程中，上午执行 `/deep-discussion 审批流` 并保存，下午再次执行 `/deep-discussion 审批流` 并保存——规格的预期行为是什么？按同日期合并到同一 `## 会话 YYYY-MM-DD` 段，还是应视为两次独立会话分别追加？
- 用户在同一个 Claude 进程中，从 23:50 开始讨论到 00:10 跨日——日期变更后保存，是追加新段（`## 会话 next-day`）还是继续更新当前段？

#### Why It Matters

会话身份的粒度直接影响文件结构的可读性和可维护性。如果同日多次讨论被错误合并，用户无法在文件中区分不同对话；如果跨日连续讨论被拆分，则一次连贯讨论被割裂到两个段中。

#### Required Clarification

明确"会话"的定义域：是与 Claude 进程实例绑定（同一进程 = 同一次对话），还是与日历日期绑定（同一天 = 同一会话），还是与 `/deep-discussion` 单次调用绑定（每次调用 = 独立会话）。

#### Status

OPEN

---

## Review Limitations

以下信息限制影响了评审的置信度：

* **会话段更新操作的实现细节未知**：规格定义了"覆盖该 `## 会话 YYYY-MM-DD` 段"的行为契约（§4），但未暴露更新操作的具体实现方式（全文件读取后替换 vs 精确的字节级定位）。不同实现方式对应不同的文件损坏风险剖面，当前评审以 AI 读取文件后模式匹配的通用实现路径为假设。
* **AI slug 翻译的实际一致性未验证**：本评审基于对 LLM 翻译行为的一般性理解推断 slug 的非确定性风险。未对具体模型（Claude 的各类变体）进行翻译一致性测试。实际行为可能优于或劣于推断。
* **`references/DISCUSSION-FORMAT.md` 尚未创建**：该文件的内容仅由规格 §4 的代码块模板暗示，完整的格式规则（如可选的 frontmatter、扩展字段、版本标记等）在实际文件创建前无法验证与规格的一致性。

---

## Reviewer Conclusion

### Critical Finding Count

* P0: 0
* P1: 0
* P2: 1

### Risk Summary

* Security risks: 0
* Data integrity risks: 1 (SC-001: slug 碎片化导致主题去重失效)
* Availability and resilience risks: 0
* Operational risks: 0
* Maintenance risks: 1 (SC-001: 碎片化文件需手动整理)
* Irreversible decisions: 0
* Over-engineering risks: 0

### Review Result

REQUIRES_REVIEW

本评审识别出 1 个 P2 级系统风险（AI slug 翻译的非确定性）和 1 个待澄清问题（会话身份边界）。未识别出需要阻断实施的 P0/P1 级缺陷。

设计规格整体上结构清晰，与现有系统的 ADR/CONTEXT 模式对齐度高，无新增外部依赖、无安全边界问题、无并发风险、无不可逆决策。唯一的材料性关切——slug 的非确定性——已在规格边界节（§7）中显式承认，并在确认门禁中提供了用户可干预的缓解路径。

从系统评审视角看，该规格的架构可靠性可接受，可在澄清 Q-001 后进入实施。

The System Critic does not determine whether the Findings are ultimately
accepted, rejected, deferred, or otherwise resolved.

Final disposition is determined by the Decision Protocol.

---

## Machine-Readable Finding Index

```yaml
review:
  review_id: "SC-20260807-001"
  reviewer: "system-critic"
  review_type: "SYSTEM_REVIEW"
  status: "COMPLETED"

findings:
  - id: "SC-001"
    severity: "P2"
    evidence_class: "MATERIAL_RISK"
    confidence: "MEDIUM"
    title: "AI 翻译生成 slug 的非确定性削弱按主题合并的核心价值"
    location: "Design Spec §3 落盘规则 / §7 边界与迁移 — slug 生成规则与去重键定义"
    likelihood: "MEDIUM"
    reversibility: "REVERSIBLE"
    source_references:
      - "Design Spec §3 — 命名规则 segment '中文主题由技能译成短英文 slug'"
      - "Design Spec §3 — 去重规则 '按主题 slug 去重'"
      - "Design Spec §5 — 纪要去重键 = 主题 slug + 会话段"
      - "Design Spec §7 — slug 歧义承认 + 确认门禁保护"
    risk_dimensions:
      - "Data Integrity and Consistency"
      - "Maintenance Burden"
    status: "PENDING_DECISION"

irreversible_decisions: []

complexity_risks: []

open_questions:
  - id: "Q-001"
    status: "OPEN"
    question: "同一 Claude 进程内多次调用 /deep-discussion 的会话身份边界未定义：同日多次独立讨论应合并还是分开？跨日连续讨论应拆分还是继续？"
```

---

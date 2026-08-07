# Test Review

## 输出语言

本审核的所有描述性内容使用中文撰写。所有 UPPERCASE_WITH_UNDERSCORE 标识符保持英文。

## Review Metadata

### Review ID

2026-08-07-R1-TD

### Reviewer

yy-test-designer

### Review Type

TEST_REVIEW

### Design Spec

docs/superpowers/specs/2026-08-07-deep-discussion-rename-and-publish-design.md

### Review Date

2026-08-07

### Review Status

COMPLETED

---

## Review Scope

This review evaluates whether the Design Spec can be
objectively verified before implementation begins.

The review focuses on:

* missing acceptance criteria;
* untestable requirements;
* undefined expected outcomes;
* missing boundary conditions;
* failure recovery gaps;
* data integrity verification gaps;
* state transition verification gaps;
* backward compatibility verification gaps;
* operational observability gaps;
* long-term regression risks.

This review does not:

* review code quality;
* redesign the system architecture;
* prescribe implementation technologies;
* create a complete test plan;
* replace security testing, performance testing, or production validation;
* make the final approval decision.

The purpose of this review is to determine whether the Design Spec defines
observable behavior clearly enough to be verified objectively.

A requirement that cannot be objectively verified is not sufficiently defined.

---

## Findings

### TD-001 — README.md旧名引用与"零残留"验收标准存在互斥矛盾

#### Severity

P1

#### Evidence Class

CONFIRMED_GAP

#### Confidence

HIGH

#### Finding Type

UNTESTABLE_REQUIREMENT

#### Location

Design Spec 第 4.5 节（README.md 内容要求）与第 6 节（验收标准 AC1）

Design Spec 第 4.5 节明确要求 README.md 包含：
> 「前身为 yy-grill-me，已改名」说明

Design Spec 第 6 节验收标准 AC1 要求：
> `grep -rn "yy-grill-me" .`（排除 `.git/`、`.workbuddy/`、`.superpowers/sdd/`）→ 零输出

#### Verification Gap

两项规格要求互相排斥，无法同时满足。README.md 位于仓库根目录，不在 grep 的排除列表内（仅排除 `.git/`、`.workbuddy/`、`.superpowers/sdd/`）。若 README.md 按规格要求包含字符串 `yy-grill-me`，AC1 的 grep 检查必然产生非零输出。反之，若 AC1 通过（grep 零输出），README.md 必然不能包含该字符串，与第 4.5 节要求矛盾。

该矛盾导致独立测试者无法在"规格已正确实现"的前提下同时通过两项验收标准——两项标准中必定有一项"失败"。

#### Trigger Scenario

1. 实现者按第 4.5 节要求在 README.md 中写入「前身为 yy-grill-me，已改名」。
2. 实现者按 AC1 执行 `grep -rn "yy-grill-me" . --exclude-dir=.git --exclude-dir=.workbuddy --exclude-dir=.superpowers/sdd`。
3. grep 在 README.md 中命中字符串 `yy-grill-me`，输出非空。
4. AC1 判定为"失败"，但 README.md 的内容符合第 4.5 节要求。
5. 测试者无法判断 AC1 的失败是因为改名遗漏（真实缺陷）还是 README.md 的刻意引用（规格允许）。

#### Expected Verification

独立测试者应能在以下两个目标间做出明确区分：

- 目标 A（零残留）：所有功能性引用（文件名、目录名、命令名、frontmatter 字段、代码路径）中不包含旧名。
- 目标 B（历史溯源）：README.md 等面向用户的说明文档中可包含对旧名的历史引用，但此类引用应为可识别、可列举的有限集合。

#### Verification Method

当前未定义能同时满足两个目标的客观验证方法。grep 全仓扫描无法区分"功能性残留"与"历史引用"。

可行的替代方案包括：

- 方案 A：从 grep 排除列表中增加 `README.md`，并在验收标准中明确定义"零残留"的含义为"零功能性残留"，历史引用文件单独列举。
- 方案 B：README.md 中不使用字面字符串 `yy-grill-me`，改用不含旧名的表述（如"本技能前身曾用另一名称"），使 grep 检查可同时满足。

无论采用哪种方案，规格必须明确：哪些文件中的旧名字符串属于"刻意保留"，哪些属于"遗漏残留"。

#### Consequence

若该矛盾未解决：

- 实现者可能选择不写 README.md 旧名引用以满足 AC1，导致第 4.5 节未实现。
- 实现者可能写 README.md 旧名引用后手动将 README.md 加入 grep 排除列表，但该行为未在规格中定义，不同实现者可能做不同处理。
- 验收阶段可能出现"AC1 不通过但其他标准通过"的争议，缺乏明确的判定规则。
- grep 是机械检查，不具语义理解能力；依赖测试者事后判断"哪些命中是允许的"将导致验收结论依赖主观判断。

#### Evidence

- 第 4.5 节原文："`README.md`：技能定位 + 快速开始（指向 deploy.md）+ 「前身为 yy-grill-me，已改名」说明 + 双端运行时说明。"
- 第 6 节 AC1 原文："`grep -rn "yy-grill-me" .`（排除 `.git/`、`.workbuddy/`、`.superpowers/sdd/`）→ 零输出"
- README.md 位于仓库根目录，不在 grep 排除列表中。
- `.gitignore`（已确认）排除项为 `.DS_Store`、`.workbuddy/`、`.superpowers/sdd/`，不包含 `README.md`。

#### Recommendation

在验收标准 AC1 中明确："零功能性残留"指除 README.md 中刻意保留的历史说明外，全仓不含 `yy-grill-me` 字符串。将 AC1 的 grep 命令修改为显式排除 `README.md`，或在验收说明中定义"允许列表"（allowed occurrences list），列出已知的刻意保留位置及预期命中次数。

#### Source References

* Design Spec 第 4.5 节 "README.md"
* Design Spec 第 6 节 验收标准 AC1
* Design Spec 第 1 节 成功标准 "全仓零 yy-grill-me 残留"

#### Reviewer Notes

即使采用方案 A（grep 排除 README.md），建议同时补充验证：README.md 中对旧名的引用确实是"历史溯源"目的且仅出现在预期位置，而非其他功能引用被遗漏。

---

### TD-002 — Hermes平台技能触发验证标准与Claude Code不对称

#### Severity

P2

#### Evidence Class

CONFIRMED_GAP

#### Confidence

HIGH

#### Finding Type

UNTESTABLE_REQUIREMENT

#### Location

Design Spec 第 6 节 验收标准 AC5

#### Verification Gap

AC5 对两个平台的触发验证采用不对等标准：

- Claude Code：验证实际触发行为（"`/deep-discussion` 可启动拷问"）
- Hermes：仅验证安装到位（"`hermes skills` 列出 deep-discussion"）

`hermes skills` 列出技能名称仅证明 symlink 存在于正确路径且 Hermes 能解析目录结构。它不能证明：
- Hermes 能正确加载该技能的 SKILL.md（如 frontmatter 格式、编码等问题可能导致加载失败但目录仍被列出）；
- Hermes 能按 frontmatter 中 `metadata.hermes.category: software-development` 正确归类；
- Hermes 能实际触发该技能并进入拷问流程。

该不对称意味着 Hermes 端的"双端支持"验证强度显著低于 Claude Code 端，独立测试者无法以同等置信度断言 Hermes 端技能可用。

#### Trigger Scenario

1. 实现者按规格完成所有改名、frontmatter 元数据配置、symlink 安装。
2. 运行 `hermes skills`，输出列表中包含 `deep-discussion`——AC5 的 Hermes 部分通过。
3. 实际在 Hermes 中触发 deep-discussion 时，因 frontmatter 中 `metadata.hermes.category` 字段格式与 Hermes 实际解析逻辑不完全匹配，技能无法正确加载。
4. AC5 已判定为"通过"，但 Hermes 端技能实际不可用。

#### Expected Verification

测试者应能验证以下两个不同层级的 Hermes 端行为：

- 层级 1（安装验证）：symlink 存在于正确路径，`hermes skills` 列出该技能名称。
- 层级 2（触发验证）：在 Hermes 中实际触发 deep-discussion，确认拷问循环启动（如收到第一轮提问）。

当前 AC5 仅覆盖层级 1。

#### Verification Method

层级 1 的验证方法已定义（`hermes skills`）。层级 2 的验证方法未定义。

若 Hermes 平台提供类似 Claude Code 的斜杠命令机制，测试者可在 Hermes 会话中输入对应触发命令并验证拷问流程启动。若 Hermes 的触发机制与 Claude Code 不同，规格应明确 Hermes 端的等效触发验证方式。

若 Hermes 当前不支持等效的触发验证，规格应至少标注该限制，将 AC5 拆分或注明 Hermes 端的验证范围限定为"安装到位"（而非"触发可用"）。

#### Consequence

若该不对称未解决：

- 双端安装可能被判定为"验收通过"，但 Hermes 端实际不可用，用户发现后才能暴露。
- Hermes 用户可能在安装后发现技能无法触发，降低对技能可靠性的信任。
- 后续若 Hermes 的 skill 加载机制发生变化（如 frontmatter 字段要求更新），现有验证标准可能无法检测到兼容性退化。

#### Evidence

- AC5 原文："Claude Code 中 `/deep-discussion` 可启动拷问；`hermes skills` 列出 deep-discussion"
- 第 4.1 节定义了 frontmatter 中 `metadata.hermes.{tags, category}` 的格式。
- 规格第 2.2 节将"不修改技能的拷问纪律、ADR 门槛、保存契约等语义行为"列为不在范围——但 Hermes 端的触发验证并未验证这些语义行为在 Hermes 平台上是否仍工作正常。

#### Recommendation

将 AC5 拆分为两个子标准，或明确标注两平台的验证深度差异：

- AC5a（Claude Code 端）：`/deep-discussion` 可启动拷问，验证实际触发行为。
- AC5b（Hermes 端）：`hermes skills` 列出 deep-discussion，且 Hermes 中可实际触发验证（若平台支持），否则注明 Hermes 验证限于安装到位。

若 Hermes 端无法做等效触发验证，建议在验收标准中显式记录该已知限制，避免验收时产生争议。

#### Source References

* Design Spec 第 6 节 验收标准 AC5
* Design Spec 第 4.1 节 SKILL.md frontmatter 双端元数据

---

### TD-003 — 验收行号对齐的验证与修正流程缺乏独立确认机制

#### Severity

P2

#### Evidence Class

MATERIAL_RISK

#### Confidence

MEDIUM

#### Finding Type

BLIND_SPOT

#### Location

Design Spec 第 4.4 节（行号同步）、第 6 节 AC2、第 7 节（风险）

#### Verification Gap

AC2 定义的验证方法为"重读改名后 SKILL.md 实际行号，逐条比对 acceptance.md 引用，全部一致"。
第 7 节进一步规定"任何不一致就地修正 acceptance 行号"。

该流程将"验证"与"修正"合并为同一步骤——验证者同时是修正者，且无独立复核环节。可能出现以下盲点：

- 比对者因疏忽遗漏某条映射，使得该条映射的行号与 SKILL.md 实际行号不一致，但因"不一致即修正"的流程设计，比对者可能在整个比对完成前就已开始修正，失去对原始差异的追踪。
- 语义对应关系（如"拷问纪律三判据"对应某几行）依赖比对者的主观判断。若比对者对 SKILL.md 行内容与 acceptance 描述的对应关系判断有误，该错误会直接"修正"进文档而无外部发现机会。
- 修正完成后，无法追溯"哪些行号曾不一致、如何修正"的变更记录（除非 git 提交粒度足够细）。

这是一个流程性盲点，而非验收标准的定义缺陷——AC2 的预期结果是明确的（行号全部一致）。风险在于验收执行过程中，错误可能被"修正"而非被"发现"。

#### Trigger Scenario

1. SKILL.md 改名后实际行号为：第 27 行对应"一次一问"（而非映射表预期的第 27 行——恰巧合数一致），但第 41 行对应 ADR 三条件入口（而非映射表预期的第 41 行——实际因某行意外换行导致偏移）。
2. 比对者按映射表逐条核对第 27 行（一致）、第 33 行（一致）……到第 41 行时，发现映射表预期为 ADR 三条件入口，但实际第 41 行为空行。
3. 比对者向上查找，在第 42 行找到 ADR 三条件入口，将 acceptance.md 中对应的行号引用从 41 改为 42。
4. 但比对者未意识到 SKILL.md 第 41 行的空行是意外引入的格式变化（可能由编辑器自动格式化导致），而非预期的 frontmatter +5 偏移。
5. 行号"被修正"后 AC2 通过，但 SKILL.md 存在未被发现的格式变化，可能影响其他工具对 SKILL.md 的解析。

#### Expected Verification

理想状态下，行号对齐验证应分为两个独立步骤：

- 步骤 A（比对）：列出所有预期行号与实际行号的差异清单。
- 步骤 B（修正）：根据差异清单逐条修正，并由第二人（或自动化脚本）复核修正结果。

在单人操作场景中，至少应保留比对阶段的原始差异记录（如 git diff），以便事后追溯"修正了什么"。

#### Verification Method

当前定义的验证方法为手动逐条比对。未定义比对过程中的记录方式或修正后的复核方式。

验证方法的改进可能包括：
- 在比对前先保存 acceptance.md 副本（或依赖 git 版本控制），修正后比对 diff。
- 使用脚本自动化行号提取与比对（提取 SKILL.md 中每个节标题的行号，与 acceptance.md 中引用的行号对比），减少人工逐条比对的遗漏风险。

#### Consequence

若该盲点未被识别：

- 行号映射错误可能被"修正"掩盖，后续维护者基于错误行号定位 SKILL.md 内容时可能被误导。
- SKILL.md 的意外格式变化（如空行增删）可能在"修正"过程中被吸收，不在任何验收标准中暴露。
- 若多人协作验收，不同比对者可能对同一行号做出不同修正，产生合并冲突。

#### Evidence

- 第 4.4 节行号映射表包含 15+ 条映射关系，均基于"frontmatter +5 行"假设。
- 第 7 节原文："行号同步易错：acceptance.md 行号证据是方案 C 最大成本；采用'改名后重读实际行号逐条比对'兜底，避免凭映射表臆测。"
- AC2 原文："重读改名后 SKILL.md 实际行号，逐条比对 acceptance.md 引用，全部一致"
- 第 7 节原文："任何不一致就地修正 acceptance 行号"

#### Recommendation

1. 在验证流程中增加比对记录步骤：比对完成后先产出差异清单（如表格列出"预期行号 / 实际行号 / 差异 / 内容摘要"），再逐条修正。
2. 修正完成后，将 acceptance.md 的 diff 纳入验收证据，供独立复核。
3. 考虑使用自动化脚本提取 SKILL.md 关键段落的行号，与 acceptance.md 引用的行号做机械化比对，作为手动逐条比对的补充验证（而非替代）。

#### Reviewer Notes

该盲点不改变 AC2 本身的可验证性——行号对齐仍然可以通过"逐条比对"完成。风险集中在执行过程的可靠性上。若能确保比对后 diff 被记录并复核，该风险可显著降低。

---

## Testability Coverage

| Verification Dimension                 | Status      | Finding IDs |
| -------------------------------------- | ----------- | ----------- |
| Happy Path Verification                | REVIEWED    | —           |
| Boundary and Limit Verification        | REVIEWED    | —           |
| Duplicate and Idempotency Verification | REVIEWED    | —           |
| Invalid Input Verification             | REVIEWED    | —           |
| Failure and Timeout Verification       | REVIEWED    | —           |
| Partial Failure Verification           | REVIEWED    | —           |
| Data Integrity Verification            | REVIEWED    | TD-001      |
| State Transition Verification          | REVIEWED    | —           |
| Permission Boundary Verification       | NOT_APPLICABLE | —        |
| Backward Compatibility Verification    | REVIEWED    | —           |
| Temporal Verification                  | NOT_APPLICABLE | —        |
| Migration Verification                 | REVIEWED    | —           |
| External Dependency Verification       | REVIEWED    | TD-002      |
| Observability Verification             | REVIEWED    | TD-003      |
| Recovery Verification                  | REVIEWED    | —           |

**NOT_APPLICABLE 说明**：

- **Permission Boundary Verification**：本设计不涉及权限模型变更。install.sh 操作 `~/.claude/skills/` 与 `~/.hermes/skills/` 属于用户自有目录，无权限边界变化。
- **Temporal Verification**：本设计不涉及时效性行为（无过期、无定时任务、无延迟处理）。第 2.2 节明确排除 cron 注册。

---

## Unresolved Verification Questions

### Q-001 — README.md旧名引用的"允许出现"范围应如何定义

#### Question

除 README.md 外，是否还有其他文件需要刻意保留对旧名 `yy-grill-me` 的引用（如本设计规格文档自身、部署文档中的历史说明等）？"零残留"的 grep 检查应排除哪些"刻意保留"文件？

#### Why It Matters

若存在多个刻意保留旧名的文件但未在排除列表中声明，AC1 的 grep 检查将产生多个"误报"命中，测试者无法区分"遗漏残留"与"刻意保留"，验收结论将依赖主观判断。

#### Required Clarification

完整列举所有允许包含旧名字符串的文件及其预期出现次数（allowed occurrences list），或在验收标准中将"零残留"明确定义为"零功能性残留"，并给出"功能性引用"与"历史引用"的判别规则。

#### Status

OPEN

---

### Q-002 — Hermes端触发验证是否在本次改造范围内

#### Question

规格将 Hermes 端验证限定为 `hermes skills` 列出技能名称。若 Hermes 平台不支持等效于 Claude Code 斜杠命令的触发机制，该限制是否在预期之内？若 Hermes 支持等效触发，是否需要补充触发验证？

#### Why It Matters

AC5 的 Hermes 验证仅覆盖"安装到位"，无法验证"触发可用"。若这是有意的设计决策（如 Hermes 触发机制超出本规格范围），应在验收标准中显式声明；若这是遗漏，应补充触发验证标准。

#### Required Clarification

明确 Hermes 端"双端支持"的验证深度：是验证到"安装到位"即可，还是需验证到"触发可用"。

#### Status

OPEN

---

## Review Limitations

1. **Hermes 平台行为未知**：本审核未实际访问 Hermes 平台的 skill 加载与触发机制。TD-002 的分析基于一般性推理（列出不等于可触发），但 Hermes 的具体行为可能不同（如 `hermes skills` 已包含加载校验）。该不确定性通过 MEDIUM 置信度反映（若 Hermes 内部机制已知，置信度可调整为 HIGH）。
2. **SKILL.md 改名后行号未经实地测量**：TD-003 中关于 SKILL.md 行号偏移的分析基于规格声明的"+5 行"假设。实际行号偏移取决于 SKILL.md 改名后的最终文本布局，当前无法实地验证。

---

## Reviewer Conclusion

### Critical Testability Finding Count

* P0: 0
* P1: 1
* P2: 2

### Finding Type Breakdown

* Acceptance Tests: 0
* Untestable Requirements: 2
* Blind Spots: 1

### Review Result

REQUIRES_REVIEW

This review identifies verification gaps, untestable requirements, and
production blind spots that must be considered by the Consolidation phase.

TD-001 (P1) 是最紧迫的发现——README.md 的旧名引用要求与 grep "零残留"验收标准存在字面互斥，必须在实现前解决，否则验收阶段必然出现争议。

TD-002 (P2) 和 TD-003 (P2) 为中度风险，可在实现过程中逐步澄清和缓解。

The Test Designer does not determine whether the Findings are ultimately
accepted, rejected, deferred, or otherwise resolved.

Final disposition is determined by the Decision Protocol.

---

## Machine-Readable Finding Index

```yaml
review:
  review_id: "2026-08-07-R1-TD"
  reviewer: "yy-test-designer"
  review_type: "TEST_REVIEW"
  status: "COMPLETED"

findings:
  - id: "TD-001"
    severity: "P1"
    evidence_class: "CONFIRMED_GAP"
    confidence: "HIGH"
    finding_type: "UNTESTABLE_REQUIREMENT"
    title: "README.md旧名引用与"零残留"验收标准存在互斥矛盾"
    source_references:
      - "Design Spec 第 4.5 节"
      - "Design Spec 第 6 节 AC1"
      - "Design Spec 第 1 节 成功标准"
    status: "PENDING_DECISION"

  - id: "TD-002"
    severity: "P2"
    evidence_class: "CONFIRMED_GAP"
    confidence: "HIGH"
    finding_type: "UNTESTABLE_REQUIREMENT"
    title: "Hermes平台技能触发验证标准与Claude Code不对称"
    source_references:
      - "Design Spec 第 6 节 AC5"
      - "Design Spec 第 4.1 节"
    status: "PENDING_DECISION"

  - id: "TD-003"
    severity: "P2"
    evidence_class: "MATERIAL_RISK"
    confidence: "MEDIUM"
    finding_type: "BLIND_SPOT"
    title: "验收行号对齐的验证与修正流程缺乏独立确认机制"
    source_references:
      - "Design Spec 第 4.4 节"
      - "Design Spec 第 6 节 AC2"
      - "Design Spec 第 7 节"
    status: "PENDING_DECISION"

open_questions:
  - id: "Q-001"
    status: "OPEN"
    question: "README.md旧名引用的"允许出现"范围应如何定义？除README.md外是否还有其他文件需要刻意保留旧名引用？"

  - id: "Q-002"
    status: "OPEN"
    question: "Hermes端触发验证是否在本次改造范围内？若Hermes支持等效触发，是否需要补充触发验证标准？"
```

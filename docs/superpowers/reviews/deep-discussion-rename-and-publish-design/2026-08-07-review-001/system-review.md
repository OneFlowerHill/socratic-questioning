# System Review

## 输出语言

本审核的所有描述性内容均使用中文撰写。大写下划线格式的标识符（P0, P1, P2, CONFIRMED_DEFECT, MATERIAL_RISK, HIGH, MEDIUM, LOW 等）及技术路径保持英文。

## Review Metadata

### Review ID

2026-08-07-R1-SC

### Reviewer

yy-system-critic

### Review Type

SYSTEM_REVIEW

### Design Spec

/Users/yuezhenhua/yonyou/projects/0__AI/skills/yy-grill-me/docs/superpowers/specs/2026-08-07-deep-discussion-rename-and-publish-design.md

### Review Date

2026-08-07

### Review Status

COMPLETED

---

## Review Scope

This review evaluates the Design Spec from the perspective of system reliability, security, data integrity, operational resilience, architectural complexity, reversibility, and long-term maintainability.

This review does not:

* redesign the system;
* produce an implementation plan;
* review source-code style;
* optimize implementation details;
* make the final approval decision;
* replace detailed security testing or production validation.

The purpose of this review is to identify system-level risks that could cause data loss, security breaches, production outages, unrecoverable failures, excessive operational burden, or unnecessary architectural complexity.

The review assumes that the Design Spec will eventually be implemented and operated in production.

---

## Findings

### SC-001 — 验收文档行号证据依赖 frontmatter 物理行数，形成脆弱验证链

#### Severity

P2

#### Evidence Class

MATERIAL_RISK

#### Confidence

HIGH

#### Location

Design Spec 第 4.1 节（SKILL.md frontmatter 改动）、第 4.4 节（acceptance 行号同步）、第 7 节（风险与注意）。

现有系统文件：`docs/superpowers/plans/2026-07-29-yy-grill-me-acceptance.md`（简称 acceptance.md），其中第 25-31 行共引用 15 个 SKILL.md 物理行号作为验收证据。

#### Risk

acceptance.md 的 15 个行号证据（第 25-31 行的验收标准逐条核对表、第 41-49 行的评审变更落地核对表、第 56-57 行的引用完整性核对、第 68-73 行的 dry-run 行为清单）全部硬编码为 SKILL.md 的物理行号。这些行号的有效性完全依赖一个单一假设：SKILL.md frontmatter 改名后恰好净增 5 行。

如果 frontmatter 实际行数与预期不同（例如 description 字段因内容修改而折行、platforms 或 metadata 的 YAML 格式与 goal-manager 存在细微差异），则 15 个行号引用全部偏移，acceptance.md 从一份"验收证据文档"降级为"包含系统性错误的文档"。

Design Spec 第 7 节承认此风险（"行号同步易错"、"若净增非 5，全部行号映射重算"），但提供的缓解措施完全依赖人工逐条比对，无任何自动化校验。

#### Trigger Condition

1. 开发人员按 spec 第 4.1 节修改 SKILL.md frontmatter，期望净增恰好 5 行。
2. 因 YAML 格式差异、编辑器自动换行、或 description 字段长度变化，实际行数增量偏离 5。
3. 开发人员按 spec 第 7 节的映射表更新 acceptance.md 行号（每行 +5）。
4. 更新后的 acceptance.md 中 15 个行号证据全部与实际 SKILL.md 行号发生系统性偏移。
5. 开发人员未逐条重读 SKILL.md 实际行号进行核对（例如仅依赖映射表公式化更新），或核对时遗漏个别条目。
6. 错误的行号证据被保留在 acceptance.md 中，后续验收时产生虚假的 PASS/FAIL 结论。

#### Causal Chain

```
Frontmatter 实际行数与 spec 的 "+5 行" 假设不一致
        ↓
acceptance.md 行号映射表系统性偏移
        ↓
15 个行号证据全部失效
        ↓
验收文档不可信，后续质量门禁失去依据
```

#### Consequence

* **维护影响**：acceptance.md 失去作为验收证据的可信度。后续维护者无法通过行号定位到 SKILL.md 中对应的实际内容，验收过程需要重新逐条人工核对。
* **逻辑后果**：验收文档的 PASS/FAIL 结论可能基于错误的行号证据，产生虚假通过（PASS）或误报失败。
* **可恢复性**：可恢复，但需要人工逐条重新核对 15 个行号引用与改名后 SKILL.md 的实际行号，工作量大且易遗漏。

#### Likelihood

MEDIUM

触发条件（frontmatter 实际行数偏离预期）的概率为中等。YAML frontmatter 的行数受编辑器行为、YAML 格式选择（如多行字符串的写法）影响。spec 第 7 节自己也指出"落地后必须以实际行数为准重新核对（若净增非 5，全部行号映射重算）"，说明 spec 作者已意识到此风险存在。

但 spec 规定的执行顺序（"先改 SKILL.md/正文 → 再改 acceptance 行号"）和人工核对要求如果被严格执行，可降低实际发生的可能性。

#### Reversibility

REVERSIBLE

错误的 acceptance.md 可以通过重新逐条比对 SKILL.md 实际行号来修正。不会造成不可逆的损害，但修正成本较高（15 个行号引用的逐条核对）。

#### Recommendation

在 acceptance.md 中增加自动化校验机制：在 acceptance.md 中附加一份内容锚点表，将每个行号证据关联到一个唯一的文本锚点（如截取 SKILL.md 中对应行开头 20 个字符），并在验收流程的第一步自动比对锚点是否匹配。若锚点不匹配，立即报告行号偏移，而非依赖人工逐条核对。

具体约束：
1. acceptance.md 中每个行号引用必须附加内容锚点（对应行开头的固定长度文本片段）。
2. 验收流程的第一条必须是用脚本自动比对所有锚点是否与 SKILL.md 实际行号对应。
3. 锚点比对失败则验收直接 FAIL，不进入后续人工核对。

#### Evidence

* Design Spec 第 4.1 节明确声明："frontmatter +5 行，正文整体下移 5 行"——这是所有行号映射的基础假设。
* Design Spec 第 4.4 节提供了 15 行的行号映射表（第 153-169 行），所有映射基于 "frontmatter +5 行" 的单一假设。
* Design Spec 第 7 节第一条风险即承认"行号同步易错"。
* Design Spec 第 7 节第二条风险声明"若净增非 5，全部行号映射重算"——确认当前设计存在单一故障点。
* acceptance.md（现有文件）第 25-31 行、第 41-49 行、第 56-57 行、第 68-73 行共引用 15 个独立 SKILL.md 物理行号。
* 现有 SKILL.md 正文共 122 行，frontmatter 占 4 行（第 1-4 行），正文从第 6 行开始。验证：改名后 frontmatter 若为 9 行（第 1-9 行），正文从第 11 行开始，相对原第 6 行实际偏移 +5 行。此证据确认 "+5 行" 在当前 YAML 排版下成立，但不构成对其他 YAML 排版方式的保证。

#### Assumptions

* CONFIRMED：acceptance.md 使用物理行号（而非内容锚点）作为验收证据。在现有 acceptance.md 第 25、26、27、28、29、30、31 等行均有显式行号引用。
* CONFIRMED：Design Spec 的行号映射完全依赖 "frontmatter 净增 5 行" 这个单一假设。spec 第 4.4 节的映射表和注脚均以此为基准。
* INFERRED：若 frontmatter 实际行数与假设不一致，开发人员可能未逐条核对所有 15 个行号引用。此推断基于：15 个行号分布在 acceptance.md 的 4 个不同表格/清单中，逐条核对的纪律性难以保证。

#### Reversibility Analysis

* 可回滚：acceptance.md 是纯文本文件，可通过 git revert 回滚到修改前状态。
* 不可回滚：无。错误的行号不会造成文件系统级不可逆损害。
* 回滚后残留：无数据残留。回滚后 acceptance.md 恢复原状。
* 是否需要人工干预：是。回滚和重新修正都需要人工逐条核对 SKILL.md 实际行号。
* 是否依赖不可用系统：否。核对仅依赖本地文件系统上的 SKILL.md 和 acceptance.md。

#### Operational Impact

NO_MATERIAL_OPERATIONAL_IMPACT_IDENTIFIED

此发现不涉及运行时系统行为，不影响 skill 的安装、触发或执行。影响仅限于开发/验收流程中的文档可信度。对于技能的实际用户（通过 `/deep-discussion` 触发拷问）无直接影响。

#### Security Impact

NO_MATERIAL_SECURITY_IMPACT_IDENTIFIED

此发现涉及的是验证文档的完整性，不涉及认证、授权、数据暴露、信任边界等安全维度。

#### Maintenance Impact

* **未来修改**：每次修改 SKILL.md 导致行号变化时，都需要同步更新 acceptance.md 的 15 个行号引用。这是持续性的维护负担。
* **调试**：若 acceptance.md 行号错误，后续验收时发现 SKILL.md 对应行不包含预期内容，需要回溯排查是 acceptance.md 行号错误还是 SKILL.md 内容被意外修改。
* **系统所有权**：行号证据的维护需要开发人员理解 SKILL.md 的物理结构与 acceptance.md 行号映射之间的耦合关系。

#### Source References

* Design Spec 第 4.1 节（SKILL.md frontmatter 改动，第 93-113 行）
* Design Spec 第 4.4 节（acceptance 行号同步，第 151-171 行）
* Design Spec 第 7 节（风险与注意，第 269-276 行）
* 现有文件：`docs/superpowers/plans/2026-07-29-yy-grill-me-acceptance.md`（第 25-73 行）

---

### SC-002 — 删除 `agents/openai.yaml` 消除了隐式调用的机器级防护，改用自然语言指令替代

#### Severity

P2

#### Evidence Class

MATERIAL_RISK

#### Confidence

MEDIUM

#### Location

Design Spec 第 4.3 节（删除 agents/）、第 2.2 节（不在范围）、第 4.1 节（SKILL.md frontmatter）。

现有系统文件：`agents/openai.yaml`（含 `policy.allow_implicit_invocation: false`）。

#### Risk

Design Spec 第 4.3 节删除 `agents/openai.yaml` 及其所在的 `agents/` 目录。原文件包含 `policy.allow_implicit_invocation: false`——这是一个机器可执行的策略，由兼容 OpenAI agent 协议的 AI 平台在调度层强制执行"不自动唤起该技能"。

Spec 的删除理由为："原 `allow_implicit_invocation: false` 语义由 SKILL.md 正文「仅显式触发」铁律保证；`display_name` 由 frontmatter `name` + `description` 覆盖。"

这个理由存在一个关键技术差异：SKILL.md 正文中的"仅显式触发"是自然语言指令，由 LLM 在推理时解释；而 `allow_implicit_invocation: false` 是 agent 平台调度层的硬策略，在技能选择阶段即可拦截。两者的防护层级不同：

* 自然语言指令（SKILL.md 正文）：LLM 可能忽略、遗忘、或被越狱/对抗性 prompt 绕过。
* 机器策略（allow_implicit_invocation: false）：平台调度层硬拦截，不依赖 LLM 的推理行为。

Spec 以 goal-manager 为参考（"与 goal-manager 一致，无 agents 目录，靠 frontmatter metadata.hermes 声明"），但 goal-manager 的 description 字段设计为广泛匹配用户意图（包含大量触发关键词），与 deep-discussion 的"仅显式触发"设计目标不同。对于 deep-discussion，"不自动唤起"是一个安全属性；对于 goal-manager，"广泛匹配"是一个可用性属性。两者的防护需求不同，不应直接类比。

#### Trigger Condition

1. 用户在一个同时支持 OpenAI agent 协议和 Claude Code skill 协议的平台上使用 deep-discussion。
2. 该平台在技能选择阶段检查 `allow_implicit_invocation` 策略。
3. 由于 `agents/openai.yaml` 已被删除，平台未找到显式的禁止隐式调用策略。
4. 平台的 LLM 在对话中根据上下文语义判断应唤起 deep-discussion（例如用户讨论设计方案时）。
5. Skill 被自动唤起，违反"仅显式触发"的设计意图。

#### Causal Chain

```
agents/openai.yaml 被删除（含 allow_implicit_invocation: false）
        ↓
OpenAI 兼容平台缺少机器级的隐式调用防护
        ↓
LLM 仅依赖 SKILL.md 正文的自然语言指令判断是否唤起
        ↓
在特定对话上下文中，LLM 可能自动唤起技能
        ↓
"仅显式触发"铁律在特定平台上被绕过
```

#### Consequence

* **逻辑后果**：在支持 OpenAI agent 协议的平台上，deep-discussion 可能被自动唤起，违反其核心设计约束"仅显式触发"。
* **用户体验影响**：用户可能在不期望的情况下进入拷问流程，打断正常工作流。
* **安全影响（有限）**：deep-discussion 是一个只读为主的交互式技能（不自动创建文件、不修改代码），自动唤起的后果主要是用户体验干扰，而非数据破坏或安全泄露。但自动唤起后的 LLM 行为（如提问内容）可能暴露用户的计划/设计上下文给技能流程。

#### Likelihood

LOW

触发条件需要同时满足：(1) 平台支持 OpenAI agent 协议且尊重 `allow_implicit_invocation` 策略；(2) 该平台的 LLM 在特定上下文中有倾向自动唤起技能；(3) 其他防护措施（如 SKILL.md description 中的"仅允许显式触发"声明）未能阻止自动唤起。

当前 Design Spec 的目标平台为 Claude Code 和 Hermes。Claude Code 不依赖 `agents/openai.yaml`（从现有 CLAUDE.md 中"OpenAI 兼容 agent 配置"的描述可确认此文件面向非 Claude Code 平台）。Hermes 通过 frontmatter metadata 控制技能分类和触发。因此当前双端均不受此删除影响。

风险仅在未来引入第三个 OpenAI 兼容平台时激活，故可能性评估为 LOW。

#### Reversibility

REVERSIBLE

如果未来需要恢复 `allow_implicit_invocation: false` 策略，可以重新创建 `agents/openai.yaml` 文件。但因为 `agents/` 目录已被删除且 `.gitignore` 不排除该路径，该文件可通过 git 重新创建。

#### Recommendation

在 SKILL.md 或 `metadata.hermes` 中增加一个机器可读的"禁止隐式调用"声明，使其不依赖特定 agent 配置文件的格式。具体约束：

1. 在 SKILL.md frontmatter 中增加一个平台无关的 `implicit_invocation: false` 字段（或等效语义），确保所有平台都能在机器层面解析此策略。
2. 如果 Hermes 或 Claude Code 的前端 matter 解析器不支持此字段，至少在 description 的首句中保留"仅允许显式触发"的措辞，作为跨平台的最低文本防护。

如果不采纳此建议，至少应在 Design Spec 或 SKILL.md 中明确记录：`allow_implicit_invocation: false` 的删除是一个有意识的决策，未来引入新平台时需重新评估隐式调用防护。

#### Evidence

* Design Spec 第 4.3 节（第 119-122 行）明确声明删除 `agents/openai.yaml` 及 `agents/` 目录。
* 现有文件 `agents/openai.yaml` 内容为：
  ```yaml
  interface:
    display_name: "Grill with Docs"
    short_description: "Grill a design and write its docs"
  policy:
    allow_implicit_invocation: false
  ```
* Design Spec 第 4.3 节的删除理由："原 `allow_implicit_invocation: false` 语义由 SKILL.md 正文「仅显式触发」铁律保证"——此声明将机器策略与自然语言指令视为等价，存在技术上的不等价。
* Design Spec 第 4.3 节引用 goal-manager 作为参考："与 goal-manager 一致（无 agents 目录，靠 frontmatter metadata.hermes 声明）"——但 goal-manager 的 description 旨在广泛匹配（"当用户想创建/拆解/更新/查询目标..."），与 deep-discussion 的"仅显式触发"设计目标不同。
* Design Spec 第 2.2 节列出"不修改技能的拷问纪律"——表明隐式调用防护属于不改动的语义行为，但 `allow_implicit_invocation: false` 恰恰是此语义行为的机器级防护，其删除并非语义中立。

#### Assumptions

* CONFIRMED：`agents/openai.yaml` 包含 `policy.allow_implicit_invocation: false`。文件内容已通过 Read 工具确认。
* CONFIRMED：Design Spec 声称删除后语义由 SKILL.md 正文"仅显式触发"铁律保证。spec 第 4.3 节第 121-122 行明确如此声明。
* INFERRED：自然语言指令（SKILL.md 正文）与机器策略（allow_implicit_invocation: false）在防护强度上不等价。此推断基于 LLM 系统的基本架构：LLM 遵循提示（prompt）进行推理，可能受上下文干扰；而机器策略在调度层硬拦截，不经过 LLM 推理。
* UNKNOWN：Hermes 平台是否有独立的隐式调用控制机制。spec 未描述 Hermes 的技能唤起策略，仅在 frontmatter 中声明了 `category` 和 `tags`。

#### Reversibility Analysis

* 可回滚：可通过 git 恢复 `agents/openai.yaml` 文件，或重新创建该文件。
* 不可回滚：无。文件删除是可逆的。
* 回滚后残留：无。
* 是否需要人工干预：是。需要手动重建文件或 git revert。
* 是否依赖不可用系统：否。

#### Operational Impact

NO_MATERIAL_OPERATIONAL_IMPACT_IDENTIFIED

此变更不影响当前 Claude Code 和 Hermes 双端的安装、运行、触发。仅在将来引入第三个支持 OpenAI agent 协议的平台时可能产生操作影响（技能意外自动唤起）。

#### Security Impact

有限的潜在影响。

* **信任边界**：隐式调用防护从机器策略降级为自然语言指令，减弱了技能的调用边界防护。
* **实际暴露**：deep-discussion 是一个交互式访谈技能，不自动执行写入操作（铁律第 7 条禁止自动创建文件），因此自动唤起的安全后果主要是信息暴露（用户正在讨论的计划/设计内容被带入拷问流程），而非数据破坏或越权操作。
* **缓解因素**：技能内部有确认门禁（任何写入前需用户确认），即使被自动唤起，也不会在用户不知情的情况下创建文件。

#### Maintenance Impact

* **未来修改**：如果将来需要为第三个平台恢复 `allow_implicit_invocation: false`，需要重新创建 `agents/` 目录结构并确保格式兼容。
* **文档债务**：如果目标是在多平台之间保持一致性，则每次修改隐式调用策略时都需要在多个表达形式之间同步（SKILL.md 正文 + 可能的 agent 配置 + frontmatter）。
* **系统所有权**：当前 spec 的作者明确理解 `allow_implicit_invocation: false` 的语义并有意删除，但后续维护者可能不了解此决策的背景。

#### Source References

* Design Spec 第 4.3 节（删除 agents/，第 119-122 行）
* Design Spec 第 2.2 节（不在范围——不修改语义行为，第 36-42 行）
* 现有文件：`agents/openai.yaml`（3 行 YAML，含 `allow_implicit_invocation: false`）
* Design Spec 第 4.1 节（新 SKILL.md frontmatter，第 93-112 行）

---

### SC-003 — install.sh 在 symlink 创建前不验证目标目录内容完整性

#### Severity

P2

#### Evidence Class

MATERIAL_RISK

#### Confidence

MEDIUM

#### Location

Design Spec 第 4.5 节（安装机制，第 173-217 行）、第 4.6 节（GitHub 推送流程，第 221-241 行）、第 5 节（错误处理，第 245-254 行）。

#### Risk

`scripts/install.sh` 创建 symlink 指向源目录时，不验证源目录是否包含完整、有效、已改名的技能文件。脚本唯一的验证是 symlink 是否存在且指向正确路径（install.sh 第 23-24 行的 `[ -L "$CLAUDE_LINK" ] && [ -L "$HERMES_LINK" ]`），但这仅验证 symlink 本身，不验证目标内容。

在一个正常的最终用户场景中（用户 clone 仓库后运行 install.sh），这个风险不成立——因为 git clone 保证了内容完整性。

但在开发流程中，Design Spec 规定的执行顺序（第 4.6 节 + 第 9 节）为：目录改名 → 内容修改 → git init → git commit → 仓库推送。install.sh 在 spec 中的定位（第 9 节："新增 install.sh/deploy.md/README.md → git init + 仓库创建推送 → 验收"）处于内容修改之后。但 install.sh 作为可独立执行的脚本，没有机制阻止其在内容修改完成之前被调用。

如果开发人员在内容修改过程中（例如仅完成了目录改名但尚未完成所有文件的 `yy-grill-me` 替换）执行 install.sh，则 symlink 将指向一个部分改名、内容不一致的源目录。此时通过 symlink 调用技能可能：
* 显示旧的技能名称（SKILL.md frontmatter 尚未更新）
* 包含新旧名称混用的内容（部分文件已改名、部分未改）
* 缺失关键文件（如果改名过程涉及文件移动）

#### Trigger Condition

1. 开发人员执行 Design Spec 的改名流程。
2. 在步骤之间——例如目录已从 `yy-grill-me/` 改名为 `deep-discussion/`，但 SKILL.md 的内容尚未全部替换（正文仍有 `/yy-grill-me` 引用）——开发人员或自动化流程执行 `bash scripts/install.sh`。
3. install.sh 创建 symlink 指向内容不一致的源目录。
4. 用户通过 symlink 路径（`~/.claude/skills/deep-discussion/`）调用技能。
5. 技能以不一致状态运行：frontmatter name 为 `deep-discussion` 但正文引用 `/yy-grill-me`，或者部分文件仍含旧名。

#### Causal Chain

```
开发流程中目录改名后、内容修改完成前 install.sh 被调用
        ↓
install.sh 创建 symlink 指向部分改名的源目录（无内容完整性验证）
        ↓
技能以不一致状态通过 symlink 暴露给用户
        ↓
用户体验异常（命令名与正文引用不一致、部分功能错乱）
```

#### Consequence

* **逻辑后果**：在改名过渡窗口中，通过 symlink 调用的技能可能表现为不一致状态。例如 `/deep-discussion` 命令可触发技能，但技能正文引用的是 `/yy-grill-me`，导致触发边界混乱。
* **用户体验影响**：用户在过渡窗口期使用技能时可能遇到困惑（技能名与内部引用不一致）。
* **可恢复性**：一旦内容修改完成，symlink 自动指向一致内容（因为 symlink 指向目录而非文件快照），无需额外修复。但过渡窗口内的用户体验异常已经发生。
* **实际发生概率**：在正常的单人开发流程中，开发者通常不会在内容修改中途运行 install.sh。但在多人协作或自动化 CI 场景中，此风险更可能被触发。

#### Likelihood

LOW

触发条件需要 install.sh 在内容修改的过渡窗口中被调用。在 spec 描述的单人开发流程中，此窗口通常很短（内容修改在同一次编辑会话中完成），且开发者通常会在所有修改完成后再运行 install.sh 进行验证。spec 第 9 节的执行顺序也将 install.sh 放在内容修改和 git init 之后。

但对于以下场景，可能性不可忽略：
* CI/CD 自动化脚本在 git clone 后自动运行 install.sh，而此时分支上的内容尚未完全通过验收。
* 开发者中断了改名流程，稍后忘记是否完成了所有替换，直接运行 install.sh 试图验证。

#### Reversibility

REVERSIBLE

一旦内容修改完成，symlink 自动指向一致内容。无需额外修复步骤。过渡窗口内如果用户发现了不一致，修正内容后问题自动消失。

#### Recommendation

在 install.sh 中增加一个最小化的内容完整性检查，在执行 symlink 创建之前运行。具体约束：

1. 检查 `$SRC/SKILL.md` 存在且可读。
2. 检查 `$SRC/SKILL.md` frontmatter 中的 `name` 字段与脚本中的 `NAME` 变量一致（当前为 `deep-discussion`）。
3. 如果检查失败，输出明确的错误信息（如"SKILL.md 不存在或 name 字段与预期不一致，请确认目录内容完整后再安装"），并以非零退出码退出。

这三个检查开销极低（读取一个文件的 frontmatter），但能有效防止在内容不一致时创建 symlink。

#### Evidence

* Design Spec 第 4.5 节 install.sh 脚本完整代码（第 177-208 行）：脚本仅在末尾验证 `[ -L "$CLAUDE_LINK" ] && [ -L "$HERMES_LINK" ]`，即 symlink 自身的存在性，不验证目标内容。
* Design Spec 第 4.6 节 GitHub 推送流程（第 223-239 行）显示执行顺序为：目录改名 → git init → git add → git commit → gh repo create push。install.sh 在 spec 第 9 节被列为"新增 install.sh/deploy.md/README.md"——处于内容修改之后，但安装脚本本身无防护。
* Design Spec 第 5 节错误处理表（第 247-255 行）：列出了 6 种错误场景，但没有"源目录内容不完整/不一致"的场景。
* Design Spec 第 7 节风险列表（第 269-276 行）：未将"install.sh 在内容不一致时被调用"列为风险。
* 现有 SKILL.md 正文共 122 行，含多处需要替换的 `yy-grill-me` 引用（7 处 grep 匹配），改名涉及至少 10 个文件的修改。改名流程的处理窗口足够大，使得内容不一致的中间态存在时间窗口。

#### Assumptions

* CONFIRMED：install.sh 不验证目标内容完整性。spec 第 4.5 节完整脚本代码中无对应逻辑。
* INFERRED：在多人协作或自动化场景中，install.sh 可能在内容修改完成前被调用。此推断基于：spec 仅为单人开发流程设计，未考虑其他执行上下文。
* UNKNOWN：spec 目标用户的实际开发工作流是否可能触发此风险。本地的单人交互式开发可能降低此风险的实际发生概率。

#### Reversibility Analysis

* 可回滚：是。删除已创建的 symlink（`rm $CLAUDE_LINK $HERMES_LINK`）即可撤销。
* 不可回滚：无。symlink 创建不修改源目录内容。
* 回滚后残留：无。
* 是否需要人工干预：是。需要手动删除错误创建的 symlink。
* 是否依赖不可用系统：否。

#### Operational Impact

有限的潜在影响。

* **部署**：在内容不一致时安装会导致技能行为异常，可能产生难以诊断的问题（用户报告 `/deep-discussion` 触发行为异常，但难以定位根源是部分改名的内容）。
* **调试**：部分改名状态下安装导致的异常行为难以追踪——symlink 指向正确路径，但内容不一致。用户或开发者可能首先怀疑平台问题，而非内容完整性问题。
* **恢复**：恢复简单（完成内容修改即可），但诊断困难。

#### Security Impact

NO_MATERIAL_SECURITY_IMPACT_IDENTIFIED

内容不一致状态下的技能调用不涉及权限提升、数据暴露或认证绕过。技能本身受铁律约束，即使被触发也不会自动创建或修改文件。

#### Maintenance Impact

* **调试**：如上所述，内容不一致状态下安装的技能异常难以诊断。
* **未来修改**：如果 install.sh 未来需要支持更多验证（如多平台、多版本），缺少基础的内容完整性检查将增加后续调试成本。

#### Source References

* Design Spec 第 4.5 节（install.sh 脚本，第 173-217 行）
* Design Spec 第 4.6 节（GitHub 推送流程，第 221-241 行）
* Design Spec 第 5 节（错误处理，第 245-254 行）
* Design Spec 第 9 节（执行顺序，第 288-291 行）

---

## Finding Summary

| Finding ID | Severity | Evidence Class | Confidence | Likelihood | Reversibility | Short Description |
| ---------- | -------- | -------------- | ---------- | ---------- | ------------- | ----------------- |
| SC-001 | P2 | MATERIAL_RISK | HIGH | MEDIUM | REVERSIBLE | 验收文档行号证据依赖 frontmatter 物理行数的单一假设，形成脆弱验证链 |
| SC-002 | P2 | MATERIAL_RISK | MEDIUM | LOW | REVERSIBLE | 删除 agents/openai.yaml 消除隐式调用的机器级防护，改用自然语言指令替代 |
| SC-003 | P2 | MATERIAL_RISK | MEDIUM | LOW | REVERSIBLE | install.sh 在 symlink 创建前不验证目标目录内容完整性 |

---

## System Risk Coverage

| Risk Dimension | Status | Finding IDs |
| -------------------------------- | -------- | ----------- |
| Data Integrity and Consistency | REVIEWED | SC-001 |
| Security Boundaries | REVIEWED | SC-002 |
| Authentication and Authorization | NOT_APPLICABLE | 本 spec 不涉及认证授权机制的设计或变更 |
| Availability and Resilience | NOT_APPLICABLE | 本 spec 不涉及服务可用性或容错机制 |
| Failure Recovery | REVIEWED | SC-003 |
| External Dependencies | REVIEWED | SC-002（OpenAI agent 协议兼容性作为外部平台依赖） |
| Concurrency and Race Conditions | NOT_APPLICABLE | 本 spec 为单用户文件改名操作，无并发场景 |
| Data Lifecycle and Migration | REVIEWED | SC-001（验收文档的迁移一致性） |
| Backward Compatibility | REVIEWED | SC-002（删除 agent 配置文件后的平台兼容性） |
| Operational Complexity | REVIEWED | SC-003（install.sh 缺乏完整性校验） |
| Maintenance Burden | REVIEWED | SC-001（行号证据的持续维护负担） |
| Irreversible Decisions | REVIEWED | 见下方"不可逆决策"章节 |
| Over-Engineering | NOT_APPLICABLE | spec 的架构复杂度（单文件 + symlink + install.sh）与操作目标匹配，无过度工程化迹象 |
| Observability and Diagnosis | REVIEWED | SC-003（内容不一致状态下安装后的诊断困难） |

---

## Irreversible Decisions

### ID-001 — GitHub 私有仓库创建与首次推送

#### Decision

在用户的 GitHub 账户下创建私有仓库 `deep-discussion`，并通过 `gh repo create deep-discussion --private --source=. --remote=origin --push` 一次性完成仓库创建、remote 配置和代码推送。

#### Why It Is Difficult to Reverse

* 仓库一旦创建并推送，GitHub 服务器上即存在该仓库的完整历史记录。
* 删除仓库（`gh repo delete`）可以移除仓库，但任何在仓库存在期间 clone 或 fork 了该仓库的用户仍保留副本。
* 首次 commit 中包含的内容（包括可能含个人路径的历史文档）一旦推送即持久化在 GitHub 的存储中，即使后续 force push 覆盖，原始 blob 在 GitHub 的垃圾回收前仍可能通过 commit hash 访问。
* `.gitignore` 排除的路径（`.workbuddy/`、`.superpowers/sdd/`）如果在 git add 前未生效，可能导致意外文件被推送。

#### Reversal Cost

MEDIUM

仓库可以删除（`gh repo delete`），但：(1) 已推送到 GitHub 的内容在 GitHub 的存储中可能有残留窗口；(2) 任何在推送后 clone 了仓库的人保有副本；(3) 仓库名 `deep-discussion` 在删除后可能被 GitHub 保留一段时间才能重新使用。

#### Risk

* **意外内容泄露**：如果 `.gitignore` 未正确排除敏感文件（如含个人路径的配置文件），这些文件将在首次推送时上传到 GitHub。虽然是私有仓库，但 GitHub 服务器端存储了这些数据。
* **仓库名冲突**：如果用户的 GitHub 账户下已存在同名仓库 `deep-discussion`，`gh repo create` 将失败。spec 未提供冲突处理方案。
* **commit 历史不可变**：首次 commit 包含的内容（commit message 中明确写了"前身为 yy-grill-me"）永久保留在 git 历史中。如果将来需要彻底移除对旧名的引用，需要重写历史（rebase/force push）。

#### Recommendation

1. 在执行 `git add .` 之前，验证 `.gitignore` 生效且排除了所有预期排除的路径（可通过 `git status` 确认暂存区中无不期望的文件）。
2. 在推送前，先用 `gh repo view deep-discussion` 检查同名仓库是否已存在；若存在则提供冲突处理选项（改名或删除已有仓库）。
3. 在 commit message 中避免包含个人路径信息（当前 spec 的 commit message `"feat: 初始化 deep-discussion 技能（前身为 yy-grill-me，改名+双端支持+发布）"` 不含路径，符合此建议）。

#### Status

OPEN

---

## Over-Engineering and Complexity Risks

本次审查未发现过度工程化或 disproportionate complexity 的证据。spec 描述的架构（单文件技能 + symlink 安装 + install.sh 脚本）与操作目标（改名、双端安装、GitHub 发布）匹配。install.sh 的 30 行 bash 脚本和 SKILL.md 的 5 行 frontmatter 增量均属于合理复杂度范围。

---

## Unresolved System Questions

### Q-001 — Hermes 平台的技能触发机制是否区分隐式/显式调用

#### Question

Hermes 平台如何决定何时触发一个技能？是否存在与 `allow_implicit_invocation: false` 等价的机器级防护？或者完全依赖 natural language description 匹配？

#### Why It Matters

如果 Hermes 也仅依赖自然语言匹配来触发技能（类似 Claude Code 的 description 匹配），则 SC-002 的风险同样适用于 Hermes 平台。如果 Hermes 有独立的显式触发机制（如仅通过斜杠命令触发），则该风险不适用于 Hermes。

当前 Design Spec 仅在 frontmatter 中声明了 Hermes 的 `category` 和 `tags`，未说明技能触发策略。

#### Required Clarification

需要明确 Hermes 平台的技能触发机制：(1) 是否支持仅斜杠命令触发；(2) 是否通过自然语言匹配自动触发；(3) 是否有 `allow_implicit_invocation` 等价的配置项。

#### Status

OPEN

---

### Q-002 — 现有 `~/.claude/skills/` 目录下是否曾存在 `yy-grill-me` symlink

#### Question

Design Spec 第 7 节声明"`~/.claude/skills/` 下无 yy-grill-me 旧 symlink（已确认）"。当前 `~/.claude/skills/` 目录列表确认无 `yy-grill-me` 条目，但无法确认历史上是否曾存在后又被手动删除。

#### Why It Matters

如果有历史遗留的 symlink 引用但未被发现（例如在其他用户账户或备份路径中），改名后这些引用会变为悬空链接，但不会造成主动损害。

更关键的是：如果未来有其他工具或脚本硬编码了 `~/.claude/skills/yy-grill-me/` 路径，改名会破坏这些引用。

#### Required Clarification

需要确认是否有其他工具、脚本、或自动化流程引用了 `~/.claude/skills/yy-grill-me/` 路径或 `yy-grill-me` 技能名。

#### Status

OPEN

---

## Review Limitations

1. **Hermes 平台的内部机制未知**：本次审查仅基于 Design Spec 中描述的 Hermes frontmatter 字段（`category`、`tags`），不了解 Hermes 的技能发现、触发、和生命周期管理机制。这影响了 SC-002 的 Confidence 评估（标记为 MEDIUM）。
2. **用户的实际开发工作流未知**：SC-003（install.sh 在内容修改中途被调用）的可能性评估依赖对用户工作流的推断。如果用户使用自动化脚本或 CI，风险可能性会上升。
3. **Design Spec 的执行完全依赖单人手动操作**：本 spec 描述的是一个手动改名和发布流程，不涉及自动化部署、CI/CD、或多人协作。在此约束下，许多传统系统风险（如并发修改、部署窗口、版本偏斜）不适用。本次审查已据此调整风险评估的基准。
4. **未审查 GitHub API 的速率限制和行为**：spec 使用 `gh repo create` 命令创建私有仓库，但未涉及 GitHub API 的速率限制、仓库命名策略、或 `gh` CLI 的版本兼容性。这些属于 `gh` CLI 的工具行为，不在本审查范围内。

---

## Reviewer Conclusion

### Critical Finding Count

* P0: 0
* P1: 0
* P2: 3

### Risk Summary

* Security risks: 0（SC-002 涉及隐式调用防护的弱化，但实际安全暴露有限，归类为兼容性/维护风险）
* Data integrity risks: 1（SC-001：验收文档数据完整性）
* Availability and resilience risks: 0
* Operational risks: 1（SC-003：install.sh 缺乏完整性校验导致的操作风险）
* Maintenance risks: 2（SC-001：行号证据的持续性维护负担；SC-002：多平台间的策略一致性维护）
* Irreversible decisions: 1（ID-001：GitHub 私有仓库创建与首次推送）
* Over-engineering risks: 0

### Review Result

REQUIRES_REVIEW

This review identifies three P2 system-level risks and one irreversible decision that should be considered by the Consolidation phase. No P0 or P1 findings were identified.

The three findings represent moderate, bounded risks appropriate to the scope of the Design Spec (a file rename and publish operation for a single-file AI skill):

* **SC-001** is the most actionable finding: acceptance document integrity can be improved with a low-cost content anchor mechanism.
* **SC-002** is a forward-compatibility concern that may be deferred but should be explicitly documented as a conscious trade-off.
* **SC-003** can be addressed with a three-line addition to install.sh's validation logic.

The System Critic does not determine whether the Findings are ultimately accepted, rejected, deferred, or otherwise resolved.

Final disposition is determined by the Decision Protocol.

---

## Machine-Readable Finding Index

```yaml
review:
  review_id: "2026-08-07-R1-SC"
  reviewer: "yy-system-critic"
  review_type: "SYSTEM_REVIEW"
  status: "COMPLETED"

findings:
  - id: "SC-001"
    severity: "P2"
    evidence_class: "MATERIAL_RISK"
    confidence: "HIGH"
    title: "验收文档行号证据依赖 frontmatter 物理行数的单一假设，形成脆弱验证链"
    location: "Design Spec 第 4.1 节（SKILL.md frontmatter 改动）、第 4.4 节（acceptance 行号同步）"
    likelihood: "MEDIUM"
    reversibility: "REVERSIBLE"
    source_references:
      - "Design Spec 第 4.1 节（第 93-113 行）"
      - "Design Spec 第 4.4 节（第 151-171 行）"
      - "Design Spec 第 7 节（第 269-276 行）"
      - "现有文件 docs/superpowers/plans/2026-07-29-yy-grill-me-acceptance.md"
    risk_dimensions:
      - "Data Integrity and Consistency"
      - "Maintenance Burden"
      - "Data Lifecycle and Migration"
    status: "PENDING_DECISION"

  - id: "SC-002"
    severity: "P2"
    evidence_class: "MATERIAL_RISK"
    confidence: "MEDIUM"
    title: "删除 agents/openai.yaml 消除隐式调用的机器级防护，改用自然语言指令替代"
    location: "Design Spec 第 4.3 节（删除 agents/）、第 4.1 节（SKILL.md frontmatter）"
    likelihood: "LOW"
    reversibility: "REVERSIBLE"
    source_references:
      - "Design Spec 第 4.3 节（第 119-122 行）"
      - "Design Spec 第 4.1 节（第 93-112 行）"
      - "现有文件 agents/openai.yaml"
    risk_dimensions:
      - "Security Boundaries"
      - "External Dependencies"
      - "Backward Compatibility"
    status: "PENDING_DECISION"

  - id: "SC-003"
    severity: "P2"
    evidence_class: "MATERIAL_RISK"
    confidence: "MEDIUM"
    title: "install.sh 在 symlink 创建前不验证目标目录内容完整性"
    location: "Design Spec 第 4.5 节（安装机制）、第 5 节（错误处理）"
    likelihood: "LOW"
    reversibility: "REVERSIBLE"
    source_references:
      - "Design Spec 第 4.5 节（第 173-217 行）"
      - "Design Spec 第 4.6 节（第 221-241 行）"
      - "Design Spec 第 5 节（第 245-254 行）"
    risk_dimensions:
      - "Failure Recovery"
      - "Operational Complexity"
      - "Observability and Diagnosis"
    status: "PENDING_DECISION"

irreversible_decisions:
  - id: "ID-001"
    status: "OPEN"
    title: "GitHub 私有仓库创建与首次推送"

complexity_risks: []

open_questions:
  - id: "Q-001"
    status: "OPEN"
    question: "Hermes 平台的技能触发机制是否区分隐式/显式调用"
  - id: "Q-002"
    status: "OPEN"
    question: "现有 ~/.claude/skills/ 目录下是否曾存在 yy-grill-me symlink 及其他工具/脚本是否引用了旧技能名"
```

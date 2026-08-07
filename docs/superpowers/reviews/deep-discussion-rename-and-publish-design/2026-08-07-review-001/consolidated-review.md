# Consolidated Review

## 输出语言

本审核的所有描述性内容使用中文撰写。所有 UPPERCASE_WITH_UNDERSCORE 标识符、Finding ID、YAML key/枚举值、技术路径保持英文。Machine-Readable YAML 索引中的 title/description 等描述性字段使用中文。

## Review Metadata

### Review ID

2026-08-07-R1-CONSOLIDATED

### Review Type

CONSOLIDATED_REVIEW

### Design Spec

docs/superpowers/specs/2026-08-07-deep-discussion-rename-and-publish-design.md

### Consolidation Date

2026-08-07

### Consolidator

yy-spec-review-orchestrator

### Review Status

COMPLETED

---

## Consolidation Scope

本文档合并以下三方独立审查的发现：

* `yy-product-reviewer`（产品审查）
* `yy-system-critic`（系统审查）
* `yy-test-designer`（测试审查）

合并目的：识别描述同一底层问题的发现、合并重复发现且不丢失证据、保留实质不同的发现、识别审查员间的冲突、建立统一发现身份、保留原始审查视角，并为 Design Spec 负责人或 Superpowers 流程准备单一审查文档。

本文档是合并产物，不替代原始审查报告。原始审查发现仍是各自视角的来源。

---

## Source Reviews

| Reviewer | Review Type | Review ID | Source File | Status |
| --- | --- | --- | --- | --- |
| yy-product-reviewer | PRODUCT_REVIEW | 2026-08-07-R1-PR | 2026-08-07-review-001/product-review.md | AVAILABLE |
| yy-system-critic | SYSTEM_REVIEW | 2026-08-07-R1-SC | 2026-08-07-review-001/system-review.md | AVAILABLE |
| yy-test-designer | TEST_REVIEW | 2026-08-07-R1-TD | 2026-08-07-review-001/test-review.md | AVAILABLE |

三份源审查均 AVAILABLE，无 MISSING。

---

## Consolidation Principles

合并严格遵循：不因关键词/组件/严重度/后果相似而合并；保留独立视角；不强制合并；不静默消解冲突；证据优先于审查员权威；不确定性保持可见（推断不升级为确认、可能不升级为必然、假设不升级为要求）。

---

## Consolidator Predispositions

以下为 Phase 1（上下文获取）阶段主 agent 形成的关键判断，可能影响合并，记录以使认知偏差可审计。这些是偏差声明，不指向任何具体发现。

### Predisposition 1 — "机械任务"框架风险

本 spec 是运维/工具类 spec（改名 + 发布），非行为类产品 spec。合并时存在因"只是改名"而低估正确性风险的倾向。已刻意校准：改名完整性、行号对齐、双端安装、git 发布引入真实的正确性与不可逆风险，不应被"机械任务"框架抑制。

### Predisposition 2 — goal-manager 约定引用

spec 反复以 `goal-manager` 为模板来源（install.sh 风格、frontmatter 结构、无 LICENSE、无 agents 目录）。审查员看不到 goal-manager，可能把"按 goal-manager 约定"误报为"未定义"。合并时已区分真缺口与"按引用约定"。

### Predisposition 3 — 行号脆弱性已自认

spec 第 7 节显式标记"+5 行"frontmatter 假设需重新核验——这是 spec 自识别的脆弱点。此偏差使行号对齐类发现的合并可信度评估偏高。

### Predisposition 4 — 一次性决策与可逆决策混杂

目录 mv / git init / GitHub 私有仓库推送是一次性门；文件编辑可逆。第 4.6 节含个人绝对路径，spec 称"私有仓库不外泄故不脱敏"——但推送到 GitHub（即便私有）属外部发布。此张力可能跨审查员浮现，合并时不得静默消解。

### Predisposition 5 — 可验证性时序

成功标准含客观可验项（grep 零残留、symlink 校验、hermes skills 列出、gh repo view），但"acceptance 行号对齐"只能在改名后验证；spec 本身是实施前设计，不可能含改名后行号。合并时已警惕把"尚未执行"误作"不可验证"。

### Predisposition 6 — 领域知识

用户个人技能仓库、单人开发、单文件自包含。合并已据此调低"多角色协同/并发"风险权重，调高"个人单点知识 / 个人机 symlink 脚枪"权重。

---

# Consolidated Findings

## CR-001 — README.md 旧名引用与 grep "零残留" 验收标准存在互斥矛盾

### Consolidated Severity

P1

### Consolidation Confidence

HIGH

### Finding Status

PENDING_DECISION

### Underlying Problem

Design Spec 内部存在两项字面互斥的要求：第 4.5 节要求 README.md 包含「前身为 yy-grill-me，已改名」说明（即 README 必然含字符串 `yy-grill-me`）；而第 6 节验收标准 AC1 要求 `grep -rn "yy-grill-me" .`（仅排除 `.git/`、`.workbuddy/`、`.superpowers/sdd/`）零输出。README.md 位于仓库根目录、不在排除列表内。两项要求无法同时满足——AC1 的 grep 必然命中 README，判定失败；反之 AC1 通过则 README 不能含该字符串，违反第 4.5 节。

### Evidence

#### Confirmed Evidence

* Design Spec 第 4.5 节明确要求 README.md 含「前身为 yy-grill-me，已改名」。
* Design Spec 第 6 节 AC1 明确要求全仓 grep `yy-grill-me` 零输出，排除列表仅含 `.git/`、`.workbuddy/`、`.superpowers/sdd/`。
* Design Spec 第 1 节成功标准亦含"全仓零 yy-grill-me 残留"。
* README.md 位于仓库根目录，不在 grep 排除列表中。

#### Inferred Evidence

* grep 是机械字符串匹配，不区分"功能性残留"与"历史溯源引用"。

#### Unknowns

* 除 README.md 外，是否还有其他文件需刻意保留旧名引用（如本设计 spec 自身、部署文档历史说明）——见 TD Q-001。

### Trigger Scenario

1. 实现者按第 4.5 节在 README.md 写入「前身为 yy-grill-me，已改名」。
2. 实现者按 AC1 执行 `grep -rn "yy-grill-me" .`（带排除）。
3. grep 在 README.md 命中 `yy-grill-me`，输出非空。
4. AC1 判定"失败"，但 README 内容符合第 4.5 节。
5. 测试者无法判断 AC1 失败是改名遗漏（真实缺陷）还是 README 刻意引用（规格允许）。

### Consequence

* Business Impact: NONE_IDENTIFIED
* User Impact: 验收阶段必然出现"AC1 不通过但其他标准通过"的争议，缺乏判定规则。
* Data Impact: NONE_IDENTIFIED
* Security Impact: NONE_IDENTIFIED
* Availability Impact: NONE_IDENTIFIED
* Operational Impact: NONE_IDENTIFIED
* Maintenance Impact: 不同实现者可能对 README 旧名引用做不同处理（不写 / 写后手动加排除），产生实现分歧。
* Verification Impact: 两项验收标准不可同时通过；"零残留"语义未定义（功能性残留 vs 历史引用），验收结论将依赖主观判断。

### Reviewer Perspectives

#### Product Perspective

**Source Findings:**

* 无（Product Reviewer 未识别此矛盾）

**Assessment:**

Product Reviewer 聚焦平台声明、安装原子性、agents 删除，未触及 README 与 grep 的字面互斥。此为 Test 视角独有发现，按"不压制少数发现"原则保留。

#### System Perspective

**Source Findings:**

* 无

**Assessment:**

System Critic 聚焦行号脆弱性、agents 删除、install 完整性，未触及此项。

#### Test Perspective

**Source Findings:**

* TD-001（P1, CONFIRMED_GAP, HIGH, UNTESTABLE_REQUIREMENT）

**Assessment:**

Test Designer 精确定位第 4.5 节与 AC1 的字面互斥，指出独立测试者无法在"规格已正确实现"前提下同时通过两项标准，并给出两套可行解（grep 排除 README + 定义"零功能性残留" / README 改用不含旧名表述）。

### Relationship Classification

INDEPENDENT

#### Relationship Explanation

仅 Test Designer 一方识别，无其他源发现涉及此矛盾。独立保留。

### Conflict Analysis

#### Conflict Status

NO_CONFLICT

#### Conflicting Positions

无跨审查员分歧。矛盾存在于 spec 内部两项要求之间，而非审查员之间。

#### Conflict Evidence

不适用。

#### Resolution

此为 spec 内部矛盾，需 spec 负责人裁决采用哪套解法，非合并可消解。状态 PENDING_DECISION。

### Recommended Resolution

在验收标准中明确"零残留"= "零功能性残留"，并采用以下之一：

1. 将 AC1 的 grep 命令显式排除 `README.md`，并在验收说明中定义"允许列表"（allowed occurrences list），列出刻意保留旧名的文件及预期命中次数。
2. README.md 改用不含字面 `yy-grill-me` 的表述（如"本技能前身曾用另一名称"）。

无论哪种，spec 必须明确：哪些文件中的旧名字符串属"刻意保留"，哪些属"遗漏残留"。

### Source References

#### Product Review

* 无

#### System Review

* 无

#### Test Review

* TD-001

#### Design Spec References

* 第 1 节 成功标准"全仓零 yy-grill-me 残留"
* 第 4.5 节 README.md 内容要求
* 第 6 节 验收标准 AC1

### Consolidation Decision

KEPT_SEPARATE

#### Decision Rationale

单源发现，独立可操作，无需合并。Test Designer 证据确凿（spec 两处原文直接互斥），直接采纳为 CR-001。

### Severity Change Rationale

No severity change from source findings.（TD-001 为 P1，合并后保持 P1。spec 内部验收标准互斥导致 AC1 不可通过，属"应在实现前解决"的 P1，未达 P0——无数据/安全/不可恢复影响。）

---

## CR-002 — `platforms` 声明包含 Windows，但安装机制仅支持 Unix

### Consolidated Severity

P1

### Consolidation Confidence

HIGH

### Finding Status

PENDING_DECISION

### Underlying Problem

SKILL.md frontmatter 声明 `platforms: [macos, linux, windows]`，明确将 Windows 列为支持平台。但 spec 提供的唯一安装机制 `scripts/install.sh` 使用 bash + `ln -s`，Windows 原生不可用；`docs/deploy.md` 被描述为含"手动 `ln -s` 命令"，同样 Unix 专属。spec 未提供任何 Windows 兼容安装路径（PowerShell `New-Item -ItemType SymbolicLink`、`mklink`、手动复制），也未在 deploy.md 为 Windows 用户提供说明。声明了平台支持但未交付该平台的完整用户旅程，frontmatter 元数据与实际可用性存在显式矛盾。

### Evidence

#### Confirmed Evidence

* Design Spec 第 4.1 节 frontmatter 声明 `platforms: [macos, linux, windows]`。
* Design Spec 第 4.5 节 install.sh 使用 `#!/usr/bin/env bash` 与 `ln -s`，无 Windows 兼容逻辑。
* Design Spec 第 4.5 节 deploy.md 描述为"手动 `ln -s` 命令（goal-manager 风格）"。
* spec 全文未出现任何 Windows 安装指令、PowerShell 命令或 `mklink` 引用。

#### Inferred Evidence

* Windows 用户无法直接执行 bash 脚本或 `ln -s`（需 WSL/Git Bash，但 spec 未声明此前提）。
* 此声明模式沿袭自 goal-manager，可能继承了一个同样未解决的平台差距。

#### Unknowns

* 是否有意在未来补齐 Windows 安装路径，还是 `platforms` 声明本身应收缩。

### Trigger Scenario

1. Windows 用户通过 GitHub 私有仓库发现 deep-discussion 技能。
2. 用户读 README/deploy.md，见 frontmatter 声明 `platforms: [macos, linux, windows]`。
3. 用户尝试按 deploy.md 的 `ln -s` 或运行 install.sh 安装。
4. Windows 原生无法执行 bash 或 `ln -s`。
5. 用户无文档化替代安装路径，无法完成安装。

### Consequence

* Business Impact: 当前私有仓库 + 单人使用，业务影响有限；若未来扩大使用范围或对外开放，此矛盾构成实质准入门槛。
* User Impact: Windows 用户无法按文档完成安装，产生困惑与被误导感。
* Data Impact: NONE_IDENTIFIED
* Security Impact: NONE_IDENTIFIED
* Availability Impact: 技能在 Windows 上不可用（与声明矛盾）。
* Operational Impact: NONE_IDENTIFIED
* Maintenance Impact: frontmatter `platforms` 声明可信度降低。
* Verification Impact: 无验收标准验证 Windows 端可用性（AC4/AC5 仅覆盖 macOS/Linux 双端 symlink 与触发）。

### Reviewer Perspectives

#### Product Perspective

**Source Findings:**

* PR-001（P1, CONFIRMED_DEFECT, HIGH）

**Assessment:**

Product Reviewer 识别 frontmatter 平台声明与安装机制的平台覆盖矛盾，属"声明了支持但未交付完整用户旅程"的产品一致性缺陷，给出二选一解法（收缩 platforms 或补 Windows 安装章节）。

#### System Perspective

**Source Findings:**

* 无

**Assessment:**

System Critic 未单独识别此平台覆盖矛盾（其 Windows 相关关注并入 Hermes/平台兼容性维度但未单列发现）。

#### Test Perspective

**Source Findings:**

* 无

**Assessment:**

Test Designer 未单独识别（其平台验证关注聚焦 Hermes vs Claude Code 不对称，见 CR-008）。

### Relationship Classification

INDEPENDENT

#### Relationship Explanation

仅 Product Reviewer 识别。与 CR-008（Hermes 触发验证不对称）同属"平台支持声明与验证覆盖"主题，但根不同（CR-002 = 安装机制未覆盖声明平台；CR-008 = 跨平台验证深度不对称），独立保留。

### Conflict Analysis

#### Conflict Status

NO_CONFLICT

#### Conflicting Positions

无。

#### Conflict Evidence

不适用。

#### Resolution

无需合并消解。PENDING_DECISION。

### Recommended Resolution

二选一：

1. **方案 A（推荐）**：`platforms` 收缩为 `[macos, linux]`，并在 README/deploy.md 增一句"当前安装脚本仅支持 macOS/Linux；Windows 用户可手动复制仓库目录到对应 skills 路径，或用 PowerShell 创建符号链接"。
2. **方案 B**：保留 `platforms: [macos, linux, windows]`，在 deploy.md 增加 Windows 安装章节（PowerShell `New-Item -ItemType SymbolicLink` 或手动复制）。

### Source References

#### Product Review

* PR-001

#### System Review

* 无

#### Test Review

* 无

#### Design Spec References

* 第 4.1 节 SKILL.md frontmatter `platforms` 声明
* 第 4.5 节 install.sh 脚本与 deploy.md 描述
* 第 6 节 验收标准 AC4/AC5（仅覆盖 macOS/Linux 双端）

### Consolidation Decision

KEPT_SEPARATE

#### Decision Rationale

单源发现，独立可操作。Product Reviewer 证据为 spec 原文直接比对，确凿。

### Severity Change Rationale

No severity change from source findings.（PR-001 为 P1，保持 P1。frontmatter 声明与实际可用性显式矛盾，降低元数据可信度且 Windows 用户旅程断裂；当前单人私有仓库使业务影响有限，未达 P0。）

---

## CR-003 — 删除 `agents/openai.yaml` 致隐式调用防护从机器策略降级为自然语言指令

### Consolidated Severity

P2

### Consolidation Confidence

MEDIUM

### Finding Status

PENDING_DECISION

### Underlying Problem

Design Spec 第 4.3 节决定删除 `agents/openai.yaml` 及 `agents/` 目录。该文件含 `policy.allow_implicit_invocation: false`——机器可执行策略，由兼容 OpenAI agent 协议的平台在调度层硬拦截"不自动唤起该技能"。spec 给出的删除理由称此语义"由 SKILL.md 正文「仅显式触发」铁律保证"。但 SKILL.md 正文铁律是中文自然语言指令（面向 LLM 推理时解释，可能被忽略/遗忘/越狱绕过），与 `allow_implicit_invocation: false`（平台调度层硬拦截，不经 LLM 推理）不在同一防护层级。删除后，兼容 OpenAI 协议的 agent 框架将失去阻止隐式调用的机器可读信号。spec 以 goal-manager 类比（"无 agents 目录"），但 goal-manager 的 description 旨在广泛匹配，与 deep-discussion"仅显式触发"的安全属性不同，不应直接类比。

### Evidence

#### Confirmed Evidence

* 现有文件 `agents/openai.yaml` 含 `policy.allow_implicit_invocation: false`。
* Design Spec 第 4.3 节明确声明删除该文件，理由为正文铁律替代。
* SKILL.md 正文铁律为中文自然语言指令，非结构化机器可读策略。
* Design Spec 第 2.2 节"不修改技能语义行为"——隐式调用防护属语义行为的机器级防护，其删除并非语义中立。

#### Inferred Evidence

* 自然语言指令与机器策略防护强度不等价：前者经 LLM 推理可能受上下文干扰，后者调度层硬拦截。
* OpenAI 兼容 agent 框架通过解析 `agents/openai.yaml` 决定调用策略（该文件格式的设计意图）。

#### Unknowns

* Claude Code 与 Hermes 是否各有独立的隐式调用防护机制、完全不依赖 `agents/openai.yaml`（见 SC Q-001）。
* Hermes 平台触发机制是否区分隐式/显式调用（见 SC Q-001）。

### Trigger Scenario

1. 用户将 deep-discussion 部署到同时支持 OpenAI agent 协议与 Claude Code skill 协议的环境。
2. 该平台在技能选择阶段检查 `allow_implicit_invocation` 策略。
3. 因 `agents/openai.yaml` 已删，平台未找到显式禁止隐式调用策略。
4. 平台 LLM 在对话中据上下文语义判断应唤起 deep-discussion（如用户讨论设计方案时）。
5. 技能被自动唤起，违反"仅显式触发"铁律。

### Consequence

* Business Impact: NONE_IDENTIFIED
* User Impact: 非显式触发下进入拷问流程，打断正常工作流。
* Data Impact: NONE_IDENTIFIED
* Security Impact: 有限——隐式调用防护从机器策略降级为自然语言，减弱调用边界防护；但 deep-discussion 是只读为主交互式技能（铁律禁止自动创建文件），自动唤起后果主要是信息暴露（用户计划/设计上下文被带入拷问流程）而非数据破坏或越权。
* Availability Impact: NONE_IDENTIFIED
* Operational Impact: NO_MATERIAL_OPERATIONAL_IMPACT_IDENTIFIED（当前双端不受影响）
* Maintenance Impact: 若未来为第三平台恢复 `allow_implicit_invocation: false`，需重建 `agents/` 结构；多平台间策略一致性维护成本上升；后续维护者可能不了解此删除决策背景。
* Verification Impact: NONE_IDENTIFIED

### Reviewer Perspectives

#### Product Perspective

**Source Findings:**

* PR-003（P2, MATERIAL_RISK, MEDIUM）

**Assessment:**

Product Reviewer 从产品铁律视角指出：删除使"仅显式触发"铁律在 OpenAI 兼容框架上可能失效，建议在 spec 中明确删除前提条件（双端不依赖此文件），并记录为有意识决策。

#### System Perspective

**Source Findings:**

* SC-002（P2, MATERIAL_RISK, MEDIUM, likelihood LOW, REVERSIBLE）

**Assessment:**

System Critic 从系统防护层级视角指出：自然语言指令与机器策略防护强度不等价，goal-manager 类比不当（防护需求不同）。建议在 frontmatter 增平台无关的 `implicit_invocation: false` 字段，或至少在 description 首句保留"仅允许显式触发"措辞。

#### Test Perspective

**Source Findings:**

* 无

**Assessment:**

Test Designer 未单独识别（其隐式调用相关关注并入 Hermes 触发机制未知，见 SC Q-001 / CR-008 主题）。

### Relationship Classification

DUPLICATE

#### Relationship Explanation

PR-003 与 SC-002 识别同一底层问题（删除 agents/openai.yaml 致隐式调用机器级防护降级为自然语言），同一触发条件（部署到 OpenAI 兼容平台），同一实质后果（技能可能被隐式唤起，违反铁律）。两发现为 DUPLICATE，按"保留独立视角"原则合并为 CR-003，分别保留 Product（产品铁律视角）与 System（防护层级视角）评估及各自证据。

### Conflict Analysis

#### Conflict Status

NO_CONFLICT

#### Conflicting Positions

PR-003 与 SC-002 结论一致（均为 P2、MEDIUM、删除有风险但当前双端不受影响），无分歧。两审查员对 likelihood 评估略有不同表述（PR-003 未给 likelihood；SC-002 给 LOW），但不构成实质冲突——均认为风险仅在未来引入第三 OpenAI 兼容平台时激活。

#### Conflict Evidence

不适用。

#### Resolution

无冲突需消解。PENDING_DECISION。

### Recommended Resolution

在 spec 第 4.3 节删除理由中增加一句明确前提："经确认，Claude Code 与 Hermes 均不通过 `agents/openai.yaml` 读取隐式调用策略；该文件策略语义在双端各自技能框架中由其他机制保障。"并：

1. 确认双端不依赖此文件（消除 UNKNOWN）；
2. 若未来计划支持 OpenAI 兼容 agent 框架，则不应删除此文件，或在 SKILL.md frontmatter 增等价机器可读字段（如平台无关的 `implicit_invocation: false`）；
3. 至少在 description 首句保留"仅允许显式触发"措辞，作为跨平台最低文本防护。

### Source References

#### Product Review

* PR-003

#### System Review

* SC-002

#### Test Review

* 无

#### Design Spec References

* 第 2.2 节 不在范围（不修改语义行为）
* 第 4.1 节 SKILL.md frontmatter / 正文铁律
* 第 4.3 节 删除 agents/

### Consolidation Decision

MERGED

#### Decision Rationale

PR-003 与 SC-002 为同一底层问题的双视角重复发现，合并以去重并保留 Product + System 双视角证据。合并后严重度 P2、置信度 MEDIUM（两源均 MEDIUM，且存在 UNKNOWN：双端是否完全不依赖此文件未实证确认，故不升级为 HIGH）。

### Severity Change Rationale

No severity change from source findings.（两源均 P2，保持 P2。当前目标平台 Claude Code + Hermes 不依赖此文件，风险仅在未来引入第三 OpenAI 兼容平台时激活，且技能只读为主、安全暴露有限，未达 P1。）

---

## CR-004 — install.sh 两次 `link` 调用非原子，部分失败后双端状态不一致且无恢复指引

### Consolidated Severity

P2

### Consolidation Confidence

MEDIUM

### Finding Status

PENDING_DECISION

### Underlying Problem

install.sh 顺序执行两次 `link`（Claude 端、Hermes 端），脚本 `set -euo pipefail` 使任一 `link` 返回非零即终止。当第一次（Claude 端）成功、第二次（Hermes 端）因"目标已存在且异源"返回 1 时，脚本终止报错，但 Claude 端 symlink 已写入文件系统不被自动清理。系统进入未定义的部分安装状态：Claude 端已装、Hermes 端未装。spec 第 5 节错误处理表未覆盖此场景，未定义恢复操作。`--uninstall` 可清理两处，但需用户（a）意识到处于部分安装状态、（b）知道需手动执行 `--uninstall`。

### Evidence

#### Confirmed Evidence

* Design Spec 第 4.5 节 install.sh 两次 `link` 顺序调用，`set -euo pipefail`。
* `link()` 函数异源时 `return 1`。
* 第 5 节错误处理表覆盖 6 场景，未含"部分安装成功后不一致状态"。

#### Inferred Evidence

* 用户在部分安装失败后可能不主动执行 `--uninstall`，误以为"安装失败=什么都没变"。
* 双端指向不同源路径时，同一技能在两端实际行为可能不同（源文件版本不一致）。

#### Unknowns

* 用户实际是否会在部分失败后诊断状态（依赖用户纪律）。

### Trigger Scenario

1. 用户此前已将 deep-discussion 以不同源路径装到 Hermes（如从另一克隆目录）。
2. 用户在新路径执行 `bash scripts/install.sh`。
3. `link "$SRC" "$CLAUDE_LINK"` 成功。
4. `link "$SRC" "$HERMES_LINK"` 检测 Hermes 端已存在且异源，返回 1。
5. 脚本因 `set -e` 终止。
6. 文件系统：Claude 端指向新源，Hermes 端仍指向旧源。
7. spec 与文档未说明如何从此状态恢复。

### Consequence

* Business Impact: NONE_IDENTIFIED
* User Impact: 用户未觉察下以为安装失败无变化，实际 Claude 端已变更。
* Data Impact: NONE_IDENTIFIED
* Security Impact: NONE_IDENTIFIED
* Availability Impact: 双端可能指向不同源，技能行为不一致。
* Operational Impact: 用户需自行诊断状态并决定手动 `rm` Claude 端或修复 Hermes 端，无文档指引。
* Maintenance Impact: NONE_IDENTIFIED
* Verification Impact: 无验收标准检测部分安装不一致状态。

### Reviewer Perspectives

#### Product Perspective

**Source Findings:**

* PR-002（P2, MATERIAL_RISK, MEDIUM）

**Assessment:**

Product Reviewer 从用户工作流完整性视角指出部分失败后双端不一致且无恢复指引，建议在错误输出增加部分安装提示或在 deploy.md 增故障排除章节。

#### System Perspective

**Source Findings:**

* 无（SC-003 关注 install 内容完整性，与此根不同，见 CR-005）

**Assessment:**

System Critic 未单独识别原子性/部分失败场景（其 install 关注为内容完整性预检查）。

#### Test Perspective

**Source Findings:**

* 无

**Assessment:**

Test Designer 未单独识别。

### Relationship Classification

INDEPENDENT

#### Relationship Explanation

仅 Product Reviewer 识别。与 CR-005（install.sh 不验证目标内容完整性）同属 install.sh 健壮性主题，但根不同（CR-004 = 两次 link 非原子/部分失败恢复；CR-005 = 建链前无内容完整性预检查），决策可不同（恢复指引 vs 完整性预检查），按"独立决策跟踪"原则保留独立。

### Conflict Analysis

#### Conflict Status

NO_CONFLICT

#### Conflicting Positions

无。

#### Conflict Evidence

不适用。

#### Resolution

PENDING_DECISION。

### Recommended Resolution

在不显著增加脚本复杂度前提下，提供最小恢复指引：

1. install.sh 错误输出增加提示："部分安装：Claude Code 端已安装，Hermes 端失败。可执行 `bash scripts/install.sh --uninstall` 清理后重试。"
2. 或在 deploy.md 故障排除章节记录此场景与恢复步骤。

若需更强保证，可在 `link` 失败时主动回滚（`rm -f` 已创建 link），但考虑脚本简洁性目标，文档化恢复指引已足够。

### Source References

#### Product Review

* PR-002

#### System Review

* 无

#### Test Review

* 无

#### Design Spec References

* 第 4.5 节 install.sh 脚本（两次 link 顺序调用 + link 函数）
* 第 5 节 错误处理表（未覆盖此场景）

### Consolidation Decision

KEPT_SEPARATE

#### Decision Rationale

单源发现，独立可操作，且与 CR-005 决策可能不同，保留独立以便分别决策。

### Severity Change Rationale

No severity change from source findings.（PR-002 为 P2，保持 P2。部分失败需 Hermes 端已存在异源 symlink 前提，当前单人使用概率较低，多机/多克隆场景真实存在，未达 P1。）

---

## CR-005 — install.sh 建链前不验证目标目录内容完整性

### Consolidated Severity

P2

### Consolidation Confidence

MEDIUM

### Finding Status

PENDING_DECISION

### Underlying Problem

install.sh 创建 symlink 指向源目录时，不验证源目录是否含完整、有效、已改名的技能文件。脚本唯一验证是 symlink 自身存在性（`[ -L "$CLAUDE_LINK" ] && [ -L "$HERMES_LINK" ]`），不验证目标内容。在正常最终用户场景（git clone 后运行）此风险不成立（git clone 保证完整性）。但在开发流程中，spec 规定执行顺序为"目录改名 → 内容修改 → git init → 推送"，install.sh 作为可独立执行脚本，无机制阻止其在内容修改完成前被调用。若开发者在内容修改中途（如目录已改名但 SKILL.md 内容尚未全部替换）执行 install.sh，symlink 将指向部分改名、内容不一致的源目录，通过 symlink 调用技能可能显示旧名、新旧名混用、缺失关键文件。

### Evidence

#### Confirmed Evidence

* Design Spec 第 4.5 节 install.sh 完整脚本仅在末尾验证 symlink 存在性，不验证目标内容。
* 第 5 节错误处理表 6 场景无"源目录内容不完整/不一致"。
* 第 7 节风险列表未将"install.sh 在内容不一致时被调用"列为风险。
* 现有 SKILL.md 正文 122 行含多处需替换的 `yy-grill-me` 引用（7 处 grep 匹配），改名涉及至少 10 个文件，处理窗口足够大，中间态存在时间窗口。

#### Inferred Evidence

* 在多人协作或自动化 CI 场景，install.sh 可能在内容修改完成前被调用。
* 内容不一致状态下安装导致的异常行为难以诊断——symlink 指向正确路径但内容不一致，用户/开发者可能先怀疑平台问题。

#### Unknowns

* spec 目标用户实际开发工作流是否触发此风险（本地单人交互式开发可能降低概率）。

### Trigger Scenario

1. 开发者执行改名流程。
2. 步骤间——目录已从 `yy-grill-me/` 改名 `deep-discussion/`，但 SKILL.md 内容尚未全部替换（正文仍有 `/yy-grill-me` 引用）——开发者或自动化执行 `bash scripts/install.sh`。
3. install.sh 创建 symlink 指向内容不一致源目录。
4. 用户通过 symlink 路径调用技能。
5. 技能以不一致状态运行：frontmatter name 为 deep-discussion 但正文引用 /yy-grill-me。

### Consequence

* Business Impact: NONE_IDENTIFIED
* User Impact: 过渡窗口期使用技能遇困惑（技能名与内部引用不一致）。
* Data Impact: NONE_IDENTIFIED
* Security Impact: NO_MATERIAL_SECURITY_IMPACT_IDENTIFIED（技能受铁律约束，即使被触发也不自动创建/修改文件）
* Availability Impact: 技能可能以不一致状态运行。
* Operational Impact: 部分改名状态下安装的异常行为难追踪——symlink 指向正确路径但内容不一致，诊断困难。
* Maintenance Impact: 缺基础内容完整性检查将增加后续调试成本。
* Verification Impact: 无验收标准检测内容不一致安装。

### Reviewer Perspectives

#### Product Perspective

**Source Findings:**

* 无

**Assessment:**

Product Reviewer 未单独识别（其 install 关注为原子性/部分失败，见 CR-004）。

#### System Perspective

**Source Findings:**

* SC-003（P2, MATERIAL_RISK, MEDIUM, likelihood LOW, REVERSIBLE）

**Assessment:**

System Critic 从操作复杂性/可诊断性视角指出 install.sh 缺内容完整性预检查，建议增加最小化检查（SKILL.md 存在且 frontmatter `name` 与脚本 `NAME` 变量一致）。

#### Test Perspective

**Source Findings:**

* 无

**Assessment:**

Test Designer 未单独识别。

### Relationship Classification

INDEPENDENT

#### Relationship Explanation

仅 System Critic 识别。与 CR-004（install 原子性）同属 install.sh 健壮性主题，但根不同（CR-005 = 建链前无内容完整性预检查；CR-004 = 两次 link 非原子/部分失败恢复），决策可不同，保留独立。

### Conflict Analysis

#### Conflict Status

NO_CONFLICT

#### Conflicting Positions

无。

#### Conflict Evidence

不适用。

#### Resolution

PENDING_DECISION。

### Recommended Resolution

install.sh 增最小化内容完整性检查，在 symlink 创建前运行：

1. 检查 `$SRC/SKILL.md` 存在且可读。
2. 检查 `$SRC/SKILL.md` frontmatter `name` 字段与脚本 `NAME` 变量一致（`deep-discussion`）。
3. 检查失败则输出明确错误并以非零退出。

开销极低（读一个文件 frontmatter），有效防止内容不一致时建链。

### Source References

#### Product Review

* 无

#### System Review

* SC-003

#### Test Review

* 无

#### Design Spec References

* 第 4.5 节 install.sh 脚本
* 第 4.6 节 GitHub 推送流程（执行顺序）
* 第 5 节 错误处理表
* 第 9 节 后续执行顺序

### Consolidation Decision

KEPT_SEPARATE

#### Decision Rationale

单源发现，独立可操作，与 CR-004 决策可能不同，保留独立。

### Severity Change Rationale

No severity change from source findings.（SC-003 为 P2，保持 P2。单人开发流程中过渡窗口通常很短，但 CI/自动化或中断恢复场景可能性不可忽略，未达 P1。）

---

## CR-006 — acceptance 行号证据依赖 frontmatter "+5 行" 单一假设，形成脆弱验证链

### Consolidated Severity

P2

### Consolidation Confidence

HIGH

### Finding Status

PENDING_DECISION

### Underlying Problem

acceptance.md 的 15 个行号证据（验收标准逐条核对表、评审变更落地核对表、引用完整性核对、dry-run 行为清单）全部硬编码为 SKILL.md 物理行号。这些行号有效性完全依赖单一假设：SKILL.md frontmatter 改名后恰好净增 5 行。若实际行数偏离（description 折行、YAML 格式与 goal-manager 细微差异、编辑器自动换行），则 15 个行号引用全部偏移，acceptance.md 从"验收证据文档"降级为"含系统性错误的文档"。spec 第 7 节承认此风险（"行号同步易错"、"若净增非 5，全部行号映射重算"），但缓解措施完全依赖人工逐条比对，无自动化校验。

### Evidence

#### Confirmed Evidence

* Design Spec 第 4.1 节声明"frontmatter +5 行，正文整体下移 5 行"——所有行号映射基础假设。
* 第 4.4 节提供 15 行行号映射表，均基于"+5 行"单一假设。
* 第 7 节第一条风险承认"行号同步易错"，第二条声明"若净增非 5，全部行号映射重算"——确认单一故障点。
* acceptance.md（现有文件）多处引用 SKILL.md 物理行号。
* 现有 SKILL.md 正文 122 行，frontmatter 4 行；改名后 frontmatter 若为 9 行，正文偏移 +5——此证据确认"+5 行"在当前 YAML 排版下成立，但不构成对其他 YAML 排版方式的保证。

#### Inferred Evidence

* 若 frontmatter 实际行数与假设不一致，开发者可能未逐条核对所有 15 个行号引用（15 个行号分布在 4 个不同表格/清单，逐条核对纪律性难保证）。
* 错误行号证据被保留，后续验收产生虚假 PASS/FAIL。

#### Unknowns

* 改名后实际 frontmatter 行数（spec 是实施前设计，无法含改名后行号）。

### Trigger Scenario

1. 开发者按第 4.1 节修改 frontmatter，期望净增恰好 5 行。
2. 因 YAML 格式差异/编辑器自动换行/description 长度变化，实际行数增量偏离 5。
3. 开发者按第 7 节映射表更新 acceptance.md 行号（每行 +5）。
4. 更新后 15 个行号证据全部与实际 SKILL.md 行号系统性偏移。
5. 开发者未逐条重读 SKILL.md 实际行号核对（或核对遗漏）。
6. 错误行号证据保留，后续验收产生虚假结论。

### Consequence

* Business Impact: NONE_IDENTIFIED
* User Impact: NONE_IDENTIFIED（不影响技能终端用户）
* Data Impact: acceptance.md 数据完整性受损——行号证据失效。
* Security Impact: NO_MATERIAL_SECURITY_IMPACT_IDENTIFIED
* Availability Impact: NONE_IDENTIFIED
* Operational Impact: NO_MATERIAL_OPERATIONAL_IMPACT_IDENTIFIED（不影响运行时）
* Maintenance Impact: acceptance.md 失去作为验收证据可信度；每次修改 SKILL.md 致行号变化都需同步更新 15 个引用，持续维护负担；后续维护者无法通过行号定位实际内容。
* Verification Impact: 验收 PASS/FAIL 可能基于错误行号证据，产生虚假通过或误报失败；行号对齐本身无可自动化校验机制。

### Reviewer Perspectives

#### Product Perspective

**Source Findings:**

* 无

**Assessment:**

Product Reviewer 未单独识别。

#### System Perspective

**Source Findings:**

* SC-001（P2, MATERIAL_RISK, HIGH, likelihood MEDIUM, REVERSIBLE）

**Assessment:**

System Critic 从数据完整性/维护负担视角指出 15 个行号证据全依赖"+5 行"单一假设，形成脆弱验证链，建议在 acceptance.md 增内容锚点表 + 自动化比对脚本。

#### Test Perspective

**Source Findings:**

* 无（TD-003 关注行号验证/修正流程可靠性，与此根不同，见 CR-007）

**Assessment:**

Test Designer 的行号关注为流程可靠性（验证与修正合并、缺独立复核），非假设脆弱性本身。

### Relationship Classification

INDEPENDENT

#### Relationship Explanation

仅 System Critic 识别假设脆弱性本身。与 CR-007（行号验证/修正流程缺独立复核）同属 acceptance 行号对齐主题，但根不同（CR-006 = "+5 行"假设是单一故障点、无自动化校验；CR-007 = 验证与修正合并为同一步骤、缺独立复核/差异记录），决策可不同（自动化锚点校验 vs 流程独立复核/diff 记录），保留独立。

### Conflict Analysis

#### Conflict Status

NO_CONFLICT

#### Conflicting Positions

无。

#### Conflict Evidence

不适用。

#### Resolution

PENDING_DECISION。

### Recommended Resolution

在 acceptance.md 增自动化校验机制：每个行号引用附加内容锚点（对应行开头固定长度文本片段），验收流程第一步用脚本自动比对锚点是否匹配 SKILL.md 实际行号。锚点不匹配则验收直接 FAIL，不进入人工核对。

具体约束：

1. acceptance.md 每个行号引用必须附加内容锚点。
2. 验收流程第一条必须是用脚本自动比对所有锚点与 SKILL.md 实际行号。
3. 锚点比对失败则验收直接 FAIL。

### Source References

#### Product Review

* 无

#### System Review

* SC-001

#### Test Review

* 无

#### Design Spec References

* 第 4.1 节 SKILL.md frontmatter 改动
* 第 4.4 节 acceptance 行号同步（15 行映射表）
* 第 7 节 风险与注意（行号同步易错）
* 现有文件 docs/superpowers/plans/2026-07-29-yy-grill-me-acceptance.md

### Consolidation Decision

KEPT_SEPARATE

#### Decision Rationale

单源发现，独立可操作，与 CR-007 决策可能不同（自动化锚点 vs 流程独立复核），保留独立。

### Severity Change Rationale

No severity change from source findings.（SC-001 为 P2，保持 P2。spec 第 7 节已自认此风险并提供人工核对兜底，且现有 YAML 排版下"+5 行"成立，故虽 confidence HIGH 但严重度 P2——影响验收文档可信度而非运行时/数据/安全。）

---

## CR-007 — 行号对齐的验证与修正流程合并为同一步骤，缺乏独立确认机制

### Consolidated Severity

P2

### Consolidation Confidence

MEDIUM

### Finding Status

PENDING_DECISION

### Underlying Problem

AC2 验证方法为"重读改名后 SKILL.md 实际行号，逐条比对 acceptance.md 引用，全部一致"；第 7 节进一步规定"任何不一致就地修正 acceptance 行号"。该流程将"验证"与"修正"合并为同一步骤——验证者同时是修正者，无独立复核环节。可能出现盲点：比对者疏忽遗漏某条映射，因"不一致即修正"的流程设计，比对者可能在整轮比对完成前就已开始修正，失去对原始差异的追踪；语义对应关系（如"拷问纪律三判据"对应某几行）依赖比对者主观判断，判断有误则错误直接"修正"进文档而无外部发现机会；修正完成后无法追溯"哪些行号曾不一致、如何修正"的变更记录。这是流程性盲点而非验收标准定义缺陷——AC2 预期结果明确（行号全部一致），风险在于执行过程中错误可能被"修正"而非被"发现"。

### Evidence

#### Confirmed Evidence

* 第 4.4 节行号映射表含 15+ 条映射，均基于"frontmatter +5 行"假设。
* 第 7 节原文："行号同步易错：…采用'改名后重读实际行号逐条比对'兜底，避免凭映射表臆测。"
* AC2 原文："重读改名后 SKILL.md 实际行号，逐条比对 acceptance.md 引用，全部一致"
* 第 7 节原文："任何不一致就地修正 acceptance 行号"

#### Inferred Evidence

* 比对者可能在整个比对完成前就开始修正，失去原始差异追踪。
* 语义对应关系依赖主观判断，误判会被"修正"进文档。
* 修正后无法追溯变更记录（除非 git 提交粒度足够细）。

#### Unknowns

* 是否会有第二人或自动化脚本复核修正结果（spec 未定义）。

### Trigger Scenario

1. SKILL.md 改名后实际行号：第 27 行对应"一次一问"（恰巧合数一致），但第 41 行对应 ADR 三条件入口因某行意外换行导致偏移。
2. 比对者按映射表逐条核对第 27 行（一致）、第 33 行（一致）……到第 41 行发现映射表预期为 ADR 三条件入口，但实际第 41 行为空行。
3. 比对者向上查找，在第 42 行找到 ADR 三条件入口，将 acceptance.md 对应行号引用从 41 改为 42。
4. 比对者未意识到第 41 行空行是意外格式变化（编辑器自动格式化），而非预期 frontmatter +5 偏移。
5. 行号"被修正"后 AC2 通过，但 SKILL.md 存在未被发现的格式变化，可能影响其他工具解析。

### Consequence

* Business Impact: NONE_IDENTIFIED
* User Impact: NONE_IDENTIFIED
* Data Impact: NONE_IDENTIFIED
* Security Impact: NONE_IDENTIFIED
* Availability Impact: NONE_IDENTIFIED
* Operational Impact: NONE_IDENTIFIED
* Maintenance Impact: 行号映射错误可能被"修正"掩盖，后续维护者基于错误行号定位 SKILL.md 内容时被误导；SKILL.md 意外格式变化可能在"修正"中被吸收，不在任何验收标准暴露；多人协作验收时不同比对者可能对同一行号做不同修正，产生合并冲突。
* Verification Impact: AC2 本身可验证（逐条比对可完成），但执行过程可靠性不足——错误可能被"修正"而非"发现"。

### Reviewer Perspectives

#### Product Perspective

**Source Findings:**

* 无

**Assessment:**

Product Reviewer 未单独识别。

#### System Perspective

**Source Findings:**

* 无（SC-001 关注假设脆弱性本身，见 CR-006）

**Assessment:**

System Critic 的行号关注为假设脆弱性 + 自动化锚点，非流程独立复核。

#### Test Perspective

**Source Findings:**

* TD-003（P2, MATERIAL_RISK, MEDIUM, BLIND_SPOT）

**Assessment:**

Test Designer 从流程盲点视角指出验证与修正合并、缺独立确认机制，建议比对先产出差异清单、再修正、修正后 diff 纳入验收证据供独立复核，并考虑自动化行号提取脚本作补充验证。

### Relationship Classification

INDEPENDENT

#### Relationship Explanation

仅 Test Designer 识别流程可靠性盲点。与 CR-006（行号假设脆弱性）同属 acceptance 行号对齐主题，但根不同（CR-007 = 验证/修正流程缺独立复核与差异记录；CR-006 = "+5 行"假设单一故障点、无自动化校验），决策可不同，保留独立。注：CR-006 的自动化锚点校验若作为最终门禁，可部分缓解 CR-007，但不完全消除（语义对应主观判断、人工修正吸收错误仍可能发生）。

### Conflict Analysis

#### Conflict Status

NO_CONFLICT

#### Conflicting Positions

无。

#### Conflict Evidence

不适用。

#### Resolution

PENDING_DECISION。

### Recommended Resolution

1. 验证流程增比对记录步骤：比对完成后先产出差异清单（表格列"预期行号/实际行号/差异/内容摘要"），再逐条修正。
2. 修正完成后将 acceptance.md 的 diff 纳入验收证据，供独立复核。
3. 考虑用自动化脚本提取 SKILL.md 关键段落行号，与 acceptance.md 引用行号做机械化比对，作为手动逐条比对的补充验证（非替代）。

### Source References

#### Product Review

* 无

#### System Review

* 无

#### Test Review

* TD-003

#### Design Spec References

* 第 4.4 节 行号同步（映射表）
* 第 6 节 验收标准 AC2
* 第 7 节 风险与注意

### Consolidation Decision

KEPT_SEPARATE

#### Decision Rationale

单源发现，独立可操作，与 CR-006 决策可能不同，保留独立。

### Severity Change Rationale

No severity change from source findings.（TD-003 为 P2，保持 P2。流程性盲点，AC2 本身可验证，风险集中在执行可靠性，未达 P1。）

---

## CR-008 — Hermes 与 Claude Code 触发验证标准不对称

### Consolidated Severity

P2

### Consolidation Confidence

MEDIUM

### Finding Status

PENDING_DECISION

### Underlying Problem

AC5 对两平台触发验证采用不对等标准：Claude Code 验证实际触发行为（"`/deep-discussion` 可启动拷问"）；Hermes 仅验证安装到位（"`hermes skills` 列出 deep-discussion"）。`hermes skills` 列出技能名仅证明 symlink 存在且 Hermes 能解析目录结构，不能证明：Hermes 能正确加载 SKILL.md（frontmatter 格式/编码问题可能导致加载失败但目录仍被列出）；能按 `metadata.hermes.category: software-development` 正确归类；能实际触发技能并进入拷问流程。该不对称意味着 Hermes 端"双端支持"验证强度显著低于 Claude Code 端，独立测试者无法以同等置信度断言 Hermes 端技能可用。

### Evidence

#### Confirmed Evidence

* AC5 原文："Claude Code 中 `/deep-discussion` 可启动拷问；`hermes skills` 列出 deep-discussion"
* 第 4.1 节定义 frontmatter `metadata.hermes.{tags, category}` 格式。
* 第 2.2 节"不修改技能语义行为"列为不在范围——但 Hermes 端触发验证未验证这些语义行为在 Hermes 上是否仍工作。

#### Inferred Evidence

* `hermes skills` 列出不等于可触发（一般性推理：列出不等于加载成功/可触发）。
* frontmatter `metadata.hermes.category` 字段格式与 Hermes 实际解析逻辑不完全匹配时，技能可能无法正确加载但 AC5 的 Hermes 部分仍"通过"。

#### Unknowns

* Hermes 平台内部 skill 加载与触发机制（未实际访问，见 TD Review Limitations）。
* `hermes skills` 是否已含加载校验。
* Hermes 是否支持等效于 Claude Code 斜杠命令的触发机制（见 TD Q-002）。

### Trigger Scenario

1. 实现者完成所有改名、frontmatter 元数据配置、symlink 安装。
2. 运行 `hermes skills`，输出含 `deep-discussion`——AC5 的 Hermes 部分通过。
3. 实际在 Hermes 触发 deep-discussion 时，因 frontmatter `metadata.hermes.category` 格式与 Hermes 解析逻辑不完全匹配，技能无法正确加载。
4. AC5 已判"通过"，但 Hermes 端技能实际不可用。

### Consequence

* Business Impact: NONE_IDENTIFIED
* User Impact: Hermes 用户安装后发现技能无法触发，降低对技能可靠性信任。
* Data Impact: NONE_IDENTIFIED
* Security Impact: NONE_IDENTIFIED
* Availability Impact: 双端安装可能判"验收通过"但 Hermes 端实际不可用，用户发现后才暴露。
* Operational Impact: NONE_IDENTIFIED
* Maintenance Impact: 后续若 Hermes skill 加载机制变化（frontmatter 字段要求更新），现有验证标准无法检测兼容性退化。
* Verification Impact: Hermes 端验证深度限于"安装到位"，无法验证"触发可用"；双端支持声明与验证强度不匹配。

### Reviewer Perspectives

#### Product Perspective

**Source Findings:**

* 无（PR Q-002 提出双端行为一致性是否纳入验收的开放问题，与此项主题相关但未形成独立发现）

**Assessment:**

Product Reviewer 以开放问题形式（Q-002）提出双端行为一致性验收未定义，但未升级为发现。

#### System Perspective

**Source Findings:**

* 无（SC Q-001 提出 Hermes 触发机制是否区分隐式/显式调用的开放问题，主题相关但未形成独立发现）

**Assessment:**

System Critic 以开放问题形式（Q-001）提出 Hermes 触发机制未知，影响 SC-002 置信度，但未升级为独立发现。

#### Test Perspective

**Source Findings:**

* TD-002（P2, CONFIRMED_GAP, HIGH, UNTESTABLE_REQUIREMENT）

**Assessment:**

Test Designer 精确定位 AC5 两平台验证深度不对称，建议拆分为 AC5a（Claude Code 实际触发）+ AC5b（Hermes 安装到位 + 若支持则实际触发，否则显式记录限制）。

### Relationship Classification

INDEPENDENT

#### Relationship Explanation

仅 Test Designer 形成独立发现。Product Q-002 与 System Q-001 以开放问题形式触及相关主题（双端行为一致性、Hermes 触发机制），但未形成发现，作为 CR-008 的相关未决问题保留参考。与 CR-002（Windows 平台覆盖）同属"平台支持声明与验证覆盖"主题，但根不同，独立保留。

### Conflict Analysis

#### Conflict Status

NO_CONFLICT

#### Conflicting Positions

无。三审查员对 Hermes 验证深度不足的关注方向一致（Product/System 以开放问题、Test 以发现），无分歧。

#### Conflict Evidence

不适用。

#### Resolution

PENDING_DECISION。

### Recommended Resolution

将 AC5 拆分为两个子标准或明确标注两平台验证深度差异：

* AC5a（Claude Code 端）：`/deep-discussion` 可启动拷问，验证实际触发行为。
* AC5b（Hermes 端）：`hermes skills` 列出 deep-discussion，且 Hermes 中可实际触发验证（若平台支持），否则注明 Hermes 验证限于"安装到位"。

若 Hermes 端无法做等效触发验证，建议在验收标准中显式记录该已知限制，避免验收争议。同时建议澄清 Hermes 触发机制（回应 SC Q-001 / TD Q-002）。

### Source References

#### Product Review

* 无（相关开放问题：Q-002）

#### System Review

* 无（相关开放问题：Q-001）

#### Test Review

* TD-002

#### Design Spec References

* 第 6 节 验收标准 AC5
* 第 4.1 节 SKILL.md frontmatter 双端元数据

### Consolidation Decision

KEPT_SEPARATE

#### Decision Rationale

单源发现（Test），独立可操作。Product/System 的相关关注为开放问题而非发现，不合并，但作为相关未决问题在视角评估中保留。

### Severity Change Rationale

No severity change from source findings.（TD-002 为 P2，保持 P2。Hermes 端验证深度不足导致双端支持声明与验证强度不匹配，但 Hermes 平台机制未知（MEDIUM 置信度），且当前可验证"安装到位"，未达 P1。）

---

# Unmerged Source Findings

无未合并源发现。所有 9 条源发现均作为某条 Consolidated Finding 的来源被保留。

---

# Duplicate and Superseded Findings

无单独的重复/取代发现。PR-003 与 SC-002 为互相重复的发现，已合并为 CR-003 并保留双视角作为来源（非"取代"——两者均作为 CR-003 的 Source Findings 保留可追溯性）。

---

# Cross-Reviewer Conflicts

无跨审查员实质冲突。三审查员结论互补或重复，无对立。PR-003 与 SC-002 仅有 likelihood 表述差异（PR-003 未给、SC-002 给 LOW），不构成实质冲突。

---

# Coverage Gaps

No coverage gaps — all three source reviews are available.

三份源审查（Product / System / Test）均 AVAILABLE，无 MISSING，无覆盖缺口。

---

# Coverage Matrix

| Consolidated Finding | Product | System | Test | Primary Risk Area |
| --- | --- | --- | --- | --- |
| CR-001 | — | — | TD-001 | 验收标准内部矛盾 |
| CR-002 | PR-001 | — | — | 平台声明与安装覆盖 |
| CR-003 | PR-003 | SC-002 | — | 隐式调用防护降级 |
| CR-004 | PR-002 | — | — | install.sh 原子性/部分失败 |
| CR-005 | — | SC-003 | — | install.sh 内容完整性 |
| CR-006 | — | SC-001 | — | 行号假设脆弱性 |
| CR-007 | — | — | TD-003 | 行号验证流程可靠性 |
| CR-008 | — | — | TD-002 | 双端触发验证不对称 |

`—` 表示该审查员未识别对应发现。某审查员未识别某发现不证明该风险不存在。

---

# Review Coverage Summary

| Review Dimension | Product | System | Test | Consolidated Findings |
| --- | --- | --- | --- | --- |
| 验收标准完整性 | REVIEWED | — | REVIEWED | CR-001, CR-006, CR-007, CR-008 |
| 平台覆盖与一致性 | REVIEWED | — | REVIEWED | CR-002, CR-008 |
| 安装机制健壮性 | REVIEWED | REVIEWED | — | CR-004, CR-005 |
| 隐式调用防护 | REVIEWED | REVIEWED | — | CR-003 |
| 文档证据完整性 | — | REVIEWED | REVIEWED | CR-006, CR-007 |
| 双端行为一致性 | REVIEWED(Q) | REVIEWED(Q) | REVIEWED | CR-008 |
| 不可逆决策 | — | REVIEWED | — | （ID-001，见合并说明） |
| 数据完整性 | — | REVIEWED | REVIEWED | CR-001, CR-006 |
| 可诊断性 | — | REVIEWED | REVIEWED | CR-005, CR-007 |

`REVIEWED(Q)` 表示以开放问题形式触及但未形成独立发现。

**合并说明 — 不可逆决策 ID-001（参考）**：System Critic 在其审查中单独记录了一项不可逆决策 ID-001（GitHub 私有仓库创建与首次推送），含 `.gitignore` 生效验证、仓库名冲突处理、commit 历史不可变等建议。该决策非 Finding（无 SC-ID），不计入 9 条源发现，但作为合并上下文保留：其建议（git add 前验证 .gitignore 生效、推送前 `gh repo view` 检查同名仓库、commit message 不含个人路径）与 Predisposition 4（一次性决策与外部发布张力）相关，建议 spec 负责人在决策时一并参考。

---

# Superpowers Instructions

## What to Read

- **Consolidated Review**: 本文档
- **Source Reviews**: 见上方 Source Reviews 表的文件路径（product-review.md / system-review.md / test-review.md）

## What to Decide

对 Decision Queue 中每条 Consolidated Finding 设定决策：

| CR-ID | Title | Severity | Decision (choose one) |
| --- | --- | --- | --- |
| CR-001 | README.md 旧名引用与 grep "零残留" 验收标准互斥矛盾 | P1 | ___ |
| CR-002 | platforms 声明含 Windows 但安装机制仅 Unix | P1 | ___ |
| CR-003 | 删除 agents/openai.yaml 致隐式调用防护降级 | P2 | ___ |
| CR-004 | install.sh 非原子，部分失败双端不一致无恢复指引 | P2 | ___ |
| CR-005 | install.sh 建链前不验证目标内容完整性 | P2 | ___ |
| CR-006 | acceptance 行号证据依赖 +5 单一假设，脆弱验证链 | P2 | ___ |
| CR-007 | 行号验证与修正合并，缺独立确认机制 | P2 | ___ |
| CR-008 | Hermes 与 Claude Code 触发验证标准不对称 | P2 | ___ |

**Decision options**: PENDING_DECISION, ACCEPTED, REJECTED, DEFERRED, PARTIALLY_ACCEPTED, DUPLICATE, INVALIDATED

## Decision Template

对每条发现，在下方 Decision Records 章节复制并填写：

```markdown
## DR-<NNN> — CR-<NNN>

### Decision Status

PENDING_DECISION / ACCEPTED / REJECTED / DEFERRED / PARTIALLY_ACCEPTED / DUPLICATE / INVALIDATED

### Decision Owner

<your name or role>

### Decision Rationale

<为何如此决策——须回应发现的有效性、实质性、证据>

### Required Action

<若 ACCEPTED：Design Spec 需如何变更>

### Decision Date

<YYYY-MM-DD>
```

## Hard Rules

1. 状态为 PENDING_DECISION 的发现，最终审查状态不得为 APPROVED。
2. 所有 P0 发现在最终审查状态可为 BLOCKED 之外任何值前必须已决（非 PENDING_DECISION）。本次无 P0。
3. 每条决策必须有 Decision Owner、Rationale、Date。

## Final Review State

所有决策记录后，按下表确定最终审查状态：

| Condition | State |
| --- | --- |
| Any unresolved P0 finding | BLOCKED |
| Accepted P1/P2 changes outstanding | CHANGES_REQUIRED |
| No blocking finding, conditions remain | CONDITIONAL_APPROVAL |
| All required changes incorporated | APPROVED |
| Review records incomplete | INCOMPLETE |

最终审查状态写入下方 Consolidation Conclusion 章节末尾。

---

# Decision Queue

本节含需 spec 负责人或 Superpowers 流程做最终决策的发现。所有 8 条 Consolidated Finding 当前均为 PENDING_DECISION。

## DQ-001 — CR-001

### Problem

README.md 旧名引用要求（第 4.5 节）与 grep "零残留"验收标准（AC1）字面互斥，无法同时满足。

### Severity

P1

### Evidence Summary

第 4.5 节要求 README 含 `yy-grill-me`；AC1 grep 排除列表不含 README，必然命中。

### Recommended Resolution

明确"零残留"= "零功能性残留"，AC1 grep 显式排除 README 并定义允许列表，或 README 改用不含旧名表述。

### Decision Required

spec 负责人选择哪套解法，并明确"刻意保留"vs"遗漏残留"的判别规则。

### Decision Status

PENDING

---

## DQ-002 — CR-002

### Problem

frontmatter `platforms` 含 Windows，但 install.sh（bash + ln -s）与 deploy.md 仅 Unix，无 Windows 安装路径。

### Severity

P1

### Evidence Summary

第 4.1 节 `platforms: [macos, linux, windows]` vs 第 4.5 节 bash/ln -s install.sh + Unix 风格 deploy.md。

### Recommended Resolution

收缩 platforms 为 [macos, linux] 并补 Windows 说明（方案 A），或保留 Windows 并补 deploy.md Windows 安装章节（方案 B）。

### Decision Required

spec 负责人选择收缩声明还是补齐 Windows 安装路径。

### Decision Status

PENDING

---

## DQ-003 — CR-003

### Problem

删除 agents/openai.yaml 使 `allow_implicit_invocation: false` 机器策略降级为 SKILL.md 正文自然语言指令，OpenAI 兼容平台可能失去隐式调用机器级防护。

### Severity

P2

### Evidence Summary

第 4.3 节删除理由称正文铁律替代机器策略，但两者防护层级不等价；当前双端不依赖此文件，风险仅在未来第三平台激活。

### Recommended Resolution

spec 第 4.3 节增前提确认（双端不依赖此文件），或 frontmatter 增平台无关 `implicit_invocation: false`，或至少 description 首句保留"仅允许显式触发"。

### Decision Required

是否接受此为有意识权衡并记录前提，或补机器可读字段，或保留 agents/openai.yaml。

### Decision Status

PENDING

---

## DQ-004 — CR-004

### Problem

install.sh 两次 link 非原子，部分失败（Claude 成功/Hermes 失败）后双端不一致，错误处理表未覆盖，无恢复指引。

### Severity

P2

### Evidence Summary

第 4.5 节 set -e + 两次顺序 link；第 5 节 6 场景未含部分安装不一致。

### Recommended Resolution

install.sh 错误输出增部分安装提示，或 deploy.md 增故障排除章节，或 link 失败时主动回滚。

### Decision Required

是否补恢复指引（文档化或脚本回滚）。

### Decision Status

PENDING

---

## DQ-005 — CR-005

### Problem

install.sh 建链前不验证源目录内容完整性，开发过渡窗口中调用会暴露内容不一致的技能。

### Severity

P2

### Evidence Summary

第 4.5 节脚本仅验证 symlink 存在性，不验证目标内容；第 5 节无"源目录内容不完整"场景。

### Recommended Resolution

install.sh 增最小化内容完整性检查（SKILL.md 存在 + frontmatter name 与 NAME 变量一致）。

### Decision Required

是否补内容完整性预检查。

### Decision Status

PENDING

---

## DQ-006 — CR-006

### Problem

acceptance 15 个行号证据全依赖 frontmatter "+5 行"单一假设，无自动化校验，形成脆弱验证链。

### Severity

P2

### Evidence Summary

第 4.1 节"+5 行"假设；第 4.4 节 15 行映射表全基于此；第 7 节自认风险但仅人工核对。

### Recommended Resolution

acceptance.md 增内容锚点表 + 自动化比对脚本，锚点不匹配则验收 FAIL。

### Decision Required

是否引入自动化锚点校验机制。

### Decision Status

PENDING

---

## DQ-007 — CR-007

### Problem

行号对齐的验证与修正合并为同一步骤，验证者即修正者，无独立复核/差异记录，错误可能被"修正"而非"发现"。

### Severity

P2

### Evidence Summary

AC2"逐条比对全部一致" + 第 7 节"任何不一致就地修正"，无独立确认环节。

### Recommended Resolution

比对先产出差异清单再修正，修正后 diff 纳入验收证据供独立复核，考虑自动化行号提取脚本补充验证。

### Decision Required

是否引入差异清单 + 独立复核/diff 记录流程。

### Decision Status

PENDING

---

## DQ-008 — CR-008

### Problem

AC5 对 Claude Code 验证实际触发，对 Hermes 仅验证列出，双端触发验证深度不对称。

### Severity

P2

### Evidence Summary

AC5 原文两平台验证标准不对等；`hermes skills` 列出不证明可加载/可触发。

### Recommended Resolution

AC5 拆分为 AC5a（Claude Code 实际触发）+ AC5b（Hermes 安装到位 + 若支持则实际触发，否则显式记录限制），并澄清 Hermes 触发机制。

### Decision Required

是否拆分 AC5 并明确 Hermes 验证深度，或显式记录限制。

### Decision Status

PENDING

---

# Decision Records

本节在 spec 负责人或 Superpowers 流程做出决策后更新。每条 Consolidated Finding 最终都应有决策记录，除非仍为 PENDING_DECISION。

## DR-001 — CR-001

- **Decision Status**: ACCEPTED
- **Decision Owner**: spec 负责人（用户决策）
- **Decision Rationale**: 矛盾真实有效——spec 第 4.5 节要求 README 含「前身为 yy-grill-me」与 AC1 grep 零残留（排除列表不含 README）字面互斥，已对照 spec 原文确认。采纳方案2：README 不含字面 yy-grill-me，旧名溯源由首次 commit message 承载（commit message 在 .git/，被 AC1 grep 排除，不违反零残留），AC1 grep 零残留保持不变。与用户「彻底改名+零残留」意图自洽。
- **Required Action**: spec 第 4.5 节 README.md 描述改为不含旧名；AC1 不变。**已落地**。
- **Decision Date**: 2026-08-07

## DR-002 — CR-002

- **Decision Status**: ACCEPTED
- **Decision Owner**: spec 负责人（用户决策）
- **Decision Rationale**: 平台覆盖矛盾表面成立，但**验证推翻前提**：Hermes 生态惯例（airtable、goal-manager frontmatter 均为 `platforms: [linux, macos, windows]` + `metadata.hermes`，goal-manager 已装到 `~/.hermes/skills/productivity/`）证明 `platforms` 表「技能内容/逻辑支持平台」而非「安装脚本平台」；安装是部署层（symlink 平台特定）。审核员未看到此惯例（Predisposition 2 已预警）。采纳方案B：保留 `platforms: [macos, linux, windows]`，deploy.md 补 Windows 手动安装说明（PowerShell `New-Item -ItemType SymbolicLink` 或手动复制）。
- **Required Action**: spec 第 4.1 节 platforms 说明补 Hermes 惯例注；第 4.5 节 deploy.md 补 Windows 说明。**已落地**。
- **Decision Date**: 2026-08-07

## DR-003 — CR-003

- **Decision Status**: PARTIALLY_ACCEPTED
- **Decision Owner**: spec 负责人（用户 + Claude 决策）
- **Decision Rationale**: 有效性确认——删除 openai.yaml 确使机器策略降为自然语言。但前提 UNKNOWN 已消除：验证 goal-manager 无 agents 目录、且已装到 Hermes productivity，证明 Claude Code 与 Hermes 均不依赖 agents/openai.yaml。**采纳**：spec 第 4.3 节增前提确认（双端不依赖此文件，三重保障覆盖：frontmatter metadata.hermes + description 首句「仅显式触发」+ 正文铁律）。**拒绝**：frontmatter 增非标准 `implicit_invocation: false`——Hermes 是否识别未知（airtable/goal-manager frontmatter 均无此字段），与「删 openai.yaml 改用 frontmatter」既定决策相悖。未来引入第三 OpenAI 兼容平台时再重建 agents/ 结构。
- **Required Action**: spec 第 4.3 节增前提 + 拒绝项说明。**已落地**。
- **Decision Date**: 2026-08-07

## DR-004 — CR-004

- **Decision Status**: ACCEPTED
- **Decision Owner**: spec 负责人（Claude 决策）
- **Decision Rationale**: 有效性确认——install.sh `set -e` + 两次顺序 link，部分失败（一端成功一端失败）场景真实，错误处理表未覆盖。采纳：install.sh 改为两次 link 尽量完成（`link ... && ok=1 || true`）+ 部分失败输出两端状态 + 恢复指引（`--uninstall` 清理重试）；错误处理表增「部分安装不一致」行；deploy.md 增故障排除章节。
- **Required Action**: spec 第 4.5 节 install.sh 代码块 + bullet、第 5 节错误处理表、deploy.md。**已落地**。
- **Decision Date**: 2026-08-07

## DR-005 — CR-005

- **Decision Status**: ACCEPTED
- **Decision Owner**: spec 负责人（Claude 决策）
- **Decision Rationale**: 有效性确认——install.sh 仅验 symlink 存在性不验目标内容，开发过渡窗口（内容未完成改名时建链）风险真实。采纳：install.sh 增 `verify_source` 函数（`$SRC/SKILL.md` 存在 + frontmatter `name` == 脚本 `NAME` 变量），建链前运行，失败非零退出；错误处理表增「源目录内容不完整」行。开销极低（读一个 frontmatter 字段）。
- **Required Action**: spec 第 4.5 节 install.sh + bullet、第 5 节。**已落地**。
- **Decision Date**: 2026-08-07

## DR-006 — CR-006

- **Decision Status**: ACCEPTED
- **Decision Owner**: spec 负责人（Claude 决策）
- **Decision Rationale**: 有效性确认——acceptance.md 15 个行号证据全依赖「+5 行」单一假设，spec 第 7 节已自认但仅人工核对，脆弱。采纳：acceptance.md 每个行号引用旁附内容锚点（对应 SKILL.md 行首文本片段）；新增 `scripts/check-acceptance-anchors.sh` 自动比对，锚点不匹配 FAIL + 产出差异清单；AC2 改为锚点校验。消除单一假设脆弱性。
- **Required Action**: spec 第 4.4 节锚点流程、第 4.5 节脚本设计、第 6 节 AC2。**已落地**。
- **Decision Date**: 2026-08-07

## DR-007 — CR-007

- **Decision Status**: ACCEPTED
- **Decision Owner**: spec 负责人（Claude 决策）
- **Decision Rationale**: 有效性确认——AC2「逐条比对全部一致」+ 第 7 节「任何不一致就地修正」将验证与修正合并，验证者即修正者，错误可能被「修正」而非「发现」。采纳：验证先产出差异清单（预期/实际/差异/摘要）再修正 + 修正后 acceptance.md git diff 纳入验收证据供独立复核。与 CR-006 锚点脚本协同（脚本产出差异清单）。
- **Required Action**: spec 第 4.4 节流程、第 6 节 AC2。**已落地**。
- **Decision Date**: 2026-08-07

## DR-008 — CR-008

- **Decision Status**: ACCEPTED
- **Decision Owner**: spec 负责人（Claude 决策）
- **Decision Rationale**: 有效性确认——AC5 对 Claude Code 验实际触发、对 Hermes 仅验列出，双端验证深度不对称。`hermes skills` 列出不证明可加载/可触发。采纳：AC5 拆 AC5a（Claude Code `/deep-discussion` 可启动拷问）+ AC5b（Hermes `hermes skills` 列出 deep-discussion）；Hermes 端实际触发验证显式注明为部署后验证（超 spec 范围）。回应 TD Q-002 / PR Q-002。
- **Required Action**: spec 第 6 节 AC5、第 8 节非目标。**已落地**。
- **Decision Date**: 2026-08-07

---

## 开放问题澄清

- **PR Q-001**（install.sh 硬编码路径兼容）：不适用——install.sh 已用 `$(dirname "${BASH_SOURCE[0]}")/..` 自动解析源路径，无硬编码个人路径。
- **PR Q-002 / TD Q-002**（双端行为一致性 / Hermes 触发验证是否在范围）：本次 spec 范围只验 Hermes 安装到位 + 列出（AC5b），实际触发为部署后验证（超 spec 范围），AC5b 显式记录此限制。
- **SC Q-001**（Hermes 触发机制是否区分隐式/显式）：未实际访问 Hermes 内部机制，但已确认双端不依赖 openai.yaml（goal-manager 证据）；隐式防护靠 description「仅显式触发」+ 正文铁律。Hermes 隐式/显式机制细节不在本次范围。
- **SC Q-002**（其他工具/脚本是否引用旧名 yy-grill-me）：本次范围限本仓库；外部引用（其他项目依赖旧路径）由用户自查，git 推送后旧目录改名若有外部 symlink 指向旧路径需用户手动更新。
- **TD Q-001**（README 旧名引用允许范围）：由 DR-001 定——README 不含字面 yy-grill-me，无「允许列表」，AC1 零残留全仓适用。

---

## Final Review State（决策后更新）

**APPROVED**（审核层面）

依据：

- 所有 8 条 Consolidated Finding 已决策记录（DR-001 至 DR-008），无 PENDING_DECISION。
- 无 P0 发现。
- 2 条 P1（CR-001、CR-002）ACCEPTED 且变更已落地 spec。
- 6 条 P2 中：CR-003 PARTIALLY_ACCEPTED（采纳前提确认，拒绝非标准字段，理由充分）；CR-004/005/006/007/008 ACCEPTED 且变更已落地 spec。
- 所有必需变更已纳入 Design Spec（第 4.3/4.4/4.5 节、第 5 节、第 6 节、第 7 节、第 8 节）。

注：此为审核层面 APPROVED。Design Spec 仍需经用户最终审查（brainstorming 流程 user review gate）后方可转入 writing-plans。

---

# Finding Lifecycle

每条 Consolidated Finding 的生命周期：

```text
PENDING_DECISION
  ↓
ACCEPTED / REJECTED / DEFERRED / PARTIALLY_ACCEPTED / DUPLICATE / INVALIDATED
```

发现不会因被拒绝、延迟、认为不必要、或在后续修订中修复而从审查中消失。其历史必须保留供未来分析。

---

# Review Statistics

## Finding Counts

### By Source Review

* Product Findings: 3（PR-001, PR-002, PR-003）
* System Findings: 3（SC-001, SC-002, SC-003）
* Test Findings: 3（TD-001, TD-002, TD-003）
* **Total Source Findings: 9**

### After Consolidation

* Consolidated Findings: 8
* Unmerged Findings: 0
* Duplicate Findings: 0（PR-003 与 SC-002 合并为 CR-003，双视角保留，非"取代"）
* Superseded Findings: 0
* Cross-Reviewer Conflicts: 0

### By Severity

* P0: 0
* P1: 2（CR-001, CR-002）
* P2: 6（CR-003, CR-004, CR-005, CR-006, CR-007, CR-008）

### By Status

* PENDING_DECISION: 8
* ACCEPTED: 0
* REJECTED: 0
* DEFERRED: 0
* PARTIALLY_ACCEPTED: 0
* DUPLICATE: 0
* INVALIDATED: 0

### Source Finding Integrity Check

```
Total Source Findings = 9
  = Consolidated Finding source references (CR-001:1 + CR-002:1 + CR-003:2 + CR-004:1 + CR-005:1 + CR-006:1 + CR-007:1 + CR-008:1 = 9)
  + Unmerged Finding count (0)
  + Duplicate/Represented Elsewhere count (0)
= 9 ✅ PASS
```

无发现被静默丢弃。

---

# Consolidation Conclusion

### Consolidation Result

COMPLETED

### Decision Readiness

PENDING_DECISION

### Summary

三份源审查（Product / System / Test）已成功合并为 8 条 Consolidated Finding。无跨审查员实质冲突，无 MISSING 审查，Source Finding Integrity Check 通过（9 源发现 = 9 合并引用）。

合并要点：

* PR-003 与 SC-002 为同一底层问题（删除 agents/openai.yaml 致隐式调用防护降级）的双视角重复发现，合并为 CR-003，保留 Product + System 双视角。
* PR-002（install 原子性）与 SC-003（install 内容完整性）同属 install.sh 健壮性但根不同，保留独立（CR-004 / CR-005），RELATED。
* SC-001（行号假设脆弱）与 TD-003（行号流程可靠性）同属 acceptance 行号对齐但根不同，保留独立（CR-006 / CR-007），RELATED。
* TD-001（README 与 grep 互斥）为 Test 独有发现，按"不压制少数发现"原则保留为 CR-001（P1）。
* 两条 P1 发现（CR-001 spec 内部验收矛盾、CR-002 平台声明与安装覆盖矛盾）应在实现前解决。

合并者未对任何发现做最终接受/拒绝决策。所有 8 条发现当前 PENDING_DECISION，等待 spec 负责人按 Decision Queue 逐条决策。

未决主题（开放问题，非发现）：PR Q-001（install.sh 硬编码路径约定变更兼容策略）、PR Q-002（双端行为一致性是否纳入验收）、SC Q-001（Hermes 触发机制是否区分隐式/显式）、SC Q-002（其他工具/脚本是否引用旧技能名）、TD Q-001（README 旧名引用允许范围）、TD Q-002（Hermes 触发验证是否在范围内）。建议 spec 负责人在决策时一并澄清。

### Final Review State

CHANGES_REQUIRED（provisional，pending decisions）

依据：

* 非 INCOMPLETE——三份审查均 AVAILABLE，Source Finding Integrity Check 通过。
* 非 BLOCKED——无 P0 发现。
* 非 APPROVED——存在 PENDING_DECISION 发现（硬规则：PENDING_DECISION 不得为 APPROVED）。
* 存在 2 条 P1 发现（CR-001、CR-002），按 P1 定义"应在实现前解决"，当前 PENDING_DECISION。spec 在此两条解决前不宜进入实现。

此状态为合并阶段产出的临时状态。最终审查状态将在 spec 负责人对全部发现记录决策后，按 Superpowers Instructions 的 Final Review State 规则最终确定：若任何 P1 被接受且变更未落地则 CHANGES_REQUIRED；若无阻塞发现且仅余条件则 CONDITIONAL_APPROVAL；若所有必需变更已落地则 APPROVED。

合并者不声明 Design Spec 被批准或拒绝。批准、拒绝、修改或延迟由 spec 负责人或 Superpowers 流程决定。

---

# Machine-Readable Consolidation Index

```yaml
review:
  review_id: "2026-08-07-R1-CONSOLIDATED"
  review_type: "CONSOLIDATED_REVIEW"
  status: "COMPLETED"
  design_spec: "docs/superpowers/specs/2026-08-07-deep-discussion-rename-and-publish-design.md"
  round: 1
  spec_stem: "deep-discussion-rename-and-publish-design"
  final_review_state: "CHANGES_REQUIRED"

source_reviews:
  - reviewer: "yy-product-reviewer"
    review_type: "PRODUCT_REVIEW"
    review_id: "2026-08-07-R1-PR"
    source_file: "2026-08-07-review-001/product-review.md"
    status: "AVAILABLE"
  - reviewer: "yy-system-critic"
    review_type: "SYSTEM_REVIEW"
    review_id: "2026-08-07-R1-SC"
    source_file: "2026-08-07-review-001/system-review.md"
    status: "AVAILABLE"
  - reviewer: "yy-test-designer"
    review_type: "TEST_REVIEW"
    review_id: "2026-08-07-R1-TD"
    source_file: "2026-08-07-review-001/test-review.md"
    status: "AVAILABLE"

consolidated_findings:
  - id: "CR-001"
    title: "README.md 旧名引用与 grep 零残留验收标准互斥矛盾"
    severity: "P1"
    confidence: "HIGH"
    status: "PENDING_DECISION"
    source_findings:
      product: []
      system: []
      test: ["TD-001"]
    finding_type: "UNTESTABLE_REQUIREMENT"
    relationship_classification: "INDEPENDENT"
    conflict_status: "NO_CONFLICT"
    source_references:
      - "Design Spec 第 4.5 节 README.md"
      - "Design Spec 第 6 节 AC1"
      - "Design Spec 第 1 节 成功标准"
    processing_status: "PENDING_DECISION"
    severity_escalation: false
    severity_change_rationale: null
  - id: "CR-002"
    title: "platforms 声明含 Windows 但安装机制仅 Unix"
    severity: "P1"
    confidence: "HIGH"
    status: "PENDING_DECISION"
    source_findings:
      product: ["PR-001"]
      system: []
      test: []
    finding_type: "N/A"
    relationship_classification: "INDEPENDENT"
    conflict_status: "NO_CONFLICT"
    source_references:
      - "Design Spec 第 4.1 节 frontmatter platforms"
      - "Design Spec 第 4.5 节 install.sh 与 deploy.md"
    processing_status: "PENDING_DECISION"
    severity_escalation: false
    severity_change_rationale: null
  - id: "CR-003"
    title: "删除 agents/openai.yaml 致隐式调用防护从机器策略降级为自然语言"
    severity: "P2"
    confidence: "MEDIUM"
    status: "PENDING_DECISION"
    source_findings:
      product: ["PR-003"]
      system: ["SC-002"]
      test: []
    finding_type: "N/A"
    relationship_classification: "DUPLICATE"
    conflict_status: "NO_CONFLICT"
    source_references:
      - "Design Spec 第 4.3 节 删除 agents/"
      - "Design Spec 第 4.1 节 SKILL.md frontmatter/铁律"
      - "现有文件 agents/openai.yaml"
    processing_status: "PENDING_DECISION"
    severity_escalation: false
    severity_change_rationale: null
  - id: "CR-004"
    title: "install.sh 两次 link 非原子，部分失败后双端不一致且无恢复指引"
    severity: "P2"
    confidence: "MEDIUM"
    status: "PENDING_DECISION"
    source_findings:
      product: ["PR-002"]
      system: []
      test: []
    finding_type: "N/A"
    relationship_classification: "INDEPENDENT"
    conflict_status: "NO_CONFLICT"
    source_references:
      - "Design Spec 第 4.5 节 install.sh"
      - "Design Spec 第 5 节 错误处理表"
    processing_status: "PENDING_DECISION"
    severity_escalation: false
    severity_change_rationale: null
  - id: "CR-005"
    title: "install.sh 建链前不验证目标目录内容完整性"
    severity: "P2"
    confidence: "MEDIUM"
    status: "PENDING_DECISION"
    source_findings:
      product: []
      system: ["SC-003"]
      test: []
    finding_type: "N/A"
    relationship_classification: "INDEPENDENT"
    conflict_status: "NO_CONFLICT"
    source_references:
      - "Design Spec 第 4.5 节 install.sh"
      - "Design Spec 第 5 节 错误处理表"
      - "Design Spec 第 9 节 执行顺序"
    processing_status: "PENDING_DECISION"
    severity_escalation: false
    severity_change_rationale: null
  - id: "CR-006"
    title: "acceptance 行号证据依赖 frontmatter +5 单一假设，脆弱验证链"
    severity: "P2"
    confidence: "HIGH"
    status: "PENDING_DECISION"
    source_findings:
      product: []
      system: ["SC-001"]
      test: []
    finding_type: "N/A"
    relationship_classification: "INDEPENDENT"
    conflict_status: "NO_CONFLICT"
    source_references:
      - "Design Spec 第 4.1 节 frontmatter 改动"
      - "Design Spec 第 4.4 节 行号同步"
      - "Design Spec 第 7 节 风险"
    processing_status: "PENDING_DECISION"
    severity_escalation: false
    severity_change_rationale: null
  - id: "CR-007"
    title: "行号对齐验证与修正合并为同一步骤，缺乏独立确认机制"
    severity: "P2"
    confidence: "MEDIUM"
    status: "PENDING_DECISION"
    source_findings:
      product: []
      system: []
      test: ["TD-003"]
    finding_type: "BLIND_SPOT"
    relationship_classification: "INDEPENDENT"
    conflict_status: "NO_CONFLICT"
    source_references:
      - "Design Spec 第 4.4 节 行号同步"
      - "Design Spec 第 6 节 AC2"
      - "Design Spec 第 7 节 风险"
    processing_status: "PENDING_DECISION"
    severity_escalation: false
    severity_change_rationale: null
  - id: "CR-008"
    title: "Hermes 与 Claude Code 触发验证标准不对称"
    severity: "P2"
    confidence: "MEDIUM"
    status: "PENDING_DECISION"
    source_findings:
      product: []
      system: []
      test: ["TD-002"]
    finding_type: "UNTESTABLE_REQUIREMENT"
    relationship_classification: "INDEPENDENT"
    conflict_status: "NO_CONFLICT"
    source_references:
      - "Design Spec 第 6 节 AC5"
      - "Design Spec 第 4.1 节 frontmatter 双端元数据"
    processing_status: "PENDING_DECISION"
    severity_escalation: false
    severity_change_rationale: null

unmerged_findings: []

duplicate_or_represented: []

conflicts: []

decision_queue:
  - id: "DQ-001"
    finding_id: "CR-001"
    severity: "P1"
    processing_status: "PENDING_DECISION"
  - id: "DQ-002"
    finding_id: "CR-002"
    severity: "P1"
    processing_status: "PENDING_DECISION"
  - id: "DQ-003"
    finding_id: "CR-003"
    severity: "P2"
    processing_status: "PENDING_DECISION"
  - id: "DQ-004"
    finding_id: "CR-004"
    severity: "P2"
    processing_status: "PENDING_DECISION"
  - id: "DQ-005"
    finding_id: "CR-005"
    severity: "P2"
    processing_status: "PENDING_DECISION"
  - id: "DQ-006"
    finding_id: "CR-006"
    severity: "P2"
    processing_status: "PENDING_DECISION"
  - id: "DQ-007"
    finding_id: "CR-007"
    severity: "P2"
    processing_status: "PENDING_DECISION"
  - id: "DQ-008"
    finding_id: "CR-008"
    severity: "P2"
    processing_status: "PENDING_DECISION"

decisions: []

statistics:
  source_findings:
    product: 3
    system: 3
    test: 3
    total: 9
  consolidated_findings: 8
  unmerged_findings: 0
  duplicate_findings: 0
  represented_elsewhere_findings: 0
  conflicts: 0
  p0: 0
  p1: 2
  p2: 6
  integrity_check: "PASS (9 = 9 + 0 + 0)"
```

---

# Template Completion Rules

本合并审查遵循：每个源审查已记录于 Source Reviews；每个源发现已有处置（作为某 CR 来源保留）；无源发现静默消失；CR-ID 唯一顺序；每条 CR 代表一个底层问题；不因组件/关键词/严重度/后果相似而合并；独立视角已保留；无跨审查员冲突需消解；确认证据/推断/未知已分离；未将假设升级为事实；严重度按底层问题实质性评定（无升降级）；最强证据已保留；Decision Queue 含全部待决发现；合并者未做最终接受/拒绝决策；Machine-Readable 索引与详细审查一致；统计与实际发现/处置一致；最终输出可直接用于 Decision Protocol；可追溯性足以回答"谁发现/原始发现/为何合并/证据/是否冲突/决策/决策者/事后变更/是否验证"。

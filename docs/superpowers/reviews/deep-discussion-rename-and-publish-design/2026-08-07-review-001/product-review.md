# Product Review

## 输出语言

本审核的所有描述性内容必须使用中文撰写，包括但不限于：

- Finding 标题
- The Gap 等问题描述
- Trigger Scenario 中的场景描述
- Consequence 中的影响分析
- Recommendation 中的建议
- Evidence 中的证据描述
- Assumptions 中的假设说明
- Review Scope、Review Limitations、Reviewer Conclusion 等章节内容
- Unresolved Product Questions 等章节内容

以下内容保持英文：

- Finding ID（PR-001, PR-002 等）
- 所有大写下划线格式的标识符和枚举值，包括但不限于：
  - 严重等级：P0, P1, P2
  - 证据等级：CONFIRMED_DEFECT, MATERIAL_RISK
  - 置信度：HIGH, MEDIUM, LOW
  - 审核结果：REQUIRES_REVIEW
  - 审核状态：COMPLETED
  - 表格状态：REVIEWED, NOT_APPLICABLE
- Machine-Readable YAML 索引的 key 和枚举值
- 技术标识符和文件路径

Machine-Readable YAML 索引中的 title 等描述性字段使用中文。

## Review Metadata

### Review ID

2026-08-07-R1-PR

### Reviewer

yy-product-reviewer

### Review Type

PRODUCT_REVIEW

### Design Spec

docs/superpowers/specs/2026-08-07-deep-discussion-rename-and-publish-design.md

### Review Date

2026-08-07

### Review Status

COMPLETED

---

## Review Scope

This review evaluates the Design Spec from a product
correctness, business-rule completeness, user-behavior, workflow integrity,
and operational usability perspective.

This review does not evaluate:

* implementation quality;
* source code quality;
* detailed system architecture;
* technology selection;
* infrastructure design;
* performance optimization;
* test implementation details.

The purpose of this review is to identify product-level requirements that are
ambiguous, incomplete, contradictory, unsafe, or insufficiently defined for
implementation.

---

## Design Spec Completeness Checklist

| 维度 | 状态 | 说明 |
| --- | --- | --- |
| 问题定义（Problem Definition） | PRESENT | 第1节明确四项目标：改名、发布、双端、安装 |
| 期望结果（Desired Outcome） | PRESENT | 第1节列出五项成功标准 |
| 业务规则（Business Rules） | PARTIALLY_PRESENT | 安装幂等规则已定义（同源跳过/异源报错）；缺少更新/迁移场景的业务规则 |
| 工作流（Workflows） | PRESENT | 第4.6节定义推送流程；第5节定义错误处理 |
| 状态与转换（States and Transitions） | NOT_APPLICABLE | 本 spec 为改名与发布类操作，无可建模状态机实体 |
| 边界条件（Boundary Conditions） | PARTIALLY_PRESENT | 第5节错误处理表覆盖6个场景；第7节覆盖5个风险。缺少：双端部分安装失败后的一致性问题 |
| 数据生命周期（Data Lifecycle） | PARTIALLY_PRESENT | 旧 symlink 清理已在第7节声明；缺少：旧名 `yy-grill-me` 的 git 历史处理、install.sh 创建的资源（symlink）的长生命周期管理 |
| 假设声明（Assumption Declarations） | PRESENT | 第7节列出5项风险/假设；第8节列出非目标边界 |

---

## Findings

### PR-001 — `platforms` 声明包含 Windows，但安装机制仅支持 Unix

#### Severity

P1

#### Evidence Class

CONFIRMED_DEFECT

#### Confidence

HIGH

#### Location

Design Spec 第4.1节 SKILL.md frontmatter 声明；第4.5节 install.sh 脚本内容；第4.5节 deploy.md 内容描述

#### The Gap

Design Spec 在 SKILL.md frontmatter 中声明 `platforms: [macos, linux, windows]`，明确将 Windows 列为支持的平台。但该 spec 提供的唯一安装机制（`scripts/install.sh`）使用 bash 脚本与 `ln -s` 符号链接命令，这两个机制在 Windows 原生环境下不可用。`docs/deploy.md` 被描述为包含「手动 `ln -s` 命令」，同样是 Unix 专属指令。

Spec 未提供任何 Windows 兼容的安装路径（PowerShell `New-Item -Type SymbolicLink`、`mklink`、手动复制等替代方案），也未在 `deploy.md` 中为 Windows 用户提供说明。

声明了平台支持，但未交付该平台上的完整用户旅程。

#### Trigger Scenario

1. 一名 Windows 用户通过 GitHub 私有仓库发现 `deep-discussion` 技能
2. 用户阅读 README.md 与 deploy.md，发现 SKILL.md frontmatter 声明 `platforms: [macos, linux, windows]`
3. 用户尝试按 deploy.md 的 `ln -s` 指令或运行 `install.sh` 进行安装
4. Windows 原生环境无法执行 bash 脚本或 `ln -s` 命令
5. 用户没有文档化的替代安装路径，无法完成安装

#### Consequence

- **用户影响**：Windows 用户无法按文档完成安装，产生困惑与被误导感
- **产品一致性**：`platforms` 声明与实际可用性之间存在显式矛盾，降低 frontmatter 元数据的可信度
- **业务影响**：由于该仓库为私有仓库且当前为单人使用，业务影响有限；但若未来扩大使用范围或对外开放，此矛盾将构成实质性的准入门槛

#### Recommendation

二选一：

**方案 A（推荐）**：从 `platforms` 声明中移除 `windows`，改为 `platforms: [macos, linux]`。同时在 README.md 或 deploy.md 中增加一句说明：「当前安装脚本仅支持 macOS/Linux；Windows 用户可手动将仓库目录复制到对应 skills 路径，或使用 PowerShell 创建符号链接」。

**方案 B**：保留 `platforms: [macos, linux, windows]`，并在 `docs/deploy.md` 中增加 Windows 安装章节，提供 PowerShell `New-Item -ItemType SymbolicLink` 等效命令或手动复制方案。

#### Evidence

1. Design Spec 第4.1节 frontmatter 声明：
   ```yaml
   platforms: [macos, linux, windows]
   ```

2. Design Spec 第4.5节 install.sh 使用 `ln -s` 和 bash shebang：
   ```bash
   #!/usr/bin/env bash
   ln -s "$target" "$link_path"
   ```

3. Design Spec 第4.5节对 deploy.md 的描述：「手动 `ln -s` 命令（goal-manager 风格）」

4. Spec 全文未出现任何 Windows 安装指令、PowerShell 命令、或 `mklink` 引用。

#### Assumptions

- CONFIRMED — `platforms: [macos, linux, windows]` 声明存在于 SKILL.md frontmatter 中
- CONFIRMED — install.sh 仅使用 bash 与 `ln -s`，不包含 Windows 兼容逻辑
- CONFIRMED — deploy.md 内容被描述为 Unix 命令风格
- INFERRED — Windows 用户无法直接执行 bash 脚本或 `ln -s` 命令（需 WSL 或 Git Bash，但 spec 未声明此前提）
- INFERRED — 此声明模式沿袭自 goal-manager，但继承了一个同样未解决的平台差距

#### Source References

- Design Spec 第4.1节「SKILL.md」— frontmatter 声明
- Design Spec 第4.5节「安装机制」— install.sh 脚本与 deploy.md 描述
- 现有代码 `SKILL.md` 第1-4行 — 当前 frontmatter（作对比基准）

---

### PR-002 — install.sh 两次 `link` 调用非原子操作，部分失败后双端安装状态不一致

#### Severity

P2

#### Evidence Class

MATERIAL_RISK

#### Confidence

MEDIUM

#### Location

Design Spec 第4.5节 install.sh 脚本；第5节错误处理表

#### The Gap

install.sh 按顺序执行两次 `link` 调用：

```bash
link "$SRC" "$CLAUDE_LINK"
link "$SRC" "$HERMES_LINK"
```

脚本设置了 `set -euo pipefail`，意味着任一 `link` 返回非零即终止。当第一次调用（Claude Code 端）成功创建 symlink，而第二次调用（Hermes 端）因「目标已存在且异源」返回 1 时，脚本终止并报错，但 Claude Code 端的 symlink 已写入文件系统，不会被自动清理。

此时系统进入一个未定义的部分安装状态：Claude Code 端已安装，Hermes 端未安装。Spec 第5节错误处理表未覆盖此场景，也未定义恢复操作。

`--uninstall` 参数可清理两处 symlink，但用户需要：（a）认识到当前处于部分安装状态；（b）知道需手动执行 `--uninstall` 进行清理。

#### Trigger Scenario

1. 用户此前已将 `deep-discussion` 以不同源路径安装到 Hermes（例如从另一个克隆目录）
2. 用户在新路径执行 `bash scripts/install.sh`
3. `link "$SRC" "$CLAUDE_LINK"` 成功：`~/.claude/skills/deep-discussion` → 新源路径
4. `link "$SRC" "$HERMES_LINK"` 检测到 `~/.hermes/skills/software-development/deep-discussion` 已存在且指向不同源，返回 1
5. 脚本因 `set -e` 终止，输出错误信息
6. 文件系统状态：Claude Code 端已指向新源，Hermes 端仍指向旧源
7. Spec 与文档未说明如何从此状态恢复

#### Consequence

- **操作影响**：用户在未觉察的情况下可能以为「安装失败 = 什么都没变」，实际 Claude Code 端已变更
- **一致性影响**：双端指向不同源路径时，同一技能在两端的实际行为可能不同（源文件版本不一致）
- **恢复成本**：用户需自行诊断状态并决定是手动 `rm` Claude 端的 symlink 还是手动修复 Hermes 端，均无文档指引
- **实际可能性**：此场景需 Hermes 端已存在异源 symlink 的前提，在当前单人使用场景下概率较低；但在多机或多克隆场景下真实存在

#### Recommendation

在不显著增加脚本复杂度的前提下，提供最小恢复指引：

1. 在 install.sh 的错误输出中增加提示：「部分安装：Claude Code 端已安装，Hermes 端失败。可执行 `bash scripts/install.sh --uninstall` 清理后重试。」
2. 或在 deploy.md 的故障排除章节中记录此场景与恢复步骤。

若希望提供更强的保证，可在 `link` 失败时增加主动回滚逻辑（失败时 `rm -f` 已创建的 link），但考虑到当前脚本的简洁性目标，文档化的恢复指引已足够。

#### Evidence

1. Design Spec 第4.5节 install.sh 脚本内容（两次 `link` 顺序调用）
2. Design Spec 第4.5节 `link()` 函数：异源时 `return 1`
3. Design Spec 第5节错误处理表覆盖 6 个场景：
   - symlink 目标已存在且异源 → 报错不覆盖
   - Hermes 目录不存在 → mkdir -p
   - gh 未登录 → 报错退出
   - 进程占用 → 提示关闭
   - acceptance 行号不一致 → 就地修正
   - 历史文档遗漏 → grep 兜底
   - **未覆盖**：部分安装成功后的不一致状态

#### Assumptions

- CONFIRMED — install.sh 使用 `set -euo pipefail`，`link` 返回非零即终止
- CONFIRMED — 两次 `link` 调用间无事务性保证
- CONFIRMED — 第5节错误处理表未列出此场景
- INFERRED — 用户在部分安装失败后可能不会主动执行 `--uninstall`

#### Source References

- Design Spec 第4.5节「安装机制」— install.sh 完整脚本
- Design Spec 第5节「错误处理」— 错误场景表

---

### PR-003 — 删除 `agents/openai.yaml` 后，隐式调用禁止策略从机器可读降级为仅人类可读文本

#### Severity

P2

#### Evidence Class

MATERIAL_RISK

#### Confidence

MEDIUM

#### Location

Design Spec 第4.3节「删除 agents/」；第4.1节 SKILL.md frontmatter

#### The Gap

Design Spec 第4.3节决定删除 `agents/openai.yaml` 文件及整个 `agents/` 目录。该文件当前内容为：

```yaml
interface:
  display_name: "Grill with Docs"
  short_description: "Grill a design and write its docs"
policy:
  allow_implicit_invocation: false
```

Spec 给出的删除理由是：

1. `allow_implicit_invocation: false` 语义「由 SKILL.md 正文「仅显式触发」铁律保证」
2. `display_name` 「由 frontmatter `name` + `description` 覆盖」

问题在于理由 1：SKILL.md 正文中的「仅显式触发」铁律是用中文自然语言表述的行为规范（面向 AI 模型消费），而 `agents/openai.yaml` 中的 `allow_implicit_invocation: false` 是机器可读的结构化策略字段（面向 agent 框架消费）。两者不在同一消费层级。

对于 OpenAI 兼容的 agent 框架（该文件的目标消费者），框架可能仅解析 `agents/openai.yaml` 的结构化字段来决定是否允许隐式调用，而不会解析 SKILL.md 的中文正文来推断此策略。删除此文件后，兼容 OpenAI 协议的 agent 框架将失去阻止隐式调用的机器可读信号。

Spec 引用的 goal-manager 类比（「与 goal-manager 一致，无 agents 目录」）提供了一个现有先例，但未论证 goal-manager 在缺乏此文件的情况下，其隐式调用防护在 OpenAI 兼容框架上是否同样有效。

#### Trigger Scenario

1. 用户将 `deep-discussion` 部署到同时支持 Claude Code 与 OpenAI 兼容 agent 框架的环境中
2. 该框架按 OpenAI 兼容协议查找 `agents/openai.yaml` 以获取调用策略
3. 由于 `agents/` 目录已被删除，框架找不到 `allow_implicit_invocation` 字段
4. 框架按默认行为（可能允许隐式调用）处理该技能
5. 技能可能在用户未显式触发的情况下被自动唤起，违反「仅显式触发」铁律

#### Consequence

- **可能影响**：在 OpenAI 兼容 agent 框架上，技能可被隐式唤起，违背核心产品铁律
- **用户感知**：在非 Claude Code 平台上，技能行为可能与文档声明不一致
- **实际风险**：取决于目标部署环境中是否存在依赖 `agents/openai.yaml` 的 agent 框架。若该技能仅部署在 Claude Code 与 Hermes 双端（它们各自有独立的技能发现与唤起机制，不依赖 `agents/openai.yaml`），则此风险不实际发生

#### Recommendation

在 spec 中明确此删除决策的前提条件：

1. 确认 `deep-discussion` 的目标部署平台（Claude Code + Hermes）均不依赖 `agents/openai.yaml` 来读取隐式调用策略
2. 在 spec 第4.3节的删除理由中增加一句：「经确认，Claude Code 与 Hermes 均不通过 `agents/openai.yaml` 读取隐式调用策略；该文件的策略语义在双端各自的技能框架中由其他机制保障」
3. 若未来计划支持 OpenAI 兼容 agent 框架，则不应删除此文件，或应在 SKILL.md frontmatter 中增加等价的机器可读字段

#### Evidence

1. 现有文件 `agents/openai.yaml` 内容（3行 policy 配置，含 `allow_implicit_invocation: false`）
2. Design Spec 第4.3节删除理由原文：
   > 原 `allow_implicit_invocation: false` 语义由 SKILL.md 正文「仅显式触发」铁律保证；`display_name` 由 frontmatter `name` + `description` 覆盖。
3. Design Spec 第4.3节类比引用：
   > 与 goal-manager 一致（无 agents 目录，靠 frontmatter metadata.hermes 声明）。
4. SKILL.md 正文第16行铁律表述：「不得根据上下文语义自动 / 隐式唤起」—— 此为中文自然语言指令，非结构化机器可读策略

#### Assumptions

- CONFIRMED — `agents/openai.yaml` 当前包含 `allow_implicit_invocation: false` 字段
- CONFIRMED — Design Spec 决定删除该文件，通过正文铁律替代
- INFERRED — OpenAI 兼容 agent 框架通过解析 `agents/openai.yaml` 来决定调用策略（此为该文件格式的设计意图）
- UNKNOWN — Claude Code 与 Hermes 是否各自有独立的隐式调用防护机制，完全不依赖 `agents/openai.yaml`

#### Source References

- Design Spec 第4.3节「删除 agents/」
- Design Spec 第4.1节「SKILL.md」
- 现有文件 `agents/openai.yaml`（被删除目标）

---

## Finding Summary

| Finding ID | Severity | Evidence Class | Confidence | Short Description |
| ---------- | -------- | -------------- | ---------- | ----------------- |
| PR-001 | P1 | CONFIRMED_DEFECT | HIGH | `platforms` 声明包含 Windows，但安装机制仅支持 Unix，缺少 Windows 安装路径 |
| PR-002 | P2 | MATERIAL_RISK | MEDIUM | install.sh 两次 link 非原子操作，部分失败后双端状态不一致且无恢复指引 |
| PR-003 | P2 | MATERIAL_RISK | MEDIUM | 删除 agents/openai.yaml 后隐式调用禁止策略从机器可读降级为仅人类可读文本 |

---

## Product Risk Coverage

| Risk Dimension | Status | Finding IDs |
| --- | --- | --- |
| State Machine Vulnerabilities | NOT_APPLICABLE | 本 spec 为改名与发布操作，无可建模状态机实体 |
| Hard Boundaries and Limits | REVIEWED | PR-001 |
| Data Lifecycle | REVIEWED | PR-002 |
| Backward Compatibility | REVIEWED | PR-003 |
| Implicit Assumptions | REVIEWED | PR-001, PR-003 |
| Business Rule Conflicts | REVIEWED | PR-001 |
| Temporal Consistency | NOT_APPLICABLE | 本 spec 为一次性改名与发布操作，不涉及持续运行中的时态一致性问题 |
| User Workflow Integrity | REVIEWED | PR-002 |
| Administrative Operability | REVIEWED | PR-002 |
| Abuse and Misuse Scenarios | NOT_APPLICABLE | 本 spec 不涉及多用户交互或权限模型，无可利用的滥用路径 |

---

## Unresolved Product Questions

### Q-001 — install.sh 硬编码的路径约定变更后的兼容策略

#### Question

install.sh 将双端安装路径硬编码为 `~/.claude/skills/` 与 `~/.hermes/skills/software-development/`。若 Claude Code 或 Hermes 在未来版本中变更其技能发现目录约定，install.sh 将失效。Spec 未定义对此类外部约定变更的兼容策略或检测机制。

#### Why It Matters

技能的可用性完全依赖 symlink 位于正确的路径。若路径约定变更而用户不知情，技能将静默失效（symlink 存在但不再被发现）。

#### Required Clarification

是否需要 install.sh 增加对目标目录存在性的检测（如检测 `~/.claude/` 目录是否存在、是否为 Claude Code 的标准配置目录），并在目录不存在时给出警告而非静默创建？或者，当前「不做检测、由用户确保目录正确」的隐式策略是否已足够？

#### Status

OPEN

---

### Q-002 — 双端技能行为差异的验收未定义

#### Question

Spec 第6节验收标准包括「Claude Code 中 `/deep-discussion` 可启动拷问」和「`hermes skills` 列出 deep-discussion」，但未定义双端上的技能行为是否应一致、如何验证一致性。若 SKILL.md 中某条指令在 Claude Code 上有效但在 Hermes 上被忽略（或解释不同），验收标准不要求检测此差异。

#### Why It Matters

技能被声明为「双端支持」，但仅在两个平台上分别能触发和能列出，不等同于在两个平台上行为一致。

#### Required Clarification

是否需要将「双端行为一致性」纳入验收标准？或者当前立场（「一次修改源目录，双端通过 symlink 同步可见」即视为充分的双端支持）是否已足够？

#### Status

OPEN

---

## Review Limitations

1. **目标平台的隐式调用防护机制未经验证**：本审查未实际测试 Claude Code 与 Hermes 在缺少 `agents/openai.yaml` 情况下的技能唤起行为。PR-003 基于 `agents/openai.yaml` 格式的设计意图进行推断，但未获得两平台的实证确认。

2. **Hermes 的 `skills` 命令行为未经验证**：本审查假设 `hermes skills` 命令按 spec 预期列出已安装技能，但未实际验证该命令的存在性、输出格式与行为。

3. **goal-manager 前例的差异范围未穷举**：Spec 多处引用 goal-manager 作为设计先例，但本审查未对 goal-manager 进行完整审计。若 goal-manager 中存在未被本 spec 继承的防护机制或边界处理，本审查未覆盖此类遗漏。

---

## Reviewer Conclusion

### Critical Finding Count

* P0: 0
* P1: 1
* P2: 2

### Review Result

REQUIRES_REVIEW

This review identifies product-level gaps that must be considered by the
Consolidation phase.

The Product Reviewer does not determine whether the Findings are ultimately
accepted, rejected, deferred, or otherwise resolved.

Final disposition is determined by the Decision Protocol.

---

## Machine-Readable Finding Index

```yaml
review:
  review_id: "2026-08-07-R1-PR"
  reviewer: "yy-product-reviewer"
  review_type: "PRODUCT_REVIEW"
  status: "COMPLETED"

findings:
  - id: "PR-001"
    severity: "P1"
    evidence_class: "CONFIRMED_DEFECT"
    confidence: "HIGH"
    title: "platforms 声明包含 Windows，但安装机制仅支持 Unix，缺少 Windows 安装路径"
    location: "Design Spec 第4.1节 SKILL.md frontmatter；第4.5节 install.sh 与 deploy.md"
    source_references:
      - "Design Spec 第4.1节：frontmatter platforms 声明"
      - "Design Spec 第4.5节：install.sh 脚本（bash + ln -s）"
      - "Design Spec 第4.5节：deploy.md 描述（ln -s 命令）"
    risk_dimensions:
      - "Hard Boundaries and Limits"
      - "Implicit Assumptions"
      - "Business Rule Conflicts"
    status: "PENDING_DECISION"

  - id: "PR-002"
    severity: "P2"
    evidence_class: "MATERIAL_RISK"
    confidence: "MEDIUM"
    title: "install.sh 两次 link 非原子操作，部分失败后双端状态不一致且无恢复指引"
    location: "Design Spec 第4.5节 install.sh 脚本；第5节错误处理表"
    source_references:
      - "Design Spec 第4.5节：install.sh link 函数与主流程"
      - "Design Spec 第5节：错误处理表（未覆盖此场景）"
    risk_dimensions:
      - "Data Lifecycle"
      - "User Workflow Integrity"
      - "Administrative Operability"
    status: "PENDING_DECISION"

  - id: "PR-003"
    severity: "P2"
    evidence_class: "MATERIAL_RISK"
    confidence: "MEDIUM"
    title: "删除 agents/openai.yaml 后隐式调用禁止策略从机器可读降级为仅人类可读文本"
    location: "Design Spec 第4.3节删除 agents/；第4.1节 SKILL.md frontmatter"
    source_references:
      - "Design Spec 第4.3节：删除理由"
      - "Design Spec 第4.1节：SKILL.md 铁律（中文自然语言）"
      - "现有文件 agents/openai.yaml（policy.allow_implicit_invocation: false）"
    risk_dimensions:
      - "Backward Compatibility"
      - "Implicit Assumptions"
    status: "PENDING_DECISION"

open_questions:
  - id: "Q-001"
    status: "OPEN"
    question: "install.sh 硬编码路径约定（~/.claude/skills/、~/.hermes/skills/software-development/）在外部工具变更约定后的兼容策略未定义"

  - id: "Q-002"
    status: "OPEN"
    question: "双端（Claude Code / Hermes）技能行为一致性是否需要纳入验收标准"
```

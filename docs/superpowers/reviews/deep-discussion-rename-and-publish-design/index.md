# Review Index — deep-discussion-rename-and-publish-design

## 输出语言

本审核索引的所有描述性内容使用中文。CR-ID、大写下划线标识符与枚举值、YAML key/枚举值、技术路径保持英文。Machine-Readable YAML 索引中的 title 等描述性字段使用中文。

## Design Spec

docs/superpowers/specs/2026-08-07-deep-discussion-rename-and-publish-design.md

## Review Rounds

| 轮次 | 日期 | P0 | P1 | P2 | 已接受 | 已拒绝 | 已延迟 | 状态 |
|-------|------|----|----|-----|----------|----------|----------|--------|
| 1 | 2026-08-07 | 0 | 2 | 6 | 7 | 0 | 0 | APPROVED |

<!--
Status values: PENDING_DECISION, BLOCKED, CHANGES_REQUIRED,
CONDITIONAL_APPROVAL, APPROVED, INCOMPLETE

合并阶段产出的临时最终审查状态为 CHANGES_REQUIRED（存在 2 条 P1 PENDING_DECISION 发现，spec 在此两条解决前不宜进入实现）。轮次状态记为 PENDING_DECISION，反映所有发现等待 spec 负责人决策。最终审查状态将在决策记录后按规则最终确定。
-->

## Finding Tracking

| CR-ID | 轮次 | 严重度 | 标题 | 决策 | 前轮 CR-ID | 来源审核员 | 状态 |
|-------|-------|----------|-------|----------|---------------------|-----------------|--------|
| CR-001 | 1 | P1 | README.md 旧名引用与 grep "零残留" 验收标准互斥矛盾 | ACCEPTED | — | TD | RESOLVED |
| CR-002 | 1 | P1 | platforms 声明含 Windows 但安装机制仅 Unix | ACCEPTED | — | PR | RESOLVED |
| CR-003 | 1 | P2 | 删除 agents/openai.yaml 致隐式调用防护降级 | PARTIALLY_ACCEPTED | — | PR, SC | RESOLVED |
| CR-004 | 1 | P2 | install.sh 非原子，部分失败双端不一致无恢复指引 | ACCEPTED | — | PR | RESOLVED |
| CR-005 | 1 | P2 | install.sh 建链前不验证目标内容完整性 | ACCEPTED | — | SC | RESOLVED |
| CR-006 | 1 | P2 | acceptance 行号证据依赖 +5 单一假设，脆弱验证链 | ACCEPTED | — | SC | RESOLVED |
| CR-007 | 1 | P2 | 行号验证与修正合并，缺独立确认机制 | ACCEPTED | — | TD | RESOLVED |
| CR-008 | 1 | P2 | Hermes 与 Claude Code 触发验证标准不对称 | ACCEPTED | — | TD | RESOLVED |

<!--
Cross-round tracking:
- Previous Round CR-ID: 链接前轮同一发现。首轮用 "—"。
- Status across rounds:
  - PENDING_DECISION: 等待决策
  - CARRIED_FORWARD: 前轮 DEFERRED，仍开放
  - RESOLVED: ACCEPTED 且必需动作已实现
  - STILL_OPEN: ACCEPTED 但必需动作未实现
  - REJECTED: 未接受
  - INVALIDATED: 事实基础被推翻
-->

## Trend

- Overall status: APPROVED
- Open findings: 0 P0, 0 P1, 0 P2
- 首轮审查——8 条发现全部已决（7 ACCEPTED + 1 PARTIALLY_ACCEPTED），变更已落地 spec。

## 合并摘要

- 源发现：Product 3 / System 3 / Test 3，共 9 条
- 合并后：8 条 Consolidated Finding（PR-003 与 SC-002 合并为 CR-003，保留双视角）
- 关系：DUPLICATE 1 组（CR-003）、RELATED 跨 CR 2 组（CR-004↔CR-005 install.sh 健壮性、CR-006↔CR-007 行号对齐）、其余 INDEPENDENT
- 跨审查员冲突：0
- 覆盖缺口：无（三份源审查均 AVAILABLE）
- Source Finding Integrity Check：PASS（9 = 9 + 0 + 0）
- 合并阶段临时最终审查状态：CHANGES_REQUIRED（2 条 P1 待决，spec 在此两条解决前不宜进入实现）

## 未决开放问题（非发现，供 spec 负责人参考）

- PR Q-001：install.sh 硬编码路径约定变更后的兼容策略
- PR Q-002：双端技能行为一致性是否纳入验收
- SC Q-001：Hermes 触发机制是否区分隐式/显式调用
- SC Q-002：其他工具/脚本是否引用旧技能名 yy-grill-me
- TD Q-001：README 旧名引用"允许出现"范围如何定义
- TD Q-002：Hermes 端触发验证是否在本次改造范围内

---

## Machine-Readable Index

```yaml
spec:
  path: "docs/superpowers/specs/2026-08-07-deep-discussion-rename-and-publish-design.md"
  stem: "deep-discussion-rename-and-publish-design"

rounds:
  - round: 1
    date: "2026-08-07"
    directory: "2026-08-07-review-001"
    findings:
      p0: 0
      p1: 2
      p2: 6
    decisions:
      accepted: 0
      rejected: 0
      deferred: 0
    status: "PENDING_DECISION"
    consolidated_file: "2026-08-07-review-001/consolidated-review.md"

findings:
  - id: "CR-001"
    round: 1
    severity: "P1"
    title: "README.md 旧名引用与 grep 零残留验收标准互斥矛盾"
    decision: "PENDING_DECISION"
    previous_round_cr_id: null
    source_reviewers:
      - "TD"
    status: "PENDING_DECISION"
  - id: "CR-002"
    round: 1
    severity: "P1"
    title: "platforms 声明含 Windows 但安装机制仅 Unix"
    decision: "PENDING_DECISION"
    previous_round_cr_id: null
    source_reviewers:
      - "PR"
    status: "PENDING_DECISION"
  - id: "CR-003"
    round: 1
    severity: "P2"
    title: "删除 agents/openai.yaml 致隐式调用防护降级"
    decision: "PENDING_DECISION"
    previous_round_cr_id: null
    source_reviewers:
      - "PR"
      - "SC"
    status: "PENDING_DECISION"
  - id: "CR-004"
    round: 1
    severity: "P2"
    title: "install.sh 非原子，部分失败双端不一致无恢复指引"
    decision: "PENDING_DECISION"
    previous_round_cr_id: null
    source_reviewers:
      - "PR"
    status: "PENDING_DECISION"
  - id: "CR-005"
    round: 1
    severity: "P2"
    title: "install.sh 建链前不验证目标内容完整性"
    decision: "PENDING_DECISION"
    previous_round_cr_id: null
    source_reviewers:
      - "SC"
    status: "PENDING_DECISION"
  - id: "CR-006"
    round: 1
    severity: "P2"
    title: "acceptance 行号证据依赖 +5 单一假设，脆弱验证链"
    decision: "PENDING_DECISION"
    previous_round_cr_id: null
    source_reviewers:
      - "SC"
    status: "PENDING_DECISION"
  - id: "CR-007"
    round: 1
    severity: "P2"
    title: "行号验证与修正合并，缺独立确认机制"
    decision: "PENDING_DECISION"
    previous_round_cr_id: null
    source_reviewers:
      - "TD"
    status: "PENDING_DECISION"
  - id: "CR-008"
    round: 1
    severity: "P2"
    title: "Hermes 与 Claude Code 触发验证标准不对称"
    decision: "PENDING_DECISION"
    previous_round_cr_id: null
    source_reviewers:
      - "TD"
    status: "PENDING_DECISION"
```

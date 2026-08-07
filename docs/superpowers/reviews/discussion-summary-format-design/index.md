# Review Index — 讨论纪要归档格式设计

## Design Spec

docs/superpowers/specs/2026-08-07-discussion-summary-format-design.md

## Review Rounds

| 轮次 | 日期 | P0 | P1 | P2 | 已接受 | 已拒绝 | 已延迟 | 状态 |
|-------|------|----|----|-----|----------|----------|----------|--------|
| 1 | 2026-08-07 | 0 | 3 | 3 | 6 | 0 | 0 | APPROVED |

<!--
Status values: PENDING_DECISION, BLOCKED, CHANGES_REQUIRED,
CONDITIONAL_APPROVAL, APPROVED, INCOMPLETE

Update this table after each review round and after decisions are recorded.
-->

## Finding Tracking

| CR-ID | 轮次 | 严重度 | 标题 | 决策 | 前轮 CR-ID | 来源审核员 | 状态 |
|-------|-------|----------|-------|----------|---------------------|-----------------|--------|
| CR-001 | 1 | P1 | 主题→slug 映射的非确定性破坏「按主题合并」 | ACCEPTED | — | PR, SC, TD | RESOLVED |
| CR-002 | 1 | P1 | 主题提取规则未定义，「同主题」判断无客观标准 | ACCEPTED | — | TD | RESOLVED |
| CR-003 | 1 | P1 | docs/discussions/ 目录懒创建与显式保存请求的交互歧义 | ACCEPTED | — | PR | RESOLVED |
| CR-004 | 1 | P2 | 会话段去重依赖易失上下文内存，同日多段不可区分 | ACCEPTED | — | PR, TD | RESOLVED |
| CR-005 | 1 | P2 | 纪要文件的长期生命周期管理缺失 | ACCEPTED | — | PR | RESOLVED |
| CR-006 | 1 | P2 | 编号扫描对非标准文件名的过滤规则未定义 | ACCEPTED | — | TD | RESOLVED |

<!--
Cross-round tracking:
- Previous Round CR-ID: Links to the same finding from a previous round.
  Use "—" for first-round findings.
- Status across rounds:
  - PENDING_DECISION: Awaiting decision
  - CARRIED_FORWARD: DEFERRED from a previous round, still open
  - RESOLVED: ACCEPTED and the required action has been implemented
  - STILL_OPEN: ACCEPTED but the required action has not yet been implemented
  - REJECTED: Not accepted
  - INVALIDATED: Factual basis disproven
-->

## Trend

- Overall status: APPROVED（6 条 CR 全部 ACCEPTED，Required Action 已纳入 spec v2，2026-08-07）
- Open findings: 0 P0, 0 P1, 0 P2
- First review round — no trend data yet.

---

## Machine-Readable Index

```yaml
spec:
  path: "docs/superpowers/specs/2026-08-07-discussion-summary-format-design.md"
  stem: "discussion-summary-format-design"

rounds:
  - round: 1
    date: "2026-08-07"
    directory: "2026-08-07-review-001"
    findings:
      p0: 0
      p1: 3
      p2: 3
    decisions:
      accepted: 6
      rejected: 0
      deferred: 0
    status: "APPROVED"
    consolidated_file: "2026-08-07-review-001/consolidated-review.md"

findings:
  - id: "CR-001"
    round: 1
    severity: "P1"
    title: "主题→slug 映射的非确定性破坏「按主题合并」"
    decision: "ACCEPTED"
    previous_round_cr_id: null
    source_reviewers:
      - "PR"
      - "SC"
      - "TD"
    status: "RESOLVED"

  - id: "CR-002"
    round: 1
    severity: "P1"
    title: "主题提取规则未定义，「同主题」判断无客观标准"
    decision: "ACCEPTED"
    previous_round_cr_id: null
    source_reviewers:
      - "TD"
    status: "RESOLVED"

  - id: "CR-003"
    round: 1
    severity: "P1"
    title: "docs/discussions/ 目录懒创建与显式保存请求的交互歧义"
    decision: "ACCEPTED"
    previous_round_cr_id: null
    source_reviewers:
      - "PR"
    status: "RESOLVED"

  - id: "CR-004"
    round: 1
    severity: "P2"
    title: "会话段去重依赖易失上下文内存，同日多段不可区分"
    decision: "ACCEPTED"
    previous_round_cr_id: null
    source_reviewers:
      - "PR"
      - "TD"
    status: "RESOLVED"

  - id: "CR-005"
    round: 1
    severity: "P2"
    title: "纪要文件的长期生命周期管理缺失"
    decision: "ACCEPTED"
    previous_round_cr_id: null
    source_reviewers:
      - "PR"
    status: "RESOLVED"

  - id: "CR-006"
    round: 1
    severity: "P2"
    title: "编号扫描对非标准文件名的过滤规则未定义"
    decision: "ACCEPTED"
    previous_round_cr_id: null
    source_reviewers:
      - "TD"
    status: "RESOLVED"
```

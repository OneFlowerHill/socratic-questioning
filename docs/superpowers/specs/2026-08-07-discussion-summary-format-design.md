# 讨论纪要归档到 docs/discussions/（命名同 ADR）

**日期**：2026-08-07
**主题**：把可选纪要文件从 `docs/grill-summary.md` 迁到 `docs/discussions/NNNN-slug.md`，命名规则对齐 ADR，支持多会话区分
**影响技能**：deep-discussion
**关联**：对 v1（2026-07-29 交付）的增量改动；不改 v1 历史 spec / plan / review

---

## 1. 背景与目标

v1 的可选纪要固定写到 cwd 的 `docs/grill-summary.md` 单文件：

- 多次会话写同一文件，无法区分哪次会话的内容
- 放在 docs 根目录，与 ADR（`docs/adr/`）的归类习惯不一致

目标：

1. 多会话可区分
2. 归到 `docs/discussions/`
3. 命名规则与 ADR 一致（`NNNN-slug.md` + 扫 max+1）

## 2. 关键设计决策（已与用户确认）

| 决策 | 选择 | 理由 |
|---|---|---|
| 多会话区分模型 | 按主题合并（严格同 ADR） | 同主题 slug → 同一文件；不同主题 → 不同文件 |
| 文件内多会话排版 | 一会话一段 `## 会话 YYYY-MM-DD` + 同会话内幂等 | 镜像 ADR「重复保存幂等」，同会话不产生碎片段 |
| 格式规则存放 | 新建 `references/DISCUSSION-FORMAT.md` | 镜像 ADR / CONTEXT 各有格式文件的架构 |

## 3. 落盘规则（行为契约）

- **路径**：`docs/discussions/NNNN-slug.md`（不再放 docs 根目录）
- **命名**：`NNNN-slug.md`；slug = 主题归一化 kebab-case；中文主题由技能译成短英文 slug（如「内部审批流」→ `internal-approval-flow`）；与 ADR 同规则
- **编号**：扫描 `docs/discussions/` 已有最大号 +1
- **去重**：按主题 slug 去重——同主题再存 → 复用既有文件序号、在该文件内追加 / 更新会话段（见 §4；不新建整文件）；只有新主题才追加新序号
- **懒创建**：用户没额外要求就不建 `docs/discussions/`
- **默认关闭**：仅当用户额外要求「连过程也存 / 要纪要」时才生成（沿用现状）
- **确认门禁**：写入前展示路径 + 段落 diff，用户确认后才写（沿用 CR-003）

## 4. 文件内结构

一个文件 = 一个主题的会话史，按会话分段累积。模板详见 `references/DISCUSSION-FORMAT.md`：

```md
# {主题}

## 会话 YYYY-MM-DD

**关键问答**
- Q：…  A（推荐）：…
- …

**结论**
- …
- 关联 ADR：[0003-foo](../adr/0003-foo.md)
```

行为：

- **同会话重存**：更新本段（覆盖该 `## 会话 YYYY-MM-DD` 段），不追加；技能在上下文内记住本次会话写的文件 + 段日期
- **跨会话同主题**：新一次 `/deep-discussion` 同主题 → 同文件追加新段；识别方式 = save 时按 slug 扫 `docs/discussions/` 匹配既有文件，命中 → 复用序号、追加段
- **跨会话不同主题**：新文件、新序号

## 5. 保存契约扩展（CR-001 增补）

把纪要纳入 CR-001 的去重 / 幂等契约，与 CONTEXT.md（按术语名合并）、ADR（按标题 slug 去重）并列：

- **写入前检测存在性**：目标 slug 文件已存在时走合并（追加段 / 更新段）而非整覆盖
- **按段合并**：同会话段更新；新会话段追加
- **幂等**：用户重复说「保存」，不产生重复段
- 纪要去重键 = 「主题 slug + 会话段」

## 6. 受影响文件与改动清单

| 文件 | 改动 |
|---|---|
| `SKILL.md` | :64 `docs/grill-summary.md` → `docs/discussions/NNNN-slug.md`（+ 引用 DISCUSSION-FORMAT.md）；:122 验收#4 同步；按需落盘段把纪要纳入去重 / 幂等契约（扩 CR-001）；落盘提示文案更新 |
| `references/DISCUSSION-FORMAT.md` | **新建**：模板、分段、slug / 编号、同会话幂等 + 跨会话追加规则 |
| `CLAUDE.md` | :43 `docs/grill-summary.md` → `docs/discussions/NNNN-slug.md` |
| `docs/superpowers/plans/2026-07-29-deep-discussion-acceptance.md` | 同步 #4 行号证据（:64 / :122 位移后）；追加「2026-08-07 增补」注记指向本 spec |
| `docs/superpowers/specs/2026-08-07-discussion-summary-format-design.md` | 本文档 |
| 历史 docs（07-29 spec / plan / review） | 不动 |

## 7. 边界与迁移

- **slug 歧义**：同主题不同措辞 → 不同 slug → 不同文件；沿用 ADR 同款风险（YAGNI）；首次保存在确认门禁展示拟用 slug，用户可改
- **既有 `docs/grill-summary.md`**：不自动迁移；cwd 已有旧文件时提示用户手动迁移或保留，不静默改写
- **多 context 仓库**：纪要仍写到 cwd 根 `docs/discussions/`，不按 context 分仓（沿用 CR-009 DEFERRED 范围）
- **跨 Claude 进程**：新进程不知上次段日期 → 按「新会话」追加新段（可接受：本就是不同会话）

## 8. 验收

- 用户额外要求纪要时，写到 `docs/discussions/NNNN-slug.md`，不再出现 `docs/grill-summary.md`
- 同会话重复保存：同一文件同一段，不新增段、不新增文件
- 跨会话同主题：同文件追加新日期段
- 跨会话不同主题：新文件新序号
- 默认不生成；无额外要求时 `docs/discussions/` 不被创建

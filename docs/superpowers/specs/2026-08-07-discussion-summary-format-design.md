# 讨论纪要归档到 docs/discussions/（命名同 ADR）

**日期**：2026-08-07
**版本**：v2（经 spec-review `2026-08-07-review-001` 评审，6 条 CR 全部 ACCEPTED 并纳入；评审见 `docs/superpowers/reviews/discussion-summary-format-design/2026-08-07-review-001/`）
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

## 2. 关键设计决策（已与用户确认 + 评审 ACCEPTED）

| 决策 | 选择 | 理由 |
|---|---|---|
| 多会话区分模型 | 按主题合并：slug 去重机制同 ADR（文件系统扫描 + slug 匹配），slug 确定权归用户 | 同 slug → 同一文件；不同 slug → 不同文件。ADR slug 源自用户给定的确定性标题，纪要 slug 多一层 AI 翻译（非确定），故 slug 最终由用户在确认门禁确认/修正（DR-001） |
| 主题提取 | 命令参数优先；无参数则技能推断 + 确认门禁展示 | 使「同主题」可验证：同主题 = slug 匹配（用户确认）（DR-002） |
| 文件内多会话排版 | 一会话一段 `## 会话 YYYY-MM-DD HH:MM` + 同会话内幂等 | 段含时间戳以区分同日多段；同会话重存更新该段不追加（DR-004） |
| 格式规则存放 | 新建 `references/DISCUSSION-FORMAT.md` | 镜像 ADR / CONTEXT 各有格式文件的架构 |

**「会话」定义**：一次 `/deep-discussion` 调用 = 一次会话（非进程生命周期、非日历日期）。段时间戳 = 本次调用首次保存时刻；同调用内多次保存更新该段（时间戳不变）；新调用 = 新段。

## 3. 落盘规则（行为契约）

- **路径**：`docs/discussions/NNNN-slug.md`（不再放 docs 根目录）
- **命名**：`NNNN-slug.md`；slug = 主题归一化 kebab-case；中文主题由技能译成短英文 slug（AI 翻译非确定，已承认）。**slug 在确认门禁由用户确认/修正，一经确认即作为该主题的持久去重键**（DR-001）。文件 H1 记中文主题原名辅助人工识别（DR-001）
- **编号**：扫描 `docs/discussions/`，仅匹配文件名满足 `NNNN-*.md`（NNNN 为 4 位数字前缀）的文件，取最大 NNNN +1；不匹配的文件忽略（DR-006）
- **去重**：按用户确认的 slug 去重——同 slug 再存 → 复用既有文件序号、在该文件内追加 / 更新会话段（见 §4；不新建整文件）；只有新 slug 才追加新序号
- **懒创建**：无用户显式保存请求时不创建 `docs/discussions/` 目录。用户显式要求保存纪要时，若目录不存在则**自动创建**（与 `docs/adr/` 一致），无需用户手动建目录（DR-003）
- **默认关闭**：仅当用户额外要求「连过程也存 / 要纪要」时才生成（沿用现状）
- **确认门禁**：写入前展示路径 + 段落 diff，用户确认后才写（沿用 CR-003）。首次保存某主题时，门禁额外展示：拟用主题（中文）+ 拟用 slug + `docs/discussions/` 既有 slug 列表 + 去重语义提示「此 slug 将作为该主题的持久去重标识；若与既有讨论相关，请对齐 slug 或选择合并到既有文件」（DR-001 / DR-002）

## 4. 文件内结构

一个文件 = 一个主题的会话史，按会话分段累积。模板详见 `references/DISCUSSION-FORMAT.md`：

```md
---
状态: 进行中  # 可选 frontmatter，为后续生命周期管理预留扩展点（DR-005）；默认不填
---

# {中文主题原名}

## 会话 YYYY-MM-DD HH:MM

**关键问答**
- Q：…  A（推荐）：…
- …

**结论**
- …
- 关联 ADR：[0003-foo](../adr/0003-foo.md)
```

行为：

- **同会话重存**：更新本段（覆盖该 `## 会话 YYYY-MM-DD HH:MM` 段，时间戳不变），不追加；技能在上下文内记住本次会话写的文件 + 段时间戳
- **文件系统安全网**（DR-004）：写入前读取目标文件，若已存在同时间戳段则更新而非追加——镜像 ADR 文件系统去重，不纯靠上下文内存；上下文意外丢失时同时间戳碰撞仍被兜底
- **跨会话同主题**：新一次 `/deep-discussion` 同主题 → 同文件追加新段时间戳；识别方式 = save 时按 slug 扫 `docs/discussions/` 匹配既有文件，命中 → 复用序号、追加段
- **跨会话不同主题**：新文件、新序号

## 5. 保存契约扩展（CR-001 增补）

把纪要纳入 CR-001 的去重 / 幂等契约，与 CONTEXT.md（按术语名合并）、ADR（按标题 slug 去重）并列：

- **写入前检测存在性**：目标 slug 文件已存在时走合并（追加段 / 更新段）而非整覆盖
- **按段合并**：同会话段更新（同时间戳）；新会话段追加（新时间戳）
- **文件系统级段去重**：写入前读文件，按段时间戳检测重复，存在则更新（DR-004）
- **幂等**：用户重复说「保存」，不产生重复段
- 纪要去重键 = 用户确认的 slug + 会话段时间戳

## 6. 受影响文件与改动清单

| 文件 | 改动 |
|---|---|
| `SKILL.md` | :64 `docs/grill-summary.md` → `docs/discussions/NNNN-slug.md`（+ 引用 DISCUSSION-FORMAT.md）；:122 验收#4 同步；按需落盘段把纪要纳入 slug 去重 / 幂等契约（扩 CR-001）；边界节增「显式保存时自动创建目录」「编号仅计 NNNN-*.md」；落盘提示文案更新 |
| `references/DISCUSSION-FORMAT.md` | **新建**：模板（H1 中文原名 + 可选状态 frontmatter）、分段（含时间戳）、主题提取规则、slug / 编号（含 NNNN-*.md 过滤）、同会话幂等 + 文件系统安全网 + 跨会话追加规则 |
| `references/ADR-FORMAT.md` | 编号规则同步「仅匹配 NNNN-*.md」过滤（DR-006） |
| `CLAUDE.md` | :43 `docs/grill-summary.md` → `docs/discussions/NNNN-slug.md` |
| `docs/superpowers/plans/2026-07-29-deep-discussion-acceptance.md` | 同步 #4 行号证据（:64 / :122 位移后）；追加「2026-08-07 增补」注记指向本 spec |
| `docs/superpowers/specs/2026-08-07-discussion-summary-format-design.md` | 本文档 |
| 历史 docs（07-29 spec / plan / review） | 不动 |

## 7. 边界与迁移

- **slug 非确定性**（DR-001）：AI 中译英非确定，故 slug 最终由用户在确认门禁确认 / 修正；门禁展示既有 slug 列表辅助对齐；文件 H1 记中文原名辅助识别。不再以纯 YAGNI 免责——主动缓解
- **主题提取**（DR-002）：命令参数优先，无参数则推断 + 门禁展示；同主题 = slug 匹配（用户确认）
- **跨 Claude 进程 / 上下文丢失**（DR-004）：新一次 `/deep-discussion` 调用 = 新会话 = 新段时间戳（可区分）；上下文意外丢失时，新段时间戳使「新保存事件」可见而非静默重复，文件系统安全网兜底同时间戳碰撞
- **既有 `docs/grill-summary.md`**：不自动迁移；cwd 已有旧文件时提示用户手动迁移或保留，不静默改写
- **多 context 仓库**：纪要仍写到 cwd 根 `docs/discussions/`，不按 context 分仓（沿用 CR-009 DEFERRED 范围）
- **已知局限 / 后续增强**（DR-005）：纪要文件长期生命周期管理（文件增长、归档、清理、浏览辅助、ADR 关联维护）为 v1 范围外，后续增强；DISCUSSION-FORMAT.md 预留可选「状态」frontmatter 为扩展点

## 8. 验收

- 用户额外要求纪要时，写到 `docs/discussions/NNNN-slug.md`，不再出现 `docs/grill-summary.md`
- 用户显式要求保存但目录不存在时，自动创建 `docs/discussions/`（无需手动建目录）
- 首次保存某主题时，确认门禁展示拟用主题 + slug + 既有 slug 列表 + 去重语义提示；slug 由用户确认 / 修正
- 文件 H1 为中文主题原名；段标题含时间戳 `## 会话 YYYY-MM-DD HH:MM`
- 同会话重复保存：同一文件同一段（同时间戳），不新增段、不新增文件
- 跨会话同主题：同文件追加新时间戳段
- 跨会话不同主题：新文件新序号
- 编号仅计 `NNNN-*.md` 文件的最大号 +1，非标准文件忽略
- 默认不生成；无额外要求时 `docs/discussions/` 不被创建

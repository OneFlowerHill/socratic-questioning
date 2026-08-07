# CONTEXT.md 格式

## 结构

```md
# {上下文名称}

{一两句话说明这个上下文是什么、为什么存在。}

## 语言

**Order（订单）**：
{一两句话描述该术语}
_避免_：Purchase, transaction（采购、交易）

**Invoice（发票）**：
交付后发给客户的付款请求。
_避免_：Bill, payment request（账单、付款请求）

**Customer（客户）**：
下单的个人或组织。
_避免_：Client, buyer, account（客户、买家、账户）
```

## 规则

- **要有立场。** 同一概念有多种叫法时，挑最好的一个，其余列在 `_避免_` 下。
- **定义要紧凑。** 最多一两句话。定义它「是什么」，而非「做什么」。
- **只收录本项目上下文特有的术语。** 通用编程概念（超时、错误类型、工具模式）即便项目大量使用也不收录。添加前先问：这是本上下文独有的概念，还是通用编程概念？只有前者才收录。
- **自然成簇时按子标题分组。** 若所有术语属于同一内聚领域，平铺列表即可。

## 单 context 与多 context 仓库

**单 context（多数仓库）**：仓库根目录一个 `CONTEXT.md`。

**多 context**：根目录 `CONTEXT-MAP.md` 列出各 context 的位置与关系：

```md
# Context Map

## Contexts

- [Ordering](./src/ordering/CONTEXT.md) — 接收并跟踪客户订单
- [Billing](./src/billing/CONTEXT.md) — 生成发票并处理付款
- [Fulfillment](./src/fulfillment/CONTEXT.md) — 管理仓储拣货与发货

## Relationships

- **Ordering → Fulfillment**：Ordering 发出 `OrderPlaced` 事件；Fulfillment 消费以开始拣货
- **Fulfillment → Billing**：Fulfillment 发出 `ShipmentDispatched` 事件；Billing 消费以生成发票
- **Ordering ↔ Billing**：共享 `CustomerId` 与 `Money` 类型
```

技能推断适用哪种结构：

- 若存在 `CONTEXT-MAP.md`，读取它来定位各 context。
- 若仅有根目录 `CONTEXT.md`，为单 context。
- 若两者都不存在，仅在用户**显式要求保存**且首个术语已确定时，按需懒创建根目录 `CONTEXT.md`。

存在多 context 时，推断当前主题归属哪一个；若不确定，询问用户。

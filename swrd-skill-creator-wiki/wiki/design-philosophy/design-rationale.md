# SWRD 设计思路溯源

> Sources: 本次 brainstorming 会话, 2026-05-23
> Raw: [设计思路原始素材](../../raw/design-philosophy/2026-05-23-design-rationale.md)

## 概述

SWRD 的设计基于对 5 个项目的深度调研：SkillFather（工程化骨架）、darwin-skill（评分优化）、Karpathy autoresearch（棘轮机制）、Claude Autoresearch（模块化路由）、XSkill（经验检索思想）。每个项目贡献了不同的设计理念。

## 关键设计决策

### 人在回路 vs 全自动
Skill 质量比 ML 模型的 loss 更微妙，涉及结构、效果、可读性、跨平台等多个维度。有些改进在分数上不显著但对体验提升很大。所以 SWRD 选择"每个模块优化后暂停，用户确认再继续"。

### YAML + JSONL 双日志
YAML 人类可读，JSONL 机器可解析。双格式互补，不需要在可读性和可训练性之间做取舍。

### karpathy-llm-wiki 而非 embedding 检索
零依赖、纯文件、完全离线可用。对于 Skill 经验记录场景，关键词检索 + 结构化目录已经足够。

### 模块化约束 ≤3 文件/300 行
3 个文件覆盖定义、实现、测试。300 行是职责单一的警戒线。约束的目的是强制模块化思考。

## 被否决的方案

1. 全自动无人干预 → 人在回路
2. 单一日志格式 → YAML + JSONL 双格式
3. llm-wiki 作为外部依赖 → 内置零依赖引擎
4. 联动工程假设为 git 仓库 → 通用适配层
5. embedding 向量检索 → 关键词检索 + 结构化目录

## See Also

- [用户提出的关键约束](user-constraints.md)
- [棘轮进化模式](optimization-patterns.md)
- [会话连续性](session-continuity.md)
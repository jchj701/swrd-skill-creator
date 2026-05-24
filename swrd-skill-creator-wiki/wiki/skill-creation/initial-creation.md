# SWRD 初始创建经验

> Sources: 本次 brainstorming + writing-plans 会话, 2026-05-23
> Raw: [初始创建原始素材](../../raw/skill-creation/2026-05-23-swrd-initial-creation.md)

## 概述

SWRD 自进化工程级 Skill 创造器基于对 5 个项目的深度调研（SkillFather、XSkill、darwin-skill、Karpathy autoresearch、Claude Autoresearch），融合各自优点设计而成。

## 核心设计决策

### 状态机
SkillFather 的状态机是完备的工程化基础，SWRD 增加了 revisit 回退路径和 auto_optimization_loop 自进化闭环，最终 17 个状态。

### 评分体系
参考 darwin-skill 的 8 维度评分，但改进为 3 子 Agent 投票取中位数 + 动态阈值。

### 全日志系统
YAML 主日志（人类可读）+ JSONL 训练集（机器可解析），记录每次调用、Eval、优化迭代、回退。

### 模块化约束
每个模块 ≤ 3 文件、≤ 300 行，创建时通过子 Agent 审查。

### 版本号策略
三段式，0.1.0 起始，棘轮前进升最小版本，禁止回退。

### 联动工程适配
通用适配层：git 仓库 / 非 git 目录 / 自动 init / 全量备份。

## 关键教训

1. 模板文件必须先于 SKILL.md 中的引用存在
2. 边界条件容易被忽略，需要系统性检查每个外部操作的失败场景
3. 工作流步骤需要明确标注输入/输出/退出条件/fallback
4. 评分标准需要量化才能客观评估

## See Also

- [第一轮进化：填充模板](round1-template-filling.md)
- [第二轮进化：边界条件](round2-boundary-conditions.md)
- [第三轮进化：工作流清晰度](round3-workflow-clarity.md)
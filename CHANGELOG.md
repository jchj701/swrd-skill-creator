# CHANGELOG.md

# SWRD 自进化工程级 Skill 创造器 变更记录

## [0.1.0] - 2026-05-23
### 新增
- 初始创建 SWRD 自进化工程级 Skill 创造器
- 完整的状态机定义（17 个状态，含自进化循环）
- 8 维度评分体系（3 子 Agent 投票，动态阈值）
- 全日志系统（YAML 主日志 + JSONL 训练集）
- karpathy-llm-wiki 经验知识库集成
- 模块化审查机制（3 子 Agent 独立审查）
- 跨平台 Runtime 审查（红灯/绿灯扫描）
- 联动工程通用适配层（git/非 git/自动 init/全量备份）
- 三段式版本号策略（棘轮前进升最小版本）
- git 棘轮机制（结构化 commit message）
- 人在回路检查点
- 探索性重写机制
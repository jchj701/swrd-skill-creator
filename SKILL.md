---
name: swrd-skill-creator
version: 0.1.6
description: |
  SWRD 自进化工程级 Skill 创造器。一个元 Skill（Meta-Skill），用于创建、评估、自动优化其他工程化 Skill，
  并让被创建的 Skill 具备自进化能力（棘轮机制 + 全日志 + wiki 经验积累）。
  
  当用户提到"创建 Skill"、"生成技能"、"优化 Skill"、"Skill 评分"、"自动优化"、"Skill 质量检查"时触发。
  不适用于：一次性简单提问、普通聊天、单次文本生成。

category:
  - meta-skill
  - skill-generation
  - auto-optimization
  - eval-driven-development

author: SWRD

trigger:
  semantic:
    - 创建 Skill
    - 生成技能
    - 优化 Skill
    - Skill 评分
    - 自动优化
    - Skill 质量检查
    - 改进技能
    - 完善 Skill
    - 更新技能
    - 自进化
    - 棘轮进化
    - 工程化 Skill

  should_trigger_when:
    - 用户希望创建可复用的工程化 Skill
    - 用户需要评估现有 Skill 的质量
    - 用户需要自动优化 Skill
    - 用户需要 Skill 具备自进化能力
    - 用户需要为 Skill 建立全日志系统
    - 用户需要为 Skill 集成经验知识库

  should_not_trigger_when:
    - 一次性简单提问
    - 普通聊天
    - 单次文本生成
    - 不具备复用价值的需求

inputs:
  - task_description
  - expected_outputs
  - constraints
  - runtime_environment
  - dependent_targets

outputs:
  - structured_skill_package
  - eval_suite
  - workflow_definition
  - trigger_specification
  - telemetry_system
  - wiki_knowledge_base

dependencies:
  - git
  - karpathy-llm-wiki

token_budget:
  soft_limit: 24000
  hard_limit: 48000

latency_budget:
  target_ms: 30000

risk_level: low

observability:
  enabled: true
  collect:
    - trigger_accuracy
    - completion_rate
    - token_usage
    - latency
    - eval_scores
    - optimization_rounds
    - keep_revert_ratio

eval_strategy:
  methodology:
    - trigger-eval
    - execution-eval
    - regression-eval
    - adversarial-eval

  success_criteria:
    trigger_accuracy: ">= 90%"
    completion_rate: ">= 85%

---

# SWRD 自进化工程级 Skill 创造器

> 版本：0.1.0 | 作者：SWRD
> 融合 SkillFather 的工程化骨架 + darwin-skill 的评分优化 + Karpathy Loop 的棘轮机制 + Claude Autoresearch 的模块化路由 + karpathy-llm-wiki 的经验记录。

你是一个**元 Skill（Meta-Skill）**。你的任务不是直接解决用户的问题，而是**创建能够解决问题的工程化 Skill**，并让这些 Skill 具备**自进化能力**。

---

# 核心原则

1. **工程化优先**：创建的 Skill 必须遵循标准化目录结构、状态机、Eval 体系
2. **测试优先（Test First）**：先定义 Eval，再生成 Skill
3. **棘轮机制**：只保留改进，自动回滚退步，分数只升不降
4. **独立评分**：评分用子 Agent，避免自己改自己评的偏差
5. **人在回路**：每个关键决策点暂停，用户确认再继续
6. **全量可追溯**：每次调用、每次 Eval、每次优化都记录到日志
7. **经验积累**：每个 Skill 拥有独立的 karpathy-llm-wiki 知识库
8. **跨平台兼容**：创建的 Skill 不绑定单一 Runtime
9. **模块化约束**：每个模块 ≤ 3 文件、≤ 300 行，高内聚低耦合
10. **版本号纪律**：三段式版本号，棘轮前进升最小版本，禁止回退

---

# 工作流程

工作流定义：workflows/state-machine.yaml

每个阶段必须明确标注：
- **输入**：进入该阶段前必须准备好的数据
- **输出**：该阶段完成后必须产出的结果
- **退出条件**：什么情况下可以离开该阶段
- **fallback**：该阶段失败时的处理路径

---

## 阶段一：意图抽取

**输入**：用户原始需求描述
**输出**：结构化的意图抽取结果（含用户目标、任务边界、输入输出、复用价值判断）
**退出条件**：意图完整且具备复用价值，或确认不具备复用价值
**fallback**：意图不完整时循环追问，最多 5 轮；超时后提示用户简化需求

分析用户真实需求，判断是否适合创建 Skill：

1. **询问用户**（使用 ask_followup_question 工具，如果没有则使用普通对话）：
   - 你想要创建什么类型的 Skill？
   - 这个 Skill 解决什么问题？
   - 预期的输入和输出是什么？
   - 有什么约束条件？
   - 运行环境是什么？
   - 是否有联动工程（被 Skill 操作的代码/文件）？

2. **判断复用价值**：
   - 如果任务不具备复用价值 → STOP，告知用户原因
   - 如果任务适合创建 Skill → 进入能力抽象

3. **记录到 telemetry**：
   - 记录用户意图、问答内容

---

## 阶段二：能力抽象

**输入**：意图抽取结果（用户目标、任务边界）
**输出**：模块划分方案（模块列表、接口定义、依赖关系）
**退出条件**：模块划分通过自检，或用户确认调整后的方案
**fallback**：意图冲突时回退到阶段一重新确认；抽象失败时停止

将用户需求转换为可复用的能力模块：

1. **识别逻辑单元**：
   - 分析用户需求，拆分为独立的逻辑单元
   - 每个逻辑单元对应一个模块

2. **模块化约束检查**（自检）：
   - 每个模块 ≤ 3 个文件
   - 每个文件 ≤ 300 行
   - 模块间无循环依赖
   - 每个模块职责单一
   - 模块间接口明确定义

3. **定义模块间依赖**：
   - 在 skill.yaml 的 workflow.steps 中定义

4. **展示给用户确认**：
   - 展示模块划分方案
   - 等待用户确认

5. **记录到 telemetry**

---

## 阶段三：Eval 定义

**输入**：模块划分方案（模块列表、接口定义）
**输出**：4 个 Eval JSON 文件（trigger_cases.json、success_cases.json、failure_cases.json、benchmarks.json）
**退出条件**：4 个 Eval 文件全部生成且通过格式校验
**fallback**：无法定义有意义的 Eval 时回退到阶段二重新抽象；连续 2 次回退后停止

测试优先，先定义 Eval 再生成 Skill：

1. **生成 Trigger Eval**（trigger_cases.json）：
   - 应该触发的情况（5+ 个用例）
   - 不应该触发的情况（3+ 个用例）

2. **生成 Success Eval**（success_cases.json）：
   - 正常流程测试用例（2+ 个）

3. **生成 Failure Eval**（failure_cases.json）：
   - 异常场景测试用例（4+ 个）

4. **生成 Benchmark**（benchmarks.json）：
   - 性能基准测试

5. **展示给用户确认**

6. **记录到 telemetry**

---

## 阶段四：Skill 生成

**输入**：Eval 文件 + 模块划分方案 + 模板文件
**输出**：完整的 Skill 目录结构（含 SKILL.md、skill.yaml、workflows/、evals/、telemetry/、wiki/）
**退出条件**：所有必需文件创建完成且通过验证
**fallback**：模板缺失时使用内嵌默认模板；git 初始化失败时提示用户手动操作；文件创建失败时重试 1 次后停止
     - 尝试从 `assets/skill-template/` 中同类模板推断结构
     - 如果无法推断，使用硬编码的默认模板（内置于本 SKILL.md 中）
     - 记录模板缺失情况到 telemetry，但不中断流程
   - 检查 `assets/wiki-template/SKILL.md` 是否存在
   - 如果 wiki 模板缺失，使用内嵌的 wiki 结构描述生成

2. **创建目录结构**：
   ```
   <skill-name>/
   ├── SKILL.md                    # 版本号唯一位置：0.1.0
   ├── skill.yaml
   ├── CHANGELOG.md                # 变更记录
   ├── workflows/
   │   └── state-machine.yaml
   ├── evals/
   │   ├── trigger_cases.json
   │   ├── success_cases.json
   │   ├── failure_cases.json
   │   └── benchmarks.json
   ├── scripts/
   ├── references/
   ├── assets/
   ├── telemetry/                  # 全日志系统
   │   ├── <skill-name>-telemetry.yaml
   │   └── <skill-name>-telemetry.jsonl
   └── <skill-name>-wiki/          # karpathy-llm-wiki 知识库
       ├── SKILL.md
       ├── raw/
       ├── wiki/
       │   ├── index.md
       │   └── log.md
       └── references/
   ```

2. **从模板生成各文件**：
   - SKILL.md：包含 frontmatter（版本号 0.1.0）+ Markdown body
   - skill.yaml：机器可读配置
   - workflows/state-machine.yaml：状态机定义
   - evals/*.json：测试用例
   - telemetry/：日志模板
   - wiki/：karpathy-llm-wiki 模板

3. **初始化 git 仓库**：
   ```bash
   cd <skill-name>
   git init
   git add .
   git commit -m "[SWRD] <skill-name> v0.1.0 | 初始创建"
   ```
   **边界处理**：
   - 如果 `git init` 失败（如目录已存在非空、权限不足）：
     - 检查目录是否已经是 git 仓库 → 如果是，直接使用
     - 如果权限不足 → 提示用户手动初始化，提供命令
     - 记录失败原因到 telemetry，不中断流程
   - 如果 `git commit` 失败（如 user.name/email 未配置）：
     - 尝试使用环境变量 GIT_AUTHOR_NAME / GIT_AUTHOR_EMAIL
     - 如果仍失败 → 提示用户配置，提供命令
     - 记录到 telemetry，继续后续流程

4. **验证生成结果**：
   - 检查所有必需文件是否已创建
   - 检查 SKILL.md 中 version 字段是否存在且格式正确
   - 检查 skill.yaml 格式是否正确
   - 如果验证失败 → 记录到 telemetry，提示用户手动修复

5. **记录到 telemetry**

---

## 阶段五：模块化审查

**输入**：生成的 Skill 目录结构（所有文件）
**输出**：审查结果（通过/不通过/降级通过 + 各规则检查详情）
**退出条件**：≥2 子 Agent 通过，或降级模式下主 Agent 自检通过
**fallback**：子 Agent 超时时降级为主 Agent 自检；审查不通过时回退到阶段四重新拆分

1. **spawn 3 个子 Agent**，每个独立审查：
   - M1：每个模块不超过 3 个文件
   - M2：每个文件不超过 300 行
   - M3：模块间无循环依赖
   - M4：每个模块职责单一
   - M5：模块间接口在 skill.yaml 中明确定义
   - M6：禁止跨模块引用内部文件

2. **子 Agent 超时处理**：
   - 每个子 Agent 设置 60 秒超时
   - 如果 1 个子 Agent 超时 → 使用剩余 2 个的结果（多数决仍有效）
   - 如果 2 个及以上子 Agent 超时 → 降级为主 Agent 自检，标记 `degraded_mode` 到 telemetry
   - 降级模式下，主 Agent 逐条检查 M1-M6，记录检查结果

3. **汇总结果**：
   - ≥2 子 Agent（或降级模式下主 Agent）判定 error → 审查不通过，回退到阶段四
   - 审查通过 → 进入阶段六
   - 如果审查结果不明确（平局）→ 标记为 warning，允许进入阶段六但记录到 telemetry

4. **记录到 telemetry**

---

## 阶段六：触发优化

**输入**：生成的 SKILL.md（含初始 description 和 trigger）
**输出**：优化后的 SKILL.md（description 更精准、trigger 覆盖更全）
**退出条件**：description 和 trigger 优化完成
**fallback**：优化失败时使用初始版本，不阻塞流程

1. **优化 description**：
   - 包含用户意图
   - 包含同义表达
   - 包含典型场景
   - 包含上下文信号
   - 包含排除条件

2. **优化 semantic trigger**：
   - 增加同义词和变体
   - 确保不与其他 Skill 冲突

3. **优化 should_trigger_when / should_not_trigger_when**

4. **记录到 telemetry**

---

## 阶段七：运行时优化

**输入**：优化后的 SKILL.md + skill.yaml
**输出**：通过运行时检查的配置（token 预算、懒加载、渐进式披露）
**退出条件**：三项检查全部通过
**fallback**：检查不通过时自动修正配置项

确保支持渐进式披露和按需加载：

1. **检查 token 预算设置**：soft_limit / hard_limit 合理
2. **检查懒加载机制**：references/ 目录按需加载
3. **检查渐进式披露**：L1（frontmatter）→ L2（SKILL.md body）→ L3（references/）

---

## 阶段八：跨平台审查

**输入**：SKILL.md + README.md（如有）
**输出**：审查结果（红灯列表 + 修复建议）
**退出条件**：无红灯，或所有红灯已修复
**fallback**：发现红灯时回退到阶段六修复；无法修复时标记 warning 并记录到 telemetry

1. **红灯扫描**（grep 检查）：
   ```bash
   grep -nE "(在 Claude Code|Claude Code skill|Claude Code 用户|^\[!\[Claude Code|~/\.claude/skills/[a-z]|/plugin install\b)" SKILL.md README.md 2>/dev/null
   ```

2. **红灯修复**：
   - "在 Claude Code 里" → "在你的 Agent 里"
   - "Claude Code skill" → "Agent Skill"
   - 硬编码路径 → 环境变量或通用路径

3. **绿灯确认**：
   - 使用 Agent Skills 标准格式
   - 提供通用安装命令
   - 多平台安装说明

4. **记录到 telemetry**

---

## 阶段九：用户确认

**输入**：完整的 Skill 目录 + 模块化审查结果 + 跨平台审查结果
**输出**：用户决策（满意不优化 / 满意并优化 / 不满意需修改）
**退出条件**：用户做出明确选择
**fallback**：用户不满意时回退到阶段四修改；用户不回应时默认进入完成

展示生成的 Skill 给用户确认：

1. **展示**：
   - Skill 目录结构
   - 各模块概览
   - Eval 测试用例
   - Runtime 审查结果

2. **询问用户**：
   - 是否满意当前结果？
   - 是否进入自进化循环进行自动优化？

3. **根据用户选择**：
   - 满意且不优化 → 进入完成
   - 满意且优化 → 进入自进化循环
   - 不满意 → 回退修改

---

## 阶段十：自进化循环

**输入**：已生成的 Skill + 用户确认进入优化 + 联动工程信息
**输出**：优化后的 Skill（分数提升）+ 优化报告 + 更新后的 telemetry
**退出条件**：收敛（连续 5 轮不提升）或用户确认完成
**fallback**：联动工程不可用时使用临时目录；子 Agent 评分超时时降级

自动优化 Skill 质量（hill-climbing + 棘轮机制）：

### 10.1 初始化

1. **确认联动工程**：
   - 检查用户指定的联动工程路径
   - **边界处理**：
     - 如果路径不存在 → 提示用户路径不存在，询问是否创建空目录或使用其他路径
     - 如果路径存在但为空 → 提示用户，询问是否继续（空目录不影响评分）
     - 如果路径存在但无读权限 → 提示用户检查权限，提供修复命令
     - 如果路径存在但无写权限 → 提示用户，降级为只读模式（不执行修改类测试）
   - 判断类型（git 仓库 / 非 git 目录）
   - 如果非 git 目录，询问用户是否初始化 git
   - 如果用户拒绝，启用全量备份模式
   - 如果用户未指定联动工程 → 使用临时目录作为测试环境，测试后自动清理

2. **设计测试 Prompt**：
   - 为 Skill 设计 2-3 个典型测试 prompt
   - 展示给用户确认

3. **记录到 telemetry**

### 10.2 基线评估

1. **结构评分**（spawn 3 个子 Agent，独立评分）：
   - 每个子 Agent 按 8 维度打分
   - 取中位数作为最终分数

2. **效果评分**（spawn 独立子 Agent）：
   - 带 Skill 执行测试 prompt
   - 不带 Skill 执行同一 prompt（baseline）
   - 对比输出质量打分

3. **计算加权总分**

4. **记录到 telemetry**

### 10.3 优化迭代

```
for round = 1 to MAX_ROUNDS:
  1. 诊断最低分维度
  2. 生成 1 个具体改进方案
  3. 修改目标模块文件（每次只改一个模块）
  4. 更新版本号（最小版本 +1）
  5. git commit（含结构化 message）
  6. spawn 3 个子 Agent 独立重新评分
  7. 判断 keep / revert：
     - 新分中位数 > 旧分中位数 → keep
     - 否则 → git revert
  8. 记录到 telemetry
  9. 如果连续 5 轮不提升 → 收敛，退出循环
```

### 10.4 人在回路检查点

每个模块优化完成后暂停：

1. **展示**：
   - git diff
   - 分数变化（哪些维度提升/下降）
   - 测试输出对比

2. **等待用户确认**：
   - 确认继续 → 进入下一轮
   - 说"不好" → 回退到优化前版本
   - 确认完成 → 进入汇总报告

### 10.5 探索性重写

当 hill-climbing 连续 2 个 Skill 首轮即瓶颈时：

1. **询问用户是否同意探索性重写**
2. **如果同意**：
   - git stash 保存当前最优版本
   - 从头重写 SKILL.md
   - 重新评估
   - 重写版更优 → 采用；否则 → git stash pop 恢复
3. **如果不同意** → 直接完成

---

## 阶段十一：完成

**输入**：优化结果数据（轮次、分数变化、keep/revert 记录）
**输出**：优化报告 + 更新后的 CHANGELOG.md + 更新后的 telemetry
**退出条件**：报告生成完成且用户确认
**fallback**：报告生成失败时输出简化版报告

生成汇总报告：

1. **生成优化报告**：
   ```
   ## 优化报告
   
   ### 总览
   - 优化轮数：N
   - 保留改进：X（Y%）
   - 回滚次数：Z
   
   ### 分数变化
   | 轮次 | Before | After | Δ |
   |------|--------|-------|---|
   | 1    | 66     | 72    | +6 |
   | 2    | 72     | 68    | -4(revert) |
   
   ### 主要改进
   1. 补充了边界条件处理
   ```

2. **更新 CHANGELOG.md**

3. **展示最终结果给用户**

4. **记录到 telemetry**

## 用户中途取消处理

在任何阶段，如果用户中途取消操作：

1. **立即停止当前操作**，不继续执行后续步骤
2. **清理临时文件**：
   - 删除已创建的临时目录和文件
   - 如果已初始化 git 仓库但未提交 → 删除 .git 目录
   - 如果已提交 git commit → 保留，不强制回退
3. **联动工程恢复**：
   - 如果已对联动工程执行了修改 → 执行 env-snapshot.sh restore 恢复
4. **记录取消事件到 telemetry**：
   - 记录取消时的阶段、已执行的操作、清理结果
5. **告知用户已清理的内容和保留的内容**

---

# 执行约束

禁止：
- 一次性读取整个大型项目的所有文件
- 生成超大单体 Prompt
- 跳过 Eval
- 忽略 Trigger 边界
- 忽略失败场景
- 忽略可观测性
- 自己评自己（必须用子 Agent）
- 回退版本号
- 生成绑定单一 Runtime 的 Skill
- 模板文件缺失时不提供 fallback 直接报错
- git 操作失败时不处理直接继续
- 子 Agent 超时不降级处理
- 联动工程路径不存在时不提示直接使用
- 用户中途取消时不清理残留文件
- 磁盘空间不足时不检查直接写入
- 文件写入冲突时不处理直接覆盖
- 版本号解析失败时不校验直接使用

必须：
- 模块化设计（≤ 3 文件/模块，≤ 300 行/文件）
- Eval First
- Trigger Optimization
- Runtime Safety
- Skill Composability
- Telemetry Collection
- 全量日志记录
- wiki 经验积累
- 棘轮机制
- 人在回路
- 每个阶段必须有明确的 fallback 路径
- 所有外部操作（git、文件写入、子 Agent 调用）必须有错误处理
- 用户中断操作时必须清理临时文件
- 每次文件写入前检查磁盘空间
- 每次 git 操作后验证结果
- 每次子 Agent 调用设置超时并准备降级方案

---

# 输出格式

生成的 Skill 必须包含：
1. Skill Summary
2. Trigger Specification
3. Workflow Definition
4. Eval Suite
5. Runtime Strategy
6. Telemetry Plan
7. Wiki Knowledge Base
8. Optimization Suggestions

---

# 成功标准

一个成功的 Skill 必须：
- Trigger 正确
- 执行稳定
- 抗 Prompt Injection
- 支持组合调用
- 支持持续优化
- 可通过 Telemetry 演化
- 可通过 wiki 积累经验
- 具备棘轮进化能力
- 跨平台兼容
- 模块化设计合理

---

# Skill Engineering Philosophy

Skill ≠ Prompt

Skill 是：能力单元

Skill 应具备：
- 生命周期
- Eval
- Runtime
- Telemetry
- Versioning
- Retrieval
- Workflow
- State Machine
- Wiki Knowledge Base
- Ratchet Evolution

你正在构建的：
不是 Prompt。
而是：Agent 能力基础设施。
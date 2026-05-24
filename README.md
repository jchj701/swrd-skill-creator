# SWRD 自进化工程级 Skill 创造器

> **版本**: 0.1.5 | **状态**: 迭代优化中

<p align="center">
  <strong>一个能创建、评估、自动优化其他工程化 Skill 的元 Skill（Meta-Skill），
  并让被创建的 Skill 具备自进化能力。</strong>
</p>

<p align="center">
  <a href="#"><img src="https://img.shields.io/badge/version-0.1.5-blue.svg" alt="Version"></a>
  <a href="#"><img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License"></a>
  <a href="#"><img src="https://img.shields.io/badge/Agent_Skills-compatible-blueviolet" alt="Agent Skills"></a>
</p>

---

## 目录

- [设计理念](#设计理念)
- [核心能力](#核心能力)
- [快速开始](#快速开始)
- [工作流程](#工作流程)
- [评分体系](#评分体系)
- [全日志系统](#全日志系统)
- [经验知识库](#经验知识库)
- [版本号策略](#版本号策略)
- [Git 工作流](#git-工作流)
- [安装](#安装)
- [贡献](#贡献)
- [许可证](#许可证)

---

## 设计理念

SWRD 的设计不是凭空产生的，而是基于对 **5 个开源项目**的深度调研和横向对比，融合各自优点而成。

### 灵感来源

| 项目 | 贡献 | 作者 |
|------|------|------|
| **[SkillFather](https://github.com/huanqwer/SkillFather)** | 工程化骨架：标准化目录结构、状态机、Eval 驱动开发、可观测性设计 | gavin.qin |
| **[darwin-skill](https://github.com/alchaincyf/darwin-skill)** | 评分优化：8 维度评分体系、hill-climbing 优化循环、Runtime 适配性审查 | 花叔 |
| **[Karpathy autoresearch](https://github.com/karpathy/autoresearch)** | 棘轮机制：单文件修改、固定时间预算、单一标量指标、git 即记忆 | @karpathy |
| **[Claude Autoresearch](https://github.com/uditgoenka/autoresearch)** | 模块化路由：薄路由 + 独立命令文件、95% token 缩减、多种循环模式 | Udit Goenka |
| **[XSkill](https://github.com/XSkill-Agent/XSkill)** | 经验检索思想：从轨迹中自动提取经验、持续学习 | ICML 2026 |

### 核心设计决策

| 决策 | 选择 | 理由 |
|------|------|------|
| **人在回路 vs 全自动** | 人在回路 | Skill 质量比 ML 模型的 loss 更微妙，涉及多个维度，需要人类判断 |
| **日志格式** | YAML + JSONL 双格式 | YAML 人类可读，JSONL 机器可解析，兼顾可读性和可训练性 |
| **经验存储** | karpathy-llm-wiki（零依赖） | 纯文件、完全离线可用，无需向量数据库 |
| **模块化约束** | ≤3 文件/模块、≤300 行/文件 | 强制模块化思考，高内聚低耦合 |
| **评分方式** | 3 子 Agent 投票取中位数 | 避免自己改自己评的偏差 |
| **联动工程** | 通用适配层 | 支持 git/非 git/自动 init/全量备份 |

### 被否决的方案

- ❌ 全自动无人干预 → ✅ 人在回路
- ❌ 单一日志格式 → ✅ YAML + JSONL 双格式
- ❌ llm-wiki 作为外部依赖 → ✅ 内置零依赖引擎
- ❌ 联动工程假设为 git 仓库 → ✅ 通用适配层
- ❌ embedding 向量检索 → ✅ 关键词检索 + 结构化目录

---

## 核心能力

### 1. 工程化 Skill 创建

从用户需求出发，经过完整的 11 阶段工作流，生成标准化的工程化 Skill：

```
意图抽取 → 能力抽象 → Eval定义 → Skill生成 → 模块化审查
→ 触发优化 → 运行时优化 → 跨平台审查 → 用户确认
→ 自进化循环 → 完成
```

每个阶段都有明确的**输入、输出、退出条件、fallback 路径**。

### 2. 8 维度评分体系

| 维度 | 权重 | 类型 | 说明 |
|------|------|------|------|
| D1 Frontmatter 质量 | 8 | 结构 | name/description/version 规范 |
| D2 工作流清晰度 | 15 | 结构 | 步骤明确可执行，有输入/输出标注 |
| D3 边界条件覆盖 | 10 | 结构 | 异常处理、fallback、错误恢复 |
| D4 检查点设计 | 7 | 结构 | 人在回路、防止自主失控 |
| D5 指令具体性 | 15 | 结构 | 有具体参数/格式/示例 |
| D6 资源整合度 | 5 | 结构 | 模板/脚本/引用完整 |
| D7 架构合理性 | 15 | 效果 | 模块化、高内聚低耦合 |
| D8 实测表现 | 25 | 效果 | 跑测试对比 baseline |

评分方式：**3 个子 Agent 独立评分，取中位数**，避免自己改自己评的偏差。

### 3. 棘轮自进化

```
for each round:
  1. 诊断最低分维度
  2. 生成改进方案
  3. 修改目标模块（每次只改一个模块）
  4. 更新版本号（最小版本 +1）
  5. git commit（含结构化 message）
  6. 3 子 Agent 独立重新评分
  7. 新分 > 旧分 → keep，否则 → git revert
  8. 人在回路检查点
```

**只保留改进，自动回滚退步，分数只升不降。**

### 4. 全日志系统

每次调用、每次 Eval、每次优化迭代、每次回退都记录到日志：

- **YAML 主日志**（`telemetry/<skill-name>-telemetry.yaml`）：人类可读，追加写入
- **JSONL 训练集**（`telemetry/<skill-name>-telemetry.jsonl`）：机器可解析，可用于二次训练

### 5. 经验知识库

每个被创建的 Skill 拥有独立的 **karpathy-llm-wiki** 知识库：

```
<skill-name>-wiki/
├── SKILL.md          # 遵循 karpathy-llm-wiki 规范
├── raw/              # 不可变的原始素材
└── wiki/             # 编译后的知识页面
    ├── index.md      # 全局索引
    └── log.md        # 操作日志
```

零依赖、纯文件、完全离线可用。越用越好用。

### 6. 跨平台兼容

创建 Skill 时自动进行 **Runtime 适配性审查**：

- 红灯扫描：检查是否绑定了单一 Runtime（如"在 Claude Code 里"）
- 自动修复：替换为通用表述
- 绿灯确认：使用 Agent Skills 标准格式

---

## 快速开始

### 安装

```bash
# 克隆仓库
git clone https://github.com/<你的用户名>/swrd-skill-creator.git
cd swrd-skill-creator

# 复制到你的 Agent 的 skills 目录
# Claude Code:
cp -r skills/swrd-skill-creator ~/.claude/skills/swrd-skill-creator

# CodeBuddy / OpenClaw:
cp -r skills/swrd-skill-creator ~/.codebuddy/skills/swrd-skill-creator
```

### 使用

在 Agent 对话框中直接说：

> **"帮我创建一个 PDF 处理的 Skill"**
> **"优化一下这个 Skill"**
> **"给这个 Skill 打个分"**

Agent 会自动触发 SWRD，引导你完成创建或优化流程。

---

## 工作流程

### 完整流程（11 阶段）

```
阶段一：  意图抽取       → 分析用户需求，判断复用价值
阶段二：  能力抽象       → 拆分为模块，定义接口
阶段三：  Eval 定义      → 测试优先，先定义测试用例
阶段四：  Skill 生成     → 从模板生成标准化文件
阶段五：  模块化审查     → 3 子 Agent 独立审查
阶段六：  触发优化       → 优化 description 和 trigger
阶段七：  运行时优化     → 渐进式披露、按需加载
阶段八：  跨平台审查     → Runtime 红灯扫描
阶段九：  用户确认       → 展示结果，确认是否优化
阶段十：  自进化循环     → hill-climbing + 棘轮
阶段十一：完成           → 生成汇总报告
```

### 自进化循环（阶段十内部）

```
初始化 → 基线评估 → 优化迭代 → 人在回路检查点
         ↑                      │
         └──── 继续优化 ────────┘
         
         如果卡住 → 探索性重写
```

---

## 评分体系

### 8 维度评分

| 维度 | 权重 | 评分方式 |
|------|------|----------|
| D1 Frontmatter 质量 | 8 | 静态分析 |
| D2 工作流清晰度 | 15 | 静态分析 |
| D3 边界条件覆盖 | 10 | 静态分析 |
| D4 检查点设计 | 7 | 静态分析 |
| D5 指令具体性 | 15 | 静态分析 |
| D6 资源整合度 | 5 | 静态分析 |
| D7 架构合理性 | 15 | 效果评估 |
| D8 实测表现 | 25 | 跑测试对比 |

### 评分规则

- 每个维度 1-10 分，乘以权重得到该维度得分
- 总分 = Σ(维度分 × 权重) / 10，满分 100
- **3 个子 Agent 独立评分，取中位数**
- **动态阈值**：总分 < 60 时 Δ ≥ 1 算提升；60-80 时 Δ ≥ 2 算提升；≥ 80 时 Δ ≥ 1 算提升
- **收敛条件**：连续 5 轮不提升则退出

---

## 全日志系统

### YAML 主日志结构

```yaml
meta:
  skill_name: "<skill-name>"
  version: "0.1.0"

sessions:
  - session_id: "ses-20260523-001"
    agent_id: "codebuddy-cli"
    user_intent: "创建一个 PDF 处理的 Skill"
    
    calls:
      - call_id: "call-001"
        skill_phase: "意图抽取"
        tokens_used: 2340
        eval_result:
          passed: true
    
    evals:
      - eval_id: "eval-001"
        eval_type: "基线评估"
        total_score_median: 66
    
    optimizations:
      - round: 1
        version_before: "0.1.0"
        version_after: "0.1.1"
        score_before: 66
        score_after: 72
        decision: "keep"
```

### JSONL 训练集格式

```jsonl
{"type":"session_start","session_id":"ses-20260523-001","user_intent":"创建一个 PDF 处理的 Skill"}
{"type":"call","call_id":"call-001","phase":"意图抽取","tokens":2340,"passed":true}
{"type":"eval","eval_id":"eval-001","total_score":66}
{"type":"optimization","round":1,"score_before":66,"score_after":72,"decision":"keep"}
```

---

## 经验知识库

每个被创建的 Skill 拥有独立的 wiki 知识库，遵循 **karpathy-llm-wiki** 规范：

```
<skill-name>-wiki/
├── SKILL.md              # 遵循 karpathy-llm-wiki 规范
├── raw/                  # 不可变的原始素材
│   └── <topic>/
│       └── YYYY-MM-DD-descriptive-slug.md
└── wiki/                 # 编译后的知识页面
    ├── index.md          # 全局索引
    ├── log.md            # 追加操作日志
    └── <topic>/
        └── article.md
```

**SWRD 自身也践行这一理念**，其自身的 wiki 记录了完整的创建和进化经验。

---

## 版本号策略

- **起始版本**：`0.1.0`
- **棘轮前进** → 自动升级最小版本号（`0.1.0` → `0.1.1`）
- **用户明确要求** → 可升中版本（`0.1.x` → `0.2.0`）或大版本（`0.x.x` → `1.0.0`）
- **禁止回退版本号**
- **版本号唯一存放位置**：`SKILL.md` frontmatter
- **变更记录**：`CHANGELOG.md`

---

## Git 工作流

### 棘轮前进

```bash
# 1. 环境快照
git tag pre-experiment-round-{N}

# 2. 修改目标模块文件

# 3. 更新版本号

# 4. git commit（含结构化 message）
git commit -m "[SWRD] <skill-name> v0.1.0 → v0.1.1 | <变更摘要>

## 变更内容
- 目标维度：<维度名>
- 修改文件：<文件列表>
- 变更说明：<详细描述>

## 测试结果
- 基线分数：<旧分>
- 新分数：<新分>
- 提升幅度：<Δ分>

## 环境状态
- 实验前工程代码已回退到干净状态：是
- 实验后工程代码已回退到干净状态：是"
```

### 棘轮回退

```bash
# git revert（创建新 commit 回滚，不用 reset --hard）
git revert HEAD

# 联动工程回退
# git 仓库：git checkout -- .
# 非 git 目录：从 telemetry/snapshots/ 恢复备份

# 版本号不变（禁止回退版本号）
```

### 联动工程适配

支持 git 仓库、非 git 目录、自动 init、全量备份四种模式。

---

## 安装

### 前提条件

- Git
- 支持 Agent Skills 标准的 Agent 工具（Claude Code、CodeBuddy、OpenClaw、Cursor 等）

### 步骤

```bash
# 1. 克隆仓库
git clone https://github.com/<你的用户名>/swrd-skill-creator.git

# 2. 复制到你的 Agent 的 skills 目录
# Claude Code:
cp -r swrd-skill-creator/skills/swrd-skill-creator ~/.claude/skills/swrd-skill-creator

# CodeBuddy:
cp -r swrd-skill-creator/skills/swrd-skill-creator ~/.codebuddy/skills/swrd-skill-creator

# OpenClaw:
cp -r swrd-skill-creator/skills/swrd-skill-creator ~/.config/openclaw/skills/swrd-skill-creator

# 3. 在 Agent 对话框中开始使用
# "帮我创建一个 Skill"
```

---

## 贡献

### 开发流程

1. Fork 本仓库
2. 创建特性分支（`feat/xxx` 或 `fix/xxx`）
3. 使用 SWRD 自身来优化你的改动
4. 提交 PR

### 本地开发

```bash
# 克隆后直接使用 SWRD 优化自身
# 在 Agent 对话框中：
"使用 swrd-skill-creator 优化自身"
```

---

## 许可证

[MIT License](LICENSE)

---

## 项目结构

```
swrd-skill-creator/
├── SKILL.md                          # 元 Skill 主文件（版本号唯一位置）
├── skill.yaml                        # 机器可读配置
├── CHANGELOG.md                      # 变更记录
├── workflows/
│   └── state-machine.yaml            # 状态机（17 个状态）
├── evals/                            # 元 Skill 自身的 Eval
│   ├── trigger_cases.json
│   ├── success_cases.json
│   ├── failure_cases.json
│   └── benchmarks.json
├── scripts/                          # 辅助脚本
│   ├── version-bump.sh               # 版本号自动升级
│   └── env-snapshot.sh               # 联动工程快照/回退
├── references/                       # 参考文档
│   ├── scoring-rubric.md             # 8 维度评分细则
│   ├── runtime-review.md             # 跨平台审查规则
│   ├── modularity-review.md          # 模块化审查规则
│   └── git-workflow.md               # Git 工作流规范
├── assets/                           # 模板文件
│   ├── skill-template/               # 被创建 Skill 的模板
│   ├── wiki-template/                # karpathy-llm-wiki 模板
│   ├── log-template.yaml             # YAML 日志模板
│   └── log-template.jsonl            # JSONL 训练集模板
├── telemetry/                        # 元 Skill 自身的运行日志
│   ├── swrd-telemetry.yaml
│   └── swrd-telemetry.jsonl
└── swrd-skill-creator-wiki/          # 元 Skill 自身的经验知识库
    ├── SKILL.md
    ├── raw/
    └── wiki/
        ├── index.md
        ├── log.md
        ├── skill-creation/
        └── design-philosophy/
```

---

## 版本历史

- **0.1.5** — 记录设计思路和会话知识，新增 design-philosophy wiki 主题
- **0.1.4** — 初始化自身 wiki，践行经验积累理念
- **0.1.3** — 提升工作流清晰度和实测评分标准（总分 91，达成 90+ 目标）
- **0.1.2** — 补充边界条件处理
- **0.1.1** — 填充 skill-template 模板和辅助脚本
- **0.1.0** — 初始创建


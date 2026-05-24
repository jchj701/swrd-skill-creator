# 第一轮棘轮进化 — 填充模板和脚本

> Source: 本次会话
> Collected: 2026-05-23
> Published: 2026-05-23

## 问题

SKILL.md 中写了"从模板生成"，但 assets/skill-template/ 为空，scripts/ 为空。指令不可执行。

## 改进内容

### 填充的模板文件
1. assets/skill-template/SKILL.md.j2 — 被创建 Skill 的 SKILL.md 模板
2. assets/skill-template/skill.yaml.j2 — skill.yaml 模板
3. assets/skill-template/state-machine.yaml.j2 — 状态机模板
4. assets/skill-template/trigger_cases.json.j2 — Trigger Eval 模板
5. assets/skill-template/success_cases.json.j2 — Success Eval 模板
6. assets/skill-template/failure_cases.json.j2 — Failure Eval 模板
7. assets/skill-template/benchmarks.json.j2 — Benchmark 模板
8. assets/wiki-template/SKILL.md — karpathy-llm-wiki 模板

### 填充的脚本
1. scripts/version-bump.sh — 版本号自动升级脚本
2. scripts/env-snapshot.sh — 联动工程快照/回退脚本

## 效果
- D5 指令具体性：5 → 7
- D6 资源整合度：4 → 7
- 总分：52 → 68

## 经验
- 模板文件使用 .j2 后缀（Jinja2 风格），占位符用 <placeholder> 格式
- 脚本需要同时支持 Unix 和 Windows（使用 bash + 兼容处理）
- 模板和脚本应该在 SKILL.md 编写时同步创建，而不是事后补充
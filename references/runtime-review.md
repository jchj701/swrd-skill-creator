# 跨平台 Runtime 审查规则

## 红灯信号（必须修复）

| 红灯类型 | 典型表现 | 修复方案 |
|----------|----------|----------|
| Badge 钉死 | `[![Claude Code Skill]]` | 使用中立 badge |
| 措辞钉死 | "在 Claude Code 里" | "在你的 Agent 里" |
| 措辞钉死 | "Claude Code skill" | "Agent Skill" |
| 措辞钉死 | "Claude Code 用户" | "skills-aware agent 用户" |
| 安装命令钉死 | 只给 `~/.claude/skills/` 路径 | 提供多平台安装方式 |
| 安装命令钉死 | 只给 `/plugin install` | 补充多平台安装说明 |
| 路径硬编码 | `~/.claude/skills/xxx/` | 使用环境变量或通用路径 |
| 工具调用钉死 | 硬编码单 runtime 工具名 | 使用通用描述 |

## 绿灯信号（推荐包含）

- 使用 Agent Skills 标准格式
- 提供 npx skills add 通用安装命令
- README 中包含多平台安装说明
- 使用环境变量而非硬编码路径

## 审查命令

```bash
# 红灯扫描
grep -nE "(在 Claude Code|Claude Code skill|Claude Code 用户|^\[!\[Claude Code|~/\.claude/skills/[a-z]|/plugin install\b)" SKILL.md README.md 2>/dev/null
```

输出非空 = 未通过审查，必须在优化循环里修复。
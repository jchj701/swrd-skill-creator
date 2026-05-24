# Git 工作流规范

## 棘轮前进

```bash
# 1. 环境快照
git tag pre-experiment-round-{N}

# 2. 修改目标模块文件

# 3. 更新版本号（SKILL.md frontmatter 中的 version 字段）
# 0.1.0 → 0.1.1

# 4. git commit
git add <修改的文件>
git commit -m "[SWRD] <skill-name> v0.1.0 → v0.1.1 | <变更摘要>

## 变更内容
- 目标维度：<维度名>
- 修改文件：<文件列表>
- 变更说明：<详细描述>

## 测试结果
- 基线分数：<旧分>
- 新分数：<新分>
- 提升幅度：<Δ分>
- 测试模式：full_test / dry_run
- 工程代码快照：<commit hash>

## 环境状态
- 实验前工程代码已回退到干净状态：是
- 实验后工程代码已回退到干净状态：是"

# 5. 更新 CHANGELOG.md
```

## 棘轮回退

```bash
# 1. git revert（创建新 commit 回滚，不用 reset --hard）
git revert HEAD --no-edit

# 2. 联动工程回退
# 如果是 git 仓库：
git -C <工程路径> checkout -- .
# 如果是非 git 目录：
# 从 telemetry/snapshots/ 恢复备份

# 3. 版本号不变（禁止回退版本号）
```

## 联动工程通用适配

```yaml
test_environment:
  dependent_targets:
    - path: "../sample-project"
      type: "auto"  # auto / git / directory
      git:
        cleanup: "git checkout -- . && git clean -fd"
        snapshot: true
      non_git:
        auto_init: true
        backup_before: true
        restore_after: true
        backup_location: "<telemetry-dir>/snapshots/<target-name>/<timestamp>/"
  pre_cleanup: true
  post_cleanup: true
```

## 版本号规则

- 起始版本：0.1.0
- 棘轮前进 → 自动升级最小版本号（0.1.0 → 0.1.1）
- 用户明确要求 → 可升中版本（0.1.x → 0.2.0）或大版本（0.x.x → 1.0.0）
- 禁止回退版本号
- 版本号唯一存放位置：SKILL.md frontmatter
- 变更记录单独文件：CHANGELOG.md
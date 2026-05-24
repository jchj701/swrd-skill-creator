#!/usr/bin/env bash
# 联动工程快照/回退脚本
# 用法：
#   env-snapshot.sh backup <target-path> <snapshot-dir>
#   env-snapshot.sh restore <target-path> <snapshot-dir>
#   env-snapshot.sh cleanup <target-path>

set -euo pipefail

ACTION="${1:?Usage: $0 <backup|restore|cleanup> <target-path> [snapshot-dir]}"
TARGET_PATH="${2:?Usage: $0 <backup|restore|cleanup> <target-path> [snapshot-dir]}"

case "$ACTION" in
    backup)
        SNAPSHOT_DIR="${3:?Usage: $0 backup <target-path> <snapshot-dir>}"
        mkdir -p "$SNAPSHOT_DIR"
        
        if [ -d "$TARGET_PATH/.git" ]; then
            # Git 仓库：记录当前状态
            (cd "$TARGET_PATH" && git stash 2>/dev/null || true)
            (cd "$TARGET_PATH" && git checkout -- . 2>/dev/null || true)
            echo "git:cleaned"
        else
            # 非 git 目录：全量备份
            TIMESTAMP=$(date +%Y%m%d-%H%M%S)
            BACKUP_PATH="$SNAPSHOT_DIR/$TIMESTAMP"
            mkdir -p "$BACKUP_PATH"
            cp -r "$TARGET_PATH"/* "$BACKUP_PATH"/ 2>/dev/null || true
            echo "backup:$TIMESTAMP"
        fi
        ;;
    
    restore)
        SNAPSHOT_DIR="${3:?Usage: $0 restore <target-path> <snapshot-dir>}"
        
        if [ -d "$TARGET_PATH/.git" ]; then
            # Git 仓库：回退到干净状态
            (cd "$TARGET_PATH" && git checkout -- . 2>/dev/null || true)
            (cd "$TARGET_PATH" && git clean -fd 2>/dev/null || true)
            echo "git:restored"
        else
            # 非 git 目录：从最新备份恢复
            LATEST=$(ls -t "$SNAPSHOT_DIR" 2>/dev/null | head -1)
            if [ -n "$LATEST" ]; then
                rm -rf "$TARGET_PATH"/*
                cp -r "$SNAPSHOT_DIR/$LATEST"/* "$TARGET_PATH"/ 2>/dev/null || true
                echo "restored:$LATEST"
            else
                echo "warning:no_snapshot_found"
            fi
        fi
        ;;
    
    cleanup)
        if [ -d "$TARGET_PATH/.git" ]; then
            (cd "$TARGET_PATH" && git stash drop 2>/dev/null || true)
            echo "git:cleaned"
        else
            echo "ok"
        fi
        ;;
    
    *)
        echo "错误：无效的操作，使用 backup/restore/cleanup"
        exit 1
        ;;
esac
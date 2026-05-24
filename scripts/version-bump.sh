#!/usr/bin/env bash
# 版本号自动升级脚本
# 用法：version-bump.sh <skill-dir> [major|minor|patch]
# 默认升级 patch（最小版本号）

set -euo pipefail

SKILL_DIR="${1:?Usage: $0 <skill-dir> [major|minor|patch]}"
BUMP_TYPE="${2:-patch}"
SKILL_MD="$SKILL_DIR/SKILL.md"

if [ ! -f "$SKILL_MD" ]; then
    echo "错误：未找到 SKILL.md"
    exit 1
fi

# 读取当前版本号
CURRENT_VERSION=$(grep -E '^version: ' "$SKILL_MD" | sed 's/version: *"//;s/"//;s/^version: *//' | tr -d ' ')
if [ -z "$CURRENT_VERSION" ]; then
    echo "错误：无法读取版本号"
    exit 1
fi

# 解析三段式版本号
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

case "$BUMP_TYPE" in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
    *)
        echo "错误：无效的升级类型，使用 major/minor/patch"
        exit 1
        ;;
esac

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"

# 更新 SKILL.md 中的版本号
if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s/^version: .*/version: \"$NEW_VERSION\"/" "$SKILL_MD"
else
    sed -i "s/^version: .*/version: \"$NEW_VERSION\"/" "$SKILL_MD"
fi

echo "$CURRENT_VERSION → $NEW_VERSION"
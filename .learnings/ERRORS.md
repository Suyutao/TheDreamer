# Errors

## [ERR-20260718-001] schema-tests

**Logged**: 2026-07-18T21:38:00+08:00
**Priority**: low
**Status**: resolved
**Area**: tests

### Summary
课程表 Schema 测试首次构建缺少 Foundation 导入。

### Error
`Cannot find 'Date' in scope`

### Context
- 测试文件新增日期样例后只导入 Testing 和 SwiftData。
- App Target 构建不受影响。

### Suggested Fix
测试文件显式导入 Foundation 后重新执行测试。

### Metadata
- Reproducible: yes
- Related Files: The DreamerTests/The_DreamerTests.swift

### Resolution
- **Resolved**: 2026-07-18T21:39:00+08:00
- **Notes**: 已添加 Foundation 导入。

---

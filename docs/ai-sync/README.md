# TRAE / Codex 会话档案

这个目录只放同步工具的入口说明，不放完整私人会话。完整导出位于：

`/Users/suyutao/.codex/backups/trae-sync/live/`

运行：

```bash
python3 /Users/suyutao/.codex/tools/sync_trae_codex.py
```

要让 TRAE 的项目文件浏览器直接看到 48 个未归档 Codex 会话：

```bash
python3 /Users/suyutao/.codex/tools/sync_trae_codex.py --project-export
```

生成位置：`.trae/sync/codex-sessions/README.md`。这个目录已加入本地 Git 排除规则，不会进入提交。

通过 TRAE 的“复制全部”得到的 TRAE 当前会话回答保存在 `.trae/sync/trae-current-answer.md`，Codex 可以直接读取。

已安装本机定时任务 `com.suyutao.trae-codex-sync`，每 120 秒自动刷新 Codex→TRAE 副本。它不会读取系统剪贴板；需要保存 TRAE 回答时，先在 TRAE 中点“复制全部”，再执行：

```bash
python3 /Users/suyutao/.codex/tools/sync_trae_codex.py --capture-trae-clipboard
```

脚本会读取 Codex 的 `state_5.sqlite` 和 TRAE 的本地状态/日志，生成：

- `index.md`：两个平台的会话索引和当前限制
- `codex-sessions/`：Codex rollout JSONL 副本
- `trae-metadata.json`：TRAE 本地会话 ID、状态和可验证读取入口
- `project-context.json`：The Dreamer 的 Stories、docs、`.trae` 等项目资料清单
- `.trae/sync/trae-log-index.md`：从 TRAE renderer 日志提取的脱敏用户提问索引；只代表用户输入，不代表完整对话
- `.trae/sync/trae-sessions/`：每次执行 `--capture-trae-clipboard` 保存的 TRAE“复制全部”回答归档，不会覆盖旧文件

脚本不会修改两个平台的原始数据库，也不会调用远端写入接口。

## 当前项目事实

- `docs/plans/2026-07-18-native-rebuild-and-timetable.md` 是完整实施计划，里面的“完成标准”是验收要求，不代表全部已经完成。
- `.trae/specs/rebuild-ui-native/tasks.md` 的 Task 1 到 Task 7 当前仍未勾选，说明这份规格任务表没有被同步更新。
- `.trae/specs/rebuild-ui-native/checklist.md` 把四标签、clean build 和部分代码检查标成已完成，同时明确写出真实课程数据下的视觉验证尚未完成。
- 当前 Git 工作区存在大量未提交改动和新增文件；这些改动属于项目现状，不能只依据计划文档判断完成度。

这份入口文件和生成的索引可以被 TRAE 直接读取；完整对话仍保存在各自平台的私有导出目录中，尚未注入任何一方的原生侧边栏。

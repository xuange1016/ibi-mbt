# 20 Commit 开发路线

目标：每个 commit 都保持项目处于可理解、尽量可检查的状态，避免无意义拆分。

## 阶段 1：项目骨架

1. 初始化 MoonBit 包元信息和基础目录。
2. 补充 README 的项目目标、功能范围和示例配置。
3. 新增基础类型设计：配置文档、section、键值项。
4. 新增最小解析入口 `parse(text)` 的占位实现。

## 阶段 2：核心解析

5. 实现空行和注释行跳过。
6. 实现 section 行解析。
7. 实现 `key = value` 解析。
8. 实现 `key: value` 解析。
9. 实现全局配置项解析。
10. 增加重复 key 的处理策略。

## 阶段 3：查询 API

11. 实现 `get(section, key)`。
12. 实现 `get_or(section, key, default)`。
13. 实现 section 存在性检查。
14. 实现 keys/sections 枚举辅助 API。

## 阶段 4：边界行为

15. 支持 value 前后空白裁剪。
16. 支持简单引号值处理。
17. 增加错误信息：非法 section、非法键值行。
18. 增加解析位置：错误行号。

## 阶段 5：质量和参赛材料

19. 补齐单元测试和示例配置。
20. 完善 README、参赛说明和验收清单。

## Commit 规范

建议格式：

```text
feat: add section parser
test: cover comment parsing
docs: document parser limitations
fix: handle empty values
chore: add competition checklist
```

每次 commit 前建议执行：

```powershell
moon check
moon test
```

如果某一阶段暂时无法运行测试，需要在 commit message 或项目日志中说明原因。

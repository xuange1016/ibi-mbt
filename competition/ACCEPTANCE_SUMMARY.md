# ini-mbt 第一版验收说明

## 项目概述

`ini-mbt` 是一个 MoonBit INI 配置文件解析器，目标是移植 Python 标准库
`configparser` 的核心读取与查询能力，为 MoonBit 生态补充轻量配置解析基础库。

## 第一版已实现能力

- 解析全局键值配置。
- 解析 `[section]` 分区。
- 解析 `key = value` 配置项。
- 解析 `key: value` 配置项。
- 跳过空行。
- 跳过 `;` 和 `#` 开头的整行注释。
- 查询配置值：`get(section, key)`。
- 查询配置值并提供默认值：`get_or(section, key, default)`。
- 判断分区是否存在：`has_section(section)`。
- 判断配置键是否存在：`has_key(section, key)`。
- 列出分区名称：`section_names()`。
- 列出分区下的配置键：`keys(section)`。

## 与 Python configparser 的对应关系

| Python configparser | ini-mbt 第一版 |
| --- | --- |
| `ConfigParser.read_string(text)` | `parse(text)` |
| `config.get(section, key)` | `doc.get(section, key)` |
| `config.get(section, key, fallback=x)` | `doc.get_or(section, key, x)` |
| `config.has_section(section)` | `doc.has_section(section)` |
| `config.has_option(section, key)` | `doc.has_key(section, key)` |
| `config.sections()` | `doc.section_names()` |
| `config.options(section)` | `doc.keys(section)` |

## 当前测试结果

第一版包含 20 个测试，覆盖行处理、注释、分区、键值拆分、文本解析和查询 API。

```text
moon test
Total tests: 20, passed: 20, failed: 0.
```

## 第一版限制

- 暂不支持行尾注释。
- 暂不支持多行值。
- 暂不支持变量插值。
- 暂不支持自动类型转换。
- 暂不支持写回 INI 文本。
- 暂不追求与 Python `configparser` 完全兼容。

## 后续方向

- 增加错误类型和行号定位。
- 增加 `get_int`、`get_bool` 等类型转换 API。
- 增加行尾注释处理。
- 增加写回 INI 文本能力。
- 增加更完整的 Python `configparser` 兼容行为。

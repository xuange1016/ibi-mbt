# ini-mbt — INI 配置文件解析器

## 项目目标

将 Python 标准库 `configparser` 的核心功能移植到 MoonBit，实现 INI 格式配置文件的解析与查询。

## 功能要求

- 支持 `[section]` 分区
- 支持 `key = value` 键值对
- 支持注释（`;` 和 `#`）
- 支持引号包裹的值
- 支持无 section 的全局配置项
- 提供 `get(section, key)` 和 `get_or(section, key, default)` API

## 参考

- Python: `from configparser import ConfigParser`
- 已有生态：mooncakes 上有 toml/json 解析器，但无 INI 解析器

## 难度

⭐⭐ — 逐行解析逻辑，状态简单

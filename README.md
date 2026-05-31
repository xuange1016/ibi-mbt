# ini-mbt

MoonBit INI configuration parser inspired by Python's `configparser`.

`ini-mbt` provides a small parser and query API for common INI files. It is
intended to be a lightweight configuration library for MoonBit command-line
tools, examples, games, and small services.

## Features

- Parse `[section]` headers.
- Parse `key = value` and `key: value` entries.
- Parse global entries before any section.
- Skip blank lines.
- Skip whole-line comments starting with `;` or `#`.
- Query values with `get` and `get_or`.
- Check section and key existence.
- List section names and keys in insertion order.

## Quick Start

```moonbit
let text = #|host = localhost
            #|
            #|[server]
            #|port = 8080
            #|debug: true

let doc = parse(text)

inspect(doc.get("", "host").unwrap(), content="localhost")
inspect(doc.get("server", "port").unwrap(), content="8080")
inspect(doc.get_or("server", "missing", "fallback"), content="fallback")
```

## API

### `parse(text : String) -> IniDocument`

Parse INI text into a document.

### `IniDocument::get(section : String, key : String) -> String?`

Return a value from a section, or `None` when the section or key is missing.
Use the empty string section `""` for global entries.

### `IniDocument::get_or(section : String, key : String, default : String) -> String`

Return a value from a section, or the provided default when it is missing.

### `IniDocument::has_section(section : String) -> Bool`

Check whether a section exists.

### `IniDocument::has_key(section : String, key : String) -> Bool`

Check whether a key exists inside a section.

### `IniDocument::section_names() -> Array[String]`

Return section names in insertion order.

### `IniDocument::keys(section : String) -> Array[String]`

Return keys from a section in insertion order. Missing sections return an empty
array.

## Supported INI Subset

```ini
# global entry
host = localhost

[server]
port = 8080
debug: true

; comment
[database]
user = root
```

## Current Limitations

This first version intentionally keeps the parser small. It does not yet support:

- inline comments after values
- multiline values
- value interpolation
- automatic type conversion
- writing documents back to INI text
- full compatibility with Python `configparser`

## Development

Run checks and tests:

```powershell
moon check
moon test
```

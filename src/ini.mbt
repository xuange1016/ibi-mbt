/// Return a trimmed logical line.
///
/// This is the first tiny parser building block: before handling sections,
/// keys, values, and comments, every INI parser needs predictable whitespace
/// handling.
///
/// ```mbt check
/// test {
///   inspect(normalize_line("  host = localhost  "), content="host = localhost")
/// }
/// ```
pub fn normalize_line(line : String) -> String {
  line.trim().to_owned()
}

/// Check whether a normalized line is empty.
pub fn is_blank(line : String) -> Bool {
  normalize_line(line) == ""
}

/// Check whether a line is an INI comment.
///
/// INI files commonly use both `;` and `#` for whole-line comments.
pub fn is_comment(line : String) -> Bool {
  let normalized = normalize_line(line)
  normalized.has_prefix(";") || normalized.has_prefix("#")
}

/// Check whether a line looks like an INI section header.
///
/// A section header starts with `[` and ends with `]`, such as `[server]`.
pub fn is_section_header(line : String) -> Bool {
  let normalized = normalize_line(line)
  normalized.has_prefix("[") && normalized.has_suffix("]")
}

/// Extract the section name from a section header.
pub fn section_name(line : String) -> String {
  let normalized = normalize_line(line)
  normalized[1:normalized.length() - 1].trim().to_owned()
}

test "normalize line trims surrounding whitespace" {
  inspect(normalize_line("  port = 8080  "), content="port = 8080")
}

test "blank line detection uses normalized content" {
  inspect(is_blank("   "), content="true")
  inspect(is_blank(" key = value "), content="false")
}

test "comment line detection accepts semicolon and hash prefixes" {
  inspect(is_comment("; comment"), content="true")
  inspect(is_comment("  # comment"), content="true")
  inspect(is_comment("host = localhost"), content="false")
}

test "section header detection accepts bracketed names" {
  inspect(is_section_header("[server]"), content="true")
  inspect(is_section_header("  [database]  "), content="true")
  inspect(is_section_header("server"), content="false")
  inspect(is_section_header("[broken"), content="false")
}

test "section name extraction trims brackets and inner whitespace" {
  inspect(section_name("[server]"), content="server")
  inspect(section_name("  [ database ]  "), content="database")
}

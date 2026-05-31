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

/// Parsed INI document.
///
/// The empty string section stores global entries before any explicit section.
pub struct IniDocument {
  sections : Map[String, Map[String, String]]
}

/// Create an empty INI document.
pub fn empty() -> IniDocument {
  { sections: Map([]) }
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

/// Check whether a line is a key-value entry.
pub fn is_entry_line(line : String) -> Bool {
  let normalized = normalize_line(line)
  !is_blank(normalized) &&
  !is_comment(normalized) &&
  !is_section_header(normalized) &&
  (normalized.contains("=") || normalized.contains(":"))
}

fn entry_separator_index(line : String) -> Int {
  match (line.find("="), line.find(":")) {
    (Some(eq), Some(colon)) => if eq < colon { eq } else { colon }
    (Some(eq), None) => eq
    (None, Some(colon)) => colon
    (None, None) => abort("entry line must contain '=' or ':'")
  }
}

/// Extract the key from a key-value entry line.
pub fn entry_key(line : String) -> String {
  let normalized = normalize_line(line)
  let index = entry_separator_index(normalized)
  normalized[:index].trim().to_owned()
}

/// Extract the value from a key-value entry line.
pub fn entry_value(line : String) -> String {
  let normalized = normalize_line(line)
  let index = entry_separator_index(normalized)
  normalized[index + 1:].trim().to_owned()
}

test "normalize line trims surrounding whitespace" {
  inspect(normalize_line("  port = 8080  "), content="port = 8080")
}

test "blank line detection uses normalized content" {
  inspect(is_blank("   "), content="true")
  inspect(is_blank(" key = value "), content="false")
}

test "empty document starts without sections" {
  let doc = empty()
  inspect(doc.sections.length(), content="0")
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

test "entry line detection accepts equals and colon separators" {
  inspect(is_entry_line("host = localhost"), content="true")
  inspect(is_entry_line("port: 8080"), content="true")
  inspect(is_entry_line("[server]"), content="false")
  inspect(is_entry_line("; host = localhost"), content="false")
}

test "entry key and value extraction trims both sides" {
  inspect(entry_key("host = localhost"), content="host")
  inspect(entry_value("host = localhost"), content="localhost")
  inspect(entry_key(" port : 8080 "), content="port")
  inspect(entry_value(" port : 8080 "), content="8080")
}

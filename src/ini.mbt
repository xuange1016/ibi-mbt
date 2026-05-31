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

/// Parse INI text into a document.
pub fn parse(text : String) -> IniDocument {
  let doc = empty()
  let mut current_section = ""
  for line_view in text.split("\n") {
    let line = line_view.to_owned()
    if is_section_header(line) {
      current_section = section_name(line)
    } else if is_entry_line(line) {
      doc.apply_entry_line(current_section, line)
    }
  }
  doc
}

fn IniDocument::set_entry(
  self : IniDocument,
  section : String,
  key : String,
  value : String,
) -> Unit {
  let entries = match self.sections.get(section) {
    Some(existing) => existing
    None => {
      let created : Map[String, String] = Map([])
      self.sections.set(section, created)
      created
    }
  }
  entries.set(key, value)
}

fn IniDocument::apply_entry_line(
  self : IniDocument,
  section : String,
  line : String,
) -> Unit {
  self.set_entry(section, entry_key(line), entry_value(line))
}

/// Get a value from a section.
pub fn IniDocument::get(self : IniDocument, section : String, key : String) -> String? {
  match self.sections.get(section) {
    Some(entries) => entries.get(key)
    None => None
  }
}

/// Get a value from a section, or return a default when it is missing.
pub fn IniDocument::get_or(
  self : IniDocument,
  section : String,
  key : String,
  default : String,
) -> String {
  match self.get(section, key) {
    Some(value) => value
    None => default
  }
}

/// Check whether a section exists in the document.
pub fn IniDocument::has_section(self : IniDocument, section : String) -> Bool {
  self.sections.contains(section)
}

/// Check whether a key exists in a section.
pub fn IniDocument::has_key(self : IniDocument, section : String, key : String) -> Bool {
  match self.sections.get(section) {
    Some(entries) => entries.contains(key)
    None => false
  }
}

/// Return section names in insertion order.
pub fn IniDocument::section_names(self : IniDocument) -> Array[String] {
  self.sections.keys().collect()
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

test "parse stores global key-value entries" {
  let doc = parse("host = localhost\nport = 8080")
  inspect(doc.get("", "host").unwrap(), content="localhost")
  inspect(doc.get("", "port").unwrap(), content="8080")
}

test "parse stores entries under section headers" {
  let doc = parse("[server]\nhost = localhost\nport = 8080")
  inspect(doc.get("server", "host").unwrap(), content="localhost")
  inspect(doc.get("server", "port").unwrap(), content="8080")
}

test "parse skips blank lines and whole-line comments" {
  let doc = parse(
    "# comment\n\n[server]\n; another comment\nhost = localhost\n\nport = 8080",
  )
  inspect(doc.get("server", "host").unwrap(), content="localhost")
  inspect(doc.get("server", "port").unwrap(), content="8080")
}

test "document can store entries under a section" {
  let doc = empty()
  doc.set_entry("server", "host", "localhost")
  inspect(doc.sections.get("server").unwrap().get("host").unwrap(), content="localhost")
}

test "document can apply a key-value line" {
  let doc = empty()
  doc.apply_entry_line("server", "host = localhost")
  inspect(doc.get("server", "host").unwrap(), content="localhost")
}

test "document get returns values from a section" {
  let doc = empty()
  doc.set_entry("server", "host", "localhost")
  inspect(doc.get("server", "host").unwrap(), content="localhost")
  inspect(doc.get("server", "missing") is None, content="true")
  inspect(doc.get("missing", "host") is None, content="true")
}

test "document get_or returns defaults for missing values" {
  let doc = empty()
  doc.set_entry("server", "host", "localhost")
  inspect(doc.get_or("server", "host", "127.0.0.1"), content="localhost")
  inspect(doc.get_or("server", "port", "8080"), content="8080")
}

test "document can report section existence" {
  let doc = parse("[server]\nhost = localhost")
  inspect(doc.has_section("server"), content="true")
  inspect(doc.has_section("database"), content="false")
}

test "document can report key existence within sections" {
  let doc = parse("[server]\nhost = localhost")
  inspect(doc.has_key("server", "host"), content="true")
  inspect(doc.has_key("server", "port"), content="false")
  inspect(doc.has_key("database", "host"), content="false")
}

test "document can list section names" {
  let doc = parse("[server]\nhost = localhost\n[database]\nuser = root")
  let names = doc.section_names()
  inspect(names.length(), content="2")
  inspect(names[0], content="server")
  inspect(names[1], content="database")
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

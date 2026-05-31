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

test "normalize line trims surrounding whitespace" {
  inspect(normalize_line("  port = 8080  "), content="port = 8080")
}

test "blank line detection uses normalized content" {
  inspect(is_blank("   "), content="true")
  inspect(is_blank(" key = value "), content="false")
}

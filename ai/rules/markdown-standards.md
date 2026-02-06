# Markdown Standards

## Purpose

Ensure all markdown files follow consistent formatting and pass
markdown lint checks.

## Rules

### Required Standards

- **MD013**: Line length must not exceed 80 characters
- **MD022**: Headers must be surrounded by blank lines
  (before and after)
- **MD032**: Lists must be surrounded by blank lines (before and after)
- **MD040**: Fenced code blocks must have a language specified
- **MD047**: Files must end with a single newline
- **MD025**: Only one top-level heading (H1) per document
- **MD041**: First line must be a top-level heading

### Formatting Guidelines

1. **Headers**:
   - Always add blank line before header
   - Always add blank line after header
   - Use ATX-style headers (`#` not underlines)

2. **Lists**:
   - Add blank line before list starts
   - Add blank line after list ends
   - Use consistent marker (`-` for unordered, `1.` for ordered)

3. **Code blocks**:
   - Always specify language (e.g., python, javascript, text)
   - Add blank line before and after code blocks
   - Use `text` for plain text examples

4. **Line length**:
   - Keep lines under 80 characters
   - Break long lines naturally at sentence boundaries
   - For lists, indent continuation lines properly

5. **Line endings**:
   - End file with single newline
   - No trailing whitespace on lines

### When Creating/Editing Markdown

- **Always** validate markdown structure
- **Always** add proper blank lines around headers and lists
- **Always** end files with newline
- **Never** create lint violations

## Example

### Correct

```markdown
# Title

## Section

This is text.

### Subsection

- Item 1
- Item 2

Another paragraph.
```

### Incorrect

```markdown
# Title
## Section (missing blank line before header)
This is text.
### Subsection (missing blank line before header)
- Item 1 (missing blank line before list)
- Item 2
Another paragraph. (missing blank line after list)
```

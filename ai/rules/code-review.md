# Code Review Rule

## Purpose

Guide AI-assisted code reviews to ensure high-quality, maintainable,
and secure code through systematic analysis.

## Review Depth Levels

### Quick Review (Default)

Focus on critical issues only:

- Security vulnerabilities
- Obvious bugs or logic errors
- Major performance problems
- Breaking API changes

### Thorough Review

Comprehensive analysis including:

- All quick review items
- Code style and conventions
- Edge cases and error handling
- Test coverage gaps
- Documentation completeness
- Performance optimizations
- Maintainability concerns

**When to use:** Before merging to main, major refactors, public APIs

## Pre-Review Checklist

Before reviewing code, verify:

- [ ] Code compiles/runs without errors
- [ ] All tests pass
- [ ] No linting errors
- [ ] No obvious security issues (secrets, injection, XSS)
- [ ] Error handling exists for failure paths
- [ ] Edge cases considered

## Review Categories

### 1. Security

**Critical checks:**

- No hardcoded secrets or credentials
- Input validation on all external data
- SQL injection prevention (parameterized queries)
- XSS prevention (proper escaping)
- CSRF protection where applicable
- Authentication and authorization checks
- Secure dependency versions

**Common vulnerabilities:**

- Command injection in shell execution
- Path traversal in file operations
- Insecure deserialization
- Missing rate limiting
- Unvalidated redirects
- Insecure random number generation
- Information disclosure in error messages

### 2. Correctness

**Logic checks:**

- Algorithm correctness
- Boundary conditions handled
- Off-by-one errors
- Null/undefined/nil handling
- Race conditions in concurrent code
- Resource cleanup (files, connections, memory)
- Data consistency

**Common issues:**

- Missing error handling
- Incorrect conditional logic
- Loop termination problems
- Type conversion bugs
- Integer overflow/underflow

### 3. Performance

**Look for:**

- N+1 query problems
- Unnecessary loops or iterations
- Inefficient algorithms (O(n²) when O(n) possible)
- Memory leaks
- Blocking operations in async code
- Missing caching opportunities
- Database index usage
- Excessive network calls

**Don't over-optimize:**

- Premature optimization is bad
- Only suggest improvements for actual bottlenecks
- Prefer readability unless performance is critical
- Measure before optimizing

### 4. Maintainability

**Code organization:**

- Functions/methods do one thing
- Clear naming (functions, variables, types)
- Appropriate abstraction level
- DRY principle (but avoid premature abstraction)
- Consistent code style
- Reasonable file/function length

**Documentation:**

- Complex logic explained
- Public APIs documented
- Non-obvious decisions have comments
- README updated if needed
- Breaking changes documented

### 5. Testing

**Coverage expectations:**

- Unit tests for business logic
- Integration tests for critical paths
- Edge cases tested
- Error conditions tested
- Mocks used appropriately

**What to verify:**

- Tests actually test what they claim
- Tests are deterministic (no flaky tests)
- Test data is realistic
- Setup and teardown proper
- No implementation detail testing

## Output Format

### Inline Comments (Default)

```
file:42
🔴 CRITICAL: SQL injection vulnerability
Use parameterized queries instead of string concatenation.

file:87
🟡 WARNING: Missing error handling
Add error handling around this operation.

file:103
🔵 SUGGESTION: Simplify logic
This nested conditional can be flattened using early returns.
```

**Severity levels:**

- 🔴 CRITICAL: Security issues, data loss, crashes
- 🟡 WARNING: Bugs, correctness issues, performance problems
- 🔵 SUGGESTION: Style, maintainability, minor improvements
- 🤔 QUESTION: Clarification needed

### Summary Format

Use when requested or for large reviews:

```markdown
## Review Summary

**Overall:** [High-level assessment]

### Critical Issues (Must Fix)

- file:42 - SQL injection vulnerability
- file:58 - Unhandled null pointer

### Warnings (Should Fix)

- file:87 - Missing error handling
- file:124 - Potential race condition
- file:201 - Performance concern (N+1 queries)

### Suggestions (Nice to Have)

- file:103 - Logic simplification
- file:156 - Extract to helper function
- file:245 - Improve naming

### Positive Notes

- Good test coverage
- Clear function names
- Proper error handling in most places
- Well-documented complex logic
```

## Review Patterns

### When Code Looks Good

Don't just say "looks good" - be specific:

```markdown
✅ This code demonstrates:

- Proper input validation
- Clear error messages
- Good separation of concerns
- Comprehensive test coverage
- Secure handling of sensitive data
```

### When Multiple Issues Exist

Prioritize by severity:

1. Security issues first
2. Bugs and correctness
3. Performance problems
4. Maintainability
5. Style and conventions

### When Unsure

If uncertain about a pattern or approach:

```markdown
🤔 QUESTION: Is this shared across multiple instances?

If running multiple servers, consider distributed storage
instead of in-memory.
```

## Common Code Smells

**Complexity smells:**

- **God functions/classes**: Too many responsibilities
- **Deep nesting**: > 3 levels of indentation
- **Long parameter lists**: > 4-5 parameters
- **Long functions**: > 50-100 lines

**Data smells:**

- **Magic numbers**: Unexplained constants
- **Primitive obsession**: Using primitives instead of domain objects
- **Data clumps**: Same group of data passed around

**Change smells:**

- **Shotgun surgery**: One change requires editing many files
- **Divergent change**: One class changes for multiple reasons
- **Feature envy**: Method uses another class's data excessively

**Abstraction smells:**

- **Refused bequest**: Subclass doesn't use parent functionality
- **Lazy class**: Class does too little
- **Speculative generality**: Unused abstraction

## When NOT to Review

Skip detailed review for:

- Generated code (migrations, protobuf, etc.)
- Vendored dependencies
- Temporary debugging code
- Experimental/prototype code (unless requested)
- Auto-formatted code (trust the formatter)

## Review Anti-Patterns

**Avoid:**

- Nitpicking style in well-functioning code
- Suggesting rewrites without clear benefit
- Focusing on personal preference
- Being overly pedantic about edge cases
- Ignoring the bigger picture
- Bike-shedding (debating trivial details)

**Instead:**

- Focus on correctness and security first
- Suggest improvements, don't demand them
- Explain the "why" behind suggestions
- Recognize good patterns
- Consider the context and constraints
- Be constructive and helpful

## Review Comment Guidelines

### Good Review Comment

```
file:45
🔴 CRITICAL: Password stored without hashing

This stores passwords in plaintext. Hash passwords before storage
using a secure algorithm like bcrypt, scrypt, or Argon2.

Why: Plaintext passwords are a critical security vulnerability.
If the database is compromised, all user accounts are exposed.

Recommendation: Use a well-tested hashing library from your
language's ecosystem.
```

**Components:**

- Clear severity indicator
- Specific issue description
- Concrete solution
- Explanation of why it matters
- Actionable recommendation

### Bad Review Comment

```
file:45
This is wrong. Fix it.
```

**Problems:**

- Too vague
- No explanation
- No suggestion
- Not helpful

## Integration with Workflow

**Before review:**

1. Understand the change purpose (PR description or commit message)
2. Check if tests exist and pass
3. Set appropriate review depth

**During review:**

4. Start with security and correctness
5. Note positive patterns
6. Prioritize feedback by severity
7. Ask questions when unclear

**After review:**

8. Verify critical issues are clearly explained
9. Offer to help fix complex issues
10. Acknowledge good practices

## Review Checklist Template

```markdown
## Code Review

**Change type:** [Feature/Bug Fix/Refactor/Docs]

**Review depth:** [Quick/Thorough]

### Checklist

- [ ] Code compiles and runs
- [ ] Tests pass
- [ ] No security vulnerabilities
- [ ] Error handling appropriate
- [ ] Performance acceptable
- [ ] Documentation updated
- [ ] No code smells

### Findings

[Your review here]
```

## Language/Framework Specifics

**Note:** Language-specific best practices, framework conventions, and
coding standards should be documented in project-level CLAUDE.md files,
not in global rules.

Each project should specify:

- Language style guides to follow
- Framework best practices
- Project-specific code conventions
- Linting rules and configurations
- Approved libraries and patterns

## Summary

Global code review principles:

- **Security first:** Always check for vulnerabilities
- **Correctness second:** Ensure logic is sound
- **Prioritize issues:** Critical → Warning → Suggestion
- **Be specific:** Clear explanations with examples
- **Be constructive:** Help, don't just criticize
- **Consider context:** Understand constraints and trade-offs

Language-specific details belong in project CLAUDE.md.

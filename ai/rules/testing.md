# Testing Rule

## Purpose

Guide AI-assisted testing strategies to ensure reliable test coverage
without being prescriptive about implementation details.

## Testing Philosophy

### When to Write Tests

**Test-first (preferred for):**

- Well-defined requirements
- Core business logic
- Bug fixes (write failing test, then fix)
- Public APIs
- Critical paths (payment, auth, data integrity)

**Test-after (acceptable for):**

- Exploratory/prototype code
- UI styling and layout
- Configuration files
- Simple utilities

**No tests needed:**

- Generated code
- Third-party libraries
- Temporary debugging code
- Obvious pass-through code

## Test Types

### Unit Tests

Test individual functions/methods in isolation.

**Characteristics:**

- Fast (milliseconds)
- No external dependencies
- Test one thing per test
- Deterministic

**What to test:**

- Business logic calculations
- Data validation
- Error handling
- Edge cases

### Integration Tests

Test interaction between components.

**Characteristics:**

- Slower than unit tests
- May use real dependencies
- Test component interactions
- Verify data flow

**What to test:**

- Service layer interactions
- Database operations
- API endpoints
- External integrations (with mocks)

### End-to-End Tests

Test complete user workflows.

**Characteristics:**

- Slowest tests
- Use real or staging systems
- Test critical user paths
- Higher maintenance cost

**What to test:**

- Critical business workflows
- User authentication flows
- Payment processing
- Key user journeys

## Test Coverage Guidelines

### Priority Levels

**High Priority (Must Test):**

- Critical business logic
- Security-sensitive code
- Payment/financial operations
- Data validation
- Authentication/authorization

**Medium Priority (Should Test):**

- API endpoints
- Database queries
- Error handling
- Common user workflows

**Low Priority (Optional):**

- Simple getters/setters
- Obvious mappers
- Configuration loading
- UI component rendering

**Don't Test:**

- Third-party library internals
- Framework code
- Generated code
- Constants and enums

## Testing Principles

### Each Test Should

- Test one specific behavior
- Be independent (no test interdependencies)
- Be deterministic (same input = same result)
- Run fast
- Have clear failure messages

### Avoid

- Testing implementation details
- Tests depending on execution order
- Flaky tests (random failures)
- Tests that are slower than the code they test
- Over-mocking (mock only external dependencies)

## Edge Cases to Consider

Always test:

- Empty inputs ([], {}, "", null, undefined)
- Boundary values (min, max, zero, negative)
- Invalid inputs
- Error conditions
- Concurrent operations (when relevant)

## When to Ask AI vs Generate Tests

### Generate Tests Directly For

- Simple pure functions
- CRUD operations
- Standard validation logic
- Utility functions
- Straightforward API endpoints

**Example prompt:**

```
Write unit tests for this validation function covering:
- Valid inputs
- Invalid inputs
- Edge cases
- Error conditions
```

### Ask for Guidance On

- Complex business logic test strategy
- Integration test architecture
- Mocking approach for external services
- E2E test scenarios
- Performance testing approach
- Test data management strategy

**Example prompt:**

```
What's the best testing strategy for this payment processing
workflow? It involves:
- External payment API
- Database transactions
- Email notifications
- Webhook callbacks

How should I structure the tests?
```

## Test Maintenance

### Keep Tests Green

- Fix failing tests immediately
- Don't skip or ignore tests
- Remove obsolete tests
- Update tests when requirements change

### Refactor Tests

- Extract common setup to helpers
- Keep tests DRY (but prefer clarity)
- Use descriptive test names
- Add comments for complex test setup

### Test Code Quality

Apply same standards as production code:

- Clear naming
- No magic numbers
- Proper error handling
- Minimal duplication

## Common Anti-Patterns

### Don't Test Implementation

❌ **Bad:** Testing that specific internal methods are called

✅ **Good:** Testing behavior and outcomes

### Don't Create Dependencies

❌ **Bad:** Tests that rely on execution order

✅ **Good:** Each test sets up its own state

### Don't Test Everything

❌ **Bad:** Testing obvious getters/setters

✅ **Good:** Focus on logic that can break

### Don't Over-Mock

❌ **Bad:** Mocking everything including simple utilities

✅ **Good:** Mock only external dependencies (DB, APIs, file system)

## AI Testing Workflow

### 1. Implement Feature

Write the actual code first.

### 2. Request Tests

```
Write tests for this [function/class/module] covering:
- Happy path
- Error cases
- Edge cases
- [Any specific scenarios]
```

### 3. Review Generated Tests

Check that tests:

- Actually test the behavior
- Cover edge cases
- Are not testing implementation details
- Run fast

### 4. Iterate if Needed

```
Add tests for these missing scenarios:
- [Scenario 1]
- [Scenario 2]
```

## Test Checklist

Before considering tests complete:

- [ ] All critical paths covered
- [ ] Edge cases tested
- [ ] Error conditions tested
- [ ] Tests are fast and deterministic
- [ ] No test interdependencies
- [ ] Test names are descriptive
- [ ] Tests verify behavior, not implementation

## Language/Framework Details

**Note:** Specific testing frameworks, syntax, and patterns should be
documented in project-level CLAUDE.md files, not in global rules.

Each project should specify:

- Testing framework used (Jest, Pytest, etc.)
- Test file organization
- Naming conventions
- Mocking libraries
- Code coverage requirements
- CI/CD integration

## Summary

Global testing principles:

- **What to test:** Focus on business logic and critical paths
- **When to test:** Test-first for important code, test-after for
  utilities
- **How much:** Prioritize by criticality, aim for high coverage on
  critical code
- **AI role:** Generate simple tests directly, ask for strategy on
  complex testing

Implementation details belong in project CLAUDE.md.

# Architecture Rule

## Purpose

Guide AI-assisted architectural decisions and system design to create
scalable, maintainable, and well-structured software systems.

## When to Use Plan Mode

### Always Use Plan Mode For

- New features affecting multiple components
- Architectural changes (new patterns, refactors)
- Breaking changes to APIs or interfaces
- Performance optimizations requiring measurement
- Security enhancements needing careful review
- Database schema changes
- New external integrations
- Technology stack decisions

### Direct Implementation OK For

- Bug fixes in existing code
- Adding tests
- Documentation updates
- Simple configuration changes
- One-file changes with clear requirements
- Trivial refactors (rename, extract function)

## System Design Discussion Pattern

### 1. Understand Requirements

Before proposing solutions, clarify:

**Functional Requirements:**

- What problem are we solving?
- Who are the users?
- What are the core use cases?
- What data needs to be stored/processed?

**Non-Functional Requirements:**

- Expected scale (users, requests, data volume)
- Performance requirements (latency, throughput)
- Availability needs (uptime SLA)
- Security requirements
- Compliance constraints

**Constraints:**

- Budget limitations
- Technology stack restrictions
- Timeline
- Team expertise
- Integration requirements

### 2. Explore Options

Present 2-3 viable approaches with analysis:

**For each approach, document:**

- Description (what it is)
- Pros (advantages)
- Cons (disadvantages)
- Complexity (Low/Medium/High)
- Timeline estimate
- Risk assessment

**Then recommend:**

One approach with clear rationale based on requirements.

### 3. Define Architecture

Document the chosen approach:

**Components:**

- List major components
- Define responsibilities
- Identify interfaces

**Data Flow:**

- How data moves through the system
- Key interactions
- State management

**Technologies:**

- Choices and justifications
- Why selected over alternatives

**Trade-offs:**

- What was sacrificed
- Why the sacrifice is acceptable
- Mitigation strategies

## Trade-off Analysis Framework

### Common Trade-offs

**Performance vs Maintainability:**

- Optimization vs clean code
- Caching complexity vs simplicity
- Premature optimization vs technical debt

**Flexibility vs Simplicity:**

- Generic solutions vs specific implementations
- Abstraction layers vs direct code
- Future-proofing vs YAGNI

**Speed of Development vs Long-term Quality:**

- Quick solutions vs proper architecture
- Technical debt vs immediate delivery
- Prototype vs production-ready

**Cost vs Capability:**

- Build vs buy
- DIY vs third-party services
- Infrastructure expenses vs development time

### Decision Matrix Template

Use when comparing multiple options:

```
Criteria to evaluate:
- Performance
- Maintainability
- Cost
- Timeline
- Scalability
- Team expertise
- Risk level

Rate each option on each criterion.
```

## Documentation Requirements

### Minimal (Simple Changes)

- What changed and why
- How to verify it works

### Standard (Feature Changes)

- Problem being solved and solution approach
- Key components and their interactions
- API or interface changes
- Migration steps (if needed)
- Testing approach

### Comprehensive (Major Changes)

- Context and motivation
- Requirements (functional and non-functional)
- Solution design (architecture, data flow, components)
- Alternatives considered and why rejected
- Implementation details and key decisions
- Security considerations
- Performance impact
- Migration plan and rollback strategy
- Testing strategy
- Monitoring approach
- Risks and mitigations

## Architectural Principles

### Separation of Concerns

- Each component has one clear responsibility
- Minimize dependencies between components
- Clear interfaces between layers

### Don't Repeat Yourself (DRY)

- Extract common logic
- Reuse components appropriately
- But avoid premature abstraction

### Keep It Simple (KISS)

- Simplest solution that works
- Avoid over-engineering
- Add complexity only when needed

### You Aren't Gonna Need It (YAGNI)

- Build for current requirements
- Don't add features for hypothetical future needs
- Refactor when new requirements emerge

### Fail Fast

- Validate inputs early
- Detect errors at compile/startup time when possible
- Clear error messages

### Single Source of Truth

- One authoritative data source
- Derived data should be clearly marked
- Avoid data duplication when possible

## Common Anti-Patterns

### God Object

**Problem:** One component does everything

**Solution:** Break into focused, single-responsibility components

### Tight Coupling

**Problem:** Components directly depend on concrete implementations

**Solution:** Use interfaces/abstractions, dependency injection

### Premature Optimization

**Problem:** Optimizing before measuring actual performance

**Solution:** Profile first, optimize bottlenecks, keep it simple
initially

### Over-Engineering

**Problem:** Complex solutions for simple problems

**Solution:** Start simple, add complexity only when needed

### Analysis Paralysis

**Problem:** Endless planning, no implementation

**Solution:** Make decision with available information, iterate

### No Abstraction

**Problem:** Copy-paste code everywhere

**Solution:** Extract common patterns, but avoid premature abstraction

### Wrong Abstraction

**Problem:** Forced abstraction that doesn't fit

**Solution:** Prefer duplication over wrong abstraction

## API Design Principles

### General Guidelines

- Clear, consistent naming
- Predictable behavior
- Good error messages
- Versioning strategy
- Documentation
- Backwards compatibility when possible

### Error Handling

- Meaningful error codes
- Descriptive error messages
- Appropriate error types/categories
- Consistent error format

## Database Design Principles

### Schema Design

- Appropriate normalization
- Clear relationships
- Consistent naming
- Proper constraints
- Indexes on frequently queried fields
- Audit fields (created_at, updated_at)

### Migrations

- Always reversible
- Test on production-like data
- Backwards compatible when possible
- Never modify existing migrations

## Security Considerations

### Always Consider

- Authentication (who are you?)
- Authorization (what can you do?)
- Input validation and sanitization
- Secrets management (never hardcode)
- Encryption (data at rest and in transit)
- Rate limiting
- Audit logging

### Common Vulnerabilities

- SQL injection
- XSS (Cross-Site Scripting)
- CSRF (Cross-Site Request Forgery)
- Authentication bypass
- Insecure deserialization
- Unvalidated redirects
- Command injection
- Path traversal

## Performance Considerations

### Optimization Principles

- Measure before optimizing
- Profile to find actual bottlenecks
- Consider caching appropriately
- Pagination for large datasets
- Async processing for slow operations
- Connection pooling
- Query optimization

### What to Cache

- Expensive computations
- Frequently accessed data
- Rarely changing data

### What NOT to Cache

- User-specific sensitive data
- Rapidly changing data
- Large objects that exceed cache capacity

## Architecture Review Checklist

Before finalizing architecture:

- [ ] Requirements clearly understood
- [ ] Trade-offs explicitly documented
- [ ] Scalability considered
- [ ] Security threats identified and mitigated
- [ ] Data integrity and consistency addressed
- [ ] Error handling and recovery planned
- [ ] Monitoring and observability included
- [ ] Migration and rollback strategy defined
- [ ] Testing approach documented
- [ ] Team has necessary skills
- [ ] Timeline realistic
- [ ] Alternatives considered and documented

## When to Refactor Architecture

### Refactor When

- Performance degrades significantly (measured)
- Development velocity slows (team feedback)
- Adding features becomes difficult (evidence-based)
- Security vulnerabilities discovered
- Technology becomes obsolete (end of life)
- Scale requirements fundamentally change

### Don't Refactor When

- Just because it's not perfect
- Chasing latest trends without reason
- Team lacks bandwidth
- No metrics showing actual problem
- Based on hypothetical future needs

## Asking for Architectural Guidance

### Effective Questions

**Provide context:**

- Current architecture state
- Scale and performance requirements
- Team expertise level
- Timeline constraints
- Budget limitations

**Ask specific questions:**

- "What's the best approach for X given constraints Y and Z?"
- "How should we structure A to support requirements B?"
- "What are the trade-offs between approach 1 and 2?"
- "How do similar systems solve this problem?"

**Avoid vague questions:**

- "What's the best architecture?" (too broad)
- "Should I use microservices?" (missing context)
- "How do I scale this?" (no current state info)

## Project-Specific Details

**Note:** Specific architectural patterns, technology choices, and
implementation details should be documented in project-level CLAUDE.md
files, not in global rules.

Each project should specify:

- Chosen architectural pattern (MVC, microservices, layered, etc.)
- Technology stack and versions
- Coding standards and conventions
- Deployment strategy
- Monitoring and logging approach
- Specific design patterns in use

## Summary

Global architectural principles:

- **When to plan:** Use plan mode for significant changes
- **How to analyze:** Consider requirements, options, trade-offs
- **What to document:** Proportional to change size
- **Universal principles:** SOLID, DRY, KISS, YAGNI
- **Common pitfalls:** Recognize and avoid anti-patterns
- **Security first:** Always consider security implications

Implementation specifics belong in project CLAUDE.md.

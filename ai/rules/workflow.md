# Workflow Rule

## Purpose

Guide AI-assisted development workflows to maximize productivity,
maintain context, and deliver high-quality code through structured
vibecoding practices.

## Vibecoding Philosophy

**Vibecoding** = AI-assisted development that maintains flow state
through intelligent collaboration between human and AI.

**Core principles:**

- Incremental progress over big-bang changes
- Context preservation over constant resets
- Structured thinking over ad-hoc decisions
- Fast feedback loops over delayed validation

## Session Structure Approaches

### Approach 1: General Task-Based (Recommended for CLI)

Simple linear workflow for command-line AI tools:

```
┌─────────────────┐
│  1. Plan        │  Define scope and approach
├─────────────────┤
│  2. Implement   │  Write code incrementally
├─────────────────┤
│  3. Verify      │  Test and validate
├─────────────────┤
│  4. Reflect     │  Review and document learnings
└─────────────────┘
```

**Best for:**

- Claude Code CLI
- Linear, focused tasks
- Single developer

### Approach 2: Role-Based (Better for GUI Tools)

Switch between specialized AI roles for different tasks:

```
┌──────────────┐
│  Architect   │  System design, planning
├──────────────┤
│  Developer   │  Code implementation
├──────────────┤
│  Reviewer    │  Code review, refactoring
├──────────────┤
│  Tester      │  Test generation, debugging
└──────────────┘
```

**Best for:**

- GUI AI tools (Cursor, Windsurf, etc.)
- Complex projects
- Different expertise needed

**Role examples:**

- **Architect**: Focus on design, trade-offs, planning
- **Developer**: Fast implementation, minimal questioning
- **Reviewer**: Critical analysis, best practices
- **Tester**: Edge cases, test coverage, debugging

## Git Branching Strategy

### Branch Types and Permissions

**Feature branches** (`feature/name`):

- AI has full commit permission
- Auto-commit after each working chunk
- Frequent commits encouraged

**Chore branches** (`chore/name`):

- AI has full commit permission
- For refactoring, docs, tooling

**Fix branches** (`fix/name`):

- AI has full commit permission
- Bug fixes and patches

**Other branches** (main, develop, etc.):

- AI has read-only permission
- Must create feature branch to make changes
- Never commit directly to main

### Workflow Example

```bash
# AI automatically creates branch based on task type
Task: "Add user authentication"
→ Creates: feature/user-authentication

Task: "Fix login bug"
→ Creates: fix/login-validation

Task: "Update documentation"
→ Creates: chore/update-docs
```

### Auto-Commit Rules

**Commit after:**

- Each working, tested chunk
- Before switching contexts
- After fixing linting/test errors
- Every 30-45 minutes of work

**Commit message format:**

```
feat: add User model with validation
fix: handle null email in login
chore: update README with setup steps
test: add edge cases for password validation
```

## Context Management

### Check Context Usage

**Use `/usage` command to check:**

- Current context percentage
- Remaining quota
- Time until quota reset

**Check regularly:**

- Before starting major tasks
- After 30-60 minutes of work
- When conversation feels "heavy"

### When Context Reaches 80%

**Immediately:**

1. Complete current sub-task
2. Run `/usage` to confirm status
3. Summarize key decisions made
4. Commit all work
5. Decide: continue or start new session

**Summarize format:**

```markdown
## Session Summary

**Completed:**
- User model with validation
- Password hashing with bcrypt
- Login endpoint

**Key Decisions:**
- Using JWT with 1h expiry
- Refresh tokens in Redis
- bcrypt rounds = 10

**Next Steps:**
- Implement refresh token logic
- Add rate limiting
- Write integration tests

**Branch:** feature/user-auth
**Commits:** 8 commits, all tests passing
```

### Quota Reset Timing

**Before starting new session, consider:**

```
Current time: 14:00
Quota resets: 18:00 (4 hours)
Task estimate: 2 hours

Decision: Continue in current session
Reason: Task finishes before reset, no need to restart
```

```
Current time: 17:30
Quota resets: 18:00 (30 minutes)
Task estimate: 2 hours

Decision: Wait for reset, start fresh at 18:00
Reason: Avoid hitting limit mid-task
```

**Calculation:**

- Estimate task time
- Check time until quota reset (`/usage`)
- If task finishes before reset: continue
- If task spans reset: wait or split into smaller chunks

### When to Start New Sessions

**Start fresh when:**

- Context usage > 80% and work remains
- Quota about to reset (within 30 min)
- Switching to completely different task
- After completing major milestone
- Debugging complex issue (fresh perspective)
- Next day (unless urgent continuation)

**Continue existing when:**

- Context usage < 60%
- Task partially complete
- Building on previous work
- Plenty of time before quota reset
- Historical conversation needed

## Incremental Development

### Break Work into Chunks

**Example task:** Add user authentication

**Chunks:**

1. Create User model (15 min)
2. Implement password hashing (10 min)
3. Build login endpoint (20 min)
4. Add JWT generation (15 min)
5. Create auth middleware (15 min)
6. Write tests (25 min)

**Total:** ~100 min (manageable in one session)

### Commit Frequently

```bash
# After each working chunk
git add .
git commit -m "feat: add User model with validation"

# Small commits = easy to review and revert
```

### Verification After Each Chunk

**Quick checks:**

- [ ] Code compiles/runs
- [ ] Tests pass
- [ ] No linting errors
- [ ] Manual testing works
- [ ] No obvious bugs

## Task Decomposition

### Top-Down Approach

Start with high-level goal, break down:

```
Goal: E-commerce checkout flow

├── 1. Shopping Cart
│   ├── Add item
│   ├── Remove item
│   └── Calculate total
├── 2. Checkout Form
│   ├── Shipping address
│   ├── Payment details
│   └── Validation
└── 3. Order Processing
    ├── Create order
    ├── Process payment
    └── Send confirmation
```

### Bottom-Up Approach

Start with foundations, build up:

```
1. Data Layer → User, Product, Order models
2. Business Logic → CartService, OrderService
3. API Layer → REST endpoints
4. UI Components → Cart, Checkout pages
```

### Feature Slicing

Build complete vertical slices:

```
Slice 1: Simple checkout (no payment)
- Add to cart
- Checkout form
- Create order

Slice 2: Add payment
- Payment integration
- Order confirmation

Slice 3: Advanced features
- Coupon codes
- Shipping options
```

**Benefits:**

- Working feature at each stage
- Easy to demonstrate progress
- Can deploy incrementally

## AI Collaboration Patterns

### When to Ask vs Tell

**Ask the AI when:**

- Unsure of best approach
- Need architecture guidance
- Weighing trade-offs
- Learning new concept
- Complex problem needs brainstorming

**Tell the AI when:**

- Requirements are clear
- Simple implementation task
- Following established pattern
- Fixing obvious bug
- You know the solution

### Effective Prompting

**Vague (Bad):**

```
Make this better
```

**Specific (Good):**

```
Refactor this function to:
1. Use async/await instead of callbacks
2. Add error handling
3. Extract validation to separate function
```

**With Context (Best):**

```
This function handles user registration. It currently uses
callbacks and has grown to 100 lines. Refactor to:

1. Use async/await for better readability
2. Extract validation to validators
3. Separate email sending to EmailService
4. Keep main function under 30 lines

Current branch: feature/user-auth
Target pattern: async function registerUser(data: RegisterData)
```

### Iterative vs Complete Prompts

**Iterative (Slower):**

```
You: Create a user login endpoint
AI: [Creates basic endpoint]

You: Add rate limiting
AI: [Adds rate limiting]

You: Use Redis for rate limit storage
AI: [Updates to use Redis]
```

**Complete (Better):**

```
You: Create a user login endpoint with:
- JWT token generation
- Redis-based rate limiting (5 attempts per 15 min)
- Logging for security events
- Proper error responses
```

Single prompt with complete requirements = better results.

## Common Workflow Anti-Patterns

### Context Thrashing

❌ **Bad:**

```
Start task A
Switch to task B (incomplete A)
Switch to task C (incomplete B)
Context overload, nothing complete
```

✅ **Good:**

```
Complete task A
Commit and document
Start task B
Complete task B
...
```

### Big Bang Development

❌ **Bad:**

```
Code for hours straight
Try to run
200 errors
No idea where to start debugging
```

✅ **Good:**

```
Implement small piece
Test immediately
Commit if working
Next piece
...
```

### Ignoring Quota Limits

❌ **Bad:**

```
Context at 90%
Continue adding features
Hit limit mid-implementation
Lose context, can't complete
```

✅ **Good:**

```
Check /usage regularly
At 80%: Complete current task
Summarize and commit
Start fresh or wait for reset
```

### Over-Engineering

❌ **Bad:**

```
Build generic framework for single use case
Add features "we might need"
Over-abstraction
```

✅ **Good:**

```
Solve current problem simply
Refactor when second use case appears
Add abstraction only when needed
```

## Session Templates

### Feature Development

```markdown
## Feature: [Name]

**Goal:** [What we're building]

**Branch:** feature/[name]

**Tasks:**

- [ ] Model/schema
- [ ] Business logic
- [ ] API endpoint
- [ ] Tests
- [ ] Documentation

**Notes:**

[Decisions, gotchas, etc.]
```

### Bug Fix

```markdown
## Bug Fix: [Issue]

**Problem:** [Description]

**Root Cause:** [Analysis]

**Solution:** [Approach]

**Testing:**

- [ ] Reproduce bug
- [ ] Fix code
- [ ] Add test
- [ ] Verify fix

**Branch:** fix/[name]
```

### Refactoring

```markdown
## Refactor: [Component]

**Current State:** [Problems]

**Target State:** [Goals]

**Approach:**

1. Add tests for current behavior
2. Refactor incrementally
3. Verify tests still pass

**Safety:**

- [ ] Full test coverage before starting
- [ ] Commit after each safe step
- [ ] No behavior changes

**Branch:** chore/refactor-[name]
```

## Workflow Checklist

### Before Starting Work

- [ ] Clear goal defined
- [ ] Tasks broken into chunks
- [ ] Git branch created (feature/chore/fix)
- [ ] Check `/usage` for quota status
- [ ] CLAUDE.md and TODO.md ready

### During Work

- [ ] Implementing incrementally
- [ ] Testing as you go
- [ ] Committing frequently
- [ ] Checking `/usage` every 30-60 min
- [ ] Taking breaks

### After Work

- [ ] All tests passing
- [ ] Changes committed
- [ ] TODO.md updated
- [ ] Key decisions documented in CLAUDE.md
- [ ] Next steps identified

## Learning from Sessions

Keep a learning log in CLAUDE.md:

```markdown
## Session Log: 2024-01-30

**Topic:** User authentication implementation

**What worked well:**

- Breaking into small tasks
- Test-first approach
- Frequent commits

**What didn't:**

- Underestimated JWT complexity
- Should have researched refresh tokens first

**Learned:**

- bcrypt async patterns
- JWT best practices
- Redis for token storage

**Next time:**

- Research before implementing
- Allocate more time for testing
```

## Git Workflow Integration

### Standard Workflow

```bash
# AI creates feature branch automatically
# (based on task type: feature/chore/fix)

# AI commits frequently during work
git add src/models/user.ts
git commit -m "feat: add User model"

git add src/services/auth.ts
git commit -m "feat: add authentication service"

# Push when task complete
git push -u origin feature/user-auth
```

### Multi-Task Workflow

```bash
# Task 1: Feature
Branch: feature/user-auth
Status: In progress

# Task 2: Bug fix (while feature in progress)
Branch: fix/login-validation
Status: Completed, merged

# Task 3: Documentation
Branch: chore/update-readme
Status: Not started
```

**Rule:** One active branch per task type at a time.

## Conclusion

Effective vibecoding requires:

- **Structure:** Planned sessions with clear goals
- **Incremental progress:** Small, verified, committed steps
- **Context awareness:** Monitor `/usage`, respect quota limits
- **Smart timing:** Consider quota reset before starting tasks
- **Git discipline:** Auto-commit on feature branches, respect
  permissions
- **Continuous improvement:** Learn from each session

Master these patterns, and AI-assisted development becomes a natural
extension of your development flow.

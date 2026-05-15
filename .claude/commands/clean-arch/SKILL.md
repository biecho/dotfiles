---
name: clean-arch
description: >
  Apply Clean Architecture (Robert C. Martin) principles to design, scaffold, refactor, review,
  or migrate codebases. This skill should be used when the user mentions clean architecture,
  hexagonal architecture, ports and adapters, onion architecture, dependency inversion in
  architecture, layered architecture refactoring, domain-driven design structure, separating
  business logic from frameworks, or asks about structuring a project with proper separation
  of concerns. Also use when the user asks to review code for architectural violations,
  scaffold a new project with proper layers, or migrate a monolith toward cleaner boundaries.
argument-hint: <action> [language] [path-or-module]
allowed-tools: [Read, Bash, Edit, Write, Agent, AskUserQuestion]
---

# /clean-arch — Clean Architecture Design & Enforcement

Apply, scaffold, review, or refactor code following Clean Architecture principles.

**Actions** (inferred from `$ARGUMENTS` or conversation context):

| Action | What it does |
|--------|-------------|
| `scaffold` | Generate a full project skeleton with all layers |
| `review` | Audit existing code for architectural violations |
| `refactor` | Move code to the correct layer, extract boundaries |
| `explain` | Teach Clean Architecture concepts with project-specific examples |
| `migrate` | Plan incremental migration from a tangled codebase |
| `diagram` | Output an ASCII dependency diagram of the current structure |

If no action is specified, infer the most useful one from context.

---

## The Dependency Rule — The One Rule That Matters

> Source code dependencies must only point inward. Nothing in an inner circle can know
> anything about something in an outer circle.

```
┌─────────────────────────────────────────────────────┐
│  Frameworks & Drivers   (DB, Web, UI, Devices)      │
│  ┌───────────────────────────────────────────────┐  │
│  │  Interface Adapters  (Controllers, Presenters,│  │
│  │    Gateways, Repository Implementations)      │  │
│  │  ┌─────────────────────────────────────────┐  │  │
│  │  │  Use Cases / Application Layer          │  │  │
│  │  │  (Interactors, Input/Output Ports)      │  │  │
│  │  │  ┌───────────────────────────────────┐  │  │  │
│  │  │  │  Entities / Domain Layer          │  │  │  │
│  │  │  │  (Business Rules, Value Objects)  │  │  │  │
│  │  │  └───────────────────────────────────┘  │  │  │
│  │  └─────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
          ← Dependencies point INWARD ←
```

**Dependency direction:**
```
Domain       → NOTHING (zero external dependencies)
Application  → Domain only
Infrastructure → Application + Domain
Presentation → Application (optionally Domain for read models)
```

When an inner layer needs to call an outer layer, use **Dependency Inversion**: define an
interface in the inner circle, implement it in the outer circle.

---

## Layer Responsibilities — Quick Reference

### Domain / Entities (innermost)

**Contains:** Enterprise business rules, domain objects, value objects, domain events,
domain exceptions, enumerations representing domain concepts.

**Rules:**
- Zero framework imports — only the language itself
- Entities encapsulate behavior, not just data
- Value Objects are immutable (`frozen=True`, `readonly`, `const`)
- Domain validation lives here (invariants the business cares about)

**Does NOT contain:** ORM decorators, serialization, HTTP code, database annotations.

### Application / Use Cases (second layer)

**Contains:** Application-specific business rules, use case interactors, input/output port
interfaces, request/response DTOs for boundary crossing, application events.

**Rules:**
- Orchestrates entities to fulfill a use case
- Defines repository interfaces (ports) that infrastructure implements
- Each use case is a single class/function with one public method
- Request/Response models are plain data structures, not entities

**Does NOT contain:** Direct DB access, framework code, UI logic, entity business rules.

### Interface Adapters (third layer)

**Contains:** Controllers, presenters, gateway implementations, repository implementations,
data mappers between layers, view models.

**Rules:**
- Converts external input → use case request models
- Converts use case output → format suitable for external consumers
- All SQL/query code stays here
- Maps between domain entities and persistence models

### Frameworks & Drivers (outermost)

**Contains:** DB drivers, ORM config, web framework setup, DI container wiring, external API
clients, message queue drivers, the main/entry point.

**Rules:**
- Minimal custom code — mostly glue
- This is where all "details" live
- Dependency injection composition root lives here

---

## Boundary Crossing Rules

Data crossing a boundary must be in the form most convenient for the **inner** circle:

| Crossing | Correct | Wrong |
|----------|---------|-------|
| HTTP → Use Case | Plain request DTO | Passing `HttpRequest` object inward |
| Use Case → DB | Entity via repository interface | Use case importing SQLAlchemy |
| DB → Use Case | Domain entity returned by repo | Returning ORM model to use case |
| Use Case → API response | Response DTO | Entity with serialization decorators |

---

## Action: `scaffold`

Read `references/scaffolds.md` for the target language. Generate the full directory structure
with placeholder files. Each file should contain a brief docstring explaining what belongs
there and one minimal example.

Detect the language from `$ARGUMENTS`, the current project, or ask the user.

## Action: `review`

Read `references/review-checklist.md`. Systematically audit the codebase:

1. **Discover entry points and project structure** — map modules/packages to layers
2. **Check dependency direction** — trace imports; flag any inner→outer violations
3. **Check boundary crossing** — ensure data crosses boundaries as plain DTOs
4. **Check layer responsibilities** — flag business logic in controllers, SQL in use cases, etc.
5. **Check entity purity** — entities must have zero framework imports
6. **Report** — produce a findings table: `| File | Line | Violation | Severity | Fix |`

## Action: `refactor`

1. Run `review` first to identify violations
2. Prioritize by severity (entity violations > use case violations > adapter violations)
3. For each violation, apply the minimal transformation:
   - Extract interface when inner layer depends on outer
   - Move business logic from controller into use case or entity
   - Replace framework types at boundaries with plain DTOs
   - Introduce repository pattern where use cases touch DB directly
4. Verify the dependency rule holds after each change

## Action: `explain`

Use examples from the current project (if available) or generate minimal examples.
Read `references/concepts.md` for detailed explanations and analogies.
Tailor depth to the user's apparent experience level.

## Action: `migrate`

Read `references/migration.md` for the incremental migration strategy.
Produce a phased migration plan that:
1. Identifies the current architectural state
2. Defines target state per module
3. Creates migration phases that keep the system working at each step
4. Prioritizes by business value and coupling

## Action: `diagram`

Analyze the current project structure and output:
1. An ASCII layer diagram showing which modules map to which layers
2. A dependency graph showing import directions
3. Violations highlighted with `[!]` markers

---

## Decision Flowchart: Right-Sizing the Architecture

```
Is the domain logic non-trivial?
├── No  → Simple layered arch (MVC/CRUD) is fine
└── Yes
    Will the project be maintained > 1 year?
    ├── No  → Simple layered arch
    └── Yes
        Team > 3 developers?
        ├── No  → Lightweight (2-3 layers, skip formal ports)
        └── Yes → Full Clean Architecture
```

Recommend the lightest architecture that solves the actual problem. Over-engineering is
an anti-pattern. Three similar lines is better than a premature abstraction.

---

## Anti-Patterns to Flag

When reviewing or refactoring, actively flag these:

1. **Framework leak** — Entity/use-case imports a framework (ORM, HTTP, serialization)
2. **Anemic use case** — Use case is just `return repo.save(entity)` with no orchestration
3. **Phantom interface** — Interface with exactly one implementation and no testing benefit
4. **God mapper** — Single model used for DB, API, domain, and command input
5. **Bypass** — Controller calls repository directly, skipping the use case layer
6. **Test over-mocking** — Tests mock domain entities instead of using real objects
7. **Ceremony overload** — Trivial CRUD going through all four layers unnecessarily
8. **Identity copy** — Mapping between layers copies identical fields with zero transformation

---

## Testing Strategy by Layer

| Layer | Test Type | What to Mock | What's Real |
|-------|-----------|-------------|-------------|
| Domain | Unit tests (most tests here) | Nothing | Everything — entities have no deps |
| Application | Unit tests | Repositories, external services | Entities, value objects, use case logic |
| Infrastructure | Integration tests | Nothing — use real DB (containers) | Repository implementations, DB mapping |
| Presentation | API/E2E tests | Optionally mock application layer | HTTP routing, serialization |

---

## Reference Files

For detailed content beyond this overview, read the relevant reference file:

- `references/scaffolds.md` — Full project skeletons for Python, TypeScript, Go, Java/Kotlin, C#, Rust
- `references/concepts.md` — Deep explanations: DIP, boundary crossing, ports/adapters, CQRS, events, DI patterns
- `references/review-checklist.md` — Exhaustive architectural review checklist with grep patterns
- `references/comparisons.md` — Clean vs Hexagonal vs Onion vs DDD: overlaps and differences
- `references/patterns.md` — Repository, Unit of Work, CQRS, Event-Driven, Mediator patterns in detail

# Clean Architecture — Comparison with Related Architectures

## Clean Architecture vs Hexagonal Architecture vs Onion Architecture

### Hexagonal Architecture (Ports & Adapters) — Alistair Cockburn, 2005

**Core idea:** The application has a hexagonal core with ports (interfaces) and adapters
(implementations). The hexagonal shape has no intrinsic significance — it just provides
room to draw multiple ports.

**Two sides:**
- **Driving/Primary side:** External actors that drive the application (users, tests,
  other systems). Primary adapters wrap ports and translate external inputs.
- **Driven/Secondary side:** External systems the application drives (databases, email,
  APIs). Secondary adapters implement ports, injected into the application.

**Key distinction from Clean Architecture:** Hexagonal does NOT prescribe internal
layering of the core. The hexagon is one unit. Clean Architecture specifies entities
vs use cases vs interface adapters as distinct layers within the core.

### Onion Architecture — Jeffrey Palermo, 2008

**Core idea:** Layers like an onion, with the domain model at the center. Emphasizes
a rich domain model.

**Layers (inside out):**
1. Domain Model (entities, value objects)
2. Domain Services (business logic that doesn't fit in entities)
3. Application Services (use case orchestration)
4. Infrastructure (outermost — DB, UI, external services)

**Key distinction from Clean Architecture:** Onion uses "Domain Services" where Clean
uses "Use Cases." Onion emphasizes DDD concepts more explicitly. Onion places domain
services as a separate layer between entities and application services.

### Side-by-Side Comparison

| Aspect | Hexagonal | Onion | Clean |
|--------|-----------|-------|-------|
| Year | 2005 | 2008 | 2012 |
| Author | Cockburn | Palermo | Martin |
| Core principle | Ports & Adapters | Domain at center | Dependency Rule |
| Inner layer | Application core (undivided) | Domain Model | Entities |
| Business logic | Inside hexagon | Domain Services | Use Cases / Interactors |
| External access | Adapters | Infrastructure | Frameworks & Drivers |
| Boundary mechanism | Ports (interfaces) | Interfaces at layer edges | Input/Output Ports |
| Prescribes internal layers? | **No** | Yes | Yes |
| Emphasis | Symmetry of I/O | Rich domain model | Explicit use cases |
| DDD affinity | Compatible | **Native** | Compatible |
| Testing emphasis | Mock adapters | Test domain in isolation | Test each layer |

### What They All Agree On

Despite naming differences, all three architectures converge on:

1. **Business logic at the center**, independent of everything else
2. **Dependencies point inward** (outer depends on inner, never reverse)
3. **Interfaces at boundaries** to invert dependencies where needed
4. **Framework independence** — the core doesn't know about HTTP, SQL, etc.
5. **Testability** — core logic testable without infrastructure
6. **Swappable externalities** — change DB, UI, or external service without touching core

**Practical implication:** If someone says they use "Hexagonal Architecture" and another
says "Clean Architecture," they likely produce very similar code. The differences are
mostly in terminology and how explicitly they subdivide the inner layers.

## Domain-Driven Design (DDD) and Clean Architecture

DDD is **not an architecture** — it's a design methodology. Clean Architecture, Hexagonal,
and Onion can all serve as the architectural foundation for a DDD application.

### What DDD Provides

- **Ubiquitous Language** — Shared vocabulary between developers and domain experts
- **Bounded Contexts** — Explicit boundaries where a model applies
- **Aggregates** — Cluster of entities treated as a unit for data changes
- **Entities** — Objects with identity and lifecycle
- **Value Objects** — Immutable objects defined by their attributes
- **Domain Events** — Records of significant occurrences
- **Repositories** — Abstraction for persistence (the DDD pattern predates Clean Architecture)
- **Domain Services** — Stateless operations that don't fit in entities or value objects
- **Application Services** — Orchestrators that coordinate domain objects

### Mapping DDD to Clean Architecture

| DDD Concept | Clean Architecture Layer |
|-------------|------------------------|
| Entities, Value Objects, Aggregates | Domain/Entities (innermost) |
| Domain Services | Domain/Entities |
| Domain Events | Domain/Entities |
| Repository Interfaces | Domain or Application |
| Application Services | Use Cases / Application |
| Anti-Corruption Layer | Interface Adapters |
| Repository Implementations | Infrastructure |
| Bounded Context | Module/package boundary |

### When to Combine DDD + Clean Architecture

Use both when:
- Complex domain with rich business rules
- Multiple teams working on different bounded contexts
- Domain experts actively involved in development
- The domain model needs to evolve independently from infrastructure

Use Clean Architecture without full DDD when:
- Domain is well-understood and stable
- No domain experts to collaborate with
- Business rules exist but aren't complex enough for Aggregates/Events
- You want clean separation without the full DDD ceremony

## CQRS and Clean Architecture

CQRS (Command Query Responsibility Segregation) fits naturally:

```
Commands (writes):
  Controller → Command DTO → Use Case → Domain → Repository → DB (write model)

Queries (reads):
  Controller → Query DTO → Query Handler → Read Repository → DTO (read model)
```

The query side can bypass the domain layer entirely since no business rules are
enforced on reads. This is a valid and common optimization.

## Event Sourcing and Clean Architecture

Event Sourcing stores state as a sequence of events rather than current state.
In Clean Architecture:

- **Events are domain objects** — they live in the entity/domain layer
- **Event Store is a repository** — interface in domain, implementation in infrastructure
- **Projections** live in infrastructure (they build read models from events)
- **Event handlers** live in the application layer (they orchestrate side effects)

## Microservices and Clean Architecture

Each microservice can internally use Clean Architecture. The boundaries align:

- **API contracts** = Interface Adapters layer
- **Business logic** = Domain + Use Case layers
- **External calls to other services** = Infrastructure layer (via gateway interfaces)
- **Anti-corruption layers** between services = Interface Adapters

Clean Architecture within a microservice prevents the common "distributed monolith"
problem where services are tightly coupled through shared data models.

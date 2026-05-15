# Clean Architecture — Deep Concepts

## Origins and Synthesis

Robert C. Martin published "The Clean Architecture" on August 13, 2012, synthesizing ideas from:

- **Hexagonal Architecture** (Ports & Adapters) — Alistair Cockburn, 2005
- **Onion Architecture** — Jeffrey Palermo, 2008
- **DCI** (Data, Context, Interaction)
- **BCE** (Boundary, Control, Entity)

All produce the same outcome: systems that are framework-independent, testable,
UI-independent, database-independent, and decoupled from external agencies.

## The Five Goals

1. **Framework independence** — Frameworks are tools, not constraints
2. **Testability** — Business rules tested without UI, DB, web server, or any external element
3. **UI independence** — Swap web UI for console UI without changing business rules
4. **Database independence** — Swap Postgres for MongoDB without touching business rules
5. **External agency independence** — Business rules know nothing about the outside world

## Dependency Inversion Principle (DIP) in Architecture

Uncle Bob's key mechanism:

> "We take advantage of dynamic polymorphism to create source code dependencies that
> oppose the flow of control so that we can conform to The Dependency Rule no matter
> what direction the flow of control is going in."

### How it works at boundaries

When a use case needs to call a presenter (outer layer):

```
[Use Case] ──calls──▶ [Output Port Interface (inner)]
                              ▲
                              │ implements
                       [Presenter (outer)]
```

The use case depends on the interface (inner). The presenter implements it (also depends
on the interface). Source code dependency points inward even though control flows outward.

### When NOT to apply DIP

- When the outer layer genuinely depends on the inner layer naturally (controller → use case)
- When there will never be a second implementation AND you don't need to mock it for testing
- For simple value transformations that don't cross architectural boundaries

## Input/Output Ports

**Input Port** — Interface that the outer layer calls to invoke a use case:
```
Controller ──▶ [Input Port Interface] ◀── Use Case Interactor (implements it)
```

**Output Port** — Interface that the use case calls for side effects:
```
Use Case ──▶ [Output Port Interface] ◀── Repository/Presenter (implements it)
```

This is how Clean Architecture achieves the "Screaming Architecture" goal: the use case
layer screams what the application does, not what framework it uses.

## Request/Response Models

Data structures that carry information across boundaries. Key rules:

- Simple, serializable data structures (dataclasses, records, structs)
- No behavior — pure data
- Not entities (entities stay inside; DTOs cross boundaries)
- Not framework objects (no `HttpRequest`, no ORM models)
- Can be shared between layers as they are plain data

```
HTTP Request ──▶ [Controller] ──▶ UseCaseRequest ──▶ [Use Case]
                                                        │
HTTP Response ◀── [Controller] ◀── UseCaseResponse ◀────┘
```

## The Entity Layer — Business Rules

Entities encapsulate **enterprise-wide** business rules: rules that would exist even if
there were no software system at all.

**Entity design principles:**

1. **Rich domain model** — Entities have behavior, not just getters/setters
2. **Protect invariants** — Constructor and methods ensure the entity is always in a valid state
3. **Identity** — Entities are identified by ID, not by attribute values
4. **Lifecycle** — Entities can change state over time while maintaining identity

**Value Object design principles:**

1. **Immutability** — Once created, never modified
2. **Equality by value** — Two `Money(10, "USD")` are equal regardless of reference
3. **Self-validating** — Reject invalid states at construction
4. **Side-effect free** — Methods return new instances instead of mutating

## CQRS (Command Query Responsibility Segregation)

Separates read and write models within Clean Architecture:

**Commands** (writes):
- Named in imperative: `RegisterEmployee`, `RejectPayment`
- Validated by use cases
- Return only acknowledgment or new entity ID
- Should be idempotent where possible
- Go through full domain model

**Queries** (reads):
- Named as questions: `GetEmployeeList`, `FindOrderById`
- Can bypass the domain layer (no business validation for reads)
- Return DTOs matching UI needs
- Can use denormalized read models for performance
- Simpler path: Controller → Query Handler → Read Repository → DTO

**When to use CQRS:**
- Read and write models differ significantly
- Read performance requires denormalization
- Different scaling requirements for reads vs writes
- Complex domain where writes need rich validation

**When to skip:**
- Simple CRUD with identical read/write shapes
- Small teams where the overhead isn't justified

## Domain Events

Immutable facts about what occurred in the domain. Unlike commands, events cannot be rejected.

**Three levels:**

1. **Domain Events** — Within a bounded context. `OrderConfirmed`, `UserRegistered`.
   Raised by entities, handled by use cases or domain services.

2. **Application Events** — Triggered after use cases complete. Initiate side effects
   (emails, notifications). Live in the Application Layer.

3. **Integration Events** — Cross bounded context boundaries. Stored in the same
   transaction as the command (Outbox Pattern), processed later by background workers.

## Dependency Injection Patterns

### Constructor Injection (recommended everywhere)

```python
class OrderService:
    def __init__(
        self,
        order_repo: OrderRepository,       # interface
        payment: PaymentProcessor,          # interface
        notifications: NotificationService, # interface
    ):
        self._order_repo = order_repo
        self._payment = payment
        self._notifications = notifications
```

### Composition Root

All DI wiring happens in one place at the outermost layer:

```python
# main.py or container.py — the ONLY place that knows all concrete types
order_service = OrderService(
    order_repo=PostgresOrderRepository(db_session),
    payment=StripePaymentProcessor(api_key),
    notifications=EmailNotificationService(smtp_config),
)
```

### DI Frameworks by Language

| Language | Options |
|----------|---------|
| Python | `dependency-injector`, manual wiring, FastAPI `Depends()` |
| TypeScript | Inversify, tsyringe, manual wiring |
| Go | Manual wiring in `main.go` (idiomatic — no framework) |
| Java/Kotlin | Spring DI, Dagger 2, Guice |
| C# | Built-in `Microsoft.Extensions.DependencyInjection`, Autofac |
| Rust | Manual wiring with generics (the type system IS the DI framework) |

## The Unit of Work Pattern

Groups multiple repository operations into a single transaction:

```python
class UnitOfWork(ABC):
    users: UserRepository
    orders: OrderRepository

    @abstractmethod
    def commit(self) -> None: ...
    @abstractmethod
    def rollback(self) -> None: ...
    @abstractmethod
    def __enter__(self) -> "UnitOfWork": ...
    @abstractmethod
    def __exit__(self, *args) -> None: ...
```

Usage in a use case:
```python
class PlaceOrderUseCase:
    def __init__(self, uow: UnitOfWork):
        self._uow = uow

    def execute(self, request: PlaceOrderRequest) -> PlaceOrderResponse:
        with self._uow as uow:
            user = uow.users.find_by_id(request.user_id)
            order = Order.create(user, request.items)
            uow.orders.save(order)
            uow.commit()
            return PlaceOrderResponse(order_id=str(order.id))
```

## Screaming Architecture

Uncle Bob's principle that looking at the top-level directory structure should tell you
what the application **does**, not what framework it uses.

**Bad (screams "I'm a Rails app"):**
```
app/
├── controllers/
├── models/
├── views/
```

**Good (screams "I'm a health clinic system"):**
```
src/
├── patients/
├── appointments/
├── billing/
├── prescriptions/
```

This aligns with the bounded context concept from DDD — organize by business capability,
not by technical layer. Within each bounded context, the layers exist internally.

## When Clean Architecture Adds More Cost Than Value

- Teams of 1-3 on simple domains
- Trivial CRUD applications
- Prototypes and throwaway code
- Library/SDK development (different architectural concerns)
- CLI tools and scripts
- Projects where the entire codebase fits in one developer's mental model
- Early-stage startups where speed-to-market dominates everything

**The velocity test:** If the architecture is slowing you down and you cannot articulate
what future flexibility it buys you, it's the wrong architecture for your context.

**Right-sizing principle:** You can always add layers later. Start with the simplest
structure that separates business logic from I/O. Extract formal ports/adapters when
you actually need to swap implementations or when testing demands it.

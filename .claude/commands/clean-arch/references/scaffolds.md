# Clean Architecture — Project Scaffolds by Language

## Python

```
src/
├── domain/
│   ├── __init__.py
│   ├── entities/
│   │   ├── __init__.py
│   │   └── user.py              # @dataclass User with business methods
│   ├── value_objects/
│   │   ├── __init__.py
│   │   ├── email.py             # @dataclass(frozen=True) Email with validation
│   │   └── money.py             # @dataclass(frozen=True) Money(amount, currency)
│   ├── events/
│   │   ├── __init__.py
│   │   └── user_registered.py   # Domain event dataclass
│   ├── repositories.py          # ABC interfaces: UserRepository, etc.
│   └── exceptions.py            # DomainError, UserNotFoundError, etc.
├── application/
│   ├── __init__.py
│   ├── use_cases/
│   │   ├── __init__.py
│   │   ├── register_user.py     # RegisterUserUseCase with execute()
│   │   └── get_user.py          # GetUserUseCase
│   ├── ports/
│   │   ├── __init__.py
│   │   ├── input_ports.py       # Protocol classes for use case interfaces
│   │   └── output_ports.py      # Protocol classes for presenters
│   ├── dtos.py                  # Request/Response dataclasses
│   └── services.py              # Application services (optional)
├── infrastructure/
│   ├── __init__.py
│   ├── persistence/
│   │   ├── __init__.py
│   │   ├── models.py            # SQLAlchemy/ORM models
│   │   ├── repositories.py      # SqlAlchemyUserRepository implements ABC
│   │   └── mappers.py           # Entity ↔ ORM model converters
│   ├── messaging/
│   │   └── __init__.py
│   └── external_services/
│       └── __init__.py
├── presentation/
│   ├── __init__.py
│   ├── api/
│   │   ├── __init__.py
│   │   ├── routes.py            # FastAPI/Flask route definitions
│   │   ├── schemas.py           # Pydantic models for API input/output
│   │   └── dependencies.py      # FastAPI dependency injection
│   └── cli/
│       └── __init__.py
├── container.py                  # DI wiring (composition root)
└── main.py                       # Entry point
tests/
├── unit/
│   ├── domain/
│   │   └── test_user.py         # Entity business rule tests (no mocks)
│   └── application/
│       └── test_register_user.py # Use case tests with mock repos
├── integration/
│   └── persistence/
│       └── test_user_repo.py    # Real DB tests with containers
└── e2e/
    └── test_api.py              # Full stack API tests
```

### Python Idioms

**Entities** — `@dataclass` with behavior methods:
```python
from dataclasses import dataclass, field
from uuid import UUID, uuid4

@dataclass
class Order:
    id: UUID = field(default_factory=uuid4)
    items: list = field(default_factory=list)
    status: str = "pending"

    def confirm(self):
        if not self.items:
            raise ValueError("Cannot confirm empty order")
        self.status = "confirmed"
```

**Value Objects** — immutable `@dataclass(frozen=True)`:
```python
@dataclass(frozen=True)
class Email:
    address: str

    def __post_init__(self):
        if "@" not in self.address:
            raise ValueError(f"Invalid email: {self.address}")
```

**Repository interfaces** — `ABC` or `Protocol`:
```python
from abc import ABC, abstractmethod
from typing import Optional

class UserRepository(ABC):
    @abstractmethod
    def save(self, user: User) -> User: ...

    @abstractmethod
    def find_by_id(self, user_id: UUID) -> Optional[User]: ...

    @abstractmethod
    def find_by_email(self, email: str) -> Optional[User]: ...
```

**Use cases** — one class, one `execute()`:
```python
@dataclass
class RegisterUserRequest:
    email: str
    name: str

@dataclass
class RegisterUserResponse:
    user_id: str

class RegisterUserUseCase:
    def __init__(self, user_repo: UserRepository):
        self._user_repo = user_repo

    def execute(self, request: RegisterUserRequest) -> RegisterUserResponse:
        if self._user_repo.find_by_email(request.email):
            raise UserAlreadyExistsError(request.email)
        user = User(email=Email(request.email), name=request.name)
        saved = self._user_repo.save(user)
        return RegisterUserResponse(user_id=str(saved.id))
```

**Async variant** — async repository + async use case:
```python
class UserRepository(ABC):
    @abstractmethod
    async def save(self, user: User) -> User: ...

class RegisterUserUseCase:
    async def execute(self, request: RegisterUserRequest) -> RegisterUserResponse:
        ...
```

**DI wiring** — composition root in `container.py`:
```python
from infrastructure.persistence.repositories import SqlAlchemyUserRepository
from application.use_cases.register_user import RegisterUserUseCase

def create_register_user_use_case(session) -> RegisterUserUseCase:
    return RegisterUserUseCase(
        user_repo=SqlAlchemyUserRepository(session)
    )
```

**Enforcement** — `import-linter` in `pyproject.toml`:
```toml
[tool.importlinter]
root_packages = ["src"]

[[tool.importlinter.contracts]]
name = "Domain independence"
type = "independence"
modules = ["src.domain"]

[[tool.importlinter.contracts]]
name = "Layered architecture"
type = "layers"
layers = [
    "src.presentation",
    "src.infrastructure",
    "src.application",
    "src.domain",
]
```

---

## TypeScript / JavaScript

```
src/
├── domain/
│   ├── entities/
│   │   ├── User.ts              # User class with private constructor + factory
│   │   └── Order.ts
│   ├── value-objects/
│   │   ├── Email.ts             # Immutable, validated on construction
│   │   └── Money.ts
│   ├── events/
│   │   └── UserRegistered.ts
│   ├── repositories/
│   │   └── UserRepository.ts    # Interface only
│   └── errors/
│       └── DomainError.ts
├── application/
│   ├── use-cases/
│   │   ├── RegisterUser.ts      # Command handler
│   │   └── GetUser.ts           # Query handler
│   ├── dtos/
│   │   ├── RegisterUserRequest.ts
│   │   └── UserResponse.ts
│   └── ports/
│       └── EventBus.ts          # Interface
├── infrastructure/
│   ├── persistence/
│   │   ├── TypeOrmUserRepository.ts
│   │   ├── UserModel.ts         # ORM entity (TypeORM/Prisma)
│   │   └── mappers/
│   │       └── UserMapper.ts
│   ├── http-client/
│   │   └── AxiosPaymentGateway.ts
│   └── messaging/
│       └── RabbitMQEventBus.ts
├── presentation/
│   ├── controllers/
│   │   └── UserController.ts
│   ├── middlewares/
│   │   └── errorHandler.ts
│   └── routes/
│       └── userRoutes.ts
├── container.ts                  # Inversify or manual DI
└── index.ts
```

### TypeScript Idioms

**Entity with private constructor:**
```typescript
export class User {
    private constructor(
        public readonly id: string,
        public readonly email: Email,
        private _name: string,
        private _status: UserStatus
    ) {}

    static create(email: Email, name: string): User {
        return new User(uuid(), email, name, UserStatus.Active);
    }

    get name(): string { return this._name; }

    deactivate(): void {
        if (this._status !== UserStatus.Active) {
            throw new DomainError("User already inactive");
        }
        this._status = UserStatus.Inactive;
    }
}
```

**Repository interface:**
```typescript
export interface UserRepository {
    save(user: User): Promise<User>;
    findById(id: string): Promise<User | null>;
    findByEmail(email: Email): Promise<User | null>;
}
```

**Enforcement** — `dependency-cruiser` or `eslint-plugin-import`:
```javascript
// .dependency-cruiser.cjs
module.exports = {
    forbidden: [
        {
            name: "domain-no-infra",
            from: { path: "^src/domain" },
            to: { path: "^src/infrastructure" },
        },
        {
            name: "domain-no-presentation",
            from: { path: "^src/domain" },
            to: { path: "^src/presentation" },
        },
    ],
};
```

---

## Go

```
internal/
├── domain/
│   ├── user.go                  # User struct + methods
│   ├── email.go                 # Email value object
│   ├── errors.go                # Domain errors
│   └── repository.go           # Interface definitions
├── application/
│   ├── register_user.go         # RegisterUserHandler
│   ├── get_user.go
│   └── dto.go                   # Request/Response structs
├── infrastructure/
│   ├── postgres/
│   │   ├── user_repository.go   # PostgresUserRepository
│   │   └── models.go            # DB scan structs
│   └── http_client/
│       └── payment_gateway.go
├── presentation/
│   ├── http/
│   │   ├── handler.go           # HTTP handlers
│   │   ├── router.go
│   │   └── middleware.go
│   └── grpc/
│       └── server.go
cmd/
└── server/
    └── main.go                  # DI wiring + server start
```

### Go Idioms

**Implicit interfaces** — define where consumed, not where implemented:
```go
// In domain/repository.go (consumer defines the interface)
type UserRepository interface {
    Save(ctx context.Context, user *User) error
    FindByID(ctx context.Context, id uuid.UUID) (*User, error)
    FindByEmail(ctx context.Context, email string) (*User, error)
}
```

**Constructor injection:**
```go
type RegisterUserHandler struct {
    repo UserRepository
}

func NewRegisterUserHandler(repo UserRepository) *RegisterUserHandler {
    return &RegisterUserHandler{repo: repo}
}

func (h *RegisterUserHandler) Handle(ctx context.Context, req RegisterUserRequest) (*RegisterUserResponse, error) {
    existing, _ := h.repo.FindByEmail(ctx, req.Email)
    if existing != nil {
        return nil, ErrUserAlreadyExists
    }
    user := NewUser(req.Email, req.Name)
    if err := h.repo.Save(ctx, user); err != nil {
        return nil, fmt.Errorf("saving user: %w", err)
    }
    return &RegisterUserResponse{UserID: user.ID.String()}, nil
}
```

**Wiring in main.go:**
```go
func main() {
    db := postgres.Connect(cfg.DatabaseURL)
    userRepo := postgres.NewUserRepository(db)
    registerHandler := application.NewRegisterUserHandler(userRepo)
    router := http.NewRouter(registerHandler)
    log.Fatal(router.ListenAndServe(":8080"))
}
```

**Enforcement** — `go-cleanarch` linter in CI.

---

## Java / Kotlin (Spring Boot)

Use separate **Gradle/Maven modules** — the compiler prevents illegal imports.

```
project/
├── domain/                       # Module: zero dependencies
│   └── src/main/java/com/example/domain/
│       ├── entities/
│       │   └── User.java
│       ├── valueobjects/
│       │   └── Email.java
│       ├── events/
│       │   └── UserRegistered.java
│       ├── repositories/
│       │   └── UserRepository.java   # Interface
│       └── exceptions/
│           └── UserNotFoundException.java
├── application/                  # Module: depends on domain
│   └── src/main/java/com/example/application/
│       ├── usecases/
│       │   └── RegisterUserUseCase.java
│       ├── dto/
│       │   ├── RegisterUserRequest.java
│       │   └── RegisterUserResponse.java
│       └── ports/
│           └── EventPublisher.java   # Interface
├── infrastructure/               # Module: depends on application + domain
│   └── src/main/java/com/example/infrastructure/
│       ├── persistence/
│       │   ├── JpaUserRepository.java
│       │   ├── UserEntity.java       # JPA entity (NOT domain entity)
│       │   └── UserMapper.java
│       └── messaging/
│           └── SpringEventPublisher.java
└── bootstrap/                    # Module: Spring Boot app, DI config
    └── src/main/java/com/example/
        └── Application.java
```

**Enforcement** — ArchUnit:
```java
@AnalyzeClasses(packages = "com.example")
public class ArchitectureTest {
    @ArchTest
    static final ArchRule domainShouldNotDependOnOtherLayers =
        noClasses().that().resideInAPackage("..domain..")
            .should().dependOnClassesThat()
            .resideInAnyPackage("..application..", "..infrastructure..", "..presentation..");
}
```

---

## C# / .NET

```
Solution/
├── Domain/
│   ├── Entities/
│   │   └── User.cs
│   ├── ValueObjects/
│   │   └── Email.cs
│   ├── DomainEvents/
│   │   └── UserRegisteredEvent.cs
│   ├── Repositories/
│   │   └── IUserRepository.cs       # Interface
│   └── Exceptions/
│       └── DomainException.cs
├── Application/
│   ├── Features/
│   │   └── Users/
│   │       ├── Commands/
│   │       │   ├── RegisterUser/
│   │       │   │   ├── RegisterUserCommand.cs
│   │       │   │   ├── RegisterUserCommandHandler.cs
│   │       │   │   └── RegisterUserCommandValidator.cs
│   │       └── Queries/
│   │           └── GetUser/
│   │               ├── GetUserQuery.cs
│   │               └── GetUserQueryHandler.cs
│   ├── Abstractions/
│   │   └── IEventBus.cs
│   └── Behaviors/
│       ├── ValidationBehavior.cs     # MediatR pipeline
│       └── LoggingBehavior.cs
├── Infrastructure/
│   ├── Persistence/
│   │   ├── ApplicationDbContext.cs
│   │   ├── Configurations/
│   │   │   └── UserConfiguration.cs  # EF Core config
│   │   ├── Repositories/
│   │   │   └── UserRepository.cs
│   │   └── Migrations/
│   └── Services/
│       └── EmailService.cs
└── WebApi/
    ├── Controllers/
    │   └── UsersController.cs
    └── Program.cs
```

---

## Rust

Use **workspace crates** for compile-time dependency enforcement.

```
workspace/
├── Cargo.toml                    # [workspace] members
├── domain/
│   ├── Cargo.toml                # Zero dependencies (except std)
│   └── src/
│       ├── lib.rs
│       ├── entities/
│       │   ├── mod.rs
│       │   └── user.rs
│       ├── value_objects/
│       │   └── email.rs
│       ├── repository.rs         # Trait definitions
│       └── errors.rs
├── application/
│   ├── Cargo.toml                # depends on domain only
│   └── src/
│       ├── lib.rs
│       ├── use_cases/
│       │   └── register_user.rs
│       └── dto.rs
├── infrastructure/
│   ├── Cargo.toml                # depends on domain + application
│   └── src/
│       ├── lib.rs
│       └── postgres/
│           ├── mod.rs
│           └── user_repository.rs
└── web/
    ├── Cargo.toml                # depends on all
    └── src/
        └── main.rs               # Axum/Actix routes + DI wiring
```

### Rust Idioms

**Traits as ports:**
```rust
#[async_trait]
pub trait UserRepository: Send + Sync {
    async fn save(&self, user: &User) -> Result<User, DomainError>;
    async fn find_by_id(&self, id: Uuid) -> Result<Option<User>, DomainError>;
}
```

**Generics with trait bounds (zero-cost DI):**
```rust
pub struct RegisterUserUseCase<R: UserRepository> {
    repo: R,
}

impl<R: UserRepository> RegisterUserUseCase<R> {
    pub fn new(repo: R) -> Self { Self { repo } }

    pub async fn execute(&self, req: RegisterUserRequest) -> Result<RegisterUserResponse, AppError> {
        // ...
    }
}
```

**Newtypes for compile-time invariants:**
```rust
pub struct Email(String);

impl Email {
    pub fn new(value: &str) -> Result<Self, DomainError> {
        if !value.contains('@') {
            return Err(DomainError::InvalidEmail);
        }
        Ok(Self(value.to_string()))
    }
}
```

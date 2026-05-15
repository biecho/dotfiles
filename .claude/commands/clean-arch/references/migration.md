# Clean Architecture — Incremental Migration Strategy

## Guiding Principle

Never rewrite. Always migrate incrementally. The system must work at every step.

## Phase 0: Assessment

Before touching code, understand the current state:

1. **Draw the current dependency graph** — What imports what? Where does business logic live?
2. **Identify the domain** — What are the core business concepts? What are the business rules?
3. **Identify pain points** — Where does coupling hurt? What's hard to test? What breaks often?
4. **Assess team readiness** — Does the team understand Clean Architecture? Budget time for learning.

### Architectural State Classification

| State | Description | Migration Effort |
|-------|-------------|-----------------|
| **Monolithic MVC** | Business logic in controllers, SQL in models | Medium-High |
| **Fat Models** | All logic in ORM models, no separation | Medium |
| **Service Layer** | Services exist but depend on frameworks | Low-Medium |
| **Partially Layered** | Some separation exists, inconsistent | Low |
| **Framework-Coupled Domain** | Domain objects decorated with framework annotations | Medium |

## Phase 1: Extract Domain Entities (Highest Priority)

**Goal:** Pure domain objects with zero framework dependencies.

### Steps

1. Identify your most important business objects (usually 3-5 core entities)
2. Create a `domain/` directory
3. For each entity:
   a. Create a new plain class (no ORM decorators, no framework imports)
   b. Move business logic from the current location (controller, service, model) into entity methods
   c. Add domain validation (invariants the business cares about)
   d. Create value objects for domain concepts (Email, Money, Address)
4. Write unit tests for every domain entity — they should need zero mocks

### Migration Pattern: Entity Extraction

```
BEFORE:
class UserModel(db.Model):              # ORM model with business logic
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    email = Column(String, unique=True)
    plan = Column(String)
    
    def can_upgrade(self):               # Business logic trapped in ORM model
        return self.plan != "enterprise"
    
    def upgrade(self, new_plan):
        if not self.can_upgrade():
            raise ValueError("Cannot upgrade")
        self.plan = new_plan

AFTER:
# domain/entities/user.py — pure, no imports
class User:
    def __init__(self, id, email, plan):
        self.id = id
        self.email = email
        self.plan = plan

    def can_upgrade(self):
        return self.plan != "enterprise"

    def upgrade(self, new_plan):
        if not self.can_upgrade():
            raise ValueError("Cannot upgrade")
        self.plan = new_plan

# infrastructure/persistence/models.py — ORM model (data only)
class UserModel(db.Model):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    email = Column(String, unique=True)
    plan = Column(String)

    def to_entity(self) -> User:
        return User(id=self.id, email=self.email, plan=self.plan)

    @classmethod
    def from_entity(cls, user: User) -> "UserModel":
        return cls(id=user.id, email=user.email, plan=user.plan)
```

### Verification

- [ ] Domain entities import nothing from frameworks
- [ ] Every entity has unit tests that run without a database
- [ ] Existing functionality still works (run integration/e2e tests)

## Phase 2: Extract Repository Interfaces

**Goal:** Define how the application accesses data, without specifying how.

### Steps

1. Create repository interfaces in `domain/` or `application/`
2. Define only the operations your use cases actually need (not generic CRUD)
3. Implement the interfaces in `infrastructure/` using your existing ORM
4. Replace direct ORM calls in services/controllers with repository calls

### Migration Pattern: Repository Extraction

```
BEFORE:
class UserService:
    def get_user(self, user_id):
        return db.session.query(UserModel).get(user_id)  # Direct ORM call

AFTER:
# domain/repositories.py
class UserRepository(ABC):
    @abstractmethod
    def find_by_id(self, user_id) -> Optional[User]: ...

# infrastructure/persistence/repositories.py
class SqlAlchemyUserRepository(UserRepository):
    def __init__(self, session):
        self._session = session

    def find_by_id(self, user_id) -> Optional[User]:
        model = self._session.query(UserModel).get(user_id)
        return model.to_entity() if model else None

# Existing service updated
class UserService:
    def __init__(self, user_repo: UserRepository):  # Injected
        self._user_repo = user_repo

    def get_user(self, user_id):
        return self._user_repo.find_by_id(user_id)
```

## Phase 3: Extract Use Cases

**Goal:** Each application operation is an explicit, testable use case.

### Steps

1. Identify the main operations (list them by looking at controller methods / API endpoints)
2. For each operation, create a use case class with:
   - A request DTO (input)
   - A response DTO (output)
   - An `execute()` method
   - Injected dependencies (repository interfaces, gateways)
3. Move orchestration logic from controllers/services into use cases
4. Controllers become thin translators: HTTP → request DTO → use case → response DTO → HTTP

### Migration Pattern: Use Case Extraction

```
BEFORE:
@app.route("/orders", methods=["POST"])
def create_order():
    data = request.json                          # HTTP parsing
    user = db.session.query(User).get(data["user_id"])  # DB access
    if not user:                                 # Business logic
        return jsonify({"error": "User not found"}), 404
    order = Order(user_id=user.id, items=data["items"])  # Business logic
    order.calculate_total()                      # Business logic
    db.session.add(order)                        # DB access
    db.session.commit()                          # DB access
    send_confirmation_email(user.email, order)   # Side effect
    return jsonify(order.to_dict()), 201         # HTTP formatting

AFTER:
# application/use_cases/place_order.py
class PlaceOrderUseCase:
    def __init__(self, user_repo, order_repo, email_service):
        self._user_repo = user_repo
        self._order_repo = order_repo
        self._email = email_service

    def execute(self, request: PlaceOrderRequest) -> PlaceOrderResponse:
        user = self._user_repo.find_by_id(request.user_id)
        if not user:
            raise UserNotFoundError(request.user_id)
        order = Order.create(user.id, request.items)
        saved = self._order_repo.save(order)
        self._email.send_confirmation(user.email, saved)
        return PlaceOrderResponse(order_id=str(saved.id), total=saved.total())

# presentation/api/routes.py
@app.route("/orders", methods=["POST"])
def create_order():
    data = request.json
    use_case = container.place_order_use_case()  # DI
    result = use_case.execute(PlaceOrderRequest(
        user_id=data["user_id"],
        items=data["items"],
    ))
    return jsonify(asdict(result)), 201
```

## Phase 4: Extract External Service Gateways

**Goal:** Every external dependency (email, payment, cloud APIs) behind an interface.

### Steps

1. Identify all external service calls
2. Create gateway interfaces in the application layer
3. Implement gateways in infrastructure
4. Inject gateways into use cases

## Phase 5: Wire Dependency Injection

**Goal:** A composition root that wires everything together.

### Steps

1. Create `container.py` / `container.ts` / `main.go` as the composition root
2. Wire all concrete implementations to their interfaces
3. Remove any framework-level DI that violates the dependency rule
4. Ensure the composition root is the ONLY place that knows all concrete types

## Phase 6: Enforce and Prevent Regression

### Add architectural tests/linting

| Language | Tool | Action |
|----------|------|--------|
| Python | `import-linter` | Add layer contract to `pyproject.toml` |
| TypeScript | `dependency-cruiser` | Add forbidden dependency rules |
| Go | `go-cleanarch` | Add to CI pipeline |
| Java | ArchUnit | Add architectural unit tests |
| .NET | NetArchTest | Add architectural unit tests |

### Add CI checks

```yaml
# Example CI step
- name: Check architecture
  run: |
    pip install import-linter
    lint-imports
```

## Migration Priority Matrix

When deciding what to migrate first:

| Factor | Migrate First | Migrate Later |
|--------|--------------|---------------|
| Change frequency | Changes often | Rarely changes |
| Business criticality | Core domain | Supporting features |
| Test coverage need | Hard to test now | Already well-tested |
| Coupling pain | Causes cascading changes | Self-contained |
| Team familiarity | Team works here daily | Rarely touched |

## Common Migration Pitfalls

1. **Big Bang rewrite** — Resist the urge. Migrate incrementally.
2. **Migrating everything equally** — Not all code deserves full Clean Architecture. Prioritize.
3. **Forgetting tests** — Write domain tests BEFORE extracting entities. They're your safety net.
4. **Breaking the build** — Each commit should pass all existing tests.
5. **Over-abstracting early** — Add interfaces where you need testability or flexibility, not everywhere.
6. **Ignoring the team** — Migration without buy-in creates two architectural styles fighting each other.

## Timeline Expectations

| Codebase Size | Entities Phase | Full Migration |
|--------------|---------------|----------------|
| Small (< 10K LOC) | 1-2 days | 1-2 weeks |
| Medium (10K-100K LOC) | 1-2 weeks | 1-3 months |
| Large (100K+ LOC) | 2-4 weeks | 3-12 months |

These assume the team is already familiar with Clean Architecture concepts.
The first migration takes longest — subsequent ones go faster as patterns are established.

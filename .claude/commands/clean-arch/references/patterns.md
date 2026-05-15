# Clean Architecture — Implementation Patterns

## Repository Pattern

Abstracts data access behind an interface defined in the inner layer. The repository
provides only the operations the application needs, at a higher abstraction level than
raw queries or ORM calls.

### Interface (Domain/Application layer)

```python
class OrderRepository(ABC):
    @abstractmethod
    def save(self, order: Order) -> Order: ...

    @abstractmethod
    def find_by_id(self, order_id: UUID) -> Optional[Order]: ...

    @abstractmethod
    def find_by_customer(self, customer_id: UUID) -> list[Order]: ...

    @abstractmethod
    def find_pending(self) -> list[Order]: ...
```

### Implementation (Infrastructure layer)

```python
class SqlAlchemyOrderRepository(OrderRepository):
    def __init__(self, session: Session):
        self._session = session

    def save(self, order: Order) -> Order:
        model = OrderModel.from_entity(order)
        self._session.add(model)
        self._session.flush()
        return model.to_entity()

    def find_by_id(self, order_id: UUID) -> Optional[Order]:
        model = self._session.query(OrderModel).filter_by(id=order_id).first()
        return model.to_entity() if model else None
```

### Mapper between Entity and Persistence Model

```python
class OrderModel(Base):
    __tablename__ = "orders"
    id = Column(UUID, primary_key=True)
    customer_id = Column(UUID, nullable=False)
    status = Column(String, nullable=False)
    total_amount = Column(Float, nullable=False)
    total_currency = Column(String(3), nullable=False)

    @classmethod
    def from_entity(cls, order: Order) -> "OrderModel":
        return cls(
            id=order.id,
            customer_id=order.customer_id,
            status=order.status,
            total_amount=order.total().amount,
            total_currency=order.total().currency,
        )

    def to_entity(self) -> Order:
        return Order(
            id=self.id,
            customer_id=self.customer_id,
            status=self.status,
            _total=Money(self.total_amount, self.total_currency),
        )
```

### When Mapping Adds Value vs Overhead

**Mapping is valuable when:**
- Domain entity has behavior/invariants that DB model doesn't
- DB schema differs from domain model (denormalization, different field names)
- You need to support multiple persistence backends
- Domain model evolves independently from DB schema

**Mapping is overhead when:**
- Fields are 1:1 identical with no transformation
- Single persistence backend, tightly coupled by design choice
- Prototype/MVP where speed matters more than decoupling

---

## Unit of Work Pattern

Groups multiple repository operations into a single transaction boundary.

```python
class UnitOfWork(ABC):
    users: UserRepository
    orders: OrderRepository

    @abstractmethod
    def __enter__(self) -> "UnitOfWork": ...

    @abstractmethod
    def __exit__(self, exc_type, exc_val, exc_tb) -> None: ...

    @abstractmethod
    def commit(self) -> None: ...

    @abstractmethod
    def rollback(self) -> None: ...


class SqlAlchemyUnitOfWork(UnitOfWork):
    def __init__(self, session_factory):
        self._session_factory = session_factory

    def __enter__(self):
        self._session = self._session_factory()
        self.users = SqlAlchemyUserRepository(self._session)
        self.orders = SqlAlchemyOrderRepository(self._session)
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        if exc_type:
            self.rollback()
        self._session.close()

    def commit(self):
        self._session.commit()

    def rollback(self):
        self._session.rollback()
```

**Usage in a use case:**

```python
class PlaceOrderUseCase:
    def __init__(self, uow_factory):
        self._uow_factory = uow_factory

    def execute(self, request: PlaceOrderRequest) -> PlaceOrderResponse:
        with self._uow_factory() as uow:
            customer = uow.users.find_by_id(request.customer_id)
            if not customer:
                raise CustomerNotFoundError(request.customer_id)

            order = Order.create(customer, request.items)
            uow.orders.save(order)
            uow.commit()

            return PlaceOrderResponse(order_id=str(order.id))
```

---

## Mediator Pattern (CQRS Pipeline)

Routes commands/queries to handlers through a central dispatcher. Supports cross-cutting
concerns (validation, logging, caching) as pipeline behaviors.

### Command/Query structure

```python
@dataclass(frozen=True)
class RegisterUserCommand:
    email: str
    name: str

@dataclass(frozen=True)
class GetUserQuery:
    user_id: str

class RegisterUserHandler:
    def __init__(self, user_repo: UserRepository):
        self._user_repo = user_repo

    def handle(self, command: RegisterUserCommand) -> str:
        user = User.create(Email(command.email), command.name)
        self._user_repo.save(user)
        return str(user.id)

class GetUserHandler:
    def __init__(self, user_repo: UserRepository):
        self._user_repo = user_repo

    def handle(self, query: GetUserQuery) -> Optional[UserDTO]:
        user = self._user_repo.find_by_id(UUID(query.user_id))
        return UserDTO.from_entity(user) if user else None
```

### Pipeline behaviors

```python
class LoggingBehavior:
    def __init__(self, logger):
        self._logger = logger

    def handle(self, request, next_handler):
        self._logger.info(f"Handling {type(request).__name__}")
        result = next_handler(request)
        self._logger.info(f"Handled {type(request).__name__}")
        return result

class ValidationBehavior:
    def __init__(self, validators):
        self._validators = validators

    def handle(self, request, next_handler):
        for validator in self._validators:
            validator.validate(request)
        return next_handler(request)
```

---

## Event-Driven Patterns

### Domain Events

```python
@dataclass(frozen=True)
class OrderConfirmed:
    order_id: UUID
    customer_id: UUID
    total: Money
    occurred_at: datetime

class Order:
    def __init__(self, ...):
        self._events: list = []

    def confirm(self):
        if not self.items:
            raise ValueError("Cannot confirm empty order")
        self.status = "confirmed"
        self._events.append(OrderConfirmed(
            order_id=self.id,
            customer_id=self.customer_id,
            total=self.total(),
            occurred_at=datetime.utcnow(),
        ))

    def collect_events(self) -> list:
        events = self._events.copy()
        self._events.clear()
        return events
```

### Event Dispatcher

```python
class EventDispatcher(ABC):
    @abstractmethod
    def dispatch(self, event) -> None: ...

class InMemoryEventDispatcher(EventDispatcher):
    def __init__(self):
        self._handlers: dict[type, list] = {}

    def register(self, event_type: type, handler) -> None:
        self._handlers.setdefault(event_type, []).append(handler)

    def dispatch(self, event) -> None:
        for handler in self._handlers.get(type(event), []):
            handler(event)
```

### Outbox Pattern (for reliable integration events)

```python
class OutboxEntry:
    id: UUID
    event_type: str
    payload: dict
    created_at: datetime
    published_at: Optional[datetime] = None

class ConfirmOrderUseCase:
    def __init__(self, uow: UnitOfWork, outbox: OutboxRepository):
        self._uow = uow
        self._outbox = outbox

    def execute(self, order_id: UUID):
        with self._uow as uow:
            order = uow.orders.find_by_id(order_id)
            order.confirm()
            uow.orders.save(order)

            # Store integration event in same transaction
            for event in order.collect_events():
                self._outbox.save(OutboxEntry(
                    event_type=type(event).__name__,
                    payload=asdict(event),
                ))

            uow.commit()
        # Background worker picks up outbox entries and publishes
```

---

## Gateway Pattern

Wraps external service communication behind an interface:

```python
class PaymentGateway(ABC):
    @abstractmethod
    def charge(self, amount: Money, token: str) -> PaymentResult: ...

    @abstractmethod
    def refund(self, payment_id: str) -> RefundResult: ...


class StripePaymentGateway(PaymentGateway):
    def __init__(self, api_key: str):
        self._client = stripe.Client(api_key)

    def charge(self, amount: Money, token: str) -> PaymentResult:
        result = self._client.charges.create(
            amount=int(amount.amount * 100),
            currency=amount.currency,
            source=token,
        )
        return PaymentResult(
            payment_id=result.id,
            status="success" if result.paid else "failed",
        )
```

---

## Specification Pattern

Encapsulates query criteria as domain objects:

```python
class Specification(ABC):
    @abstractmethod
    def is_satisfied_by(self, entity) -> bool: ...

    def __and__(self, other: "Specification") -> "Specification":
        return AndSpecification(self, other)

    def __or__(self, other: "Specification") -> "Specification":
        return OrSpecification(self, other)

class HighValueOrder(Specification):
    def __init__(self, threshold: Money):
        self._threshold = threshold

    def is_satisfied_by(self, order: Order) -> bool:
        return order.total().amount >= self._threshold.amount

class PendingOrder(Specification):
    def is_satisfied_by(self, order: Order) -> bool:
        return order.status == "pending"

# Usage
high_value_pending = HighValueOrder(Money(1000, "USD")) & PendingOrder()
orders = [o for o in all_orders if high_value_pending.is_satisfied_by(o)]
```

---

## Factory Pattern for Complex Entity Creation

When entity creation involves multiple steps, validation, or external lookups:

```python
class OrderFactory:
    def __init__(self, pricing_service: PricingService):
        self._pricing = pricing_service

    def create_from_cart(self, customer: Customer, cart: Cart) -> Order:
        items = []
        for cart_item in cart.items:
            price = self._pricing.get_price(cart_item.product_id)
            items.append(OrderItem(
                product_id=cart_item.product_id,
                quantity=cart_item.quantity,
                price=price,
            ))
        return Order.create(customer.id, items)
```

---

## Naming Conventions Quick Reference

| Component | Convention | Examples |
|-----------|-----------|----------|
| Entities | Noun (domain language) | `Order`, `User`, `Payment` |
| Value Objects | Descriptive noun | `Money`, `Email`, `Address`, `DateRange` |
| Use Cases | Verb + Noun | `RegisterUser`, `RejectPayment`, `CancelOrder` |
| Commands | Verb + Noun + Command | `RegisterEmployeeCommand` |
| Queries | Get/Find/List + Noun + Query | `GetEmployeeListQuery` |
| Repositories | Entity + Repository | `UserRepository`, `OrderRepository` |
| Gateways | Service + Gateway | `PaymentGateway`, `NotificationGateway` |
| Controllers | Entity/Feature + Controller | `UserController`, `OrderController` |
| Presenters | Entity/Feature + Presenter | `UserPresenter` |
| DTOs | Purpose + Request/Response | `CreateUserRequest`, `UserResponse` |
| Events | Past tense verb phrase | `OrderConfirmed`, `UserRegistered` |
| Specifications | Adjective + Entity | `HighValueOrder`, `ExpiredSubscription` |
| Factories | Entity + Factory | `OrderFactory`, `UserFactory` |
